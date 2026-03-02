# Vento Vital Supabase Setup

Este directorio contiene la base inicial de `vital` para Fase 0.

## Requisitos
- Supabase CLI instalado.
- Proyecto Supabase existente (el mismo que hoy usa `employees`).
- Rol con permisos para ejecutar migraciones.

## Estructura actual
- `sql/000_full_schema_report.sql`
  - Reporte completo del esquema actual para revision previa.
- `migrations/20260302_000001_vital_foundation.sql`
  - Crea schema `vital`.
  - Crea tablas core (perfil, plan, tareas, carga/fatiga, juego).
  - Crea funciones de acceso (`can_access_user`, `is_vital_admin`).
  - Habilita RLS y politicas base.

## Aplicar migraciones
0. (Recomendado) correr `sql/000_full_schema_report.sql` y guardar resultado como baseline.

1. Link al proyecto:
```bash
supabase link --project-ref <PROJECT_REF>
```

2. Aplicar migraciones:
```bash
supabase db push
```

## Post-migracion (obligatorio)
1. Insertar al menos un admin en `vital.admin_users` usando `service_role`:
```sql
insert into vital.admin_users (user_id, role)
values ('<AUTH_USER_ID>', 'admin')
on conflict (user_id) do update set role = excluded.role;
```

2. Verificar que un empleado autenticado pueda crear su `user_profile`.
3. Verificar que no pueda leer datos de otros usuarios.

## Checklist rapido de seguridad
- [ ] RLS activo en todas las tablas de `vital`.
- [ ] Solo el usuario lee/escribe sus registros.
- [ ] Admins solo los definidos en `vital.admin_users`.
- [ ] Datos de salud no se mezclan con tablas laborales.
