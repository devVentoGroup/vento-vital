# APP-29 - QA Funcional Final (Checklist E2E)

Fecha: 2026-03-03
Estado: En ejecucion

## 1) Preparacion

- Entorno:
  - `apps/api` levantado.
  - `apps/mobile` levantado en dispositivo real.
- Sesion:
  - usuario de prueba valido.
  - cuenta con onboarding v2 disponible.
- Config:
  - `EXPO_PUBLIC_API_BASE_URL` correcto.
  - `EXPO_PUBLIC_SUPABASE_URL` y `EXPO_PUBLIC_SUPABASE_ANON_KEY` correctos.

## 2) Flujo E2E principal

### Caso 01 - Login

- [ ] Ingresar correo y contrasena validos.
- [ ] Confirmar ingreso exitoso sin errores de sesion.
- [ ] Cerrar app y abrir de nuevo: sesion restaurada automaticamente.

Resultado esperado:
- Login estable y persistencia correcta.

### Caso 02 - Onboarding v2

- [ ] Completar onboarding con preset `Vital Balance`.
- [ ] Completar onboarding con modulos custom (sin training).
- [ ] Completar onboarding con safety red-flag + training.

Resultado esperado:
- Se crea bundle segun modulos activos.
- Si hay red-flag, aparece aviso preventivo y training puede bloquearse sin romper flujo.

### Caso 03 - HOY

- [ ] Pulsar `Actualizar HOY`.
- [ ] Verificar chips de modulos activos.
- [ ] Verificar estado vacio cuando no hay tareas.
- [ ] Completar tarea.
- [ ] Posponer tarea.
- [ ] Reprogramar tarea.

Resultado esperado:
- Tareas y estados se actualizan sin errores.
- Mensajes de accion y fuente de feed son consistentes.

### Caso 04 - Resumen

- [ ] Abrir pestana `Resumen`.
- [ ] Verificar KPIs (adherencia, tareas, completadas).
- [ ] Verificar bloque `Plan de accion semanal`.
- [ ] Forzar fallo de red y validar `Reintentar resumen`.

Resultado esperado:
- Resumen no rompe pantalla ante fallo.
- `summaryError` visible y recuperable por boton de reintento.

### Caso 05 - Perfil

- [ ] Editar datos de perfil y guardar.
- [ ] Activar/desactivar modulos (manteniendo al menos 1 activo).
- [ ] Cambiar configuracion por modulo activo.
- [ ] Probar edge-case de modulo inactivo (debe bloquear configuracion).
- [ ] Probar sincronizacion de notificaciones.

Resultado esperado:
- Configuracion persiste sin estados ambiguos.
- Mensajes de error claros en casos limite.

## 3) Casos de resiliencia

- [ ] API offline: validar mensajes claros en Login/HOY/Resumen/Perfil.
- [ ] Sesion expirada: validar redireccion o mensaje para re-login.
- [ ] Sin modulos activos: HOY debe bloquear carga con mensaje claro.
- [ ] Sin permisos de notificaciones: mostrar error controlado.

## 4) Criterio de aprobacion APP-29

Para marcar APP-29 como completado:
- [ ] 100% de casos E2E principales ejecutados.
- [ ] 100% de casos de resiliencia ejecutados.
- [ ] Sin errores bloqueantes (P0/P1).
- [ ] Issues P2/P3 documentados con plan de correccion.

## 5) Registro de hallazgos (rellenar durante QA)

| ID | Pantalla | Paso | Severidad | Hallazgo | Estado |
|----|----------|------|-----------|----------|--------|
| QA-001 |  |  |  |  |  |
| QA-002 |  |  |  |  |  |
| QA-003 |  |  |  |  |  |

