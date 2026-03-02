-- Vento Vital - Full Schema Report
-- Ejecutar en Supabase SQL Editor y compartir resultados.
-- Objetivo: revisar el esquema actual completo ANTES de aplicar migraciones nuevas.

-- 1) Schemas
select nspname as schema_name
from pg_namespace
where nspname not in ('pg_catalog', 'information_schema')
  and nspname not like 'pg_toast%'
  and nspname not like 'pg_temp_%'
order by nspname;

-- 2) Tables
select table_schema, table_name
from information_schema.tables
where table_type = 'BASE TABLE'
  and table_schema not in ('pg_catalog', 'information_schema')
order by table_schema, table_name;

-- 3) Columns
select
  c.table_schema,
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where c.table_schema not in ('pg_catalog', 'information_schema')
order by c.table_schema, c.table_name, c.ordinal_position;

-- 4) Primary keys
select
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  kcu.column_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.table_schema = kcu.table_schema
 and tc.table_name = kcu.table_name
where tc.constraint_type = 'PRIMARY KEY'
order by tc.table_schema, tc.table_name, kcu.ordinal_position;

-- 5) Unique constraints
select
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  kcu.column_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.table_schema = kcu.table_schema
 and tc.table_name = kcu.table_name
where tc.constraint_type = 'UNIQUE'
order by tc.table_schema, tc.table_name, tc.constraint_name, kcu.ordinal_position;

-- 6) Foreign keys
select
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  kcu.column_name,
  ccu.table_schema as foreign_table_schema,
  ccu.table_name as foreign_table_name,
  ccu.column_name as foreign_column_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.table_schema = kcu.table_schema
 and tc.table_name = kcu.table_name
join information_schema.constraint_column_usage ccu
  on tc.constraint_name = ccu.constraint_name
 and tc.table_schema = ccu.table_schema
where tc.constraint_type = 'FOREIGN KEY'
order by tc.table_schema, tc.table_name, tc.constraint_name;

-- 7) Check constraints
select
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  cc.check_clause
from information_schema.table_constraints tc
join information_schema.check_constraints cc
  on tc.constraint_name = cc.constraint_name
 and tc.constraint_schema = cc.constraint_schema
where tc.constraint_type = 'CHECK'
order by tc.table_schema, tc.table_name, tc.constraint_name;

-- 8) Indexes
select
  schemaname as table_schema,
  tablename as table_name,
  indexname as index_name,
  indexdef as index_definition
from pg_indexes
where schemaname not in ('pg_catalog', 'information_schema')
order by schemaname, tablename, indexname;

-- 9) RLS status by table
select
  n.nspname as table_schema,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r'
  and n.nspname not in ('pg_catalog', 'information_schema')
order by n.nspname, c.relname;

-- 10) RLS policies
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname not in ('pg_catalog', 'information_schema')
order by schemaname, tablename, policyname;

-- 11) Triggers
select
  event_object_schema as table_schema,
  event_object_table as table_name,
  trigger_name,
  action_timing,
  event_manipulation,
  action_statement
from information_schema.triggers
where trigger_schema not in ('pg_catalog', 'information_schema')
order by event_object_schema, event_object_table, trigger_name;

-- 12) Functions (non-system)
select
  n.nspname as function_schema,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as args,
  pg_get_function_result(p.oid) as return_type,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname not in ('pg_catalog', 'information_schema')
order by n.nspname, p.proname;

-- 13) Enum types
select
  n.nspname as enum_schema,
  t.typname as enum_name,
  e.enumsortorder,
  e.enumlabel
from pg_type t
join pg_enum e on t.oid = e.enumtypid
join pg_namespace n on n.oid = t.typnamespace
where n.nspname not in ('pg_catalog', 'information_schema')
order by n.nspname, t.typname, e.enumsortorder;
