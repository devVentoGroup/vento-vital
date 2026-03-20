# Vento Vital - V1 QA Checklist 2026-03-13

Estado: `checklist QA`

Depende de:

- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-V1-IMPLEMENTATION-CHECKLIST-2026-03-13.md`

Proposito: validar que `V1` realmente cambie la experiencia de Vital y no se quede en un repaint superficial.

---

## 1. Criterio global

Si esta checklist falla, `V1` no debe darse por cerrada aunque el codigo compile.

La meta no es solo "que no haya bugs".

La meta es que:

- se vea distinto
- se sienta distinto
- se use distinto

---

## 2. QA visual

- [ ] la app ya no se siente wellness generica
- [ ] el tono general es oscuro, tecnico y sobrio
- [ ] el acento principal no depende de mint como identidad total
- [ ] el header post-login se siente parte del ecosistema Vento
- [ ] las tabs se sienten compactas y operativas
- [ ] cards, chips e inputs hablan el mismo idioma visual
- [ ] no hay bloques visuales que parezcan de otro sistema

---

## 3. QA de UX en `HOY`

- [ ] al abrir `HOY`, se entiende rapido que hacer
- [ ] existe una accion principal obvia
- [ ] se entiende el estado del dia
- [ ] los filtros son faciles de leer y usar
- [ ] la progresion del dia se entiende sin esfuerzo
- [ ] las tareas tienen prioridad visible
- [ ] las razones de cada tarea se entienden en formato corto
- [ ] las acciones principales por tarea son claras

---

## 4. QA de estados

- [ ] loading inicial se ve bien
- [ ] empty state de "sin tareas" se ve intencional
- [ ] empty state por filtros vacios se entiende
- [ ] errores visibles no rompen jerarquia
- [ ] `completed` se diferencia claramente
- [ ] `in_progress` tiene protagonismo
- [ ] `pending` sigue siendo legible
- [ ] `snoozed` y `skipped` no compiten con lo activo

---

## 5. QA de consistencia

- [ ] `Resumen` hereda el nuevo sistema
- [ ] `Perfil` hereda el nuevo sistema
- [ ] login / onboarding no quedan visualmente rotos
- [ ] ninguna pantalla principal se siente desconectada del resto

---

## 6. QA funcional minima

- [ ] la app carga sin romper flujo de sesion
- [ ] `HOY` sigue leyendo datos correctamente
- [ ] tabs funcionan sin errores
- [ ] botones principales responden
- [ ] filtros cambian el contenido esperado
- [ ] acciones sobre tareas siguen funcionando

---

## 7. QA de objetivo de producto

- [ ] Vital se reconoce como producto Vento
- [ ] `HOY` se convierte en centro operativo real
- [ ] la app transmite mas decision y menos decoracion
- [ ] la base queda lista para `V2` y `V3`

---

## 8. Criterio de aprobacion final

`V1` pasa QA si:

- no hay regresiones funcionales graves
- la transformacion visual es evidente
- `HOY` mejora en claridad de accion
- la app queda mejor preparada para crecer
