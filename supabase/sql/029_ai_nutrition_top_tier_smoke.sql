-- Vento Vital - AI + nutricion top tier smoke
-- Run after:
-- 1) 20260305110000_vital_ai_nutrition_top_tier_v1.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 1) Context bundle
select vital.get_ai_context_bundle(current_date) as ai_context_bundle;

-- 2) Nutrition profile upsert + get
select vital.upsert_nutrition_profile_v1(
  jsonb_build_object(
    'hydration_goal_l', 2.8,
    'meals_per_day', 4,
    'calories_target', 2550,
    'protein_g_target', 165,
    'carbs_g_target', 290,
    'fat_g_target', 70
  )
) as nutrition_profile_upserted;

select * from vital.get_nutrition_profile_v1();

-- 3) Daily nutrition log
select vital.upsert_daily_nutrition_log_v1(
  current_date,
  jsonb_build_object(
    'meals_logged', 4,
    'hydration_l', 2.3,
    'calories_consumed', 2480,
    'protein_g', 158,
    'carbs_g', 282,
    'fat_g', 68,
    'adherence_score', 88,
    'source', 'smoke'
  )
) as nutrition_log_upserted;

select *
from vital.list_daily_nutrition_logs_v1(current_date - 7, current_date)
order by input_date desc;

-- 4) Create AI proposal row
select vital.create_ai_plan_proposal_v1(
  vital.get_ai_context_bundle(current_date),
  jsonb_build_object(
    'summary', 'Smoketest proposal',
    'confidence_score', 80,
    'weekly_blocks', jsonb_build_array(
      jsonb_build_object(
        'module_key', 'training',
        'task_type', 'workout',
        'title', 'Sesion IA potencia',
        'estimated_minutes', 55,
        'days', jsonb_build_array(1,3,5),
        'reason_text', 'Bloque de potencia para objetivo performance.',
        'payload', jsonb_build_object('source', 'smoke')
      )
    ),
    'hoy_adjustments', jsonb_build_array()
  ),
  80,
  'smoke-model',
  'v1'
) as ai_proposal_row;

