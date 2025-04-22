-- Migration: Initial schema setup for Reels app
-- Description: Creates core tables for series, episodes, user library, wallet, and transactions
-- Author: Claude
-- Date: 2024-04-18

-- Enable required extensions
create extension if not exists "uuid-ossp";

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

-- RLS Policies for series
-- Anonymous users can view published series
create policy "Anonymous users can view published series"
on public.series for select
to anon
using (is_published = true);

-- Authenticated users can view published series
create policy "Authenticated users can view published series"
on public.series for select
to authenticated
using (is_published = true);

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

-- RLS Policies for episodes
-- Anonymous users can view episodes of published series
create policy "Anonymous users can view episodes of published series"
on public.episodes for select
to anon
using (
  exists (
    select 1 from public.series s
    where s.id = episodes.series_id
    and s.is_published = true
  )
);

-- Authenticated users can view episodes of published series
create policy "Authenticated users can view episodes of published series"
on public.episodes for select
to authenticated
using (
  exists (
    select 1 from public.series s
    where s.id = episodes.series_id
    and s.is_published = true
  )
);

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

-- RLS Policies for user_library
-- Authenticated users can view their own library entries
create policy "Users can view their own library"
on public.user_library for select
to authenticated
using (auth.uid() = user_id);

-- Authenticated users can insert their own library entries
create policy "Users can insert into their own library"
on public.user_library for insert
to authenticated
with check (auth.uid() = user_id);

-- Authenticated users can update their own library entries
create policy "Users can update their own library"
on public.user_library for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Authenticated users can delete their own library entries
create policy "Users can delete from their own library"
on public.user_library for delete
to authenticated
using (auth.uid() = user_id);

-- 4. User wallet table for managing coins and VIP status
create table public.user_wallet (
  user_id uuid primary key references auth.users(id) on delete cascade,
  coin_balance int default 0,
  is_vip boolean default false,
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.user_wallet enable row level security;

-- RLS Policies for user_wallet
-- Authenticated users can view their own wallet
create policy "Users can view their own wallet"
on public.user_wallet for select
to authenticated
using (auth.uid() = user_id);

-- Authenticated users can insert their own wallet (should happen automatically)
create policy "Users can insert their own wallet"
on public.user_wallet for insert
to authenticated
with check (auth.uid() = user_id);

-- Authenticated users can update their own wallet
create policy "Users can update their own wallet"
on public.user_wallet for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

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

-- RLS Policies for coin_transactions
-- Authenticated users can view their own transactions
create policy "Users can view their own transactions"
on public.coin_transactions for select
to authenticated
using (auth.uid() = user_id);

-- Authenticated users can insert their own transactions
create policy "Users can insert their own transactions"
on public.coin_transactions for insert
to authenticated
with check (auth.uid() = user_id);

-- 6. Episode likes table for tracking user likes
create table public.episode_likes (
  user_id uuid references auth.users(id) on delete cascade,
  episode_id uuid references public.episodes(id) on delete cascade,
  liked_at timestamp with time zone default now(),
  primary key (user_id, episode_id)
);

-- Enable RLS
alter table public.episode_likes enable row level security;

-- RLS Policies for episode_likes
-- Authenticated users can view their own likes
create policy "Users can view their own likes"
on public.episode_likes for select
to authenticated
using (auth.uid() = user_id);

-- Authenticated users can insert their own likes
create policy "Users can insert their own likes"
on public.episode_likes for insert
to authenticated
with check (auth.uid() = user_id);

-- Authenticated users can delete their own likes
create policy "Users can delete their own likes"
on public.episode_likes for delete
to authenticated
using (auth.uid() = user_id);

-- Create indexes for performance
create index idx_series_genre on public.series(genre);
create index idx_episodes_series_id on public.episodes(series_id);
create index idx_coin_transactions_user_id on public.coin_transactions(user_id);

-- Create function to automatically create wallet for new users
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.user_wallet (user_id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger to create wallet for new users
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user(); 