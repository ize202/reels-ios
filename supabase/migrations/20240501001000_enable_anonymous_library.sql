-- Migration: Enable library for anonymous users
-- Description: Allows anonymous users to have a library and updates handle_new_user function
-- Author: Claude
-- Date: 2024-05-01

-- Update user_library policies to allow anonymous users
drop policy if exists "Users can view their own library" on public.user_library;
drop policy if exists "Users can insert into their own library" on public.user_library;
drop policy if exists "Users can update their own library" on public.user_library;
drop policy if exists "Users can delete from their own library" on public.user_library;

-- New policies that work for both anonymous and regular users
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

-- Update handle_new_user trigger to create both wallet and library entries for ALL users
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