# Vento Vital - Session Handoff

Estado: `vivo`

Ultima actualizacion: `2026-03-13`

Proposito: ser el punto de entrada principal para cualquier nueva conversacion o agente que vaya a trabajar sobre Vital.

---

## 1. Estado actual

Vital ya tiene una base documental fuerte.

El proyecto no esta arrancando desde cero.
Ya existe una direccion de producto, una arquitectura conceptual, specs por version, reglas iniciales del motor, taxonomia de catalogo y un schema de dominio implementable.

La linea maestra actual es:

- Vital debe sentirse Vento, no plantilla fitness
- Vital debe construirse por versiones
- la primera gran version funcional sigue enfocada en entrenamiento adaptativo
- la arquitectura debe nacer preparada para multiples deportes
- el entorno real y el estado diario son dominios de primer orden

---

## 2. Fuentes de verdad principales

Leer primero:

- `docs/VITAL-DOCS-INDEX.md`
- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`

Segun la tarea, leer despues:

- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-V1-IMPLEMENTATION-CHECKLIST-2026-03-13.md`
- `docs/VITAL-V1-QA-CHECKLIST-2026-03-13.md`
- `docs/VITAL-SCREEN-STATES-v1-2026-03-13.md`
- `docs/VITAL-V2-SPEC-2026-03-13.md`
- `docs/VITAL-V3-SPEC-2026-03-13.md`
- `docs/VITAL-V4-SPEC-2026-03-13.md`
- `docs/VITAL-API-CONTRACTS-v1-2026-03-13.md`
- `docs/VITAL-CORE-MODEL-2026-03-13.md`
- `docs/VITAL-DECISION-RULES-v1-2026-03-13.md`
- `docs/VITAL-EXERCISE-CATALOG-SPEC-2026-03-13.md`
- `docs/VITAL-CATALOG-SEED-v1-2026-03-13.md`
- `docs/VITAL-CATALOG-SEED-DATA-v1-2026-03-13.md`
- `docs/VITAL-DOMAIN-SCHEMA-v1-2026-03-13.md`

---

## 3. Que ya esta decidido

### Producto

- Vital no debe ser una app wellness generica.
- Vital debe ser un sistema operativo personal de entrenamiento y salud.
- La experiencia debe responder: que hago hoy, por que, que cambio, que alternativa tengo.

### Versionado

- `V1`: base visual + nucleo de entrenamiento
- `V2`: entorno real de entrenamiento
- `V3`: estado diario real
- `V4`: motor adaptativo visible
- `V5`: expansion avanzada

### Arquitectura

- dominios separados, no una sola tabla grande
- `AthleteProfile`
- `SportProfile`
- `EnvironmentProfile`
- `DailyState`
- `TrainingHistory`
- `RoutineEngine`
- `ExplanationEngine`

### Catalogo

- el catalogo debe modelar familias, variantes, equipos, patrones, restricciones y sustituciones
- no debe ser una lista plana de nombres

---

## 4. Que no debe replantearse desde cero

- la idea de construir Vital por versiones
- la idea de arquitectura multisport desde el inicio
- la prioridad de entrenamiento adaptativo primero
- la importancia del entorno real
- la importancia del estado diario
- la necesidad de explicacion visible del motor
- la necesidad de un catalogo estructurado por patrones y equipos

Si algo de esto cambia, debe actualizarse explicitamente en los documentos fuente.

---

## 5. Ultimo bloque de trabajo completado

Se rehizo la primera experiencia post-login de Vital:

- `OnboardingScreen` ya no se presenta como wizard fitness generico
- ahora funciona como entrada premium en cuatro momentos:
  - briefing de sistema
  - arquitectura base
  - contexto real
  - preview operativa
- se mantuvo intacto el payload de `onCompleteOnboarding()`
- al completar onboarding, el flujo sigue entrando a `HOY` a traves de `MainTabs`

---

## 6. Estado tecnico actual

No se ha entrado todavia a implementar el sistema completo de dominio descrito en la documentacion.

Lo que si existe ya en codigo:

- una base visual editada para Vital
- primitives y `Hoy` ajustadas en una primera pasada
- `Resumen` alineado al lenguaje visual operativo de Vital
- `Perfil` alineado al sistema y con un primer bloque de contexto operativo
- `OnboardingScreen` convertido en entrada premium y no en planner rosa generico
- una estructura actual de app movil en `apps/mobile`

Lo que falta es escoger si el siguiente paso es:

- verificar runtime real del onboarding nuevo
- verificar runtime real de `HOY`, `Resumen` y `Perfil`
- seguir refinando `V1` en codigo
- o bajar el schema a DB y contratos mas estrictos

---

## 7. Siguiente paso recomendado

Hay tres rutas validas desde aqui:

### Ruta A - Seguir documentando

Crear:

- `docs/VITAL-SUBSTITUTION-RULES-v1.md`
- `docs/VITAL-CATALOG-QA-CHECKLIST-v1.md`

### Ruta B - Empezar implementacion de producto

Comenzar por:

- verificar onboarding nuevo y transicion a `HOY`
- verificar runtime de `V1`
- cerrar refinamientos visuales menores si aparecen
- luego `V2` entorno

### Ruta C - Bajar a DB y contratos

Tomar `VITAL-DOMAIN-SCHEMA-v1` y convertirlo en:

- migraciones
- tipos
- contratos

Recomendacion actual:

si el objetivo es ejecutar, el siguiente paso exacto es verificar en runtime el onboarding nuevo y confirmar la transicion limpia hacia `HOY`, `Resumen` y `Perfil`.

---

## 8. Bloqueos actuales

No hay un bloqueo tecnico duro.

El mayor riesgo actual es de continuidad:

- abrir otro chat
- olvidar que documentos mandan
- volver a proponer ideas que ya se resolvieron

Este archivo existe justamente para evitar eso.

---

## 9. Instruccion para futuras conversaciones

Si se inicia un nuevo chat sobre Vital, usar este prompt:

`Lee primero docs/VITAL-SESSION-HANDOFF.md y docs/VITAL-DOCS-INDEX.md. Usa esos archivos como contexto principal. No contradigas las decisiones ya tomadas sin proponer actualizacion explicita de los documentos fuente.`

---

## 10. Regla de mantenimiento

Cada vez que se cierre una sesion importante:

1. actualizar este archivo
2. anotar el ultimo bloque completado
3. anotar el siguiente paso exacto
4. anotar si algun documento quedo desactualizado

Si este archivo no se mantiene, el sistema pierde continuidad rapidamente.
