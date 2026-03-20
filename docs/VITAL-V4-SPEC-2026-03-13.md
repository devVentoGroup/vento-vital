# Vento Vital - V4 Spec 2026-03-13

Estado: `draft de ejecucion`

Depende de:

- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`
- `docs/VITAL-CORE-MODEL-2026-03-13.md`
- `docs/VITAL-V2-SPEC-2026-03-13.md`
- `docs/VITAL-V3-SPEC-2026-03-13.md`
- `docs/VITAL-DECISION-RULES-v1-2026-03-13.md`

Objetivo de este documento: definir `V4` como la primera version visible del motor adaptativo de Vital, donde el sistema ya no solo captura contexto sino que genera, ajusta y explica decisiones de entrenamiento.

---

## 1. Objetivo exacto de V4

`V4` es la fase en la que Vital empieza a comportarse como sistema de decision real.

La pregunta que responde es:

> "Dado tu objetivo, tu deporte, tu entorno, tu estado del dia y tu historial reciente, que te conviene hacer hoy y por que?"

`V4` no busca perfeccion cientifica total.
Busca un motor:

- util
- coherente
- explicable
- adaptable
- visible en producto

---

## 2. Resultado esperado al terminar V4

Cuando `V4` este bien implementada, Vital deberia poder:

- generar una sesion del dia con foco y formato claros
- ajustar duracion, intensidad, volumen y seleccion de ejercicios
- excluir opciones incompatibles
- proponer alternativas validas
- explicar por que ajusto el plan
- reflejar ese ajuste dentro de `HOY` y `Resumen`

El usuario deberia sentir:

- "La app no solo guarda datos: decide conmigo"
- "La recomendacion de hoy tiene sentido"
- "Puedo entender por que me cambió el plan"

---

## 3. No objetivos de V4

Para contener la fase, `V4` no debe incluir aun:

- un motor perfecto para todos los deportes al mismo nivel
- optimizacion avanzada con wearables obligatorios
- simulacion fisiologica compleja
- IA generativa como base del sistema
- coaching conversacional total
- periodizacion anual extremadamente profunda

`V4` debe ser el primer motor fuerte.
No el ultimo motor posible.

---

## 4. North Star de UX

La experiencia base de `V4` debe sentirse asi:

> "Vital me dio una recomendacion clara, posible y coherente con mi dia real."

Consecuencias practicas:

- una accion principal clara
- una explicacion corta y visible
- pocas decisiones esenciales
- buena sensacion de control
- posibilidad de ver alternativas sin perder simplicidad

---

## 5. Tesis de producto para V4

La adaptacion real no consiste en decir "hoy estas al 73%".

Consiste en traducir contexto en decisiones utiles como:

- mantener el plan
- acortar la sesion
- cambiar el foco
- sustituir ejercicios
- bajar intensidad
- pasar a una sesion minima viable
- priorizar recuperacion
- bloquear una parte del plan

Por eso `V4` no es una pantalla nueva.
Es la capa que reorganiza el comportamiento del producto.

---

## 6. Que debe decidir el motor en V4

Cada dia, como minimo, el motor debe resolver:

- `session_type`
- `primary_focus`
- `recommended_duration_min`
- `intensity_adjustment`
- `volume_adjustment`
- `exercise_selection`
- `exercise_exclusions`
- `alternative_options`
- `recovery_priority`
- `explanation_summary`

Tipos iniciales de sesion sugeridos:

- `main_training`
- `short_session`
- `recovery_session`
- `minimum_viable_session`
- `technique_session`
- `cardio_session`
- `blocked_or_caution`

---

## 7. Objetos principales de salida

## 7.1 `TodayPlan`

Campos conceptuales:

- `date`
- `overall_state`
- `session_type`
- `primary_focus`
- `secondary_focus_optional`
- `recommended_duration_min`
- `intensity_adjustment`
- `volume_adjustment`
- `recommended_structure`
- `explanation_summary`
- `caution_flags`
- `task_list`
- `alternative_options`

## 7.2 `RecommendedStructure`

Define la forma de la sesion.

Campos conceptuales:

- `warmup_required`
- `main_block_count`
- `accessory_block_count`
- `conditioning_block_optional`
- `recovery_block_optional`

## 7.3 `AlternativeOption`

Permite mostrar salidas viables sin rehacer todo manualmente.

Campos conceptuales:

- `type`
- `title`
- `reason`
- `estimated_duration_min`

Ejemplos:

- `sesion corta`
- `cardio compatible`
- `movilidad y recuperacion`
- `variante en casa`

---

## 8. Pantallas y superficies impactadas por V4

## 8.1 `HOY`

Es la superficie principal de `V4`.

Debe mostrar de forma visible:

- lectura del estado del dia
- foco principal de hoy
- siguiente accion recomendada
- explicacion corta del ajuste
- estructura o tipo de sesion sugerida
- lista/timeline de tareas adaptadas
- opcion de ver alternativa

### Nueva jerarquia sugerida en `HOY`

1. `Estado del dia`
2. `Que toca hoy`
3. `Por que cambio / por que se mantiene`
4. `Siguiente accion`
5. `Lista adaptada`
6. `Alternativas`

## 8.2 `Resumen`

Debe empezar a explicar no solo que pasó, sino:

- como se ajusto la semana
- cuantas sesiones fueron adaptadas
- si hubo reducciones por fatiga o tiempo
- donde hubo baja adherencia

## 8.3 `Perfil`

Debe exponer de forma simple:

- objetivo principal
- deporte principal
- perfil de entorno activo
- nivel de personalizacion o modo del sistema

No tiene que enseñar todo el motor, pero si sus entradas maestras.

---

## 9. Estructura visible de `HOY` en V4

## 9.1 Estado del dia

Bloque corto que resume el contexto:

- `Listo para empujar`
- `Estado estable`
- `Capacidad reducida`
- `Precaucion hoy`

No usar scores pseudo-cientificos cerrados como centro de experiencia.

## 9.2 Que toca hoy

Debe responder con una frase clara:

- `Fuerza tren superior`
- `Sesion corta de hipertrofia`
- `Cardio compatible y bajo costo`
- `Recuperacion activa`

## 9.3 Por que hoy se ve asi

Bloque de explicacion corta.

Ejemplos:

- `Ajustado por sueño bajo y 25 minutos disponibles`
- `Se evitó pierna pesada por dolor de rodilla`
- `Se mantuvo fuerza porque tu estado y entorno son favorables`

## 9.4 Siguiente accion

CTA principal:

- `Empezar sesión`
- `Completar bloque principal`
- `Hacer versión corta`
- `Actualizar estado de hoy`

## 9.5 Lista adaptada

Cada item debe poder reflejar:

- prioridad
- razon
- exclusion o sustitucion si aplica
- accion

## 9.6 Alternativas

Debe existir al menos una salida alternativa visible cuando el dia se estrecha.

Ejemplos:

- `Version de 20 min`
- `Solo cardio hoy`
- `Mover a mañana`
- `Recuperacion activa`

---

## 10. Reglas de comportamiento visibles

## 10.1 Mantener plan

Si el estado es estable y no hay restricciones:

- mantener foco
- mantener estructura base
- explicacion corta: `Tu contexto de hoy permite mantener el plan`

## 10.2 Reducir volumen

Si hay sueño bajo, estres alto o carga reciente elevada:

- bajar series o bloques accesorios
- mantener foco principal si es viable

## 10.3 Reducir intensidad

Si hay baja energia, fatiga o contexto delicado:

- usar cargas o esfuerzo percibido mas bajos
- evitar maximos y complejidad agresiva

## 10.4 Acortar sesion

Si el tiempo disponible es bajo:

- condensar estructura
- preservar lo mas importante del objetivo

## 10.5 Cambiar foco

Si una restriccion bloquea el foco original:

- mover la prioridad a otro bloque compatible

Ejemplo:

- hoy no pierna pesada
- pasar a upper, tecnica o recuperacion

## 10.6 Sustituir ejercicios

Si el entorno no permite el plan original:

- sustituir por patron y estimulo similar
- mantener explicacion visible

## 10.7 Sesion minima viable

Si motivacion, tiempo o contexto son muy bajos pero no hay riesgo:

- ofrecer una victoria pequeña
- priorizar adherencia

## 10.8 Recuperacion o precaucion

Si el contexto es claramente desfavorable:

- recomendar una sesion conservadora o de recuperacion

## 10.9 Bloqueo

Si el contexto supera el umbral de seguridad:

- bloquear parte del plan
- mostrar por que
- ofrecer alternativa segura

---

## 11. Modo de explicacion

Vital debe explicar a dos niveles:

### 11.1 Nivel corto

Una frase visible en `HOY`.

Ejemplos:

- `Reducido por sueño bajo y estrés alto`
- `Adaptado al entorno actual`
- `Se mantuvo por contexto estable`

### 11.2 Nivel extendido

Detalle opcional si el usuario quiere entender mas.

Ejemplos:

- `Dormiste poco, reportaste energía media y solo tienes 25 min. Por eso mantuvimos el foco principal pero redujimos accesorios.`

Regla:

la app no debe esconder el razonamiento, pero tampoco debe convertir cada dia en una auditoria larga.

---

## 12. Integracion con `DailyState`, `EnvironmentProfile` y `SportProfile`

`V4` es la fase donde esos dominios por fin trabajan juntos.

### 12.1 Ejemplo de combinacion

- objetivo: hipertrofia
- deporte principal: running
- entorno: hotel
- tiempo: 20 min
- sueño: bajo

Resultado esperado:

- no sesion pesada de pierna
- opcion corta y compatible
- explicacion corta por interferencia + contexto

### 12.2 Otro ejemplo

- objetivo: fuerza
- deporte principal: general fitness
- entorno: full gym
- energia: alta
- sueño: bueno
- sin dolor

Resultado esperado:

- mantener plan principal
- permitir sesion mas exigente

---

## 13. Integracion con historial

El historial no debe quedarse para despues del todo.

En `V4` ya debe usarse al menos para:

- adherencia reciente
- sesiones omitidas
- carga reciente simple
- ultimo `session_rpe` si existe
- respuesta reciente negativa

Reglas simples de impacto:

- baja adherencia -> bajar ambicion
- varias sesiones omitidas -> reentrada progresiva
- carga reciente alta -> evitar acumulacion absurda

---

## 14. Reglas visuales para V4

`V4` debe heredar `V1`.

### Debe sentirse

- claro
- tecnico
- seguro
- confiable
- poco teatrero

### Debe evitar

- gamificacion excesiva
- scores misteriosos
- dashboards sobrecargados
- jerga pseudo-cientifica

### Regla de diseño central

Cada ajuste visible debe tener:

- accion
- motivo
- alternativa si hace falta

---

## 15. Archivos y zonas probables de implementacion

UI y composicion:

- `apps/mobile/src/screens/HoyScreen.js`
- `apps/mobile/src/features/hoy/`
- `apps/mobile/src/screens/SummaryScreen.js`
- `apps/mobile/src/screens/ProfileScreen.js`
- `apps/mobile/src/components/`
- `apps/mobile/src/theme/vitalTheme.js`

Modelo y contratos:

- `packages/contracts`
- capa API / `supabase`

Motor:

- nueva capa de presentacion o decision dentro de `apps/mobile/src/features/`
- o capa server-side si luego se decide mover reglas

---

## 16. Orden de implementacion recomendado

1. definir objeto `TodayPlan`
2. conectar entradas minimas del motor
3. devolver salida base con explicacion corta
4. integrar estado y foco en `HOY`
5. integrar lista adaptada
6. agregar alternativas
7. reflejar resumen de ajustes en `Resumen`

Regla:

primero hacer que el motor se vea y se entienda.
Luego refinar profundidad.

---

## 17. Riesgos de V4

### 17.1 Riesgo: caja negra

Mitigacion:

- explicacion corta obligatoria
- alternativa visible cuando aplique

### 17.2 Riesgo: demasiadas decisiones para el usuario

Mitigacion:

- una sola accion principal
- alternativas secundarias, no competencia simultanea

### 17.3 Riesgo: demasiada ambicion

Mitigacion:

- empezar por reglas simples y defensibles
- iterar con evidencia real

### 17.4 Riesgo: el motor cambie demasiado y genere desconfianza

Mitigacion:

- ajustes graduales
- explicaciones consistentes
- evitar giros bruscos sin motivo visible

---

## 18. Criterio de aceptacion final

`V4` se considera exitosa si:

- Vital ya ajusta el plan del dia con contexto real
- la recomendacion principal es clara y posible
- el usuario entiende por que el plan se mantuvo o cambió
- el producto da sensacion de sistema, no de formulario con resultados
- `HOY` se convierte en la expresion visible del motor adaptativo

---

## 19. Lo que sigue despues de V4

Documentos siguientes sugeridos:

1. `VITAL-V5-SPEC.md`
   - expansion avanzada
   - mas deportes
   - integraciones
   - recuperacion y nutricion mas profundas

2. `VITAL-DOMAIN-SCHEMA-v1.md`
   - traduccion del core model a estructuras implementables

3. `VITAL-EXERCISE-CATALOG-SPEC.md`
   - catalogo de ejercicios
   - patrones
   - tags de estimulo
   - reglas de sustitucion

Recomendacion:

despues de `V4`, el documento mas estrategico es `VITAL-EXERCISE-CATALOG-SPEC.md`, porque sin un catalogo bien modelado el motor tendra limites muy rapido.
