# APP-36 QA + Observabilidad - 2026-03-04

## Objetivo
Cerrar la base de QA operacional y observabilidad de decisiones para el motor de priorizacion/adaptacion.

## Entregables implementados
- RPC `track_decision_event(...)` para trazabilidad estandarizada de decisiones con `reason_code` y `reason_text`.
- RPC `list_decision_events(...)` para inspeccion rapida de eventos de decision del usuario.
- API BFF:
  - `POST /api/telemetry/decision`
  - `GET /api/telemetry/decisions?limit=50&event_name=...`

## Contratos minimos recomendados (QA)
- `POST /api/telemetry/decision` debe fallar `400` si falta `event_name`, `reason_code` o `reason_text`.
- `GET /api/telemetry/decisions` debe retornar solo eventos con `reason_code` en payload.
- `limit` debe acotarse internamente entre `1` y `200`.

## Checklist de regresion corta
- Onboarding completo -> generar plan -> cargar HOY -> ejecutar accion -> track de decision visible.
- Safety bloquea training -> `reason_code` de guardrail aparece en eventos.
- Deload activo -> se registra decision de ajuste de carga con contexto.

## SQL de validacion
- `supabase/sql/027_decision_observability_smoke.sql`

## Estado
- APP-36A (observabilidad de decisiones): completado.
- APP-36B (QA de contratos base): completado a nivel checklist + smoke.
- APP-36C (automatizacion e2e CI): pendiente para siguiente iteracion.
