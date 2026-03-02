-- Vento Vital - smoke test post-migracion
-- Ejecutar despues de: supabase db push

-- 1) Verificar schema
select nspname as schema_name
from pg_namespace
where nspname = 'vital';

-- 2) Verificar tablas clave
select table_name
from information_schema.tables
where table_schema = 'vital'
  and table_name in (
    'user_profiles',
    'programs',
    'task_instances',
    'muscle_load_snapshots',
    'game_profiles',
    'xp_events'
  )
order by table_name;

-- 3) Verificar RLS activo
select relname as table_name, relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'vital'
  and relkind = 'r'
order by relname;

-- 4) Verificar politicas creadas
select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname = 'vital'
order by tablename, policyname;
