-- Vento Vital - sports profile v1 smoke
-- Run after:
-- 1) 20260309140000_vital_sports_profile_v1.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Get current profile (or defaults)
select *
from vital.get_sports_profile();

-- 2) Upsert profile
select *
from vital.upsert_sports_profile(
  jsonb_build_object(
    'sports',
    jsonb_build_array(
      jsonb_build_object('key', 'football', 'priority', 'A', 'level', 'intermediate'),
      jsonb_build_object('key', 'gym', 'priority', 'B', 'level', 'intermediate'),
      jsonb_build_object('key', 'volleyball', 'priority', 'C', 'level', 'beginner')
    ),
    'primary_sport', 'football',
    'global_objectives', jsonb_build_array('performance', 'strength'),
    'constraints', jsonb_build_object('days_per_week', 5, 'minutes_per_session', 60),
    'cycle_config', jsonb_build_object('dominant_focus', 'sport_performance', 'cycle_weeks', 4)
  )
);

-- 3) Verify persisted profile
select *
from vital.get_sports_profile();
