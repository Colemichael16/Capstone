-- Alerts table, RLS and Realtime. Mirrors shared/alert.schema.json.
-- Run once in the Supabase SQL editor (or `supabase db push` if using the CLI).

create extension if not exists postgis with schema extensions;

-- Dispatchers: users allowed to publish. Add rows by hand (see db/README.md).
create table public.dispatchers (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);

alter table public.dispatchers enable row level security;

create policy "dispatchers read own row"
  on public.dispatchers for select
  to authenticated
  using (user_id = auth.uid());

-- security definer so policies on other tables can check membership without
-- needing read access to every dispatchers row
create or replace function public.is_dispatcher()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.dispatchers where user_id = auth.uid())
$$;

create table public.alerts (
  id uuid primary key default gen_random_uuid(),
  status text not null default 'active'
    check (status in ('draft', 'active', 'updated', 'resolved', 'cancelled')),
  category text not null
    check (category in ('active_threat', 'fire', 'weather', 'hazmat', 'police', 'utility', 'protest', 'medical')),
  severity text not null
    check (severity in ('extreme', 'severe', 'moderate', 'minor')),
  headline text not null check (char_length(headline) between 1 and 60),
  short_message text not null check (char_length(short_message) between 1 and 160),
  full_details text,
  instructions text,
  center extensions.geography(Point, 4326) not null,
  -- PostgREST and Realtime return geography as EWKB hex; this gives clients the
  -- GeoJSON Point the contract expects. Filled by trigger rather than a generated
  -- column, because logical replication (Realtime) can omit generated columns.
  center_geojson jsonb not null,
  radius_m integer not null check (radius_m >= 1),
  issued_by uuid default auth.uid() references auth.users (id),
  issued_at timestamptz not null default now(),
  expires_at timestamptz not null,
  check (expires_at > issued_at)
);

create or replace function public.alerts_set_center_geojson()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.center_geojson := extensions.st_asgeojson(new.center)::jsonb;
  return new;
end
$$;

create trigger alerts_set_center_geojson
  before insert or update of center on public.alerts
  for each row execute function public.alerts_set_center_geojson();

create index alerts_active_idx on public.alerts (expires_at) where status in ('active', 'updated');
create index alerts_center_idx on public.alerts using gist (center);

alter table public.alerts enable row level security;

-- Mirrored client-side by isActive() in web/src/alerts/contract.js
create policy "public reads active alerts"
  on public.alerts for select
  to anon, authenticated
  using (status in ('active', 'updated') and expires_at > now());

create policy "dispatchers read all alerts"
  on public.alerts for select
  to authenticated
  using (public.is_dispatcher());

create policy "dispatchers publish alerts"
  on public.alerts for insert
  to authenticated
  with check (public.is_dispatcher() and issued_by = auth.uid());

create policy "dispatchers update alerts"
  on public.alerts for update
  to authenticated
  using (public.is_dispatcher())
  with check (public.is_dispatcher());

-- Read path for both clients: contract-shaped rows with center as GeoJSON.
-- security_invoker keeps the alerts RLS policies in force.
create view public.alerts_feed
with (security_invoker = true) as
select
  id, status, category, severity, headline, short_message, full_details, instructions,
  center_geojson as center,
  radius_m, issued_by, issued_at, expires_at
from public.alerts;

grant select on public.alerts_feed to anon, authenticated;

-- Realtime: clients subscribe to postgres_changes on public.alerts (RLS applies)
alter publication supabase_realtime add table public.alerts;
