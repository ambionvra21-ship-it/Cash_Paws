-- CashPaws backend for Supabase. Paste this whole file into SQL Editor and click Run once.
-- All coin changes happen inside these functions. The app cannot edit balances directly.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  coins int not null default 0,
  total int not null default 0,
  streak int not null default 0,
  last_claim date,
  streak_freeze int not null default 1,
  name text not null default 'Paw Friend',
  av text not null default '🐱',
  joined date not null default current_date,
  code text unique,
  refs int not null default 0,
  ref_earned int not null default 0,
  referred_by uuid,
  ads int not null default 0,
  ads_day date,
  spin_day date,
  steps int not null default 0,
  steps_day date,
  steps_paid int not null default 0,
  steps_at timestamptz,
  missions text[] not null default '{}',
  missions_day date,
  week_key date,
  week_coins int not null default 0
);
create index if not exists profiles_week_idx on public.profiles (week_key, week_coins desc);

create table if not exists public.withdrawals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  method text not null,
  account text not null,
  amount int not null,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

-- Security: players can only READ their own rows. No insert/update/delete from the app.
alter table public.profiles enable row level security;
alter table public.withdrawals enable row level security;
drop policy if exists "read own profile" on public.profiles;
create policy "read own profile" on public.profiles for select to authenticated using (id = auth.uid());
drop policy if exists "read own withdrawals" on public.withdrawals;
create policy "read own withdrawals" on public.withdrawals for select to authenticated using (user_id = auth.uid());
do $$ begin
  begin alter publication supabase_realtime add table public.profiles; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.withdrawals; exception when duplicate_object then null; end;
end $$;

-- Create a profile row for every new account (Google or guest).
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- helpers (not callable from the app) ----------
create or replace function public.utc_today() returns date language sql stable as
$$ select (now() at time zone 'utc')::date $$;

-- Monday of the current week (UTC). The weekly leaderboard resets then.
create or replace function public.week_start() returns date language sql stable as
$$ select public.utc_today() - (extract(isodow from public.utc_today())::int - 1) $$;

create or replace function public.lock_me() returns public.profiles
language plpgsql security definer set search_path = public as $$
declare u public.profiles;
begin
  if auth.uid() is null then raise exception 'Sign in first'; end if;
  select * into u from public.profiles where id = auth.uid() for update;
  if not found then raise exception 'Profile not found'; end if;
  return u;
end $$;

-- Every coin earned through activity goes through earn() so the weekly board stays in sync.
create or replace function public.earn(p_uid uuid, p_n int) returns void
language plpgsql security definer set search_path = public as $$
declare wk date := public.week_start();
begin
  update public.profiles set
    coins = coins + p_n,
    total = total + p_n,
    week_coins = case when week_key = wk then week_coins + p_n else p_n end,
    week_key = wk
  where id = p_uid;
end $$;

revoke execute on function public.lock_me() from public, anon, authenticated;
revoke execute on function public.earn(uuid, int) from public, anon, authenticated;

-- ---------- daily login + streak (with streak freeze) ----------
create or replace function public.claim_daily(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; t date := public.utc_today(); new_streak int := 1; fz int; reward int;
begin
  u := public.lock_me();
  if u.last_claim = t then raise exception 'Already claimed today'; end if;
  fz := u.streak_freeze;
  if u.last_claim = t - 1 then new_streak := u.streak + 1;
  elsif u.last_claim = t - 2 and fz > 0 then new_streak := u.streak + 1; fz := fz - 1;
  end if;
  reward := ((new_streak - 1) % 7 + 1) * 2 + case when new_streak % 7 = 0 then 10 else 0 end;
  perform public.earn(u.id, reward);
  update public.profiles set streak = new_streak, last_claim = t, streak_freeze = fz where id = u.id;
  return jsonb_build_object('reward', reward, 'streak', new_streak);
end $$;

create or replace function public.buy_freeze(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles;
begin
  u := public.lock_me();
  if u.streak_freeze >= 2 then raise exception 'You can hold 2 freezes'; end if;
  if u.coins < 300 then raise exception 'Not enough coins'; end if;
  update public.profiles set coins = coins - 300, streak_freeze = streak_freeze + 1 where id = u.id;
  return jsonb_build_object('freeze', u.streak_freeze + 1);
end $$;

-- ---------- rewarded ads (max 10 a day) ----------
create or replace function public.reward_ad(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; t date := public.utc_today(); n int;
begin
  u := public.lock_me();
  n := case when u.ads_day = t then u.ads else 0 end;
  if n >= 10 then raise exception 'Daily ad limit reached'; end if;
  perform public.earn(u.id, 5);
  update public.profiles set ads = n + 1, ads_day = t where id = u.id;
  return jsonb_build_object('reward', 5);
end $$;

-- ---------- daily spin (the server picks the prize) ----------
create or replace function public.spin_wheel(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  u public.profiles; t date := public.utc_today();
  prizes int[] := array[1,5,2,10,3,25,2,50];
  weights float[] := array[22,14,22,8,16,4,12,2]::float[];
  r float := random() * 100; i int := 1;
begin
  u := public.lock_me();
  if u.spin_day = t then raise exception 'Already spun today'; end if;
  while i < 8 and r >= weights[i] loop r := r - weights[i]; i := i + 1; end loop;
  perform public.earn(u.id, prizes[i]);
  update public.profiles set spin_day = t where id = u.id;
  return jsonb_build_object('index', i - 1, 'prize', prizes[i]);
end $$;

-- ---------- steps: 1 coin per 100 steps, max 10,000 a day, impossible jumps rejected ----------
create or replace function public.sync_steps(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; t date := public.utc_today(); rep int; prev int; paid int; cap int; v_steps int; due int;
begin
  u := public.lock_me();
  begin rep := (p->>'steps')::int; exception when others then rep := null; end;
  if rep is null or rep < 0 then raise exception 'Invalid steps'; end if;
  prev := case when u.steps_day = t then u.steps else 0 end;
  paid := case when u.steps_day = t then u.steps_paid else 0 end;
  cap := case when u.steps_day = t
    then prev + ceil(extract(epoch from (now() - coalesce(u.steps_at, now()))) / 60)::int * 200 + 100
    else 3000 end;
  v_steps := least(greatest(rep, prev), cap, 10000);
  due := greatest(v_steps / 100 - paid, 0);
  if due > 0 then perform public.earn(u.id, due); end if;
  update public.profiles set steps = v_steps, steps_day = t, steps_at = now(), steps_paid = paid + due where id = u.id;
  return jsonb_build_object('steps', v_steps, 'coins', due);
end $$;

-- ---------- missions ----------
create or replace function public.claim_mission(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; t date := public.utc_today(); v_id text := p->>'id'; v_done text[]; ok boolean; v_reward int;
begin
  u := public.lock_me();
  if v_id is null or v_id not in ('login','steps','ads','spin','bonus') then raise exception 'Unknown mission'; end if;
  v_done := case when u.missions_day = t then u.missions else '{}'::text[] end;
  if v_id = any(v_done) then raise exception 'Already claimed'; end if;
  if v_id = 'bonus' then
    if not (v_done @> array['login','steps','ads','spin']) then raise exception 'Finish all missions first'; end if;
  else
    ok := case v_id
      when 'login' then u.last_claim = t
      when 'steps' then u.steps_day = t and u.steps >= 2000
      when 'ads' then u.ads_day = t and u.ads >= 3
      else u.spin_day = t end;
    if not coalesce(ok, false) then raise exception 'Mission not finished yet'; end if;
  end if;
  v_reward := case v_id when 'login' then 5 when 'steps' then 10 when 'ads' then 10 when 'spin' then 5 else 20 end;
  perform public.earn(u.id, v_reward);
  update public.profiles set missions = array_append(v_done, v_id), missions_day = t where id = u.id;
  return jsonb_build_object('reward', v_reward);
end $$;

-- ---------- withdrawals (coins are taken now; you pay by hand, then set status to 'paid') ----------
create or replace function public.request_withdrawal(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; v_method text := p->>'method'; v_acct text := trim(coalesce(p->>'account','')); v_amt int;
begin
  u := public.lock_me();
  if v_method is null or v_method not in ('GCash','Maya','One') then raise exception 'Choose a payment method'; end if;
  if length(v_acct) < 5 or length(v_acct) > 80 then raise exception 'Enter a valid account'; end if;
  begin v_amt := (p->>'amount')::int; exception when others then v_amt := null; end;
  if v_amt is null or v_amt < 5000 then raise exception 'Minimum is 5,000 coins'; end if;
  if u.coins < v_amt then raise exception 'Not enough coins'; end if;
  update public.profiles set coins = coins - v_amt where id = u.id;
  insert into public.withdrawals (user_id, method, account, amount) values (u.id, v_method, v_acct, v_amt);
  return jsonb_build_object('ok', true);
end $$;

-- ---------- referrals ----------
create or replace function public.ensure_profile(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; v_code text;
begin
  u := public.lock_me();
  if u.code is not null then return jsonb_build_object('code', u.code); end if;
  loop
    v_code := 'PAW' || upper(substr(md5(random()::text), 1, 5));
    exit when not exists (select 1 from public.profiles where code = v_code);
  end loop;
  update public.profiles set code = v_code where id = u.id;
  return jsonb_build_object('code', v_code);
end $$;

create or replace function public.apply_referral(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; v_code text := upper(trim(coalesce(p->>'code',''))); v_owner uuid;
begin
  u := public.lock_me();
  if coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) then raise exception 'Sign in with Google to use a code'; end if;
  if v_code !~ '^PAW[A-Z0-9]{5}$' then raise exception 'Invalid code'; end if;
  if u.referred_by is not null then raise exception 'You already used a code'; end if;
  select id into v_owner from public.profiles where code = v_code;
  if v_owner is null then raise exception 'Code not found'; end if;
  if v_owner = u.id then raise exception 'You can''t use your own code'; end if;
  update public.profiles set coins = coins + 50, total = total + 50, referred_by = v_owner where id = u.id;
  update public.profiles set coins = coins + 100, total = total + 100, refs = refs + 1, ref_earned = ref_earned + 100 where id = v_owner;
  return jsonb_build_object('reward', 50);
end $$;

-- ---------- weekly leaderboard (only name, avatar and weekly coins are shared) ----------
create or replace function public.get_leaderboard(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare wk date := public.week_start(); mine int; v_rank int; v_top jsonb;
begin
  if auth.uid() is null then raise exception 'Sign in first'; end if;
  select coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) into v_top from (
    select name, av, week_coins as total, (id = auth.uid()) as me
    from public.profiles where week_key = wk order by week_coins desc limit 10) x;
  select coalesce(case when week_key = wk then week_coins end, 0) into mine from public.profiles where id = auth.uid();
  select count(*) + 1 into v_rank from public.profiles where week_key = wk and week_coins > coalesce(mine, 0);
  return jsonb_build_object('rank', v_rank, 'top', v_top);
end $$;

-- ---------- profile + account deletion ----------
create or replace function public.update_profile(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles; v_name text; v_av text;
begin
  u := public.lock_me();
  if (p->>'name') is not null then
    v_name := trim(regexp_replace(p->>'name', '[<>&"'']', '', 'g'));
    if length(v_name) < 2 or length(v_name) > 16 then raise exception 'Name must be 2 to 16 characters'; end if;
    update public.profiles set name = v_name where id = u.id;
  end if;
  if (p->>'av') is not null then
    v_av := p->>'av';
    if v_av not in ('🐱','🐶','🦊','🐼','🐯','🐸','🦁','🐵') then raise exception 'Unknown avatar'; end if;
    update public.profiles set av = v_av where id = u.id;
  end if;
  return jsonb_build_object('ok', true);
end $$;

create or replace function public.delete_account(p jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u public.profiles;
begin
  u := public.lock_me();
  if exists (select 1 from public.withdrawals where user_id = u.id and status = 'pending') then
    raise exception 'You have a pending withdrawal. Try again after it is paid.';
  end if;
  delete from auth.users where id = u.id; -- cascades to profile and withdrawals
  return jsonb_build_object('ok', true);
end $$;

-- ===== Update 2 (withdrawal tiers, USD/PHP, 10% share) =====
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
