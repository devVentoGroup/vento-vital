-- Vento Vital - APP-32C multisport blend priority smoke
-- Run after:
-- 1) 20260309211500_vital_multisport_priority_blend_v1.sql applied
-- 2) sports_profile configured with priority A/B/C

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Current sports profile
select *
from vital.get_sports_profile();

-- 2) Weekly plan with multisport blend weights
select
  plan_date,
  module_key,
  title,
  blend_weight,
  conflict_penalty,
  priority_hint,
  interference_note
from vital.plan_weekly_fused_schedule(
  current_date - ((extract(isodow from current_date)::int) - 1),
  'performance'
)
order by plan_date, priority_hint desc, module_key, title;

-- 3) Aggregate distribution by module
select
  module_key,
  count(*) as tasks_count,
  avg(blend_weight)::numeric(10,2) as avg_blend_weight,
  avg(priority_hint)::numeric(10,2) as avg_priority_hint
from vital.plan_weekly_fused_schedule(
  current_date - ((extract(isodow from current_date)::int) - 1),
  'performance'
)
group by module_key
order by avg_priority_hint desc;
