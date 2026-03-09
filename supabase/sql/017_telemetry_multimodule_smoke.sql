-- Vento Vital - telemetry multi-module smoke
-- Run after:
-- 1) telemetry migration and 20260303_000008..000012 applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select vital.track_event(
  'onboarding_completed_v2',
  '{"modules":["nutrition","habits"],"source":"smoke"}'::jsonb,
  'app',
  now(),
  'v1'
) as onboarding_event_id;

select vital.track_event(
  'module_toggled',
  '{"module_key":"training","enabled":false,"source":"smoke"}'::jsonb,
  'app',
  now(),
  'v1'
) as module_toggled_event_id;

select id, event_name, source, event_version, occurred_at
from vital.telemetry_events
where user_id = auth.uid()
order by occurred_at desc
limit 10;
