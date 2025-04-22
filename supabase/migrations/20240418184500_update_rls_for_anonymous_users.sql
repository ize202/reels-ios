-- Migration: Update RLS policies to handle anonymous users
-- Description: Modifies RLS policies to properly handle Supabase anonymous authentication
-- Author: Claude
-- Date: 2024-04-18

-- Drop existing policies that don't handle anonymous users correctly
drop policy if exists "Anonymous users can view published series" on public.series;
drop policy if exists "Anonymous users can view episodes of published series" on public.episodes;

-- Update series policies to handle both anonymous and regular authenticated users
create policy "All users can view published series"
on public.series for select
to authenticated
using (is_published = true);

-- Update episodes policies to handle both anonymous and regular authenticated users
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

-- Update user_library policies to restrict anonymous users
drop policy if exists "Users can view their own library" on public.user_library;
drop policy if exists "Users can insert into their own library" on public.user_library;
drop policy if exists "Users can update their own library" on public.user_library;
drop policy if exists "Users can delete from their own library" on public.user_library;

create policy "Non-anonymous users can view their own library"
on public.user_library for select
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can insert into their own library"
on public.user_library for insert
to authenticated
with check (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can update their own library"
on public.user_library for update
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
)
with check (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can delete from their own library"
on public.user_library for delete
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

-- Update user_wallet policies to restrict anonymous users
drop policy if exists "Users can view their own wallet" on public.user_wallet;
drop policy if exists "Users can insert their own wallet" on public.user_wallet;
drop policy if exists "Users can update their own wallet" on public.user_wallet;

create policy "Non-anonymous users can view their own wallet"
on public.user_wallet for select
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can insert their own wallet"
on public.user_wallet for insert
to authenticated
with check (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can update their own wallet"
on public.user_wallet for update
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
)
with check (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

-- Update coin_transactions policies to restrict anonymous users
drop policy if exists "Users can view their own transactions" on public.coin_transactions;
drop policy if exists "Users can insert their own transactions" on public.coin_transactions;

create policy "Non-anonymous users can view their own transactions"
on public.coin_transactions for select
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can insert their own transactions"
on public.coin_transactions for insert
to authenticated
with check (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

-- Update episode_likes policies to restrict anonymous users
drop policy if exists "Users can view their own likes" on public.episode_likes;
drop policy if exists "Users can insert their own likes" on public.episode_likes;
drop policy if exists "Users can delete their own likes" on public.episode_likes;

create policy "Non-anonymous users can view their own likes"
on public.episode_likes for select
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can insert their own likes"
on public.episode_likes for insert
to authenticated
with check (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

create policy "Non-anonymous users can delete their own likes"
on public.episode_likes for delete
to authenticated
using (
  auth.uid() = user_id 
  and (auth.jwt() ->> 'is_anonymous')::boolean = false
);

-- Update the handle_new_user trigger to only create wallets for non-anonymous users
create or replace function public.handle_new_user()
returns trigger as $$
begin
  -- Only create wallet for non-anonymous users
  if (new.raw_app_meta_data->>'is_anonymous')::boolean = false then
    insert into public.user_wallet (user_id)
    values (new.id);
  end if;
  return new;
end;
$$ language plpgsql security definer; 