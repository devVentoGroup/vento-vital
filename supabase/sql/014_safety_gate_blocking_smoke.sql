-- Vento Vital - safety gate blocking smoke
-- Run after:
-- 1) 20260303_000009 applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select vital.submit_safety_intake(
  '{
    "chest_pain": true,
    "dizziness": false,
    "severe_injury": false,
    "post_surgery": false,
    "pregnancy_risk": false
  }'::jsonb
) as safety_row;

select * from vital.get_safety_status();
