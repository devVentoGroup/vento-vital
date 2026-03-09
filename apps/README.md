# Apps Layer (Inicio)

## Objetivo

Arranque modular de capa app para consumir contratos `vital`:
- Backend BFF (`apps/api`) con rutas `HOY`.
- App movil objetivo con Expo (`apps/mobile`).

## Estructura

- `apps/api/src/config`: configuración y entorno.
- `apps/api/src/lib`: utilidades HTTP y cliente RPC Supabase.
- `apps/api/src/modules/hoy`: módulo de dominio `HOY` (routes/controller/service).
- `apps/api/src/modules/wear`: snapshot compacto para cliente de reloj.
- `apps/mobile`: app Expo (React Native) para `HOY`.

## Variables de entorno (API)

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_RPC_SCHEMA` (opcional, default `vital`)
- `PORT` (opcional, default `8787`)

## Ejecutar API

```bash
npm run dev:api
```

## Flujo app movil (Expo)

1. Definir en `apps/mobile/.env.local`:
   - `EXPO_PUBLIC_API_BASE_URL` (usar IP local si pruebas en telefono fisico)
   - `EXPO_PUBLIC_SUPABASE_URL`
   - `EXPO_PUBLIC_SUPABASE_ANON_KEY`
2. Ejecutar:

```bash
npm run dev:mobile
```

3. Abrir en Expo Go.
4. Iniciar sesion con correo/contrasena.
5. Cargar tareas HOY.

## Development Build (EAS, no producción)

Objetivo:
- correr app con `development client` (custom build), no `production`.

Requisitos:
- `eas login`
- proyecto Expo configurado
- credenciales iOS/Android en EAS (se generan guiado al primer build).

Comandos desde raiz:

```bash
npm run build:dev:android
npm run build:dev:ios
```

Comandos directos en mobile:

```bash
npm --prefix apps/mobile run eas:build:dev:android
npm --prefix apps/mobile run eas:build:dev:ios
```

Notas:
- perfil usado: `development` (archivo `apps/mobile/eas.json`).
- Android genera `apk` para pruebas internas.
- iOS genera build interna (y perfil `development-simulator` para simulador).

## Supabase API (importante)

- En `Project Settings > API > Exposed schemas`, incluir `vital`.
- Si `vital` no esta expuesto, los RPC devolveran error de schema.

## Endpoint base wearables

- `GET /api/wear/hoy`
  - Retorna snapshot compacto (`count`, `tasks`) útil para Apple Watch / Wear OS bridge.
