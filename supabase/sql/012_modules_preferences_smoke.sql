-- Vento Vital - module preferences smoke
-- Run after:
-- 1) 20260303_000008_vital_module_preferences.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select key, name, is_active
from vital.list_module_catalog();

select * from vital.get_user_module_preferences();

select *
from vital.upsert_user_module_preferences(
  '[
    {"module_key":"training","is_enabled":false},
    {"module_key":"nutrition","is_enabled":true},
    {"module_key":"habits","is_enabled":true},
    {"module_key":"recovery","is_enabled":false}
  ]'::jsonb
);

select * from vital.get_user_module_preferences();
