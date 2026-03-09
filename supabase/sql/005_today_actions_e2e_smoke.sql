-- Vento Vital - HOY actions e2e smoke check
-- Run after:
-- 1) 20260302_000002_vital_today_rpc.sql applied
-- 2) 20260302_000003_vital_today_automaterialize.sql applied
-- 3) at least one active task_template exists for the user
--
-- This script runs in a transaction and ends with ROLLBACK
-- so no permanent data changes are left behind.

begin;

-- Simulate authenticated context in SQL Editor
select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- Ensure HOY has at least one task and pick one id
create temporary table tmp_today_task on commit drop as
select id
from vital.today_tasks(current_date)
order by created_at asc
limit 1;

-- 1) Complete
select
  (vital.complete_task_instance(
    (select id from tmp_today_task),
    '{"source":"smoke"}'::jsonb
  )).status as status_after_complete;

-- 2) Snooze
select
  (vital.snooze_task_instance(
    (select id from tmp_today_task),
    now() + interval '2 hour'
  )).status as status_after_snooze;

-- 3) Reprogram to tomorrow
select
  (vital.reprogram_task_instance(
    (select id from tmp_today_task),
    current_date + 1
  )).task_date as date_after_reprogram;

-- 4) Final check
select
  id,
  status,
  snooze_until,
  task_date,
  updated_at
from vital.task_instances
where id = (select id from tmp_today_task);

rollback;
