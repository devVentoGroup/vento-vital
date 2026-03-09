# APP V2 RC Closeout - 2026-03-03

Estado: `CERRADA` (release candidate interna v2)

## Alcance cerrado

- Onboarding v2 modular con safety gate estricto.
- HOY unificado por modulos con scoring y explicabilidad.
- Perfil con gestion de modulos activos.
- Resumen v3 con breakdown semanal por modulo.
- Telemetria de decisiones conectada desde app a BFF.

## Hardening aplicado (APP-25)

- API:
  - guardia global en `server.js` para errores no controlados.
  - `request_id` en `/health` y respuestas 404/500 para trazabilidad.
- Mobile:
  - normalizacion de errores de red/sesion para mensajes accionables.
  - fallback controlado `today_feed -> today_tasks` con indicador de fuente.
  - regla de consistencia: no permitir dejar 0 modulos activos.
  - telemetria de eventos clave de decision (`onboarding_completed_v2`, `module_toggled`, `hoy_recommendation_accepted`).

## Riesgos abiertos

- UI visual premium aun pendiente (sistema visual v2 + microinteracciones avanzadas).
- QA e2e automatizado aun no integrado en pipeline.
- Coexistencia `today_tasks` (legacy) y `today_feed` (nuevo) mantiene deuda temporal.

## Siguiente bloque recomendado

- APP-26: polish visual premium (design system v2, motion, jerarquia, densidad y accesibilidad).
