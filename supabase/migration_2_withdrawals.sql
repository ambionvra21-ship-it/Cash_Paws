-- CashPaws update 2: fixed withdrawal tiers, USD/PHP payouts, 10% user share.
-- Paste into SQL Editor and Run (safe to run more than once).

create table if not exists public.settings (
  id int primary key default 1 check (id = 1),
  coins_per_usd int not null default 1000,      -- strict coin value: 1,000 coins = $1.00 face value
  payout_share_pct int not null default 10,     -- users receive 10% of the face value
  usd_php numeric not null default 56,          -- update this exchange rate yourself when it changes
  min_account_days int not null default 7       -- set to 0 while testing
);
insert into public.settings (id) values (1) on conflict do nothing;
alter table public.settings enable row level security;
drop policy if exists "read settings" on public.settings;
create policy "read settings" on public.settings for select to authenticated using (true);

alter table public.withdrawals
  add column if not exists tier_usd int,
  add column if not exists currency text,
  add column if not exists share_pct int,
  add column if not exists rate numeric,
  add column if not exists payout numeric,
  add column if not exists needs_id boolean not null default false;

create or replace function public.request_withdrawal(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  u public.profiles; s public.settings;
  v_method text := p->>'method'; v_acct text := trim(coalesce(p->>'account',''));
  v_cur text := upper(coalesce(p->>'currency','')); v_tier int; v_coins int; v_rate numeric; v_payout numeric;
begin
  u := public.lock_me();
  select * into s from public.settings where id = 1;
  if v_method is null or v_method not in ('GCash','Maya','One') then raise exception 'Choose a payment method'; end if;
  if v_cur not in ('USD','PHP') then raise exception 'Choose USD or PHP'; end if;
  if v_method in ('GCash','Maya') and v_cur <> 'PHP' then raise exception '% pays out in PHP only', v_method; end if;
  if length(v_acct) < 5 or length(v_acct) > 80 then raise exception 'Enter a valid account'; end if;
  begin v_tier := (p->>'tier')::int; exception when others then v_tier := null; end;
  if v_tier is null or v_tier not in (10,20,50,100,500,1000) then raise exception 'Choose a withdrawal amount'; end if;
  if u.joined > public.utc_today() - s.min_account_days then
    raise exception 'New accounts can withdraw after % days', s.min_account_days;
  end if;
  if exists (select 1 from public.withdrawals where user_id = u.id and status = 'pending') then
    raise exception 'You already have a pending withdrawal';
  end if;
  v_coins := v_tier * s.coins_per_usd;
  if u.coins < v_coins then raise exception 'Not enough coins'; end if;
  v_rate := case when v_cur = 'PHP' then s.usd_php else 1 end;
  v_payout := round(v_tier * s.payout_share_pct / 100.0 * v_rate, 2);
  update public.profiles set coins = coins - v_coins where id = u.id;
  insert into public.withdrawals (user_id, method, account, amount, tier_usd, currency, share_pct, rate, payout, needs_id)
  values (u.id, v_method, v_acct, v_coins, v_tier, v_cur, s.payout_share_pct, v_rate, v_payout, v_tier >= 100);
  return jsonb_build_object('ok', true, 'payout', v_payout, 'currency', v_cur);
end $$;
