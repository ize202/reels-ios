-- Migration: Enable wallets for anonymous users
-- Description: Allows anonymous users to have wallets and participate in the coin economy
-- Author: Claude
-- Date: 2024-04-18

-- Update user_wallet policies to allow anonymous users
drop policy if exists "Non-anonymous users can view their own wallet" on public.user_wallet;
drop policy if exists "Non-anonymous users can insert their own wallet" on public.user_wallet;
drop policy if exists "Non-anonymous users can update their own wallet" on public.user_wallet;

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

-- Update coin_transactions policies to allow anonymous users
drop policy if exists "Non-anonymous users can view their own transactions" on public.coin_transactions;
drop policy if exists "Non-anonymous users can insert their own transactions" on public.coin_transactions;

create policy "Users can view their own transactions"
on public.coin_transactions for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own transactions"
on public.coin_transactions for insert
to authenticated
with check (auth.uid() = user_id);

-- Update handle_new_user trigger to create wallets for ALL users (including anonymous)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  -- Create wallet for all users (both anonymous and regular)
  insert into public.user_wallet (user_id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer; 