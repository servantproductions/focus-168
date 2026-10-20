-- Focus 168 database setup.
-- Run this once in your Supabase project: SQL Editor -> New query -> paste -> Run.
-- It creates one table holding each person's plan, and rules so people can only ever read or change their own.

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
