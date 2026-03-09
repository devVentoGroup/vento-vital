-- Vento Vital - onboarding v2 smoke
-- Run after:
-- 1) 20260303_000008..000012 applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- Case A: nutrition only
select vital.create_initial_bundle_from_onboarding(
  jsonb_build_object(
    'objective', 'general_health',
    'days_per_week', 3,
    'minutes_per_session', 45,
    'modules', jsonb_build_array('nutrition'),
    'sports_profile', jsonb_build_object(
      'sports',
      jsonb_build_array(
        jsonb_build_object('key', 'gym', 'priority', 'A', 'level', 'beginner')
      ),
      'primary_sport', 'gym',
      'global_objectives', jsonb_build_array('health'),
      'constraints', jsonb_build_object('days_per_week', 3, 'minutes_per_session', 45),
      'cycle_config', jsonb_build_object('dominant_focus', 'balanced', 'cycle_weeks', 4)
    ),
    'safety', jsonb_build_object(
      'chest_pain', false,
      'dizziness', false,
      'severe_injury', false,
      'post_surgery', false,
      'pregnancy_risk', false
    )
  )
) as onboarding_result_nutrition_only;

-- Case B: training + recovery with red flag
select vital.create_initial_bundle_from_onboarding(
  jsonb_build_object(
    'objective', 'strength',
    'days_per_week', 4,
    'minutes_per_session', 60,
    'modules', jsonb_build_array('training', 'recovery'),
    'sports_profile', jsonb_build_object(
      'sports',
      jsonb_build_array(
        jsonb_build_object('key', 'football', 'priority', 'A', 'level', 'intermediate'),
        jsonb_build_object('key', 'gym', 'priority', 'B', 'level', 'intermediate')
      ),
      'primary_sport', 'football',
      'global_objectives', jsonb_build_array('performance', 'strength'),
      'constraints', jsonb_build_object('days_per_week', 4, 'minutes_per_session', 60),
      'cycle_config', jsonb_build_object('dominant_focus', 'sport_performance', 'cycle_weeks', 4)
    ),
    'safety', jsonb_build_object(
      'chest_pain', true,
      'dizziness', false,
      'severe_injury', false,
      'post_surgery', false,
      'pregnancy_risk', false
    )
  )
) as onboarding_result_training_blocked;

select * from vital.get_user_module_preferences();
select * from vital.get_safety_status();
select * from vital.get_sports_profile();
