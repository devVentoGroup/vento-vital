-- Vento Vital - HOY RPC smoke check
-- Run after:
-- 1) 20260302_000002_vital_today_rpc.sql applied
-- 2) at least one task_instance exists for your user

-- 1) Verify functions exist
select
  n.nspname as schema_name,
  p.proname as function_name
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'vital'
  and p.proname in (
    'today_tasks',
    'complete_task_instance',
    'snooze_task_instance',
    'reprogram_task_instance'
  )
order by p.proname;

-- 2) (Optional) call from app context with authenticated JWT:
select * from vital.today_tasks(current_date);
select * from vital.complete_task_instance('<TASK_INSTANCE_ID>'::uuid, '{}'::jsonb);
select * from vital.snooze_task_instance('<TASK_INSTANCE_ID>'::uuid, now() + interval '2 hour');
select * from vital.reprogram_task_instance('<TASK_INSTANCE_ID>'::uuid, current_date + 1);
