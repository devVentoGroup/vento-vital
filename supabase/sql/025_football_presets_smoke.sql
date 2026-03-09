-- Vento Vital - APP-35 football presets smoke
-- Run after:
-- 1) 20260309201500_vital_football_academy_vertical_v1.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) List football presets
select key, name, objective_key, dominant_focus, cycle_weeks, modules
from vital.list_football_presets()
order by key;

-- 2) Apply one preset
select vital.apply_football_preset('football_performance') as apply_result;

-- 3) Verify sports profile after apply
select *
from vital.get_sports_profile();
