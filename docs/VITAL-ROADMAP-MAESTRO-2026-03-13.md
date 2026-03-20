# Vento Vital - Roadmap Maestro 2026-03-13

Estado: `draft estrategico`

Owner: `Founder / producto`

Proposito: documentar la direccion maestra de `vento-vital` como sistema Vento de entrenamiento adaptativo, construido por versiones, sin perder el ideal de una aplicacion mucho mas completa, realista y ambiciosa.

---

## 1. Tesis del producto

Vento Vital no debe convertirse en "otra app de fitness" ni en una "app wellness bonita".

Vital debe convertirse en:

- un sistema operativo personal de entrenamiento y salud
- una app que entienda el contexto real de la persona
- una capa de decision diaria que sintetiza variables reales
- una experiencia Vento: clara, densa, operativa, sobria, explicable

La meta no es solo mostrar progreso.

La meta es responder, cada dia, preguntas como:

- que hago hoy
- por que hago eso
- que cambio por mi contexto real
- que se bloqueo por seguridad, fatiga o entorno
- cual es la mejor alternativa posible con lo que tengo

---

## 2. Ideal de la aplicacion perfecta

El ideal final de Vital es un sistema capaz de tener en cuenta:

- perfil base del usuario
- objetivo principal y objetivos secundarios
- deporte principal y deportes paralelos
- entorno real de entrenamiento
- equipamiento real disponible
- tiempo disponible del dia
- sueno, energia, estres y motivacion
- dolor, molestias, fatiga y readiness
- historial de carga y adherencia
- ciclo de entrenamiento
- interferencia entre fuerza, cardio y deporte
- recuperacion
- nutricion e hidratacion
- viaje, jet lag, clima y calor
- integraciones de salud y wearables
- importaciones externas
- explicacion humana de cada ajuste

Vital no tiene que lanzar todo eso al mismo tiempo.

Pero si debe nacer con una arquitectura que permita llegar ahi sin reescribir el producto cada dos semanas.

---

## 3. Lo que dicen las referencias visuales y de contenido

Las referencias de `assets/` no describen una app suave ni ornamental.

Describen una app:

- oscura
- tecnica
- densa
- muy operativa
- basada en listas y seleccion real
- enfocada en entorno, equipamiento, configuracion y accion

Tambien muestran un producto con contenido de alto nivel:

- actualizaciones del producto
- integraciones con salud y dispositivos
- importaciones
- analisis con IA
- perfiles de gimnasio
- seleccion de maquinas y herramientas reales
- modos distintos de crear entrenamiento

La conclusion es clara:

Vital debe mezclar dos cosas:

1. `estructura Vento`
2. `profundidad real de entrenamiento`

No se trata de copiar las pantallas.
Se trata de traducir su rigor al lenguaje Vento.

---

## 4. Principios no negociables

1. Claridad operativa diaria.
2. Personalizacion progresiva, no caos inicial.
3. Explicaciones visibles: nada de ajustes magicos.
4. Seguridad antes que agresividad.
5. El entorno real importa.
6. El estado diario importa.
7. La arquitectura debe soportar multiples deportes.
8. La primera gran version funcional debe enfocarse en entrenamiento adaptativo primero.
9. Nutricion, recuperacion e IA se integran por capas, no como ruido temprano.
10. Vital debe sentirse Vento, no plantilla fitness.

---

## 5. Fundamento externo que si conviene incorporar

La investigacion externa sugiere varias reglas base utiles para el producto:

- La progresion en fuerza e hipertrofia puede apoyarse en bases como ACSM, en vez de inventar una teoria propia desde cero.
- La autorregulacion (`RPE`, `APRE`, `VBT`) suele rendir mejor que un plan rigido ciego cuando el estado diario cambia.
- La interferencia entre fuerza y resistencia existe, asi que Vital debe contemplar secuencia, separacion y prioridad del estimulo.
- El sueno si afecta rendimiento, recuperacion, cognicion y riesgo.
- `HRV` puede servir como una senal mas, pero no debe tratarse como verdad absoluta.
- El ciclo menstrual debe tratarse como contexto de salud y sintomas, no como regla simplista universal.
- `session-RPE` y wellness questionnaires son utiles, pero deben individualizarse.
- La sustitucion por equipamiento debe preservar patron de movimiento y estimulo, no solo "mismo musculo".
- Riesgos como `RED-S`, dolor persistente, viaje, jet lag, calor, hidratacion y edad cambian decisiones reales.

Implicacion de producto:

Vital debe distinguir entre:

- variables realmente utiles para decidir
- variables aspiracionales que todavia no agregan valor suficiente

---

## 6. Arquitectura conceptual objetivo

Vital deberia crecer hacia estos modulos:

- `AthleteProfile`
- `SportProfile`
- `EnvironmentProfile`
- `DailyState`
- `TrainingHistory`
- `LoadEngine`
- `RoutineEngine`
- `RecoveryEngine`
- `ExplanationEngine`
- `IntegrationEngine`

Traduccion humana:

- quien eres
- que quieres
- que deporte haces
- donde entrenas
- con que entrenas
- como llegas hoy
- que has hecho antes
- que te conviene hoy
- por que te conviene eso

---

## 7. Variables por capas

### 7.1 Tier 1 - Imprescindibles

Estas son las variables que deberian entrar temprano porque cambian mucho la decision:

- objetivo principal
- experiencia
- deporte principal
- tiempo disponible
- entorno real
- equipamiento disponible
- sueno
- energia
- estres
- dolor o molestias
- adherencia reciente
- historial simple de sesiones

### 7.2 Tier 2 - Muy valiosas

- `HRV`
- resting HR
- disponibilidad semanal
- calendario competitivo
- fase del ciclo de entrenamiento
- hidratacion
- sintomas menstruales
- travel fatigue
- calor / humedad
- readiness subjetivo ampliado
- `session-RPE`

### 7.3 Tier 3 - Avanzadas

- `VBT`
- thresholds fisiologicos
- biomarcadores
- maduracion deportiva
- dolor multidominio muy profundo
- deteccion estructurada de `RED-S`
- contexto social y laboral mas amplio
- condiciones ambientales especiales

---

## 8. Roadmap maestro por versiones

## V1 - Base visual + nucleo de entrenamiento

### Objetivo

Cambiar la identidad completa de Vital y construir una base seria para entrenamiento adaptativo.

### Resultado esperado

- Vital deja de parecer una app wellness generica
- Vital se siente Vento
- `Hoy` se convierte en el centro operativo real
- la UI ya soporta listas, filtros, busqueda, estados y decisiones densas
- la base del sistema queda lista para crecer hacia multiples deportes

### Alcance funcional

- sistema visual oscuro, tecnico y operativo
- shell principal y navegacion mas claros
- componentes base consistentes
- `Hoy` como pantalla maestra
- claridad de estado, accion y explicacion
- preparacion para reglas de entrenamiento adaptativo

### Alcance tecnico sugerido

Puntos de entrada actuales:

- `apps/mobile/src/theme/vitalTheme.js`
- `apps/mobile/src/navigation/MainTabs.js`
- `apps/mobile/src/components/PageShell.js`
- `apps/mobile/src/components/VCard.js`
- `apps/mobile/src/components/VButton.js`
- `apps/mobile/src/components/VChip.js`
- `apps/mobile/src/components/VOptionChip.js`
- `apps/mobile/src/components/VInput.js`
- `apps/mobile/src/screens/HoyScreen.js`
- `apps/mobile/src/features/hoy/HoySummaryCard.js`
- `apps/mobile/src/features/hoy/TaskTimelineCard.js`

### Entregables de V1

1. `Design tokens` nuevos:
   - base oscura
   - acento Vital controlado
   - verde solo funcional
   - superficies, borders y estados semanticos

2. `Primitives` nuevas:
   - card
   - row
   - chip
   - input
   - button
   - search
   - toggle/check

3. `Chrome` Vento para Vital:
   - header
   - tabs
   - shell
   - jerarquia de app

4. `Hoy` replanteada:
   - estado del dia
   - siguiente accion
   - explicacion corta
   - timeline o lista operativa
   - progreso claro

5. `Guardrails` de producto:
   - no prometer precision cientifica con datos pobres
   - no tratar readiness como magia
   - no inventar ejercicios incompatibles con el entorno

### Criterio de aceptacion de V1

- se reconoce como producto Vento
- no parece clon de app fitness
- `Hoy` responde en segundos que hacer ahora
- la interfaz soporta complejidad sin verse blanda
- deja una base seria para entorno real y estado diario

---

## V2 - Entorno real de entrenamiento

### Objetivo

Hacer que Vital entienda donde y con que entrena la persona.

### Incluye

- perfiles de entrenamiento
- tipo de entorno
- nombre y color del perfil
- gimnasio grande / pequeno / casa / outdoor / otro
- equipamiento disponible
- maquinas especificas
- herramientas y recursos
- busqueda y seleccion por categoria
- activacion y desactivacion de items

### Valor

- las rutinas dejan de ser abstractas
- Vital puede aplicar sustituciones reales
- el sistema deja de proponer ejercicios imposibles

### Entidades candidatas

- `training_environment_profile`
- `equipment_category`
- `equipment_item_catalog`
- `profile_equipment_item`
- `profile_constraints`

### Criterio de aceptacion de V2

- un usuario puede modelar su entorno real
- el sistema sabe con que si y con que no puede trabajar
- la UI sigue siendo clara y operativa

---

## V3 - Estado diario real

### Objetivo

Hacer que Vital entienda como llega hoy la persona al entrenamiento.

### Incluye

- sueno
- energia
- estres
- dolor / molestias
- tiempo disponible
- adherencia reciente
- fatiga percibida
- readiness subjetivo

### Valor

- el sistema ya no decide solo por objetivo
- empieza a decidir por contexto del dia

### Criterio de aceptacion de V3

- `Hoy` cambia segun el estado diario
- el usuario entiende que el sistema lo escucha y no solo repite un plan

---

## V4 - Motor adaptativo y generacion de rutinas

### Objetivo

Generar sesiones y ajustes teniendo en cuenta objetivo, deporte, entorno y estado del dia.

### Debe responder

- que toca hoy
- por que toca eso
- que se ajusto
- que se bloqueo
- que alternativa conviene
- como influye el deporte principal
- como influye el entorno disponible

### Valor

- Vital deja de ser solo contenedor de datos
- se convierte en sistema de decision

### Criterio de aceptacion de V4

- rutina generada con explicacion
- sustituciones reales
- decisiones coherentes ante contextos distintos

---

## V5 - Expansion avanzada

### Objetivo

Acercarse al ideal completo sin perder claridad.

### Incluye

- soporte progresivo para muchos deportes
- recuperacion mas profunda
- nutricion e hidratacion como capas acopladas
- integraciones de salud y wearables
- importacion de entrenamientos
- IA para asistencia y analisis
- actualizaciones de producto y descubrimiento de funciones

### Criterio de aceptacion de V5

- Vital soporta mucha mas realidad sin colapsar UX
- la expansion agrega valor y no solo complejidad

---

## 9. Taxonomia inicial de deportes

Vital no debe nacer como "app de gym" aunque V1 se enfoque en entrenamiento.

Taxonomia inicial sugerida:

- `strength_hypertrophy`
- `general_fitness`
- `running_endurance`
- `cycling`
- `team_sports`
- `combat_sports`
- `hybrid_performance`

Esto no obliga a implementar todos ya.
Obliga a no romper la arquitectura para cuando lleguen.

---

## 10. Lo que Vital no debe hacer

- no tratar `HRV` como semaforo magico
- no aplicar reglas simplistas al ciclo menstrual
- no confundir mas datos con mejores decisiones
- no recomendar ejercicios incompatibles con el entorno
- no ignorar interferencia entre cardio, fuerza y deporte
- no saltarse seguridad cuando haya dolor, fatiga o red flags
- no volverse un dashboard bonito sin accion real

---

## 11. KPI de exito por etapa

### V1

- tiempo hasta entender "que hago hoy"
- uso de `Hoy`
- finalizacion de acciones del dia
- percepcion de claridad visual

### V2

- porcentaje de usuarios con entorno configurado
- numero de items de equipamiento registrados
- tasa de uso de perfiles

### V3

- tasa de completitud del check-in diario
- relacion entre estado reportado y ajuste realizado

### V4

- porcentaje de sesiones generadas que se completan
- uso de sustituciones
- adherencia tras ajustes

### V5

- uso de integraciones
- impacto percibido de IA
- retencion en usuarios avanzados

---

## 12. Decision estrategica final

La direccion correcta de Vital es:

- `arquitectura multisport desde el inicio`
- `primera gran version funcional enfocada en entrenamiento adaptativo`

Ese es el equilibrio correcto entre:

- ambicion real
- construccion por versiones
- vision de app perfecta
- capacidad de ejecucion

---

## 13. Siguiente paso recomendado

Despues de este roadmap maestro, el siguiente documento deberia ser uno de estos dos:

1. `VITAL-V1-SPEC.md`
   - especificacion exacta y ejecutable de V1
   - pantallas
   - componentes
   - estados
   - archivos a tocar

2. `VITAL-CORE-MODEL.md`
   - modelo maestro de datos y reglas
   - `athlete_profile`
   - `sport_profile`
   - `environment_profile`
   - `daily_state`
   - `training_history`

Recomendacion:

hacer primero `VITAL-V1-SPEC.md`, porque V1 es la puerta de entrada visible y debe quedar extremadamente clara antes de seguir.
