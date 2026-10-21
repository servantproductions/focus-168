-- Focus 168 database setup.
-- Run this once in your Supabase project: SQL Editor -> New query -> paste -> Run.
-- It creates a table for each person's plan and one for their logged weeks, with rules so people
-- can only ever read or change their own. Running it again is safe.

create table if not exists public.plans (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  areas      jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  -- Keeps any one plan to a sensible size (a full plan is a few KB).
  constraint plans_areas_size check (pg_column_size(areas) < 200000)
);

-- Row Level Security: without a matching rule below, nobody can touch a row.
alter table public.plans enable row level security;

drop policy if exists "Read own plan" on public.plans;
drop policy if exists "Create own plan" on public.plans;
drop policy if exists "Update own plan" on public.plans;
drop policy if exists "Delete own plan" on public.plans;

create policy "Read own plan" on public.plans
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Create own plan" on public.plans
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Update own plan" on public.plans
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Delete own plan" on public.plans
  for delete to authenticated
  using ((select auth.uid()) = user_id);


-- ===== weeks: actual time logged, one row per person per week =====
-- Added for the Actual focus tab. Safe to run on its own if plans already exists.
-- week_start is the Monday of the week. data holds the logged entries, a running timer,
-- and a copy of that week's plan so past weekly reviews stay accurate.

create table if not exists public.weeks (
  user_id    uuid not null references auth.users (id) on delete cascade,
  week_start date not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, week_start),
  constraint weeks_data_size check (pg_column_size(data) < 400000)
);

alter table public.weeks enable row level security;

drop policy if exists "Read own weeks" on public.weeks;
drop policy if exists "Create own weeks" on public.weeks;
drop policy if exists "Update own weeks" on public.weeks;
drop policy if exists "Delete own weeks" on public.weeks;

create policy "Read own weeks" on public.weeks
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Create own weeks" on public.weeks
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Update own weeks" on public.weeks
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Delete own weeks" on public.weeks
  for delete to authenticated
  using ((select auth.uid()) = user_id);
