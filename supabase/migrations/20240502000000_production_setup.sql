-- Migration: Production Database Setup
-- Description: Combined migration for production schema setup (excludes mock data)
-- Author: Claude
-- Date: 2024-05-02

-- Enable required extensions
create extension if not exists "uuid-ossp";

-----------------------------------------------
-- SECTION 1: Initial Schema Setup
-----------------------------------------------

-- 1. Series table for managing drama series
create table public.series (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  genre text,
  cover_url text,
  is_published boolean default false,
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.series enable row level security;

-- 2. Episodes table for individual episodes within series
create table public.episodes (
  id uuid primary key default uuid_generate_v4(),
  series_id uuid references public.series(id) on delete cascade,
  mux_asset_id text not null,
  playback_url text not null,
  episode_number int not null,
  unlock_type text check (unlock_type in ('free', 'coin', 'ad', 'vip')) not null,
  coin_cost int,
  created_at timestamp with time zone default now(),
  -- Add unique constraint to prevent duplicate episode numbers within a series
  unique(series_id, episode_number)
);

-- Enable RLS
alter table public.episodes enable row level security;

-- 3. User library table for tracking saved shows and progress
create table public.user_library (
  user_id uuid references auth.users(id) on delete cascade,
  series_id uuid references public.series(id) on delete cascade,
  last_episode_id uuid references public.episodes(id),
  is_saved boolean default false,
  primary key (user_id, series_id)
);

-- Enable RLS
alter table public.user_library enable row level security;

-- 4. User wallet table for managing coins and VIP status
create table public.user_wallet (
  user_id uuid primary key references auth.users(id) on delete cascade,
  coin_balance int default 0,
  is_vip boolean default false,
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.user_wallet enable row level security;

-- 5. Coin transactions table for tracking coin history
create table public.coin_transactions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  amount int not null,
  source text not null, -- e.g., 'ad', 'iap', 'unlock'
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.coin_transactions enable row level security;

-- 6. Episode likes table for tracking user likes
create table public.episode_likes (
  user_id uuid references auth.users(id) on delete cascade,
  episode_id uuid references public.episodes(id) on delete cascade,
  liked_at timestamp with time zone default now(),
  primary key (user_id, episode_id)
);

-- Enable RLS
alter table public.episode_likes enable row level security;

-- Create indexes for performance
create index idx_series_genre on public.series(genre);
create index idx_episodes_series_id on public.episodes(series_id);
create index idx_coin_transactions_user_id on public.coin_transactions(user_id);

-----------------------------------------------
-- SECTION 2: RLS Policies
-----------------------------------------------

-- RLS Policies for series (all users)
create policy "All users can view published series"
on public.series for select
to authenticated
using (is_published = true);

-- RLS Policies for episodes (all users)
create policy "All users can view episodes of published series"
on public.episodes for select
to authenticated
using (
  exists (
    select 1 from public.series s
    where s.id = episodes.series_id
    and s.is_published = true
  )
);

-- RLS Policies for user_library
create policy "Users can view their own library"
on public.user_library for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert into their own library"
on public.user_library for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own library"
on public.user_library for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete from their own library"
on public.user_library for delete
to authenticated
using (auth.uid() = user_id);

-- RLS Policies for user_wallet
create policy "Users can view their own wallet"
on public.user_wallet for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own wallet"
on public.user_wallet for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own wallet"
on public.user_wallet for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- RLS Policies for coin_transactions
create policy "Users can view their own transactions"
on public.coin_transactions for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own transactions"
on public.coin_transactions for insert
to authenticated
with check (auth.uid() = user_id);

-- RLS Policies for episode_likes
create policy "Users can view their own likes"
on public.episode_likes for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own likes"
on public.episode_likes for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can delete their own likes"
on public.episode_likes for delete
to authenticated
using (auth.uid() = user_id);

-----------------------------------------------
-- SECTION 3: User Wallet Management
-----------------------------------------------

-- Create function to automatically create wallet and initialize library for new users
create or replace function public.handle_new_user()
returns trigger as $$
begin
  -- Create wallet for all users (both anonymous and regular)
  insert into public.user_wallet (user_id)
  values (new.id);
  
  -- Create initial library entry for all users
  -- We don't need to insert any series initially, as users will add them later
  -- This ensures the user exists in the library table for future operations
  insert into public.user_library (user_id, series_id, is_saved)
  select new.id, s.id, false
  from public.series s
  where s.is_published = true
  limit 1;
  
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger to create wallet for new users
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created') THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
  END IF;
END$$;

-----------------------------------------------
-- SECTION 4: Watch History Functions
-----------------------------------------------

-- Function to upsert watch history
create or replace function public.upsert_watch_history(usr_id uuid, ser_id uuid, ep_id uuid)
returns void as $$
BEGIN
    INSERT INTO public.user_library (user_id, series_id, last_episode_id, is_saved)
    VALUES (usr_id, ser_id, ep_id, false)
    ON CONFLICT (user_id, series_id)
    DO UPDATE SET last_episode_id = EXCLUDED.last_episode_id;
END;
$$ language plpgsql security definer;

-- Function to get user library details
create or replace function public.get_user_library_details(p_user_id uuid, p_series_id uuid default null)
returns table (
    user_id uuid,
    series_id uuid,
    last_episode_id uuid,
    is_saved boolean,
    title text,
    cover_url text,
    last_watched_episode_number int,
    total_episodes bigint
) as $$
BEGIN
    RETURN QUERY
    SELECT
        ul.user_id,
        ul.series_id,
        ul.last_episode_id,
        ul.is_saved,
        s.title,
        s.cover_url,
        (SELECT e.episode_number FROM public.episodes e WHERE e.id = ul.last_episode_id) as last_watched_episode_number,
        (SELECT COUNT(*) FROM public.episodes e_count WHERE e_count.series_id = ul.series_id) as total_episodes
    FROM
        public.user_library ul
    JOIN
        public.series s ON ul.series_id = s.id
    WHERE
        ul.user_id = p_user_id
        -- Add this condition to filter by series_id if provided
        AND (p_series_id IS NULL OR ul.series_id = p_series_id);
END;
$$ language plpgsql security definer; 