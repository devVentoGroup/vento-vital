# Vento Vital - V3 Spec 2026-03-13

Estado: `draft de ejecucion`

Depende de:

- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`
- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-V2-SPEC-2026-03-13.md`
- `docs/VITAL-CORE-MODEL-2026-03-13.md`

Objetivo de este documento: definir `V3` como la capa de estado diario real para que Vital deje de sugerir por objetivo solamente y empiece a decidir por contexto actual.

---

## 1. Objetivo exacto de V3

`V3` introduce la pregunta clave que vuelve vivo al sistema:

> "Como llegas hoy?"

Vital ya no debe depender solo de:

- objetivo
- deporte
- historial
- entorno

Tambien debe entender:

- sueño
- energia
- estres
- dolor o molestias
- tiempo disponible
- adherencia reciente
- readiness subjetivo

`V3` no construye todavia el motor completo.
Pero si construye la mejor fuente de contexto diario para que `V4` pueda decidir con criterio.

---

## 2. Resultado esperado al terminar V3

Cuando `V3` este bien implementada, Vital deberia poder:

- capturar un check-in diario rapido
- interpretar señales subjetivas utiles
- ajustar la lectura del dia sin volverse clinica ni pseudo-cientifica
- mostrar al usuario que el plan de hoy responde a su estado real
- dejar trazabilidad del estado diario para aprendizaje futuro

El usuario deberia sentir:

- "La app me esta leyendo hoy, no repitiendo un plan ciego"
- "No tengo que llenar 40 cosas para que me entienda"
- "Mis respuestas cambian de verdad lo que me conviene hacer"

---

## 3. No objetivos de V3

Para no inflar la fase, `V3` no debe incluir aun:

- HRV obligatorio
- integraciones complejas con wearables
- modelado clinico del dolor
- diagnostico medico
- interpretacion hormonal avanzada
- deteccion automatica robusta de RED-S
- inferencia perfecta del estado del sistema nervioso
- decisiones finales ultra complejas del plan

`V3` captura y organiza señales.
`V4` las convierte en decisiones fuertes.

---

## 4. North Star de UX

La experiencia base de `V3` debe sentirse asi:

> "En menos de un minuto la app entiende como llego hoy y usa eso para ajustar el dia."

Consecuencias practicas:

- check-in corto
- preguntas claras
- lenguaje no clínico
- escala subjetiva simple
- minimo esfuerzo
- impacto visible en `HOY`

---

## 5. Tesis de producto para V3

La mejor rutina del mundo falla si ignora el estado real del dia.

Dos dias con el mismo plan base pueden requerir decisiones distintas si cambia:

- el sueño
- la energia
- el estres
- el dolor
- el tiempo disponible
- la motivacion

Por eso `DailyState` no es un extra bonito.
Es uno de los dominios centrales del producto.

---

## 6. Variables de V3

## 6.1 Variables minimas obligatorias

Estas son las que si deben entrar en `V3`:

- `sleep_duration_hours`
- `sleep_quality`
- `energy_level`
- `stress_level`
- `motivation_level`
- `soreness_level`
- `pain_flag`
- `pain_locations`
- `time_available_min`
- `readiness_self_report`

## 6.2 Variables recomendadas si caben sin friccion

- `daily_schedule_context`
- `notes`
- `yesterday_session_rpe`
- `recovery_feel`

## 6.3 Variables postergadas para mas adelante

- `hrv_rmssd`
- `resting_hr`
- `hydration_status`
- `travel_fatigue`
- `jet_lag`
- `temperature_context`
- `menstrual_cycle_tracking`
- `red_s_risk_signal`

Estas se quedan preparadas conceptualmente, pero no son parte dura del primer alcance de `V3`.

---

## 7. Modelo de dato principal

## 7.1 `daily_state`

Campos conceptuales:

- `user_id`
- `date`
- `sleep_duration_hours`
- `sleep_quality`
- `energy_level`
- `stress_level`
- `motivation_level`
- `soreness_level`
- `pain_flag`
- `pain_locations`
- `time_available_min`
- `daily_schedule_context`
- `readiness_self_report`
- `notes`
- `created_at`
- `updated_at`

### Reglas

- un solo `daily_state` por usuario y por fecha
- debe poder actualizarse durante el mismo dia
- cambios relevantes deben refrescar lectura de `HOY`

## 7.2 `pain_location`

No hace falta un sistema medico complejo.

Lista inicial sugerida:

- `neck`
- `shoulder`
- `elbow`
- `wrist`
- `upper_back`
- `lower_back`
- `hip`
- `knee`
- `ankle`
- `other`

Regla:

el objetivo no es diagnosticar, sino modular elegibilidad y precaucion.

## 7.3 `readiness_summary`

Objeto derivado, no necesariamente persistido.

Campos conceptuales:

- `overall_state`
- `sleep_signal`
- `fatigue_signal`
- `pain_signal`
- `time_constraint_signal`
- `confidence_level`

Valores posibles de `overall_state`:

- `high_readiness`
- `stable`
- `reduced_capacity`
- `caution`

---

## 8. Pantallas de V3

## 8.1 `Check-in diario`

Pantalla o modal central de `V3`.

### Debe permitir responder rapido:

- cuanto dormiste
- como dormiste
- cuanta energia tienes
- cuanto estres tienes
- cuanto tiempo real tienes
- si tienes dolor o molestias
- como te sientes en general para entrenar

### Principio UX

Debe parecer:

- rapido
- serio
- util
- nada infantil

No debe parecer:

- encuesta eterna
- evaluación psicológica
- formulario clinico

## 8.2 `Dolor o molestias`

Subflujo corto.

### Debe permitir

- indicar si existe dolor
- marcar zona
- elegir severidad simple

### Regla

No convertir V3 en historia clinica.

## 8.3 `HOY` integrada con estado diario

`HOY` debe empezar a mostrar impacto del check-in.

### Debe reflejar

- que el dia fue leido
- que hay un estado general
- que algunas recomendaciones se ajustaron
- que hay una explicacion corta del ajuste

Ejemplos:

- `Capacidad reducida hoy`
- `Ajustado por sueño bajo`
- `Tiempo disponible: 30 min`

---

## 9. Flujo principal de usuario

1. abrir Vital
2. si no existe `daily_state` del dia, invitar a check-in
3. responder check-in rapido
4. guardar estado del dia
5. recalcular la lectura de `HOY`
6. mostrar resumen corto del impacto

Flujo alterno:

1. usuario ya hizo check-in
2. entra a `HOY`
3. edita su estado
4. el sistema refresca contexto

---

## 10. Reglas de negocio de V3

## 10.1 Reglas de completitud

- no todas las variables son obligatorias
- el sistema debe funcionar con datos parciales
- si falta informacion, no debe inventar precision

## 10.2 Reglas de prioridad

Las señales del dia no pesan igual.

Jerarquia inicial sugerida:

1. dolor / red flags
2. tiempo disponible
3. sueño
4. energia
5. estres
6. motivacion

## 10.3 Reglas de impacto futuro

Estas reglas pueden empezar simples:

- sueño muy bajo reduce ambicion del dia
- energia baja reduce agresividad
- dolor relevante limita elegibilidad
- poco tiempo cambia el formato de sesion
- estres alto puede reducir volumen o complejidad

## 10.4 Reglas de degradacion elegante

Si el usuario no hace check-in:

- Vital debe seguir funcionando
- usar ultimo contexto disponible solo con cuidado
- no fingir lectura diaria inexistente

---

## 11. Escalas sugeridas

Para mantener consistencia:

### 11.1 Escalas 1 a 5

Usar para:

- calidad de sueño
- energia
- estres
- motivacion
- soreness
- readiness

Interpretacion base:

- `1`: muy bajo / muy mal
- `2`: bajo
- `3`: medio
- `4`: bueno
- `5`: muy bueno / muy alto

### 11.2 Tiempo disponible

Opciones sugeridas:

- `15 min o menos`
- `20-30 min`
- `30-45 min`
- `45-60 min`
- `60+ min`

### 11.3 Dolor

Escala simple:

- `sin dolor`
- `molestia leve`
- `molestia moderada`
- `dolor relevante`

---

## 12. Interpretacion inicial del estado

`V3` no debe dar una puntuacion pseudo-cientifica cerrada.

Debe hacer una lectura simple y explicable.

### Ejemplo de lectura

#### Caso A

- sueño bueno
- energia buena
- estres bajo
- sin dolor
- tiempo suficiente

Resultado:

- `high_readiness`

#### Caso B

- sueño bajo
- energia media
- estres alto
- tiempo corto

Resultado:

- `reduced_capacity`

#### Caso C

- dolor de rodilla moderado
- energia buena
- tiempo suficiente

Resultado:

- `caution`

Porque hay una restriccion localizada que puede bloquear parte del plan.

---

## 13. Integracion con V2 y V4

## 13.1 Integracion con `EnvironmentProfile`

V2 + V3 juntos permiten cosas como:

- hoy tienes 25 minutos
- estas en hotel
- energia baja

Eso cambia radicalmente lo que conviene hacer.

## 13.2 Integracion con `RoutineEngine`

`V4` debera usar:

- `DailyState`
- `EnvironmentProfile`
- `SportProfile`
- `TrainingHistory`

Para decidir:

- formato de sesion
- duracion
- intensidad
- ejercicios elegibles
- ajustes y explicacion

---

## 14. Impacto minimo visible en producto

Aunque `V4` aun no exista completa, `V3` ya debe mostrar impacto visible.

Ejemplos minimos:

- etiqueta de estado del dia
- aviso de capacidad reducida
- nota breve de ajuste
- CTA ajustada a tiempo disponible

No basta con guardar el dato.
Debe sentirse en la experiencia.

---

## 15. Reglas de UX visual para V3

`V3` debe heredar la direccion de `V1`.

### Debe sentirse

- rapido
- tecnico
- util
- nada melodramatico

### Debe evitar

- demasiados sliders
- mucho texto explicativo
- tono pseudo-terapeutico
- interfaz de encuesta pesada

### Regla de diseño

Cada input del check-in debe merecer su lugar porque cambia una decision futura.

Si una variable no cambia nada, no deberia estar en el check-in.

---

## 16. Archivos y zonas probables de implementacion

UI actual a tocar o extender:

- `apps/mobile/src/screens/HoyScreen.js`
- `apps/mobile/src/screens/ProfileScreen.js` si se usa como punto de edicion
- nuevas surfaces dentro de `apps/mobile/src/screens/`
- nuevas features dentro de `apps/mobile/src/features/`
- `apps/mobile/src/components/`
- `apps/mobile/src/theme/vitalTheme.js`

Modelo y contratos futuros:

- `packages/contracts`
- `supabase` o API correspondiente

---

## 17. Orden de implementacion recomendado

1. definir `daily_state`
2. crear check-in diario rapido
3. crear subflujo de dolor / molestias
4. persistir y editar el estado del dia
5. integrar lectura minima en `HOY`
6. mostrar explicacion corta del impacto

Regla:

no esperar a `V4` para que `V3` tenga algun efecto visible.

---

## 18. Riesgos de V3

### 18.1 Riesgo: demasiada friccion

Mitigacion:

- limitar preguntas
- respuestas rapidas
- evitar campos largos

### 18.2 Riesgo: falsa precision

Mitigacion:

- no usar un score cientifico artificial
- explicar ajustes en lenguaje sencillo

### 18.3 Riesgo: datos sin efecto real

Mitigacion:

- asegurar impacto visible minimo en `HOY`

### 18.4 Riesgo: complejidad emocional innecesaria

Mitigacion:

- tono funcional
- no convertir el check-in en terapia ni medicina

---

## 19. Criterio de aceptacion final

`V3` se considera exitosa si:

- el usuario puede registrar su estado del dia rapidamente
- el sistema usa ese estado para cambiar la lectura de `HOY`
- el ajuste se entiende de forma humana
- la experiencia sigue siendo ligera y Vento
- Vital se acerca a una decision contextual real

---

## 20. Lo que sigue despues de V3

Documentos siguientes sugeridos:

1. `VITAL-DECISION-RULES-v1.md`
   - reglas iniciales del motor
   - bloqueos
   - elegibilidad
   - ajustes por tiempo, sueño, dolor y energia

2. `VITAL-V4-SPEC.md`
   - generacion adaptativa
   - sustituciones
   - explicacion de decisiones

Recomendacion:

despues de `V3`, el siguiente documento mas importante es `VITAL-DECISION-RULES-v1.md`, porque ahi Vital deja de ser solo captura de contexto y empieza a decidir de verdad.
