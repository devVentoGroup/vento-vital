-- Vento Vital - today feed sports priority smoke
-- Run after:
-- 1) 20260309143000_vital_today_feed_sports_priority.sql applied
-- 2) 20260309150000_vital_today_feed_scoring_desaturation.sql applied
-- 3) sports profile configured for current user

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Check sports profile context
select *
from vital.get_sports_profile();

-- 2) Check scoring with sports signal
select *
from vital.compute_hoy_scores(current_date)
order by priority_score desc;

-- 3) Check today feed with explainability
select id, module_key, priority_score, reason_code, reason_text, safety_state
from vital.today_feed(current_date)
order by priority_score desc, module_key, ordering;
