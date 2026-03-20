# Vento Vital - Docs Index

Estado: `fuente de verdad operativa`

Proposito: reducir al minimo lo que hay que recordar en una nueva conversacion y dejar claro que documentos mandan, para que Vital no pierda continuidad entre sesiones.

---

## 1. Como usar este indice

Si una nueva conversacion o agente va a trabajar sobre Vital, el orden correcto es:

1. leer `docs/VITAL-SESSION-HANDOFF.md`
2. leer este archivo
3. leer solo los documentos fuente de verdad relevantes para la tarea
4. no contradecir esos documentos sin proponer actualizacion explicita

Este archivo existe para evitar:

- contexto perdido
- documentos obsoletos que nadie sabe si mandan
- decisiones repetidas
- propuestas que ignoran el roadmap ya escrito

---

## 2. Fuentes de verdad principales

## 2.1 Vision maestra

Documento:

- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`

Usalo para:

- vision del producto
- versiones
- principio rector
- ideal final de Vital

No lo uses para:

- detalles tecnicos finos
- seeds de catalogo

## 2.2 Version activa de producto

Documentos:

- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-V1-IMPLEMENTATION-CHECKLIST-2026-03-13.md`
- `docs/VITAL-V1-QA-CHECKLIST-2026-03-13.md`
- `docs/VITAL-SCREEN-STATES-v1-2026-03-13.md`
- `docs/VITAL-V2-SPEC-2026-03-13.md`
- `docs/VITAL-V3-SPEC-2026-03-13.md`
- `docs/VITAL-V4-SPEC-2026-03-13.md`

Usalos para:

- alcance por version
- entregables
- no-objetivos
- UX esperada
- criterio de aceptacion
- checklist de implementacion
- checklist de QA

## 2.3 Modelo central

Documento:

- `docs/VITAL-CORE-MODEL-2026-03-13.md`

Usalo para:

- dominios
- relaciones conceptuales
- objetos del sistema
- jerarquia de decision

## 2.4 Reglas del motor

Documento:

- `docs/VITAL-DECISION-RULES-v1-2026-03-13.md`

Usalo para:

- orden de evaluacion
- reglas iniciales del motor
- criterios de ajuste
- explicaciones

## 2.5 Contratos minimos

Documento:

- `docs/VITAL-API-CONTRACTS-v1-2026-03-13.md`

Usalo para:

- payloads minimos de `V1`
- campos UI-critical
- baseline de endpoints para `HOY`, `Resumen` y `Perfil`

## 2.6 Catalogo y ejercicio

Documentos:

- `docs/VITAL-EXERCISE-CATALOG-SPEC-2026-03-13.md`
- `docs/VITAL-CATALOG-SEED-v1-2026-03-13.md`
- `docs/VITAL-CATALOG-SEED-DATA-v1-2026-03-13.md`

Usalos para:

- taxonomia de equipos
- taxonomia de ejercicios
- familias
- variantes
- seed inicial

## 2.7 Schema implementable

Documento:

- `docs/VITAL-DOMAIN-SCHEMA-v1-2026-03-13.md`

Usalo para:

- entidades implementables
- enums
- relaciones
- tablas
- DTOs

---

## 3. Documento vivo mas importante

Documento:

- `docs/VITAL-SESSION-HANDOFF.md`

Este es el archivo que debe actualizarse mas a menudo.

Debe responder:

- donde va el proyecto hoy
- que ya esta decidido
- que sigue inmediatamente
- que documentos mandan en este momento
- que cosas no deben replantearse desde cero

Si este archivo no se actualiza, el resto del sistema pierde continuidad.

---

## 4. Jerarquia de autoridad

Si hay conflicto entre documentos, manda este orden:

1. `docs/VITAL-SESSION-HANDOFF.md`
2. `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`
3. `docs/VITAL-V*-SPEC-*.md`
4. `docs/VITAL-API-CONTRACTS-v1-2026-03-13.md`
5. `docs/VITAL-CORE-MODEL-2026-03-13.md`
6. `docs/VITAL-DOMAIN-SCHEMA-v1-2026-03-13.md`
7. `docs/VITAL-DECISION-RULES-v1-2026-03-13.md`
8. `docs/VITAL-EXERCISE-CATALOG-SPEC-2026-03-13.md`
9. `docs/VITAL-CATALOG-SEED*.md`

Regla:

si un documento queda desalineado, debe anotarse en el handoff.

---

## 5. Que hacer al cerrar una sesion

Antes de terminar una sesion importante:

1. actualizar `docs/VITAL-SESSION-HANDOFF.md`
2. anotar que se decidio realmente
3. anotar que quedo pendiente
4. anotar el siguiente paso exacto
5. marcar si algun doc quedo desactualizado

Esto evita que el contexto quede solo en la conversacion.

---

## 6. Que hacer al empezar una sesion

Al iniciar una nueva conversacion sobre Vital:

1. leer `docs/VITAL-SESSION-HANDOFF.md`
2. leer `docs/VITAL-DOCS-INDEX.md`
3. leer solo los documentos relevantes a la tarea
4. resumir el estado antes de proponer cambios

Plantilla util para arrancar:

`Lee primero docs/VITAL-SESSION-HANDOFF.md y docs/VITAL-DOCS-INDEX.md. Usa esos archivos como contexto principal y no contradigas las decisiones ya tomadas sin proponer actualizacion explicita.`

---

## 7. Estado actual del paquete documental

Ya existen y deben considerarse activos:

- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`
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

## 8. Regla final

Si una decision importante solo existe en el chat y no en estos documentos, esa decision no esta realmente protegida.

La continuidad de Vital debe vivir en archivos, no en memoria conversacional.
