-- Vento Vital - HOY automaterialize smoke check
-- Run after:
-- 1) 20260302_000003_vital_today_automaterialize.sql applied
-- 2) authenticated session context (auth.uid available)

-- SQL Editor note:
-- In SQL Editor there is no JWT by default, so auth.uid() is null.
-- Simulate an authenticated user for this session:
select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Call HOY query (this should auto-create today's instances if missing)
select *
from vital.today_tasks(current_date);

-- 2) Verify instances now exist for today
select count(*) as today_instances_count
from vital.task_instances
where user_id = auth.uid()
  and task_date = current_date;
