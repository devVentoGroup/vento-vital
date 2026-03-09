# APP-25 RC Closeout - 2026-03-04

## Estado general
- Resultado: Release Candidate interno listo para validacion funcional continua.
- Alcance cerrado: APP-31 a APP-35 implementados y validados por smokes SQL.
- Repositorio canonico de migraciones respetado: `vento-shell`.

## Cambios cerrados por bloque
- APP-31: perfil deportivo compuesto (`sports_profile`) + API + onboarding.
- APP-32: catalogo de templates por deporte/objetivo/nivel + aplicacion automatica.
- APP-33: orquestador semanal multiobjetivo + reglas de interferencia + API planning.
- APP-34: ciclo adaptativo (build/maintain/deload) + aplicacion de deltas en plan semanal.
- APP-35: vertical futbol academia (presets, staff assignments, dashboard semanal staff).

## Migraciones canónicas aplicadas en remoto (tramo reciente)
- `20260309173000_vital_today_feed_scoring_spread_v5.sql`
- `20260309174500_vital_sport_template_catalog_v1.sql`
- `20260309181500_vital_weekly_orchestrator_v1.sql`
- `20260309184500_vital_today_feed_interference_penalty_v1.sql`
- `20260309191500_vital_adaptive_cycle_progression_v1.sql`
- `20260309194500_vital_weekly_plan_apply_cycle_deltas_v1.sql`
- `20260309201500_vital_football_academy_vertical_v1.sql`

## Smokes ejecutados/validados en fase
- `018_sports_profile_smoke.sql`
- `019_today_feed_sports_priority_smoke.sql`
- `020_sport_templates_apply_smoke.sql`
- `021_weekly_fused_schedule_smoke.sql`
- `022_today_interference_penalty_smoke.sql`
- `023_cycle_adjustment_smoke.sql`
- `024_weekly_plan_with_cycle_deltas_smoke.sql`
- `025_football_presets_smoke.sql`
- `026_staff_weekly_overview_smoke.sql`

## Hardening aplicado
- Scoring de HOY con spread deterministico (sin empates planos).
- Guardrail de interferencia de carga del dia anterior en `today_feed`.
- Ajuste adaptativo por fase de ciclo en planificacion semanal.
- Control de acceso para dashboard staff por squad (owner/staff/admin/service).
- Endpoints API modulares para `planning` y `staff`.

## Riesgos conocidos (no bloqueantes)
- Falta tuning fino de pesos de scoring con dataset real de usuarios.
- Falta capa visual final premium en todas las pantallas mobile (bloque UX final).
- Falta e2e automatizado integral (actualmente validacion mayormente por smoke SQL/manual).

## Criterios para pasar a piloto controlado
- Mantener sincronia de migraciones solo via `vento-shell` + `sync-migrations.ps1`.
- Ejecutar set smoke 018-026 en entorno staging antes de cada release.
- Validar API `/api/planning/*` y `/api/staff/*` con JWT real de app.

## Proximo bloque recomendado
- APP-36 (QA automatizado + observabilidad):
  - pruebas de contrato API (planning/staff/onboarding),
  - trazas de decisiones (`reason_code`) en telemetria,
  - checklist de regresion para despliegues semanales.
