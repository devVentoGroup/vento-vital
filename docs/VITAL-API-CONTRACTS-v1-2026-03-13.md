# Vento Vital - API Contracts v1 2026-03-13

Estado: `baseline de contratos`

Depende de:

- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-DOMAIN-SCHEMA-v1-2026-03-13.md`
- `docs/APP-38-PRE-DESIGN-FREEZE-2026-03-04.md`

Proposito: fijar los contratos minimos que la UI de `V1` necesita para funcionar sin ambiguedad, especialmente para `HOY`, `Resumen` y `Perfil`.

---

## 1. Regla de alcance

Este documento define contratos minimos de lectura y escritura para `V1`.

No intenta cerrar:

- todo el modelo futuro
- `V2` entorno completo
- `V3` daily state completo
- `V4` motor adaptativo completo

Su objetivo es mantener `V1` construible y estable.

---

## 2. Endpoints base de V1

## 2.1 `GET /api/hoy/feed?date=YYYY-MM-DD`

Objetivo:

- cargar el feed principal de `HOY`

Respuesta minima:

```ts
type HoyFeedResponse = {
  date: string;
  source: "none" | "feed" | "legacy_today_tasks" | string;
  progressPct: number;
  completedCount: number;
  inProgressCount: number;
  pendingCount: number;
  tasks: HoyFeedItem[];
  modulePreferences: Array<{
    moduleKey: string;
    isEnabled: boolean;
  }>;
};
```

### `HoyFeedItem`

```ts
type HoyFeedItem = {
  id: string;
  moduleKey: "training" | "nutrition" | "habits" | "recovery" | string;
  taskType: string;
  title: string;
  status: "pending" | "in_progress" | "completed" | "snoozed" | "skipped";
  priorityScore: number | null;
  reasonCode: string | null;
  reasonText: string | null;
  safetyState: "ok" | "caution" | "blocked";
  meta?: string | null;
};
```

## 2.2 `POST /api/hoy/refresh`

Objetivo:

- recalcular o recargar `HOY`

Payload minimo:

```ts
type RefreshHoyRequest = {
  date: string;
};
```

Respuesta:

- mismo shape que `HoyFeedResponse`

## 2.3 `POST /api/hoy/tasks/:id/complete`

Objetivo:

- marcar tarea como hecha

Respuesta minima:

```ts
type TaskActionResponse = {
  ok: boolean;
  taskId: string;
  status: "completed";
  message?: string | null;
};
```

## 2.4 `POST /api/hoy/tasks/:id/snooze`

Objetivo:

- posponer tarea

Respuesta minima:

```ts
type TaskActionResponse = {
  ok: boolean;
  taskId: string;
  status: "snoozed";
  message?: string | null;
};
```

## 2.5 `POST /api/hoy/tasks/:id/reprogram`

Objetivo:

- enviar tarea a mañana o reprogramar

Respuesta minima:

```ts
type TaskActionResponse = {
  ok: boolean;
  taskId: string;
  status: "pending" | "snoozed";
  message?: string | null;
};
```

## 2.6 `GET /api/planning/weekly?week_start=YYYY-MM-DD`

Objetivo:

- alimentar `Resumen`

Respuesta minima:

```ts
type WeeklyPlanningResponse = {
  weekStart: string;
  items: Array<{
    planDate: string;
    moduleKey: string;
    title: string;
    blendWeight?: number | null;
    priorityHint?: string | null;
    conflictPenalty?: number | null;
    interferenceNote?: string | null;
  }>;
};
```

## 2.7 `GET /api/planning/cycle?date=YYYY-MM-DD`

Objetivo:

- alimentar ajustes de ciclo visibles en `Resumen`

Respuesta minima:

```ts
type CycleAdjustmentResponse = {
  date: string;
  items: Array<{
    moduleKey: string;
    phase: string;
    intensityDeltaPct?: number | null;
    volumeDeltaPct?: number | null;
    frequencyDelta?: number | null;
    reasonCode?: string | null;
    reasonText?: string | null;
  }>;
};
```

## 2.8 `GET /api/modules/me`

Objetivo:

- leer preferencias de modulos visibles en `Perfil`

Respuesta minima:

```ts
type ModulePreferenceResponse = Array<{
  moduleKey: "training" | "nutrition" | "habits" | "recovery" | string;
  isEnabled: boolean;
}>;
```

## 2.9 `PUT /api/modules/me`

Objetivo:

- actualizar preferencias de modulos

Payload minimo:

```ts
type UpdateModulePreferenceRequest = {
  items: Array<{
    moduleKey: string;
    isEnabled: boolean;
  }>;
};
```

## 2.10 `GET /api/sports-profile/me`

Objetivo:

- leer perfil deportivo base visible en `Perfil`

Respuesta minima:

```ts
type SportsProfileResponse = {
  primarySport?: string | null;
  secondarySports?: string[];
  competitionLevel?: string | null;
  seasonPhase?: string | null;
};
```

## 2.11 `PUT /api/sports-profile/me`

Objetivo:

- actualizar perfil deportivo base

Payload minimo:

```ts
type SportsProfileUpdateRequest = {
  primarySport?: string | null;
  secondarySports?: string[];
  competitionLevel?: string | null;
  seasonPhase?: string | null;
};
```

---

## 3. Contratos de UI obligatorios en V1

Estos campos deben existir para que `V1` no dependa de suposiciones.

### `HOY`

- `id`
- `moduleKey`
- `taskType`
- `title`
- `status`
- `priorityScore`
- `reasonCode`
- `reasonText`
- `safetyState`

### `Resumen`

- `planDate`
- `moduleKey`
- `title`
- `blendWeight`
- `priorityHint`
- `conflictPenalty`
- `interferenceNote`

### `Cycle`

- `moduleKey`
- `phase`
- `intensityDeltaPct`
- `volumeDeltaPct`
- `frequencyDelta`
- `reasonCode`
- `reasonText`

---

## 4. Reglas de contrato para V1

- no eliminar campos UI-critical sin nota de migracion
- si un campo se vuelve opcional, debe quedar documentado
- si un endpoint cambia shape, debe actualizarse este archivo y la spec relevante
- la app movil no debe depender de campos fantasma o no documentados

---

## 5. Relacion con `APP-38`

Este documento formaliza y extiende el baseline de:

- `docs/APP-38-PRE-DESIGN-FREEZE-2026-03-04.md`

Si hay conflicto:

- `APP-38` manda como freeze operativo previo
- este documento debe actualizarse para reflejarlo

---

## 6. Criterio de aceptacion

Estos contratos estan bien si:

- `HOY` puede renderizarse completa sin campos ambiguos
- `Resumen` puede renderizar plan semanal y ajustes de ciclo
- `Perfil` puede leer y escribir preferencias base
- el equipo ya no tiene que deducir payloads desde la UI

---

## 7. Siguiente paso recomendado

Despues de este documento, los siguientes utiles para `V1` serian:

- `docs/VITAL-COMPONENT-INVENTORY-v1.md`
- `docs/VITAL-SCREEN-STATES-v1.md`

Pero para empezar implementacion real, este baseline ya es suficiente.
