-- Vento Vital - APP-33C interference penalty smoke
-- Run after:
-- 1) 20260309184500_vital_today_feed_interference_penalty_v1.sql applied
-- 2) APP-33 weekly orchestrator applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Ensure there is previous-day load (synthetic marker task if needed)
-- Optional: insert your own previous-day tasks to stress interference.

-- 2) Evaluate today feed reason/score with interference guard
select
  id,
  module_key,
  priority_score,
  reason_code,
  reason_text,
  safety_state
from vital.today_feed(current_date)
order by priority_score desc, module_key, ordering;
