-- Vento Vital - F1-03 HOY flow e2e smoke
-- Validates in one run:
-- 1) list today tasks
-- 2) complete task
-- 3) snooze task
-- 4) reprogram task
--
-- Notes:
-- - Runs in transaction and ends with ROLLBACK (no persistent mutation).
-- - Requires at least one task template/program active for the user.

begin;

-- SQL Editor auth simulation
select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 0) Ensure HOY materializes and choose one task
create temporary table tmp_hoy_task on commit drop as
select id
from vital.today_tasks(current_date)
order by created_at desc
limit 1;

-- 1) List snapshot
select id, task_type, title, status, task_date, snooze_until, completed_at
from vital.today_tasks(current_date)
order by created_at desc
limit 5;

-- 2) Complete
select
  (r).id as task_id,
  (r).status as status_after_complete,
  (r).completed_at as completed_at_after_complete
from (
  select vital.complete_task_instance(
    (select id from tmp_hoy_task),
    '{"source":"f1_03_smoke"}'::jsonb
  ) as r
) q;

-- 3) Snooze
select
  (r).id as task_id,
  (r).status as status_after_snooze,
  (r).snooze_until as snooze_until_after_snooze
from (
  select vital.snooze_task_instance(
    (select id from tmp_hoy_task),
    now() + interval '90 minutes'
  ) as r
) q;

-- 4) Reprogram
select
  (r).id as task_id,
  (r).status as status_after_reprogram,
  (r).task_date as task_date_after_reprogram
from (
  select vital.reprogram_task_instance(
    (select id from tmp_hoy_task),
    current_date + 1
  ) as r
) q;

-- 5) Final state check
select id, status, task_date, snooze_until, completed_at, completion_payload
from vital.task_instances
where id = (select id from tmp_hoy_task);

rollback;
