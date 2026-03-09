# Vento Vital Supabase Setup

Este directorio contiene la base inicial de `vital` para Fase 0.

## Requisitos
- Supabase CLI instalado.
- Proyecto Supabase existente (el mismo que hoy usa `employees`).
- Rol con permisos para ejecutar migraciones.

## Estructura actual
- `sql/000_full_schema_report.sql`
  - Reporte completo del esquema actual para revision previa.
- `sql/001_smoke_test.sql`
  - Script de verificacion rapida post-migracion.
- `sql/002_bootstrap_admin_and_min_flow_check.sql`
  - Upsert de admin inicial + chequeo rapido del flujo minimo.
- `migrations/20260302_000001_vital_foundation.sql`
  - Crea schema `vital`.
  - Crea tablas core (perfil, plan, tareas, carga/fatiga, juego).
  - Crea funciones de acceso (`can_access_user`, `is_vital_admin`).
  - Habilita RLS y politicas base.
- `migrations/20260302_000002_vital_today_rpc.sql`
  - Crea RPC base para Fase 1 (`HOY`):
    - `today_tasks`
    - `complete_task_instance`
    - `snooze_task_instance`
    - `reprogram_task_instance`
- `migrations/20260302_000003_vital_today_automaterialize.sql`
  - Actualiza `today_tasks` para auto-crear `task_instances` del dia desde `task_templates` activos.
- `migrations/20260302_000004_vital_recurrence_rules_v1.sql`
  - Reglas de recurrencia v1 para materializacion diaria:
    - `daily`
    - `weekly`
    - `every_other_day`
    - `flexible_within_week`
- `migrations/20260302_000005_vital_local_notifications_v1.sql`
  - Contrato minimo de notificaciones locales:
    - validacion de `schedule`
    - `upsert_notification_plan`
    - `list_notification_plans`
    - `today_notification_intents`
- `migrations/20260302_000006_vital_telemetry_feature_flags_v1.sql`
  - Telemetria base + feature flags:
    - `feature_flags`
    - `user_feature_flags`
    - `telemetry_events`
    - `is_feature_enabled`
    - `upsert_user_feature_flag`
    - `track_event`
- `migrations/20260302_000007_vital_phase1_starter_and_minlog.sql`
  - Arranque Fase 1:
    - biblioteca starter 2-6 dias
    - `create_program_from_starter`
    - `set_task_completion_minlog` (done + RPE simple + peso opcional)
- `migrations/20260303_000008_vital_module_preferences.sql`
  - Catalogo de modulos + preferencias por usuario.
  - `module_key` agregado a templates/instances.
  - RPC: `list_module_catalog`, `get_user_module_preferences`, `upsert_user_module_preferences`.
- `migrations/20260303_000009_vital_safety_gate_v1.sql`
  - Safety intake con riesgo y modulos bloqueados.
  - RPC: `submit_safety_intake`, `get_safety_status`.
- `migrations/20260303_000010_vital_hoy_unified_feed.sql`
  - Feed unificado de HOY por modulo.
  - RPC: `today_feed`.
- `migrations/20260303_000011_vital_adaptive_scoring_v1.sql`
  - Inputs de readiness diarios y scoring adaptativo.
  - RPC: `compute_hoy_scores` + `today_feed` enriquecido.
- `migrations/20260303_000012_vital_nutrition_habits_recovery_templates.sql`
  - Templates base no-training (nutrition/habits/recovery).
  - RPC: `create_initial_bundle_from_onboarding`.
- `migrations/20260303_000013_fix_upsert_user_module_preferences_ambiguity.sql`
  - Hotfix de ambiguedad `module_key` en `upsert_user_module_preferences`.
- `migrations/20260303_000014_fix_compute_hoy_scores_module_key_ambiguity.sql`
  - Hotfix de ambiguedad `module_key` en `compute_hoy_scores`.
- `migrations/20260303_000015_fix_today_materialization_module_key.sql`
  - Hotfix de materializacion de `module_key` en `today_tasks`.
- `sql/003_today_rpc_smoke.sql`
  - Verificacion rapida de funciones RPC de `HOY`.
- `sql/004_today_automaterialize_smoke.sql`
  - Verificacion rapida de auto-materializacion al consultar `today_tasks`.
- `sql/005_today_actions_e2e_smoke.sql`
  - Prueba e2e de acciones `HOY` (complete/snooze/reprogram) en transaccion con rollback.
- `sql/006_recurrence_rules_smoke.sql`
  - Verificacion rapida de reglas de recurrencia v1.
- `sql/007_local_notifications_smoke.sql`
  - Verificacion rapida de contrato de notificaciones locales v1.
- `sql/008_telemetry_feature_flags_smoke.sql`
  - Verificacion rapida de telemetria base y feature flags.
- `sql/009_phase1_starter_minlog_smoke.sql`
  - Verificacion rapida de biblioteca starter + registro minimo.
- `sql/010_hoy_flow_e2e_smoke.sql`
  - Validacion e2e consolidada de flujo `HOY` (listar/completar/snooze/reprogramar) con rollback.
- `sql/011_onboarding_v2_smoke.sql`
  - Smoke onboarding v2 modular + safety.
- `sql/012_modules_preferences_smoke.sql`
  - Smoke de preferencias de modulos.
- `sql/013_today_feed_multimodule_smoke.sql`
  - Smoke de feed HOY por modulos con scoring.
- `sql/014_safety_gate_blocking_smoke.sql`
  - Smoke de bloqueos por safety gate.
- `sql/015_scoring_v1_smoke.sql`
  - Smoke deterministico de scoring adaptativo.
- `sql/016_module_templates_smoke.sql`
  - Smoke de catalogo de templates no-training.
- `sql/017_telemetry_multimodule_smoke.sql`
  - Smoke de telemetria para onboarding/modulos.

## Aplicar migraciones
0. (Recomendado) correr `sql/000_full_schema_report.sql` y guardar resultado como baseline.

1. Link al proyecto:
```bash
supabase link --project-ref <PROJECT_REF>
```

2. Aplicar migraciones:
```bash
supabase db push
```

3. En Supabase Dashboard (`Project Settings > API`), incluir `vital` en `Exposed schemas`.

## Post-migracion (obligatorio)
1. Insertar al menos un admin en `vital.admin_users` usando `service_role`:
```sql
insert into vital.admin_users (user_id, role)
values ('<AUTH_USER_ID>', 'admin')
on conflict (user_id) do update set role = excluded.role;
```

2. Verificar que un empleado autenticado pueda crear su `user_profile`.
3. Verificar que no pueda leer datos de otros usuarios.
4. (Opcional) correr `sql/002_bootstrap_admin_and_min_flow_check.sql` para validar flujo base.
5. (Opcional) correr `sql/003_today_rpc_smoke.sql` para validar RPC de `HOY`.
6. (Opcional) correr `sql/004_today_automaterialize_smoke.sql` para validar que `HOY` cree tareas del dia.
7. (Opcional) correr `sql/005_today_actions_e2e_smoke.sql` para validar ciclo completo de acciones `HOY`.
8. (Opcional) correr `sql/006_recurrence_rules_smoke.sql` para validar reglas de recurrencia v1.
9. (Opcional) correr `sql/007_local_notifications_smoke.sql` para validar notificaciones locales v1.
10. (Opcional) correr `sql/008_telemetry_feature_flags_smoke.sql` para validar telemetria y feature flags.
11. (Opcional) correr `sql/009_phase1_starter_minlog_smoke.sql` para validar arranque de Fase 1.
12. (Opcional) correr `sql/010_hoy_flow_e2e_smoke.sql` para validar F1-03.
13. (Opcional) correr `sql/011_onboarding_v2_smoke.sql` para validar onboarding modular.
14. (Opcional) correr `sql/012_modules_preferences_smoke.sql` para validar preferencias de modulos.
15. (Opcional) correr `sql/013_today_feed_multimodule_smoke.sql` para validar HOY unificado.
16. (Opcional) correr `sql/014_safety_gate_blocking_smoke.sql` para validar safety gate estricto.
17. (Opcional) correr `sql/015_scoring_v1_smoke.sql` para validar scoring adaptativo.
18. (Opcional) correr `sql/016_module_templates_smoke.sql` para validar templates no-training.
19. (Opcional) correr `sql/017_telemetry_multimodule_smoke.sql` para validar telemetria de decisiones.
20. (Si aplica) verificar que los hotfix `000013`, `000014`, `000015` estan aplicados antes de rerun de smokes `011-015`.

## Checklist rapido de seguridad
- [ ] RLS activo en todas las tablas de `vital`.
- [ ] Solo el usuario lee/escribe sus registros.
- [ ] Admins solo los definidos en `vital.admin_users`.
- [ ] Datos de salud no se mezclan con tablas laborales.
- [ ] `vital` expuesto en API (`public, graphql_public, vital`).
