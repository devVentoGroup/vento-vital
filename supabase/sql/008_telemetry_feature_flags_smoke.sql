-- Vento Vital - telemetry + feature flags v1 smoke
-- Run after:
-- 1) 20260302_000006_vital_telemetry_feature_flags_v1.sql applied

-- SQL Editor auth simulation
select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Function existence
select
  n.nspname as schema_name,
  p.proname as function_name
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'vital'
  and p.proname in (
    'is_feature_enabled',
    'upsert_user_feature_flag',
    'track_event'
  )
order by p.proname;

-- 2) Seed one feature flag (admin/service_role context expected in SQL editor)
insert into vital.feature_flags (key, description, enabled_by_default)
values ('today_new_layout', 'Enable new today layout', false)
on conflict (key) do update
set description = excluded.description;

-- 3) Evaluate default + override
select vital.is_feature_enabled('today_new_layout') as default_disabled;

select (vital.upsert_user_feature_flag(
  'today_new_layout',
  true,
  '{"source":"smoke"}'::jsonb
)).enabled as override_enabled;

select vital.is_feature_enabled('today_new_layout') as final_enabled;

-- 4) Track event
select vital.track_event(
  'today_opened',
  '{"screen":"today","source":"smoke"}'::jsonb,
  'app',
  now(),
  'v1'
) as telemetry_event_id;

-- 5) Verify recent telemetry rows for this user
select id, user_id, event_name, event_version, source, occurred_at
from vital.telemetry_events
where user_id = auth.uid()
order by occurred_at desc
limit 5;
