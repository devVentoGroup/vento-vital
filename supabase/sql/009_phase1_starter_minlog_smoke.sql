-- Vento Vital - Phase 1 starter + minlog smoke
-- Run after:
-- 1) 20260302_000007_vital_phase1_starter_and_minlog.sql applied

-- SQL Editor auth simulation
select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Catalog available
select key, name, objective, days_per_week, is_active
from vital.list_starter_programs();

-- 2) Create a program from starter (idempotency is not required here; creates a new program each call)
select *
from vital.create_program_from_starter('starter_3d', 'Starter 3D Smoke Program');

-- 3) Materialize and list today's tasks
select id, task_type, title, status, task_date
from vital.today_tasks(current_date)
order by created_at desc
limit 10;

-- 4) Minimal completion log (done + rpe + weight)
with one_task as (
  select id
  from vital.today_tasks(current_date)
  order by created_at desc
  limit 1
)
select
  (t.x).status as status_after_check,
  (t.x).completion_payload as completion_payload_after_check
from (
  select vital.set_task_completion_minlog(
    (select id from one_task),
    true,
    7.0,
    80.5
  ) as x
) t;
