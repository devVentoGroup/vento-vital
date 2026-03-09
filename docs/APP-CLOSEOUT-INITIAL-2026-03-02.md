# Capa App Closeout Inicial - 2026-03-02

Estado: `CERRADA` (alcance inicial de capa app)

## Alcance cerrado

- Estructura modular de app creada:
  - `apps/api` (BFF por modulos)
  - `apps/mobile` (Expo, foco movil)
  - `packages/contracts` (contratos compartidos)
- Flujo de autenticacion base en mobile:
  - login email/password con Supabase Auth
  - manejo de sesion en memoria para consumir `HOY`
- Flujo `HOY` conectado e2e en app:
  - listar tareas
  - completar tarea
  - snooze de tarea
  - reprogramar tarea
- Validaciones de entrada y manejo de errores en BFF:
  - JSON invalido -> `400`
  - validacion de fecha/UUID/parametros requeridos
  - mensaje explicito cuando `vital` no esta expuesto en API de Supabase

## Evidencia funcional

1. API healthcheck operativo (`/health`).
2. Login real desde app Expo contra Supabase.
3. `Cargar HOY` funcional con JWT real.
4. Acciones por tarea (`completar`, `snooze`, `reprogramar`) validadas en dispositivo.

## Checklist APP-04 vs resultado

- Arranque API + mobile documentado: `OK`
- Contratos RPC consumidos desde app runtime: `OK`
- Flujo HOY con acciones en cliente real: `OK`
- Manejo basico de errores y validaciones de request: `OK`
- Riesgos y siguientes pasos definidos: `OK`

## Riesgos abiertos

- Falta persistencia de sesion en mobile (actualmente en memoria).
- Falta polish visual avanzado (design system completo, animaciones, estados vacios enriquecidos).
- Falta cobertura automatizada e2e (API/mobile).
- Dependencia de configuracion manual de `Exposed schemas` (`vital`) en Supabase.

## Siguiente bloque recomendado

- Iniciar iteracion de UX visual de `HOY` (tipografia, colores, jerarquia visual, feedback de acciones y microinteracciones) manteniendo la logica actual estable.
