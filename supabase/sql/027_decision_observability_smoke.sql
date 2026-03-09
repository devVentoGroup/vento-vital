-- Vento Vital - APP-36 decision observability smoke
-- Run after:
-- 1) 20260309204500_vital_telemetry_decision_observability_v1.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Track a decision event
select vital.track_decision_event(
  'hoy_recommendation_accepted',
  'interference_load_guard',
  'Prioridad ajustada por interferencia de carga del dia anterior.',
  '{"module_key":"training","source":"smoke_app36"}'::jsonb,
  'app',
  now(),
  'v1'
) as decision_event_id;

-- 2) List recent decision events
select id, event_name, reason_code, reason_text, source, event_version, occurred_at
from vital.list_decision_events(20, null)
order by occurred_at desc;
