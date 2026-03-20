# Vento Vital - Screen States v1 2026-03-13

Estado: `baseline UX`

Depende de:

- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-V1-QA-CHECKLIST-2026-03-13.md`
- `docs/VITAL-API-CONTRACTS-v1-2026-03-13.md`

Proposito: dejar definidos los estados de pantalla que `V1` debe soportar para que la implementacion no improvise loading, vacios, errores o transiciones clave.

---

## 1. Regla general

Cada pantalla principal de `V1` debe soportar al menos estos estados:

- `loading`
- `ready`
- `empty`
- `error`

Reglas:

- cada estado debe sentirse parte del sistema visual de Vital
- ningun estado debe parecer temporal o accidental
- `empty` no debe sentirse como error
- `error` no debe destruir la jerarquia de la pantalla

---

## 2. Pantalla `HOY`

### 2.1 `loading`

Debe mostrar:

- skeleton del hero
- skeleton de progreso
- skeleton de lista/timeline

### 2.2 `ready`

Debe mostrar:

- hero operacional
- siguiente accion
- filtros
- resumen del dia
- progreso
- lista de tareas

### 2.3 `empty`

Caso A:

- no hay tareas para hoy

Caso B:

- no hay tareas para el filtro actual

### 2.4 `error`

Debe mostrar:

- mensaje corto
- accion de reintento si aplica

---

## 3. Pantalla `Resumen`

### 3.1 `loading`

Debe mostrar:

- skeleton de métricas
- skeleton de tendencia
- skeleton de paneles secundarios

### 3.2 `ready`

Debe mostrar:

- hero corto
- panorama semanal
- tendencia
- rendimiento por modulo
- recomendaciones

### 3.3 `empty`

Caso:

- no hay suficientes datos semanales

Debe sentirse como:

- falta de historial
- no como fallo del sistema

### 3.4 `error`

Debe mostrar:

- mensaje
- boton de reintento

---

## 4. Pantalla `Perfil`

### 4.1 `loading`

Debe mostrar:

- skeletons en cuenta
- skeletons en modulos
- skeletons en perfil deportivo

### 4.2 `ready`

Debe mostrar:

- hero corto
- datos de cuenta
- modulos activos
- perfil deportivo
- acciones secundarias del sistema

### 4.3 `empty`

Casos:

- no hay modulos configurados
- no hay perfil deportivo cargado aun

### 4.4 `error`

Debe mostrar:

- error local por bloque
- no romper toda la pantalla si falla un submodulo

---

## 5. Reglas de microcopy de estados

### `loading`

- evitar frases largas
- preferir skeletons sobre "cargando..." repetido

### `empty`

- explicar brevemente por que no hay contenido
- dar siguiente paso claro

### `error`

- explicar accionable
- evitar tono tecnico interno

---

## 6. Criterio de aceptacion

`V1` cumple este documento si:

- las tres pantallas principales soportan estados coherentes
- no hay estados visualmente improvisados
- loading, empty y error se sienten parte del producto
