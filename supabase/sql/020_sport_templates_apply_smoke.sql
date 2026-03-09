-- Vento Vital - APP-32 sport templates apply smoke
-- Run after:
-- 1) 20260309174500_vital_sport_template_catalog_v1.sql applied
-- 2) onboarding/profile configured with sports_profile and modules enabled

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Apply templates based on sports profile
select vital.apply_sport_templates_from_profile('performance') as sport_templates_result;

-- 2) Validate generated templates per module
select
  tt.module_key,
  tt.task_type,
  tt.title,
  tt.ordering,
  tt.estimated_minutes,
  tt.payload
from vital.task_templates tt
where tt.user_id = auth.uid()
  and tt.payload ->> 'source' = 'sport_template_catalog_v1'
order by tt.module_key, tt.ordering, tt.created_at desc;
