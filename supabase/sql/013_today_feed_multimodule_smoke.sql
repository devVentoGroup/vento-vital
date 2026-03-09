-- Vento Vital - today feed multi-module smoke
-- Run after:
-- 1) 20260303_000010 and 20260303_000011 applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select *
from vital.today_feed(current_date)
order by priority_score desc, module_key, ordering;
