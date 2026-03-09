-- Vento Vital - APP-34 adaptive cycle smoke
-- Run after:
-- 1) 20260309191500_vital_adaptive_cycle_progression_v1.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Current cycle state (auto-create if missing)
select *
from vital.get_or_create_cycle_state();

-- 2) Daily cycle adjustment for today
select *
from vital.plan_cycle_adjustment(current_date)
order by case module_key
  when 'training' then 1
  when 'recovery' then 2
  when 'nutrition' then 3
  when 'habits' then 4
  else 9
end;

-- 3) Persisted cycle state check
select user_id, cycle_start_date, cycle_length_weeks, current_week, dominant_focus, phase, last_readiness, last_adherence, last_interference_penalty, updated_at
from vital.user_cycle_states
where user_id = auth.uid();
