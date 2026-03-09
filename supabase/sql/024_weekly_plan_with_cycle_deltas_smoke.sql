-- Vento Vital - APP-34C weekly plan with cycle deltas smoke
-- Run after:
-- 1) 20260309194500_vital_weekly_plan_apply_cycle_deltas_v1.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Weekly plan should include cycle-phase context in interference_note
select
  plan_date,
  module_key,
  task_type,
  title,
  estimated_minutes,
  blend_weight,
  conflict_penalty,
  priority_hint,
  interference_note
from vital.plan_weekly_fused_schedule(
  current_date - ((extract(isodow from current_date)::int) - 1),
  'performance'
)
order by plan_date, priority_hint desc, module_key, title;

-- 2) Aggregate by module to observe frequency/materialization deltas
select
  module_key,
  count(*) as tasks_count,
  avg(estimated_minutes)::numeric(10,2) as avg_minutes,
  avg(priority_hint)::numeric(10,2) as avg_priority_hint
from vital.plan_weekly_fused_schedule(
  current_date - ((extract(isodow from current_date)::int) - 1),
  'performance'
)
group by module_key
order by avg_priority_hint desc;
