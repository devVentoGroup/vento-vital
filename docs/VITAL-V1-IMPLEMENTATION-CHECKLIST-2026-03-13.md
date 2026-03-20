# Vento Vital - V1 Implementation Checklist 2026-03-13

Estado: `checklist operativa`

Depende de:

- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`

Proposito: convertir `V1` en una lista concreta de trabajo para implementacion, evitando que el equipo tenga que reinterpretar la spec en cada sesion.

---

## 1. Regla de uso

Esta checklist no reemplaza la spec.

La spec responde:

- que es `V1`
- que debe lograr
- que no debe hacer

Esta checklist responde:

- que hay que tocar
- en que orden
- que significa terminar

---

## 2. Definicion de terminado de V1

`V1` esta terminada cuando:

- Vital cambia claramente de identidad visual
- `HOY` se vuelve la pantalla patron del producto
- `Resumen` y `Perfil` dejan de verse fuera del sistema
- el shell post-login se siente Vento
- la UI ya soporta listas, filtros y estados operativos con claridad

---

## 3. Bloque A - Theme

Archivos:

- `apps/mobile/src/theme/vitalTheme.js`

Checklist:

- [ ] definir paleta base oscura
- [ ] reducir protagonismo de mint como identidad principal
- [ ] dejar verde solo como color funcional
- [ ] definir superficies semanticas claras
- [ ] definir bordes y niveles de contraste
- [ ] definir tipografia funcional y densa
- [ ] definir estados visuales por status
- [ ] definir estilos semanticos por modulo

---

## 4. Bloque B - Primitives

Archivos:

- `apps/mobile/src/components/VCard.js`
- `apps/mobile/src/components/VButton.js`
- `apps/mobile/src/components/VChip.js`
- `apps/mobile/src/components/VOptionChip.js`
- `apps/mobile/src/components/VInput.js`
- `apps/mobile/src/components/VSectionHeader.js`

Checklist:

- [ ] `VCard` soporta superficies fuertes y densas
- [ ] `VButton` diferencia bien accion principal y secundaria
- [ ] `VChip` sirve para filtros compactos y estados
- [ ] `VOptionChip` no rompe la gramatica del sistema
- [ ] `VInput` se siente tecnico y limpio
- [ ] `VSectionHeader` alinea titulos y subtitulos del sistema
- [ ] las primitives minimizan estilos ad-hoc en pantallas

---

## 5. Bloque C - Chrome

Archivos:

- `apps/mobile/src/navigation/MainTabs.js`
- `apps/mobile/src/components/PageShell.js`

Checklist:

- [ ] el header superior expresa identidad Vital dentro del ecosistema Vento
- [ ] tabs se sienten compactas y operativas
- [ ] el shell no parece una landing o un dashboard pastel
- [ ] el fondo y la atmosfera visual son consistentes
- [ ] la navegacion base queda estable para `HOY`, `Resumen` y `Perfil`

---

## 6. Bloque D - HOY

Archivos:

- `apps/mobile/src/screens/HoyScreen.js`
- `apps/mobile/src/features/hoy/HoySummaryCard.js`
- `apps/mobile/src/features/hoy/TaskTimelineCard.js`

Checklist:

- [ ] hero corto y fuerte
- [ ] estado del dia visible
- [ ] siguiente accion clara
- [ ] filtros compactos por modulo y estado
- [ ] progreso visible y entendible
- [ ] resumen del dia breve y funcional
- [ ] timeline o lista con prioridad clara
- [ ] cada item tiene razon resumida
- [ ] acciones `Hecho`, `Posponer` y `Mañana/Reprogramar` son claras
- [ ] loading, empty y error states no rompen la experiencia

---

## 7. Bloque E - Alineacion minima de Resumen y Perfil

Archivos:

- `apps/mobile/src/screens/SummaryScreen.js`
- `apps/mobile/src/screens/ProfileScreen.js`

Checklist:

- [ ] `Resumen` hereda tokens y primitives
- [ ] `Perfil` hereda tokens y primitives
- [ ] ninguna de las dos pantallas se siente de otra app
- [ ] no se hace rediseño profundo aun
- [ ] ambas quedan listas para `V2` y `V3`

---

## 8. Bloque F - Guardrails

Checklist:

- [ ] no introducir complejidad visual que pertenezca a `V2` o `V3`
- [ ] no meter motor adaptativo completo en `V1`
- [ ] no meter catalogo o entorno complejo todavia
- [ ] no convertir `HOY` en dashboard sobrecargado
- [ ] no volver a una estetica wellness generica

---

## 9. Verificacion tecnica

Checklist:

- [ ] revisar lints de archivos tocados
- [ ] verificar que no se rompieron estados de login / onboarding / sesion
- [ ] verificar que la app sigue cargando `HOY`
- [ ] verificar que tabs siguen funcionando
- [ ] verificar que loading y empty states siguen presentes

---

## 10. Cierre de V1

Antes de cerrar la fase:

- [ ] actualizar `docs/VITAL-SESSION-HANDOFF.md`
- [ ] anotar que `V1` quedo implementada o en que porcentaje real esta
- [ ] listar archivos realmente tocados
- [ ] anotar si `Resumen` o `Perfil` quedaron pendientes de refinamiento
