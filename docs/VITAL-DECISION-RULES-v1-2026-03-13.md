# Vento Vital - Decision Rules v1 2026-03-13

Estado: `draft estructural`

Depende de:

- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`
- `docs/VITAL-CORE-MODEL-2026-03-13.md`
- `docs/VITAL-V2-SPEC-2026-03-13.md`
- `docs/VITAL-V3-SPEC-2026-03-13.md`

Proposito: definir el primer set de reglas del motor de decision de Vital para que el sistema empiece a ajustar entrenamiento de forma explicable segun contexto real.

---

## 1. Objetivo de este documento

Vital no debe decidir con una sola puntuacion magica.

Debe decidir por capas:

- seguridad
- elegibilidad
- entorno
- estado diario
- objetivo
- deporte
- sostenibilidad

Este documento define la primera version de esas reglas.

No busca precision final.
Busca un sistema:

- util
- claro
- defendible
- escalable

---

## 2. Principios del motor

1. Seguridad primero.
2. Si faltan datos, degradar con elegancia.
3. Una restriccion dura pesa mas que cinco señales blandas.
4. El entorno real limita la seleccion.
5. El estado diario modula carga, duracion y complejidad.
6. El objetivo define direccion, no obliga a ignorar la realidad.
7. El deporte principal cambia prioridades e interferencias.
8. Toda decision importante debe poder explicarse en una frase.

---

## 3. Orden de evaluacion

Vital debe evaluar en este orden:

1. `SafetyGate`
2. `EligibilityGate`
3. `EnvironmentFit`
4. `TimeFit`
5. `DailyStateAdjustment`
6. `GoalAlignment`
7. `SportAlignment`
8. `LoadSustainability`
9. `Explanation`

Regla central:

una capa posterior no puede contradecir una capa anterior sin justificacion explicita.

---

## 4. Tipos de salida del motor

Cada decision relevante debe impactar una o varias de estas salidas:

- `session_type`
- `session_duration_min`
- `intensity_adjustment`
- `volume_adjustment`
- `exercise_selection`
- `exercise_exclusions`
- `alternative_options`
- `recovery_priority`
- `explanation_summary`

---

## 5. Capa 1 - SafetyGate

## 5.1 Objetivo

Bloquear o reducir el plan cuando existan señales que hagan inseguro el estimulo original.

## 5.2 Entradas esperadas

- `medical_flags`
- `pain_flag`
- `pain_locations`
- `red_flags`
- `recent_injury_context`
- `return_to_training_status`

## 5.3 Reglas iniciales

### Regla S1

Si hay `red_flags` mayores:

- bloquear sesion intensa
- devolver estado `blocked`
- recomendar accion conservadora o consulta profesional

### Regla S2

Si hay dolor relevante en una zona critica:

- excluir patrones directamente relacionados
- bajar complejidad tecnica
- priorizar alternativa compatible

Ejemplos:

- dolor de rodilla -> cuidado con `squat`, `single_leg`, impacto alto
- dolor lumbar -> cuidado con `hinge` cargado y estabilidad demandante
- dolor de hombro -> cuidado con `vertical_push`, `horizontal_push` y rangos agresivos

### Regla S3

Si la persona esta en retorno progresivo:

- limitar volumen
- limitar intensidad
- priorizar tolerancia y control

---

## 6. Capa 2 - EligibilityGate

## 6.1 Objetivo

Definir que tipos de sesion y patrones estan permitidos hoy.

## 6.2 Entradas esperadas

- `AthleteProfile`
- `pain_locations`
- `experience_level`
- `movement_limitations`
- `return_to_training_status`

## 6.3 Reglas iniciales

### Regla E1

Si el usuario es principiante:

- reducir complejidad tecnica
- priorizar patrones basicos y estables
- evitar exceso de volumen accesorio

### Regla E2

Si hay limitacion de movimiento conocida:

- excluir variantes que dependan de ella
- elegir patron equivalente mas estable

### Regla E3

Si la confianza o adherencia son bajas:

- reducir ambicion de la sesion
- aumentar probabilidad de cumplimiento

---

## 7. Capa 3 - EnvironmentFit

## 7.1 Objetivo

Adaptar la sesion a recursos reales.

## 7.2 Entradas esperadas

- `training_environment_profile`
- `profile_equipment_item`
- `profile_constraints`

## 7.3 Reglas iniciales

### Regla ENV1

Si un ejercicio requiere equipamiento no disponible:

- excluirlo de la seleccion primaria
- buscar sustitucion por patron de movimiento y estimulo

### Regla ENV2

Si el entorno es `hotel` o `limited_access`:

- priorizar sesiones cortas
- priorizar bodyweight, bandas, cardio simple o implementos disponibles

### Regla ENV3

Si el entorno es `full_gym`:

- permitir seleccion mas especifica por objetivo
- usar maquinas y variantes mas finas cuando ayuden a adherencia o seguridad

### Regla ENV4

Si el entorno es `home_gym`:

- balancear especificidad y practicidad
- evitar transiciones absurdas o requerimientos imposibles

---

## 8. Capa 4 - TimeFit

## 8.1 Objetivo

Adaptar el formato de la sesion al tiempo real.

## 8.2 Entradas esperadas

- `time_available_min`

## 8.3 Reglas iniciales

### Regla T1

Si `time_available_min <= 15`:

- devolver micro-sesion o accion minima viable
- foco unico
- cero complejidad innecesaria

### Regla T2

Si `time_available_min` esta entre `20-30`:

- sesion corta
- 1 foco principal
- pocos ejercicios
- densidad alta

### Regla T3

Si `time_available_min` esta entre `30-45`:

- sesion estandar reducida
- 1 foco principal + 1 complemento

### Regla T4

Si `time_available_min >= 45`:

- permitir sesion completa segun objetivo y estado

Regla global:

el tiempo disponible puede recortar volumen y complejidad, pero no debe destruir siempre el objetivo.

---

## 9. Capa 5 - DailyStateAdjustment

## 9.1 Objetivo

Traducir el estado del dia en ajustes concretos.

## 9.2 Entradas esperadas

- `sleep_duration_hours`
- `sleep_quality`
- `energy_level`
- `stress_level`
- `motivation_level`
- `soreness_level`
- `pain_flag`
- `readiness_self_report`

## 9.3 Reglas iniciales

### Regla D1 - Sueño bajo

Si el sueño es muy bajo:

- bajar agresividad del dia
- reducir volumen o intensidad
- evitar complejidad tecnica innecesaria

### Regla D2 - Energia baja

Si la energia es baja:

- reducir la ambicion
- mantener consistencia
- preferir sesion sostenible a sesion perfecta

### Regla D3 - Estres alto

Si el estres es alto:

- reducir complejidad
- evitar exceso de carga interna
- favorecer claridad, estructura y cierre rapido

### Regla D4 - Soreness alto

Si hay soreness alto localizado:

- evitar repetir el mismo foco intenso
- mover la prioridad a una alternativa viable

### Regla D5 - Motivacion muy baja

Si la motivacion es muy baja pero no hay riesgo:

- reducir barrera de entrada
- sugerir sesion minima viable
- priorizar continuidad sobre optimizacion

### Regla D6 - Readiness alta

Si varias señales estan altas y no hay restricciones:

- permitir mantener o subir ligeramente la exigencia

---

## 10. Capa 6 - GoalAlignment

## 10.1 Objetivo

Mantener la direccion correcta segun el objetivo principal.

## 10.2 Objetivos base

- `fat_loss`
- `hypertrophy`
- `strength`
- `general_fitness`
- `sport_performance`
- `maintenance`

## 10.3 Reglas iniciales

### Regla G1 - Fat loss

- priorizar consistencia, gasto util y adherencia
- no sacrificar recuperacion de forma absurda

### Regla G2 - Hypertrophy

- preservar volumen efectivo siempre que el contexto lo permita
- si el dia viene malo, reducir sin romper completamente el estimulo

### Regla G3 - Strength

- proteger calidad de esfuerzos importantes
- si el dia esta malo, preferir tecnica, submaximos o variantes estables

### Regla G4 - General fitness

- priorizar sostenibilidad y equilibrio

### Regla G5 - Maintenance

- minimizador de carga innecesaria
- mantener capacidad con bajo costo

---

## 11. Capa 7 - SportAlignment

## 11.1 Objetivo

Hacer que la sesion sea coherente con el deporte principal y sus interferencias.

## 11.2 Entradas esperadas

- `primary_sport`
- `secondary_sports`
- `competition_calendar`
- `season_phase`

## 11.3 Reglas iniciales

### Regla SP1

Si el deporte principal requiere alto componente de resistencia:

- controlar interferencia con fuerza pesada de tren inferior

### Regla SP2

Si hay partido, competencia o evento cercano:

- reducir costo de fatiga
- priorizar frescura y especificidad

### Regla SP3

Si el perfil es `hybrid`:

- evitar picos simultaneos de fuerza y resistencia sin sentido
- definir prioridad del dia

### Regla SP4

Si el deporte principal es de equipo:

- considerar carga externa del calendario antes de insistir en fuerza alta

---

## 12. Capa 8 - LoadSustainability

## 12.1 Objetivo

Evitar que una buena decision para hoy sea mala para la semana.

## 12.2 Entradas esperadas

- historial reciente
- `session_rpe`
- sesiones completadas
- sesiones omitidas
- tendencia de fatiga
- adherencia

## 12.3 Reglas iniciales

### Regla L1

Si la adherencia reciente es baja:

- reducir complejidad del plan
- priorizar recuperacion de constancia

### Regla L2

Si la carga reciente fue alta:

- evitar sumar otra sesion alta sin justificacion

### Regla L3

Si el usuario viene de varios dias sin entrenar:

- no intentar compensar con una sesion excesiva
- usar reentrada progresiva

### Regla L4

Si la respuesta reciente fue mala:

- no repetir el mismo formato sin cambios

---

## 13. Reglas de sustitucion

Vital debe sustituir por:

1. patron de movimiento
2. estimulo dominante
3. costo de fatiga
4. complejidad tecnica
5. equipamiento disponible

No debe sustituir solo por:

- grupo muscular parecido
- intuicion superficial

### Ejemplos

#### SUST1

Si no hay `leg_press` pero si hay `smith_machine`:

- considerar variante de squat estable en smith

#### SUST2

Si no hay polea para jalon pero si bandas:

- considerar jalon con bandas o variante de pull compatible

#### SUST3

Si no hay air bike pero si remo o ski erg:

- buscar sustituto de demanda energetica similar

---

## 14. Tipos de decision que el motor debe producir

Cada dia el motor debe poder decidir entre:

- `maintain_plan`
- `reduce_volume`
- `reduce_intensity`
- `swap_exercises`
- `shorten_session`
- `switch_focus`
- `recovery_day`
- `minimum_viable_session`
- `block_session`

---

## 15. Formato de explicacion

Toda decision importante debe poder resumirse asi:

### Plantilla corta

`Accion + motivo principal + condicion secundaria`

Ejemplos:

- `Reduje volumen por sueño bajo y estrés alto`
- `Cambié ejercicios por entorno limitado`
- `Prioricé tren superior por dolor de rodilla`
- `Mantuve el plan porque tu estado de hoy es estable`
- `Sugerí una sesión corta porque solo tienes 20 minutos`

Regla:

una explicacion larga puede existir en detalle, pero la UI diaria necesita una version corta.

---

## 16. Degradacion elegante

Si faltan datos:

### Caso A - falta `DailyState`

- usar plan base
- no afirmar que se hizo ajuste contextual del dia

### Caso B - falta `EnvironmentProfile`

- usar contexto mas general o perfil primario
- marcar baja confianza en sustituciones

### Caso C - historial insuficiente

- usar reglas conservadoras
- evitar sobreajuste

---

## 17. Guardrails del motor

- no emitir diagnosticos
- no asumir causalidad perfecta
- no usar HRV como arbitro unico
- no forzar intensidad alta en contexto pobre
- no usar reglas rigidas del ciclo menstrual
- no compensar sesiones perdidas con castigo posterior
- no privilegiar optimizacion sobre adherencia sostenible

---

## 18. Salidas minimas visibles en producto

Aunque el motor sea simple al inicio, ya debe poder generar:

- una accion principal
- una explicacion corta
- una o dos exclusiones relevantes
- una alternativa si el plan original no aplica
- una etiqueta de estado del dia

---

## 19. Versionado de reglas

Este documento define `v1` de reglas.

Principio:

- empezar simple
- medir comportamiento
- ajustar con evidencia de uso real

No intentar construir un motor perfecto solo en papel.

---

## 20. Siguiente paso recomendado

Documentos siguientes sugeridos:

1. `VITAL-V4-SPEC.md`
   - aterrizar el motor adaptativo como producto y UI

2. `VITAL-DOMAIN-SCHEMA-v1.md`
   - traducir este modelo a tablas, enums y contratos iniciales

3. `VITAL-EXERCISE-CATALOG-SPEC.md`
   - patrones de movimiento
   - tags de estimulo
   - reglas de sustitucion
