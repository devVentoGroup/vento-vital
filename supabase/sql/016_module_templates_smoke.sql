-- Vento Vital - module templates smoke
-- Run after:
-- 1) 20260303_000012 applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select module_key, task_type, title, days_of_week, ordering, estimated_minutes
from vital.module_template_catalog
where is_active
order by module_key, ordering, title;
