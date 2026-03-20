# Vento Vital - V1 Spec 2026-03-13

Estado: `draft de ejecucion`

Depende de: `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`

Objetivo de este documento: bajar `V1` a una especificacion concreta, construible y verificable.

---

## 1. Objetivo exacto de V1

`V1` no intenta construir la aplicacion perfecta.

`V1` si intenta lograr 4 cosas:

1. reposicionar Vital como un producto claramente Vento
2. abandonar la estetica wellness generica
3. convertir `HOY` en el centro operativo real del producto
4. dejar una base lista para crecer hacia entorno real, estado diario y motor adaptativo

En otras palabras:

`V1` es la version que cambia la identidad y la forma de uso de Vital, sin intentar aun resolver todas las variables del sistema final.

---

## 2. Resultado esperado al terminar V1

Cuando alguien abra la app debe sentir esto:

- la app se ve oscura, tecnica, sobria y util
- la app se siente Vento, no una plantilla de fitness
- la pantalla principal deja claro que hacer hoy
- el usuario entiende accion, estado y prioridad sin ruido
- la interfaz ya soporta listas densas, filtros, estados y operaciones frecuentes

Si `V1` queda bien, el usuario deberia entender en pocos segundos:

- que estado tiene su dia
- cual es la siguiente accion sugerida
- que modulo o bloque del dia esta mas prioritario
- que puede hacer ahora mismo

---

## 3. No objetivos de V1

Para evitar que esta version se infle, `V1` no debe incluir:

- motor completo multisport
- perfiles de entorno complejos
- catalogo completo de equipamiento
- generacion avanzada de rutinas
- nutricion profunda
- recuperacion avanzada
- integraciones con wearables
- importaciones externas
- IA real de entrenamiento
- analitica compleja o score fisiologico profundo

`V1` prepara la base.
No intenta cerrar todo el roadmap.

---

## 4. North Star de UX

La experiencia base de `V1` debe responder a este principio:

> "Abro Vital y en menos de 10 segundos entiendo que hacer hoy."

Consecuencias practicas:

- menos bloques decorativos
- menos mensajes aspiracionales
- mas estructura operativa
- menos tarjetas blandas
- mas jerarquia visual real
- menos colores dominantes
- mas control de estados y densidad

---

## 5. Direccion visual de V1

### 5.1 Personalidad

Vital V1 debe sentirse:

- oscuro
- tecnico
- premium
- compacto
- funcional
- serio
- controlado

No debe sentirse:

- pastel
- amigable en exceso
- "wellness app"
- jugueton
- sobrecargado de gradientes
- demasiado suave o redondeado

### 5.2 Regla visual central

`estructura Vento + tono operativo + inspiracion de app tecnica`

Eso significa:

- identidad de ecosistema clara
- layout mas rigido
- filas y listas mas importantes que cards heroicas
- un solo acento de marca dominante
- verde o neones solo para estados de exito/seleccion/confirmacion

### 5.3 Tokens visuales esperados

Base:

- fondos oscuros tipo navy / grafito / petroleo
- superficies oscuras diferenciadas con bordes sutiles
- texto principal muy legible
- texto secundario atenuado pero claro

Acentos:

- acento de marca Vital controlado
- verde funcional solo para confirmacion, disponibilidad, completado
- colores de modulo con uso medido

Comportamiento:

- bordes visibles
- sombras suaves y escasas
- radios amplios pero contenidos
- chips densos
- filas largas tipo operacion

---

## 6. Superficies de producto incluidas en V1

`V1` se concentra en estas superficies:

### 6.1 Shell post-login

Incluye:

- cabecera principal
- tabs base
- estructura de pagina
- espaciados globales
- identidad Vento para Vital

### 6.2 Pantalla `HOY`

Es la pantalla mas importante de V1.

Debe incluir:

- hero corto pero fuerte
- estado del dia
- siguiente accion
- progreso visible
- filtros
- timeline o lista operativa
- acciones rapidas sobre tareas

### 6.3 Pantalla `Resumen`

En `V1` no necesita rehacerse por completo, pero si debe alinearse visualmente al nuevo idioma base.

Objetivo minimo:

- que no se sienta de otra app
- que herede tokens y primitives correctas

### 6.4 Pantalla `Perfil`

En `V1` no se profundiza aun en entorno real, pero si debe:

- heredar el nuevo lenguaje visual
- dejar espacio conceptual para futuras capas

---

## 7. Arquitectura de UI de V1

`V1` debe consolidar esta jerarquia:

1. `Theme`
2. `Primitives`
3. `PageShell / Chrome`
4. `Hoy`
5. `Resumen / Perfil` alineados al sistema

### 7.1 Theme

Archivo base:

- `apps/mobile/src/theme/vitalTheme.js`

Debe quedar como fuente central de:

- colores
- tipografia
- espaciado
- radios
- niveles de superficie
- estados visuales
- estilos semanticos por modulo y status

### 7.2 Primitives

Archivos base:

- `apps/mobile/src/components/VCard.js`
- `apps/mobile/src/components/VButton.js`
- `apps/mobile/src/components/VChip.js`
- `apps/mobile/src/components/VOptionChip.js`
- `apps/mobile/src/components/VInput.js`
- `apps/mobile/src/components/VSectionHeader.js`

Resultado esperado:

- menos estilos ad-hoc por pantalla
- una gramatica visual consistente
- componentes listos para listas, filtros, rows y acciones densas

### 7.3 Chrome

Archivos base:

- `apps/mobile/src/navigation/MainTabs.js`
- `apps/mobile/src/components/PageShell.js`

Debe resolver:

- identidad de app
- jerarquia superior
- navegacion estable
- fondo y atmosfera del producto

---

## 8. Especificacion de `HOY`

## 8.1 Rol de la pantalla

`HOY` no es dashboard.

`HOY` es:

- centro de decision
- vista de accion
- resumen del dia
- punto de ejecucion

## 8.2 Preguntas que debe responder

`HOY` debe responder con rapidez:

- como va el dia
- que sigue
- que tareas importan mas
- que modulo domina hoy
- que accion puedo tomar ya

## 8.3 Estructura de pantalla objetivo

Orden sugerido:

1. `Hero operacional`
2. `Siguiente accion`
3. `Filtros`
4. `Resumen del dia`
5. `Progreso`
6. `Lista/timeline de tareas`

## 8.4 Hero operacional

Debe contener:

- nombre de la pantalla o contexto del dia
- fecha
- etiqueta de fuente o estado del feed
- una descripcion muy corta de que representa

No debe contener:

- demasiado texto
- multiples slogans
- mensajes inspiracionales largos

## 8.5 Siguiente accion

Debe ser visible y concreta.

Ejemplos:

- `Completar siguiente tarea`
- `Actualizar hoy`
- `Retomar tarea activa`

Regla:

la accion principal debe ser una sola y obvia.

## 8.6 Filtros

Tipos de filtro minimos:

- por modulo
- por estado

Comportamiento:

- accesibles
- densos
- faciles de cambiar
- sin ocupar media pantalla

## 8.7 Resumen del dia

Debe mostrar:

- hechas
- en curso
- pendientes

No debe sentirse como un dashboard financiero.
Debe sentirse como un bloque corto de control.

## 8.8 Progreso

Debe mostrar:

- progreso numerico
- barra simple
- lectura inmediata

No necesita complejidad extra en V1.

## 8.9 Lista o timeline de tareas

Cada item debe priorizar:

- nombre
- estado
- modulo
- razon resumida
- acciones

Las acciones minimas:

- `Hecho`
- `Posponer`
- `Mañana` o `Reprogramar`

La razon del item debe existir, pero corta.
No convertir cada item en un ensayo.

---

## 9. Comportamiento de estados en V1

Estados minimos de tarea:

- `pending`
- `in_progress`
- `completed`
- `snoozed`
- `skipped`

Reglas:

- `completed` debe sentirse claramente resuelto
- `in_progress` debe tener mas protagonismo que `pending`
- `pending` debe seguir siendo legible
- `snoozed` y `skipped` no deben competir visualmente con lo activo

Estados de carga:

- skeleton para carga inicial
- empty state para sin tareas
- empty state para filtros vacios
- error state si falla la carga

---

## 10. Reglas de contenido para V1

### 10.1 Microcopy

Debe ser:

- corto
- directo
- funcional
- en espanol claro

Debe evitar:

- marketing excesivo
- frases vagas
- tono demasiado blando

### 10.2 Explicaciones

`V1` ya debe empezar a introducir el concepto de "por que aparece esto", pero en modo corto.

Ejemplos validos:

- `Priorizado por contexto del dia`
- `Bloqueado por seguridad`
- `Ajustado por tu estado actual`

Ejemplos no validos:

- explicaciones largas
- pseudo-ciencia
- decisiones sin motivo visible

---

## 11. Entregables exactos de V1

### 11.1 Design System V1

Entregables:

- tokens visuales base
- semantica de estados
- primitives listas para uso repetido
- reglas de uso documentadas

### 11.2 Chrome V1

Entregables:

- header superior consistente
- tabs alineadas con Vital
- shell general estable

### 11.3 `HOY` V1

Entregables:

- hero operacional
- bloque de accion principal
- resumen del dia
- progreso
- lista/timeline de tareas usable

### 11.4 Alineacion minima de otras pantallas

Entregables:

- `Resumen` no rompe el sistema
- `Perfil` no rompe el sistema

---

## 12. Archivos objetivo de implementacion

Prioridad alta:

- `apps/mobile/src/theme/vitalTheme.js`
- `apps/mobile/src/navigation/MainTabs.js`
- `apps/mobile/src/components/PageShell.js`
- `apps/mobile/src/components/VCard.js`
- `apps/mobile/src/components/VButton.js`
- `apps/mobile/src/components/VChip.js`
- `apps/mobile/src/components/VOptionChip.js`
- `apps/mobile/src/components/VInput.js`
- `apps/mobile/src/components/VSectionHeader.js`
- `apps/mobile/src/screens/HoyScreen.js`
- `apps/mobile/src/features/hoy/HoySummaryCard.js`
- `apps/mobile/src/features/hoy/TaskTimelineCard.js`

Prioridad media:

- `apps/mobile/src/screens/SummaryScreen.js`
- `apps/mobile/src/screens/ProfileScreen.js`

---

## 13. Orden de implementacion recomendado

1. `Theme`
2. `Primitives`
3. `Chrome`
4. `Hoy`
5. `Alineacion minima de Resumen y Perfil`

Regla:

no rehacer `Resumen` y `Perfil` en profundidad antes de cerrar `HOY`.

`HOY` debe convertirse en la pantalla patron de Vital.

---

## 14. Riesgos de V1

### 14.1 Riesgo: quedarse en un simple repaint

Mitigacion:

- medir V1 por claridad de uso, no solo por apariencia

### 14.2 Riesgo: meter demasiada logica demasiado pronto

Mitigacion:

- V1 se enfoca en representacion y operacion
- no intentar cerrar entorno real, estado diario y motor completo a la vez

### 14.3 Riesgo: perder el ADN Vento

Mitigacion:

- mantener estructura Vento en shell, jerarquia y componentes
- usar las referencias como inspiracion de rigor, no como clon visual

### 14.4 Riesgo: `Hoy` demasiado cargada

Mitigacion:

- una sola accion principal
- explicaciones cortas
- densidad alta pero controlada

---

## 15. Criterio de aceptacion final

`V1` se considera exitosa si:

- Vital cambia de personalidad de forma evidente
- la experiencia se siente mas tecnica y operativa
- `HOY` se vuelve util de inmediato
- el sistema visual queda consolidado
- la base queda lista para `V2` entorno real y `V3` estado diario

---

## 16. Lo que sigue despues de V1

Documentos siguientes sugeridos:

1. `VITAL-V2-SPEC.md`
   - perfiles de entorno
   - equipamiento disponible
   - categorias y seleccion real

2. `VITAL-CORE-MODEL.md`
   - `athlete_profile`
   - `sport_profile`
   - `environment_profile`
   - `daily_state`
   - `training_history`

Recomendacion:

cerrar primero V1 de forma fuerte y luego documentar `V2` con el mismo nivel de especificidad.
