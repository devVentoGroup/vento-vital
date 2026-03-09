-- Vento Vital - recurrence rules v1 smoke
-- Run after:
-- 1) 20260302_000004_vital_recurrence_rules_v1.sql applied

-- 1) Function existence
select
  n.nspname as schema_name,
  p.proname as function_name
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'vital'
  and p.proname = 'should_materialize_on_date';

-- 2) Deterministic rule checks
select
  vital.should_materialize_on_date('{"type":"daily"}'::jsonb, date '2026-03-02') as daily_true,
  vital.should_materialize_on_date('{"type":"weekly","days":[1,3,5]}'::jsonb, date '2026-03-02') as weekly_monday_true,
  vital.should_materialize_on_date('{"type":"weekly","days":[2,4]}'::jsonb, date '2026-03-02') as weekly_monday_false,
  vital.should_materialize_on_date('{"type":"every_other_day","anchor_date":"2026-03-01"}'::jsonb, date '2026-03-02') as eod_false,
  vital.should_materialize_on_date('{"type":"every_other_day","anchor_date":"2026-03-02"}'::jsonb, date '2026-03-02') as eod_true,
  vital.should_materialize_on_date('{"type":"flexible_within_week"}'::jsonb, date '2026-03-02') as flexible_weekday_true,
  vital.should_materialize_on_date('{"type":"flexible_within_week"}'::jsonb, date '2026-03-08') as flexible_sunday_false;
