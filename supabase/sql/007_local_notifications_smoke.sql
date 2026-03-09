-- Vento Vital - local notifications v1 smoke
-- Run after:
-- 1) 20260302_000005_vital_local_notifications_v1.sql applied

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
    'validate_notification_schedule',
    'upsert_notification_plan',
    'list_notification_plans',
    'today_notification_intents'
  )
order by p.proname;

-- 2) Validate schedules
select
  vital.validate_notification_schedule('{"type":"fixed_time","hour":7,"minute":30}'::jsonb) as fixed_time_valid,
  vital.validate_notification_schedule('{"type":"relative_to_window","offset_minutes":-30}'::jsonb) as relative_valid,
  vital.validate_notification_schedule('{"type":"fixed_time","hour":99,"minute":0}'::jsonb) as fixed_time_invalid;

-- 3) Upsert and list
select (vital.upsert_notification_plan(
  'workout',
  '{"type":"fixed_time","hour":7,"minute":30,"timezone":"America/Bogota"}'::jsonb,
  true
)).id as notification_plan_id;

select task_type, enabled, schedule
from vital.list_notification_plans();

-- 4) Build notification intents for today
select *
from vital.today_notification_intents(current_date)
order by notify_at nulls last;
