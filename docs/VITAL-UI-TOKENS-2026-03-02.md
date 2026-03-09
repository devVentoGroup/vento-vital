# Vento Vital UI Tokens - 2026-03-02

Estado: `ACTIVO` (v1 mint-first)

## Direccion visual

- Base Vento coherente con ecosistema (`pass` / `anima`), sin duplicar identidad.
- Personalidad: calmada, amigable, saludable y operativa.
- Regla de color:
  - Primario de accion: `mint`.
  - Acento secundario: `magenta`.

## Paleta Light

- `bg`: `#F7F5F8`
- `surface`: `#F2EEF2`
- `card`: `#FFFFFF`
- `textPrimary`: `#1B1A1F`
- `textSecondary`: `#6F6A77`
- `border`: `#E6E1EA`
- `mintPrimary`: `#34D399`
- `mintSoft`: `#ECFDF5`
- `mintDark`: `#065F46`
- `vitalAccent` (magenta): `#E2006A`

## Paleta Dark

- `bg`: `#0F0E12`
- `surface`: `#15141B`
- `card`: `#1B1A22`
- `textPrimary`: `#F7F5F8`
- `textSecondary`: `#B9B4C1`
- `border`: `#2A2733`
- `mintPrimary`: `#34D399`
- `mintSoft`: `#ECFDF5` (uso medido en cards de estado)
- `mintDark`: `#065F46` (estado/componente de progreso)
- `vitalAccent` (magenta): `#E2006A`

## Reglas de uso

- CTA, acciones principales y progreso: `mintPrimary`.
- Estados saludables (`completed`, `in_progress`): `mintSoft + mintDark`.
- Acentos de diferenciacion (`reprogramar`, resaltes): `vitalAccent`.
- Evitar usar magenta como color dominante de pantalla.

## Microinteracciones v1

- Feedback haptico corto al ejecutar accion exitosa en tarea.
- Barra de progreso diaria animada (suavizada) al actualizar estado.

## Componentes cubiertos

- Pantalla `HOY`.
- Timeline de tareas.
- Tarjeta de progreso diario.
- Estados de sesion/login.
