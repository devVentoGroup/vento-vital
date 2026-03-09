-- Vento Vital - bootstrap admin + min flow check
-- Run after:
-- 1) migrations applied
-- 2) 001_smoke_test.sql validated
--
-- IMPORTANT:
-- - Admin auth user id configured for this environment
-- - This script is intended for SQL Editor with service_role/admin privileges

-- 1) Upsert initial admin user
insert into vital.admin_users (user_id, role)
values ('194649ee-3f1c-42ea-a44a-2abd87053c46'::uuid, 'admin')
on conflict (user_id) do update
set role = excluded.role;

-- 2) Quick sanity checks (admin + schema counters)
select
  (select count(*) from vital.admin_users) as admin_users_count,
  (select count(*) from information_schema.tables where table_schema = 'vital') as vital_tables_count,
  (select count(*) from pg_policies where schemaname = 'vital') as vital_policies_count;

-- 3) Optional min-flow data seed for a specific user (replace placeholder)
-- Use this only if you want a fast smoke flow in SQL.
-- Keep in mind that real RLS behavior should be tested from app sessions/JWTs.
do $$
declare
  v_user_id uuid := '194649ee-3f1c-42ea-a44a-2abd87053c46'::uuid;
  v_program_id uuid;
  v_program_version_id uuid;
  v_task_template_id uuid;
begin
  insert into vital.user_profiles (user_id, profile_context, display_name)
  values (v_user_id, 'employee', 'admin-bootstrap-user')
  on conflict (user_id) do nothing;

  insert into vital.programs (user_id, name, objective, status, started_on, is_active)
  values (v_user_id, 'Bootstrap Program', 'general_health', 'active', current_date, true)
  returning id into v_program_id;

  insert into vital.program_versions (
    user_id,
    program_id,
    version_number,
    archetype,
    generated_from,
    rules_snapshot,
    is_active
  )
  values (
    v_user_id,
    v_program_id,
    1,
    'full_body_3d',
    '{}'::jsonb,
    '{}'::jsonb,
    true
  )
  returning id into v_program_version_id;

  insert into vital.task_templates (
    user_id,
    program_version_id,
    task_type,
    title,
    recurrence_rule,
    ordering,
    estimated_minutes,
    payload,
    is_active
  )
  values (
    v_user_id,
    v_program_version_id,
    'workout',
    'Sesion base',
    '{}'::jsonb,
    1,
    45,
    '{}'::jsonb,
    true
  )
  returning id into v_task_template_id;

  insert into vital.task_instances (
    user_id,
    task_template_id,
    task_date,
    status,
    priority
  )
  values (
    v_user_id,
    v_task_template_id,
    current_date,
    'pending',
    50
  )
  on conflict (task_template_id, task_date) do nothing;
end
$$;

-- 4) Show created records for visual verification
select user_id, profile_context, display_name, created_at
from vital.user_profiles
where user_id = '194649ee-3f1c-42ea-a44a-2abd87053c46'::uuid;

select id, user_id, name, objective, status, created_at
from vital.programs
where user_id = '194649ee-3f1c-42ea-a44a-2abd87053c46'::uuid
order by created_at desc
limit 3;

select id, user_id, task_date, status, created_at
from vital.task_instances
where user_id = '194649ee-3f1c-42ea-a44a-2abd87053c46'::uuid
order by created_at desc
limit 5;
