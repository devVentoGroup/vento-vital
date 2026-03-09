-- Vento Vital - scoring v1 smoke
-- Run after:
-- 1) 20260303_000011 applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

insert into vital.daily_readiness_inputs (
  user_id, input_date, sleep_score, stress_score, energy_score, pain_map, steps, source
)
values (
  auth.uid(), current_date, 70, 40, 75, '{}'::jsonb, 8500, 'smoke'
)
on conflict (user_id, input_date) do update
set
  sleep_score = excluded.sleep_score,
  stress_score = excluded.stress_score,
  energy_score = excluded.energy_score,
  pain_map = excluded.pain_map,
  steps = excluded.steps,
  source = excluded.source,
  updated_at = now();

select *
from vital.compute_hoy_scores(current_date)
order by priority_score desc;
