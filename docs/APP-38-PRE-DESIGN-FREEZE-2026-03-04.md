# APP-38 - Pre-Design Freeze (2026-03-04)

Objetivo: bloquear base funcional y de contenido antes del rediseño visual final para evitar retrabajo.

## 1) Contratos de datos congelados (UI-critical)

Estado: congelado para fase de rediseño.

Endpoints base:
- `GET /api/hoy/feed?date=YYYY-MM-DD`
- `GET /api/planning/weekly?week_start=YYYY-MM-DD&objective=...`
- `GET /api/planning/cycle?date=YYYY-MM-DD`
- `GET /api/modules/me`
- `PUT /api/modules/me`
- `GET /api/safety/status`
- `GET /api/sports-profile/me`
- `PUT /api/sports-profile/me`

Campos minimos obligatorios en UI:
- HOY feed item:
  - `id`
  - `module_key`
  - `task_type`
  - `title`
  - `status`
  - `priority_score`
  - `reason_code`
  - `reason_text`
  - `safety_state`
- Planning semanal item:
  - `plan_date`
  - `module_key`
  - `title`
  - `blend_weight`
  - `priority_hint`
  - `conflict_penalty`
  - `interference_note`
- Cycle adjustment item:
  - `module_key`
  - `phase`
  - `intensity_delta_pct`
  - `volume_delta_pct`
  - `frequency_delta`
  - `reason_code`
  - `reason_text`

Regla de cambio:
- cualquier cambio de contrato rompe freeze y requiere nota de migracion de UI.

## 2) Sistema visual v1 cerrado

Estado: congelado para rediseño v2.

Tokens (fuente): `apps/mobile/src/theme/vitalTheme.js`
- color mint-first como identidad principal.
- jerarquia tipografica y espaciado con primitives reutilizables.
- superficies/cards/chips/botones estandarizados.

Componentes base obligatorios:
- `PageShell`
- `VCard`
- `VButton`
- `VChip`
- `VInput`
- `VOptionChip`
- `VSectionHeader`

Regla de fase de diseño:
- no crear estilos ad-hoc fuera de primitives salvo excepcion justificada por componente nuevo.

## 3) Navegacion y arquitectura de pantallas

Estado: congelado para rediseño v2.

Estructura principal:
- Auth dedicada (`LoginScreen`).
- Onboarding dedicado (`OnboardingScreen`).
- Tabs base post-sesion:
  - `HOY`
  - `Resumen`
  - `Perfil`

Distribucion funcional:
- HOY:
  - timeline de tareas + acciones (hecho/posponer/reprogramar).
- Resumen:
  - adherencia semanal + plan semanal fusionado + ajuste de ciclo.
- Perfil:
  - modulos, safety, sports profile, estado de sistema.

## 4) Microcopy UX en español (baseline)

Estado: congelado como baseline para rediseño.

Etiquetas core:
- `Cargar HOY`
- `Hecho`
- `Posponer`
- `Reprogramar`
- `Resumen`
- `Plan de accion semanal`
- `Plan semanal fusionado`
- `Ajuste de ciclo (hoy)`

Errores baseline:
- red/api: `No hay conexión con API. Verifica EXPO_PUBLIC_API_BASE_URL y que dev:api esté activo.`
- sesion: `Sesión inválida. Cierra sesión e inicia de nuevo.`
- token: `Tu sesión expiró. Ingresa nuevamente para continuar.`

## 5) Criterio de salida APP-38

Se considera completado cuando:
- contratos UI-critical quedan definidos y sin cambios durante fase de rediseño;
- sistema visual base y componentes obligatorios quedan fijados;
- navegación HOY/Resumen/Perfil se mantiene estable;
- microcopy baseline en español queda definido.

Resultado:
- fase de rediseño puede comenzar sin riesgo alto de retrabajo estructural.
