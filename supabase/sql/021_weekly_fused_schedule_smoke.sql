-- Vento Vital - APP-33 weekly fused schedule smoke
-- Run after:
-- 1) 20260309181500_vital_weekly_orchestrator_v1.sql applied
-- 2) sports profile + modules configured

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Generate weekly fused schedule (dominant objective optional)
select *
from vital.plan_weekly_fused_schedule(current_date - ((extract(isodow from current_date)::int) - 1), 'performance')
order by plan_date, priority_hint desc, module_key;

-- 2) Quick aggregate by module
select module_key, count(*) as tasks_count, avg(priority_hint)::numeric(10,2) as avg_priority_hint
from vital.plan_weekly_fused_schedule(current_date - ((extract(isodow from current_date)::int) - 1), 'performance')
group by module_key
order by avg_priority_hint desc;
