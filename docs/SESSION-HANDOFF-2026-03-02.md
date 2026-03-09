# Session Handoff - 2026-03-02

Este archivo resume el estado de trabajo para continuar en otro computador sin perder contexto.

## 1) Estado actual

Se avanzo en dos frentes:
- Roadmap de producto (muy detallado, con seguridad/legal, load intelligence y gamificacion).
- Fundacion tecnica de base de datos (migracion SQL inicial para schema `vital` + RLS).

Actualizacion (2026-03-02, cierre del dia):
- La migracion `20260302_000001_vital_foundation.sql` ya fue aplicada en Supabase.
- `001_smoke_test.sql` validado (schema/tablas/RLS/politicas OK).
- Se reforzo la migracion con constraints de integridad de ownership e idempotencia de policies.
- Se ejecuto bootstrap admin + seed minimo de flujo (`002_bootstrap_admin_and_min_flow_check.sql`).
- Se agrego migracion `20260302_000002_vital_today_rpc.sql` con RPC base de Fase 1 (HOY).
- Nota operativa: `supabase db push` para `000002` quedo bloqueado por historial remoto de migraciones compartido; aplicar `000002` via SQL Editor.
- `000002` aplicada por SQL Editor y verificada con `003_today_rpc_smoke.sql` (funciones RPC presentes).
- Se agrego migracion `20260302_000003_vital_today_automaterialize.sql` para autogenerar tareas del dia al consultar `today_tasks`.
- `000003` aplicada y validada en smoke (`today_instances_count = 1`).
- Se agrego `supabase/sql/005_today_actions_e2e_smoke.sql` para validar ciclo completo de acciones `HOY` (complete/snooze/reprogram) con rollback.
- Se agrego migracion `20260302_000004_vital_recurrence_rules_v1.sql` (F0-07) para reglas de recurrencia v1 en `today_tasks`:
  - `daily`
  - `weekly`
  - `every_other_day`
  - `flexible_within_week`
- Se agrego `supabase/sql/006_recurrence_rules_smoke.sql` para validacion de recurrencia v1.
- `000004` aplicada y validada en smoke de recurrencia:
  - `daily=true`
  - `weekly` correcto por dia
  - `every_other_day` correcto por ancla
  - `flexible_within_week` correcto (weekday true, sunday false)
- Se agrego migracion `20260302_000005_vital_local_notifications_v1.sql` (F0-08) con contrato minimo de notificaciones locales.
- Se agrego `supabase/sql/007_local_notifications_smoke.sql` para validacion de notificaciones locales.
- `000005` aplicada y validada en smoke de notificaciones:
  - schedule valid/invalid correcto
  - `upsert_notification_plan` correcto
  - `today_notification_intents` retorna `notify_at` esperado para `fixed_time`
- Se agrego migracion `20260302_000006_vital_telemetry_feature_flags_v1.sql` (F0-09) con telemetria base y feature flags.
- Se agrego `supabase/sql/008_telemetry_feature_flags_smoke.sql` para validacion de F0-09.
- `000006` aplicada y validada en smoke de telemetria/flags:
  - override de feature flag por usuario correcto
  - evento `today_opened` registrado en `vital.telemetry_events`
- Fase 0 cerrada formalmente con acta:
  - `docs/FASE0-CLOSEOUT-2026-03-02.md`
- Se agrego migracion `20260302_000007_vital_phase1_starter_and_minlog.sql` (Fase 1):
  - biblioteca starter 2-6 dias
  - `create_program_from_starter`
  - `set_task_completion_minlog`
- Se agrego `supabase/sql/009_phase1_starter_minlog_smoke.sql` para validar F1-01/F1-02.
- `000007` aplicada y validada:
  - starter program creado desde catalogo
  - `set_task_completion_minlog` OK (`status=completed`, payload con `done/rpe_simple/weight_kg`)
- Se agrego `supabase/sql/010_hoy_flow_e2e_smoke.sql` para validar F1-03 en un solo flujo e2e.
- `010_hoy_flow_e2e_smoke.sql` validado:
  - estado final `pending`
  - `task_date` reprogramada a siguiente dia
  - `snooze_until` y `completed_at` en `null`
  - `completion_payload` preserva fuente de accion
- Fase 1 DB cerrada formalmente con acta:
  - `docs/FASE1-DB-CLOSEOUT-2026-03-02.md`
- Arranque de capa app creado:
  - `apps/api` modular (config/lib/modules/hoy)
  - `apps/mobile` Expo como app objetivo movil
- Base multi-dispositivo agregada:
  - layout `phone/tablet` en Expo
  - endpoint `wear` (`/api/wear/hoy`) para snapshot compacto de smartwatch
- Actualizacion mayor (post APP-17, 2026-03-02):
  - Se implemento base modular v2 (APP-18..APP-23):
    - onboarding v2 (modulos + safety gate + submit unificado)
    - preferencias de modulos por usuario
    - safety intake con bloqueos por modulo
    - feed `HOY` unificado (`today_feed`) con scoring y explicabilidad
    - templates base para `nutrition/habits/recovery`
  - Nuevas rutas API:
    - `/api/modules/*`
    - `/api/safety/*`
    - `/api/onboarding/complete`
    - `/api/hoy/feed`
  - Nuevas migraciones:
    - `20260303_000008_vital_module_preferences.sql`
    - `20260303_000009_vital_safety_gate_v1.sql`
    - `20260303_000010_vital_hoy_unified_feed.sql`
    - `20260303_000011_vital_adaptive_scoring_v1.sql`
    - `20260303_000012_vital_nutrition_habits_recovery_templates.sql`
  - Nuevos smoke tests SQL:
    - `011_onboarding_v2_smoke.sql` ... `017_telemetry_multimodule_smoke.sql`

## 2) Decisiones clave tomadas

1. Usar el mismo proyecto Supabase al inicio, pero separado por schema:
   - `public`: datos existentes (incluyendo `employees`).
   - `vital`: datos de salud/entrenamiento/gamificacion.
2. Permitir auth de empleados para entrar a Vento Vital.
3. Mantener separacion estricta:
   - Datos de salud en `vital`.
   - Datos laborales fuera de `vital`.
4. RLS obligatorio para que cada usuario vea solo su data.
5. Reportes para empresa solo agregados/anonimizados (no individuales).

## 3) Archivos creados/actualizados en esta sesion

### Producto
- `docs/Roadmap.md`
  - Reescrito y ampliado.
  - Incluye `Load Intelligence` (carga/fatiga).
  - Incluye sistema de juego competitivo (XP, niveles, ligas, fair-play).
- `docs/FASE0-CLOSEOUT-2026-03-02.md`
  - Cierre formal de Fase 0 con DoD, evidencia y riesgos abiertos.
- `docs/FASE1-DB-CLOSEOUT-2026-03-02.md`
  - Cierre formal de Fase 1 DB con DoD, evidencia y riesgos abiertos.
- `apps/README.md`
  - Guia de arquitectura y arranque de capa app.
- `apps/api/*`
  - BFF modular para RPC de `HOY` (listar/completar/snooze/reprogramar).
- `apps/api/src/modules/wear/*`
  - Endpoint para snapshot compacto `HOY` para wearables.
- `apps/mobile/*`
  - Base Expo para flujo `HOY` (listado con JWT contra BFF).
- `packages/contracts/*`
  - Contratos compartidos de tareas (`normalizado` y `wear compact`).

### Base de datos (Supabase)
- `supabase/migrations/20260302_000001_vital_foundation.sql`
  - Schema `vital`, tablas core y de juego.
  - Funciones de acceso y politicas RLS.
  - Hardening aplicado: constraints de consistencia entre `programs/program_versions/task_templates/task_instances`, checks de tiempo e idempotencia de policies.
- `supabase/migrations/20260302_000002_vital_today_rpc.sql`
  - RPC de `HOY`: listar tareas del dia, completar, snooze y reprogramar.
- `supabase/migrations/20260302_000003_vital_today_automaterialize.sql`
  - Actualiza `today_tasks` para crear `task_instances` del dia desde templates/programas activos.
- `supabase/sql/000_full_schema_report.sql`
  - Script para sacar inventario completo del schema actual antes de migrar.
- `supabase/sql/001_smoke_test.sql`
  - Script de verificacion rapida post-migracion.
- `supabase/sql/002_bootstrap_admin_and_min_flow_check.sql`
  - Upsert de admin inicial y chequeo rapido de flujo base.
- `supabase/sql/003_today_rpc_smoke.sql`
  - Verificacion de existencia de funciones RPC de `HOY`.
- `supabase/sql/004_today_automaterialize_smoke.sql`
  - Verificacion de auto-materializacion al consultar `today_tasks`.
- `supabase/sql/005_today_actions_e2e_smoke.sql`
  - Verificacion e2e de acciones `HOY` en transaccion con rollback.
- `supabase/migrations/20260302_000004_vital_recurrence_rules_v1.sql`
  - Rules Engine v1 para materializacion diaria por recurrencia.
- `supabase/sql/006_recurrence_rules_smoke.sql`
  - Smoke de reglas de recurrencia v1.
- `supabase/migrations/20260302_000005_vital_local_notifications_v1.sql`
  - Contrato minimo de notificaciones locales v1 (`schedule`, upsert/list/intents).
- `supabase/sql/007_local_notifications_smoke.sql`
  - Smoke de notificaciones locales v1.
- `supabase/migrations/20260302_000006_vital_telemetry_feature_flags_v1.sql`
  - Telemetria base + feature flags (`feature_flags`, `user_feature_flags`, `telemetry_events`).
- `supabase/sql/008_telemetry_feature_flags_smoke.sql`
  - Smoke de telemetria y feature flags.
- `supabase/migrations/20260302_000007_vital_phase1_starter_and_minlog.sql`
  - Starter library + registro minimo checklist para Fase 1.
- `supabase/sql/009_phase1_starter_minlog_smoke.sql`
  - Smoke de arranque Fase 1 (starter + minlog).
- `supabase/sql/010_hoy_flow_e2e_smoke.sql`
  - Smoke consolidado F1-03 (listar/completar/snooze/reprogramar).
- `supabase/README.md`
  - Guia de uso y orden recomendado.

## 4) Estado de migracion (actual)

Ya ejecutado:
- `supabase/sql/000_full_schema_report.sql`
- `supabase/migrations/20260302_000001_vital_foundation.sql`
- `supabase/sql/001_smoke_test.sql`
- `supabase/sql/002_bootstrap_admin_and_min_flow_check.sql`
- `supabase/migrations/20260302_000004_vital_recurrence_rules_v1.sql`
- `supabase/sql/006_recurrence_rules_smoke.sql`

Resultado:
- `vital` creado y operativo.
- RLS activo y politicas creadas para tablas core + excepciones admin/catalogo.
- Usuario admin inicial registrado y tarea base creada.

## 5) Plan para retomar manana

1. Insertar admin inicial en `vital.admin_users` (si no se hizo).
2. Ejecutar (opcional):
   - `supabase/sql/002_bootstrap_admin_and_min_flow_check.sql`
3. Aplicar migracion:
   - `supabase/migrations/20260302_000002_vital_today_rpc.sql`
4. Ejecutar (opcional):
   - `supabase/sql/003_today_rpc_smoke.sql`
5. Iniciar implementacion app de Fase 1 consumiendo RPC `HOY`:
   - `today_tasks`, `complete_task_instance`, `snooze_task_instance`, `reprogram_task_instance`.
6. Aplicar migracion:
   - `supabase/migrations/20260302_000007_vital_phase1_starter_and_minlog.sql`
7. Ejecutar:
   - `supabase/sql/009_phase1_starter_minlog_smoke.sql`
8. Iniciar implementacion de capa app:
   - frontend/backend consumiendo RPC `vital` para pantalla HOY y acciones diarias.
9. Validar APP-02:
   - levantar `apps/api`
   - probar endpoints con JWT real y registrar evidencia.

## 6) Prompt sugerido para continuar rapido

"Continuemos desde `docs/SESSION-HANDOFF-2026-03-02.md`. Ya ejecuté `supabase/sql/000_full_schema_report.sql` y estos son los resultados: ... Ajusta la migración `20260302_000001_vital_foundation.sql` y prepara el paso siguiente."

## 7) Nota operativa

Si este directorio esta bajo git en tu computador principal:
- hacer commit de estos cambios y push.

Si no esta bajo git:
- copia la carpeta `vento-vital` completa al otro computador.
