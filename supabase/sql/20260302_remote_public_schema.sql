--
-- PostgreSQL database dump
--

-- \restrict 50Spi4jUlYKYoB1XLKjd40ksLLPlMnVvvEdqQF7e9Dvcs7syahxwc1Povbe5zha

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
-- SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";

--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- Name: document_scope; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."document_scope" AS ENUM (
    'employee',
    'site',
    'group'
);


ALTER TYPE "public"."document_scope" OWNER TO "postgres";

--
-- Name: document_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."document_status" AS ENUM (
    'pending_review',
    'approved',
    'rejected'
);


ALTER TYPE "public"."document_status" OWNER TO "postgres";

--
-- Name: permission_scope_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."permission_scope_type" AS ENUM (
    'global',
    'site',
    'site_type',
    'area',
    'area_kind'
);


ALTER TYPE "public"."permission_scope_type" OWNER TO "postgres";

--
-- Name: recipe_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."recipe_status" AS ENUM (
    'draft',
    'published',
    'archived'
);


ALTER TYPE "public"."recipe_status" OWNER TO "postgres";

--
-- Name: site_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."site_type" AS ENUM (
    'satellite',
    'production_center',
    'admin'
);


ALTER TYPE "public"."site_type" OWNER TO "postgres";

--
-- Name: support_ticket_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."support_ticket_status" AS ENUM (
    'open',
    'in_progress',
    'resolved',
    'closed'
);


ALTER TYPE "public"."support_ticket_status" OWNER TO "postgres";

--
-- Name: _set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."_set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END$$;


ALTER FUNCTION "public"."_set_updated_at"() OWNER TO "postgres";

--
-- Name: _vento_norm("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."_vento_norm"("input" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE
    AS $_$
  SELECT regexp_replace(trim(coalesce($1,'')), '\s+', ' ', 'g')
$_$;


ALTER FUNCTION "public"."_vento_norm"("input" "text") OWNER TO "postgres";

--
-- Name: _vento_slugify("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."_vento_slugify"("input" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE
    AS $_$
  SELECT trim(both '-' from regexp_replace(lower(coalesce($1,'')), '[^a-z0-9]+', '-', 'g'))
$_$;


ALTER FUNCTION "public"."_vento_slugify"("input" "text") OWNER TO "postgres";

--
-- Name: _vento_uuid_from_text("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."_vento_uuid_from_text"("input" "text") RETURNS "uuid"
    LANGUAGE "sql" IMMUTABLE
    AS $_$
  SELECT (
    substr(md5(coalesce($1,'')), 1, 8)  || '-' ||
    substr(md5(coalesce($1,'')), 9, 4)  || '-' ||
    substr(md5(coalesce($1,'')), 13, 4) || '-' ||
    substr(md5(coalesce($1,'')), 17, 4) || '-' ||
    substr(md5(coalesce($1,'')), 21, 12)
  )::uuid
$_$;


ALTER FUNCTION "public"."_vento_uuid_from_text"("input" "text") OWNER TO "postgres";

--
-- Name: anonymize_user_personal_data("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."anonymize_user_personal_data"("p_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.users
  SET
    full_name = 'Deleted User',
    document_id = NULL,
    document_type = NULL,
    phone = NULL,
    email = CONCAT('deleted+', SUBSTRING(p_user_id::text, 1, 8), '@deleted.local'),
    birth_date = NULL,
    is_active = false,
    is_client = false,
    marketing_opt_in = false,
    has_reviewed_google = false,
    last_review_prompt_date = NULL,
    updated_at = now()
  WHERE id = p_user_id;

  DELETE FROM public.user_favorites WHERE user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."anonymize_user_personal_data"("p_user_id" "uuid") OWNER TO "postgres";

--
-- Name: apply_restock_receipt("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."apply_restock_receipt"("p_request_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_request record;
  v_item record;
  v_qty numeric;
begin
  select *
  into v_request
  from public.restock_requests
  where id = p_request_id;

  if v_request.id is null then
    raise exception 'restock_request not found: %', p_request_id;
  end if;

  if v_request.to_site_id is null then
    raise exception 'to_site_id requerido para recepcion de remision';
  end if;

  if not public.has_permission('nexo.inventory.remissions.receive', v_request.to_site_id) then
    raise exception 'permission denied: remissions.receive';
  end if;

  for v_item in
    select *
    from public.restock_request_items
    where request_id = p_request_id
  loop
    v_qty := coalesce(v_item.received_quantity, 0);
    if v_qty <= 0 then
      continue;
    end if;

    insert into public.inventory_movements (
      site_id,
      product_id,
      movement_type,
      quantity,
      note,
      related_restock_request_id
    )
    values (
      v_request.to_site_id,
      v_item.product_id,
      'transfer_in',
      v_qty,
      'Recepcion remision ' || p_request_id::text,
      p_request_id
    );

    insert into public.inventory_stock_by_site (site_id, product_id, current_qty, updated_at)
    values (v_request.to_site_id, v_item.product_id, v_qty, now())
    on conflict (site_id, product_id)
    do update set
      current_qty = public.inventory_stock_by_site.current_qty + excluded.current_qty,
      updated_at = now();
  end loop;
end;
$$;


ALTER FUNCTION "public"."apply_restock_receipt"("p_request_id" "uuid") OWNER TO "postgres";

--
-- Name: apply_restock_shipment("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."apply_restock_shipment"("p_request_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_request record;
  v_item record;
  v_qty numeric;
begin
  select *
  into v_request
  from public.restock_requests
  where id = p_request_id;

  if v_request.id is null then
    raise exception 'restock_request not found: %', p_request_id;
  end if;

  if v_request.from_site_id is null then
    raise exception 'from_site_id requerido para salida de remision';
  end if;

  if not public.has_permission('nexo.inventory.remissions.prepare', v_request.from_site_id) then
    raise exception 'permission denied: remissions.prepare';
  end if;

  for v_item in
    select *
    from public.restock_request_items
    where request_id = p_request_id
  loop
    v_qty := coalesce(v_item.shipped_quantity, 0);
    if v_qty <= 0 then
      continue;
    end if;

    insert into public.inventory_movements (
      site_id,
      product_id,
      movement_type,
      quantity,
      note,
      related_restock_request_id
    )
    values (
      v_request.from_site_id,
      v_item.product_id,
      'transfer_out',
      v_qty,
      'Salida remision ' || p_request_id::text,
      p_request_id
    );

    insert into public.inventory_stock_by_site (site_id, product_id, current_qty, updated_at)
    values (v_request.from_site_id, v_item.product_id, -v_qty, now())
    on conflict (site_id, product_id)
    do update set
      current_qty = public.inventory_stock_by_site.current_qty + excluded.current_qty,
      updated_at = now();
  end loop;
end;
$$;


ALTER FUNCTION "public"."apply_restock_shipment"("p_request_id" "uuid") OWNER TO "postgres";

--
-- Name: award_loyalty_points_external("uuid", "uuid", numeric, "text", "text", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."award_loyalty_points_external"("p_user_id" "uuid", "p_site_id" "uuid", "p_amount_cop" numeric, "p_external_ref" "text", "p_description" "text" DEFAULT NULL::"text", "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_points integer;
  v_ref text;
  v_sale_id uuid;
  v_grant_result jsonb;
  v_transaction_id uuid;
  v_new_balance integer;
begin
  if not public.is_active_staff() then
    return jsonb_build_object('success', false, 'error', 'No autorizado (staff requerido)');
  end if;

  if p_user_id is null then
    return jsonb_build_object('success', false, 'error', 'user_id es requerido');
  end if;

  if p_site_id is null then
    return jsonb_build_object('success', false, 'error', 'site_id es requerido');
  end if;

  if not public.has_permission('pulso.pos.main', p_site_id, null) then
    return jsonb_build_object('success', false, 'error', 'No autorizado para operar en esta sede');
  end if;

  if p_amount_cop is null or p_amount_cop <= 0 then
    return jsonb_build_object('success', false, 'error', 'amount_cop debe ser mayor a 0');
  end if;

  v_ref := btrim(coalesce(p_external_ref, ''));
  if v_ref = '' then
    return jsonb_build_object('success', false, 'error', 'external_ref es requerido');
  end if;

  v_points := floor(p_amount_cop / 1000);
  if v_points <= 0 then
    return jsonb_build_object('success', false, 'error', 'El monto no genera puntos');
  end if;

  begin
    insert into public.loyalty_external_sales (
      site_id,
      user_id,
      amount_cop,
      points_awarded,
      external_ref,
      source_app,
      awarded_by,
      metadata
    ) values (
      p_site_id,
      p_user_id,
      p_amount_cop,
      v_points,
      v_ref,
      'pulso',
      auth.uid(),
      coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('external_ref', v_ref, 'site_id', p_site_id)
    )
    returning id into v_sale_id;
  exception
    when unique_violation then
      return jsonb_build_object(
        'success', false,
        'duplicate', true,
        'error', 'Referencia externa ya registrada en esta sede'
      );
  end;

  v_grant_result := public.grant_loyalty_points(
    p_user_id,
    v_points,
    coalesce(p_description, format('Compra externa (%s)', v_ref)),
    coalesce(p_metadata, '{}'::jsonb)
      || jsonb_build_object(
        'source_app', 'pulso',
        'flow', 'external_pos',
        'site_id', p_site_id,
        'external_ref', v_ref,
        'external_sale_id', v_sale_id
      )
  );

  if coalesce((v_grant_result->>'success')::boolean, false) is not true then
    raise exception '%', coalesce(v_grant_result->>'error', 'Error otorgando puntos');
  end if;

  v_transaction_id := nullif(v_grant_result->>'transaction_id', '')::uuid;
  v_new_balance := nullif(v_grant_result->>'new_balance', '')::integer;

  update public.loyalty_external_sales
  set loyalty_transaction_id = v_transaction_id
  where id = v_sale_id;

  return jsonb_build_object(
    'success', true,
    'duplicate', false,
    'points_awarded', v_points,
    'new_balance', v_new_balance,
    'transaction_id', v_transaction_id,
    'external_sale_id', v_sale_id
  );
exception
  when others then
    return jsonb_build_object('success', false, 'error', sqlerrm);
end;
$$;


ALTER FUNCTION "public"."award_loyalty_points_external"("p_user_id" "uuid", "p_site_id" "uuid", "p_amount_cop" numeric, "p_external_ref" "text", "p_description" "text", "p_metadata" "jsonb") OWNER TO "postgres";

--
-- Name: can_access_area("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."can_access_area"("p_area_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select p_area_id is null
    or public.is_owner()
    or public.is_global_manager()
    or exists (
      select 1
      from public.employee_areas ea
      join public.areas a on a.id = ea.area_id
      where ea.employee_id = auth.uid()
        and ea.area_id = p_area_id
        and coalesce(ea.is_active, true) = true
        and a.site_id = public.current_employee_selected_site_id()
    )
    or exists (
      select 1
      from public.employees e
      where e.id = auth.uid()
        and e.area_id = p_area_id
    );
$$;


ALTER FUNCTION "public"."can_access_area"("p_area_id" "uuid") OWNER TO "postgres";

--
-- Name: can_access_recipe_scope("uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."can_access_recipe_scope"("p_site_id" "uuid", "p_area_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select
    public.is_owner()
    or public.is_global_manager()
    or (
      public.current_employee_role() = any (array['gerente'::text, 'bodeguero'::text])
      and p_site_id is not null
      and public.can_access_site(p_site_id)
    )
    or (
      public.is_employee()
      and p_site_id is not null
      and p_area_id is not null
      and public.can_access_site(p_site_id)
      and public.can_access_area(p_area_id)
    );
$$;


ALTER FUNCTION "public"."can_access_recipe_scope"("p_site_id" "uuid", "p_area_id" "uuid") OWNER TO "postgres";

--
-- Name: can_access_site("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."can_access_site"("p_site_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select
    case
      when p_site_id is null then false
      when is_owner() then true
      when is_global_manager() then true
      when exists (
        select 1
        from public.employee_sites es
        where es.employee_id = auth.uid()
          and es.site_id = p_site_id
          and es.is_active = true
      ) then true
      when exists (
        select 1
        from public.employees e
        where e.id = auth.uid()
          and e.site_id = p_site_id
          and (e.is_active is true or e.is_active is null)
      ) then true
      else false
    end;
$$;


ALTER FUNCTION "public"."can_access_site"("p_site_id" "uuid") OWNER TO "postgres";

--
-- Name: check_nexo_permissions("uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_nexo_permissions"("p_employee_id" "uuid", "p_site_id" "uuid") RETURNS TABLE("permission_code" "text", "allowed" boolean)
    LANGUAGE "sql" STABLE
    AS $$
  with perms as (
    select ap.code as permission_code
    from public.app_permissions ap
    join public.apps a on a.id = ap.app_id
    where a.code = 'nexo'
  ),
  ctx as (
    select p_employee_id as employee_id, p_site_id as site_id
  )
  select p.permission_code,
         public.has_permission('nexo.' || p.permission_code, (select site_id from ctx), null) as allowed
  from perms p
  order by p.permission_code;
$$;


ALTER FUNCTION "public"."check_nexo_permissions"("p_employee_id" "uuid", "p_site_id" "uuid") OWNER TO "postgres";

--
-- Name: close_open_attendance_day_end("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."close_open_attendance_day_end"("p_timezone" "text" DEFAULT 'America/Bogota'::"text") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_day_start timestamptz;
  v_day_end timestamptz;
  v_closed int := 0;
begin
  v_day_start := (date_trunc('day', now() at time zone p_timezone)) at time zone p_timezone;
  v_day_end := (date_trunc('day', now() at time zone p_timezone) + interval '1 day' - interval '1 second') at time zone p_timezone;

  with last_logs as (
    select distinct on (employee_id)
      employee_id,
      site_id,
      action,
      occurred_at
    from public.attendance_logs
    where occurred_at <= v_day_end
    order by employee_id, occurred_at desc, created_at desc
  ),
  inserted as (
    insert into public.attendance_logs (
      employee_id,
      site_id,
      action,
      source,
      occurred_at,
      latitude,
      longitude,
      accuracy_meters,
      device_info,
      notes
    )
    select
      l.employee_id,
      l.site_id,
      'check_out',
      'system',
      v_day_end,
      s.latitude,
      s.longitude,
      0,
      jsonb_build_object('auto_close', true, 'reason', 'day_end'),
      'Cierre automatico: turno abierto cerrado por el sistema a las 23:59'
    from last_logs l
    join public.sites s on s.id = l.site_id
    where l.action = 'check_in'
      and not exists (
        select 1
        from public.attendance_logs al
        where al.employee_id = l.employee_id
          and al.action = 'check_out'
          and al.occurred_at > l.occurred_at
          and al.occurred_at <= v_day_end
      )
    returning 1
  )
  select count(*) into v_closed from inserted;

  return v_closed;
end;
$$;


ALTER FUNCTION "public"."close_open_attendance_day_end"("p_timezone" "text") OWNER TO "postgres";

--
-- Name: current_employee_area_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."current_employee_area_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select public.current_employee_selected_area_id();
$$;


ALTER FUNCTION "public"."current_employee_area_id"() OWNER TO "postgres";

--
-- Name: current_employee_primary_site_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."current_employee_primary_site_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select coalesce(
    (
      select es.site_id
      from public.employee_sites es
      where es.employee_id = auth.uid()
        and es.is_primary = true
      limit 1
    ),
    (
      select e.site_id
      from public.employees e
      where e.id = auth.uid()
    )
  );
$$;


ALTER FUNCTION "public"."current_employee_primary_site_id"() OWNER TO "postgres";

--
-- Name: current_employee_role(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."current_employee_role"() RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select e.role
  from public.employees e
  where e.id = auth.uid();
$$;


ALTER FUNCTION "public"."current_employee_role"() OWNER TO "postgres";

--
-- Name: current_employee_selected_area_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."current_employee_selected_area_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select coalesce(
    (
      select s.selected_area_id
      from public.employee_settings s
      where s.employee_id = auth.uid()
    ),
    (
      select ea.area_id
      from public.employee_areas ea
      where ea.employee_id = auth.uid()
        and ea.is_primary = true
      limit 1
    ),
    (
      select e.area_id
      from public.employees e
      where e.id = auth.uid()
    )
  );
$$;


ALTER FUNCTION "public"."current_employee_selected_area_id"() OWNER TO "postgres";

--
-- Name: current_employee_selected_site_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."current_employee_selected_site_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select coalesce(
    (
      select s.selected_site_id
      from public.employee_settings s
      where s.employee_id = auth.uid()
    ),
    public.current_employee_primary_site_id()
  );
$$;


ALTER FUNCTION "public"."current_employee_selected_site_id"() OWNER TO "postgres";

--
-- Name: current_employee_site_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."current_employee_site_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select public.current_employee_selected_site_id();
$$;


ALTER FUNCTION "public"."current_employee_site_id"() OWNER TO "postgres";

--
-- Name: device_info_has_blocking_warnings("jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."device_info_has_blocking_warnings"("di" "jsonb") RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $$
  select exists (
    select 1
    from jsonb_array_elements_text(
      case
        when di is null then '[]'::jsonb
        when jsonb_typeof(di->'validationWarnings') = 'array' then di->'validationWarnings'
        else '[]'::jsonb
      end
    ) as w(txt)
    where lower(w.txt) like any (
      array[
        '%mock%',
        '%simulada%',
        '%spoof%',
        '%punto nulo%',
        '%patron sospechoso%',
        '%digitos repetidos%'
      ]
    )
  );
$$;


ALTER FUNCTION "public"."device_info_has_blocking_warnings"("di" "jsonb") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: attendance_breaks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."attendance_breaks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "site_id" "uuid" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ended_at" timestamp with time zone,
    "start_source" "text" DEFAULT 'mobile'::"text" NOT NULL,
    "end_source" "text",
    "start_notes" "text",
    "end_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "attendance_breaks_end_source_check" CHECK ((("end_source" IS NULL) OR ("end_source" = ANY (ARRAY['mobile'::"text", 'web'::"text", 'kiosk'::"text", 'system'::"text"])))),
    CONSTRAINT "attendance_breaks_start_source_check" CHECK (("start_source" = ANY (ARRAY['mobile'::"text", 'web'::"text", 'kiosk'::"text", 'system'::"text"]))),
    CONSTRAINT "attendance_breaks_time_check" CHECK ((("ended_at" IS NULL) OR ("ended_at" >= "started_at")))
);


ALTER TABLE "public"."attendance_breaks" OWNER TO "postgres";

--
-- Name: end_attendance_break("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."end_attendance_break"("p_source" "text" DEFAULT 'mobile'::"text", "p_notes" "text" DEFAULT NULL::"text") RETURNS "public"."attendance_breaks"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_employee_id uuid;
  v_open_break public.attendance_breaks%rowtype;
  v_result public.attendance_breaks%rowtype;
begin
  v_employee_id := auth.uid();
  if v_employee_id is null then
    raise exception 'No autenticado';
  end if;

  select *
    into v_open_break
  from public.attendance_breaks
  where employee_id = v_employee_id
    and ended_at is null
  order by started_at desc
  limit 1
  for update;

  if not found then
    raise exception 'No hay descanso activo para finalizar';
  end if;

  update public.attendance_breaks
  set
    ended_at = now(),
    end_source = coalesce(p_source, 'mobile'),
    end_notes = p_notes
  where id = v_open_break.id
  returning *
    into v_result;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."end_attendance_break"("p_source" "text", "p_notes" "text") OWNER TO "postgres";

--
-- Name: enforce_attendance_geofence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."enforce_attendance_geofence"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_site record;
  v_emp record;

  v_requires_geo boolean;
  v_max_acc integer;
  v_radius integer;

  v_distance double precision;
  v_accuracy double precision;
  v_is_assigned boolean;
begin
  if new.source <> 'system' then
    new.occurred_at := now();
  end if;

  select id, site_id, is_active
    into v_emp
  from public.employees
  where id = new.employee_id;

  if not found then
    raise exception 'Empleado no encontrado';
  end if;

  if v_emp.is_active is false then
    raise exception 'Empleado inactivo';
  end if;

  if new.action = 'check_in' then
    v_is_assigned := (v_emp.site_id is not distinct from new.site_id)
      or exists (
        select 1
        from public.employee_sites es
        where es.employee_id = new.employee_id
          and es.site_id = new.site_id
          and es.is_active = true
      );

    if not v_is_assigned then
      raise exception 'No autorizado: check-in solo permitido en tu sede asignada';
    end if;
  end if;

  select id, name, type, is_active, latitude, longitude, checkin_radius_meters
    into v_site
  from public.sites
  where id = new.site_id;

  if not found then
    raise exception 'Sede no encontrada';
  end if;

  if v_site.is_active is false then
    raise exception 'Sede inactiva';
  end if;

  if new.source = 'system' then
    return new;
  end if;

  if v_site.type <> 'vento_group' then
    if v_site.latitude is null or v_site.longitude is null then
      raise exception 'Configuracion invalida: la sede % no tiene coordenadas', v_site.name;
    end if;
    if v_site.checkin_radius_meters is null or v_site.checkin_radius_meters <= 0 then
      raise exception 'Configuracion invalida: la sede % no tiene radio de check-in configurado', v_site.name;
    end if;
    v_requires_geo := true;
  else
    v_requires_geo := false;
  end if;

  if v_requires_geo then
    if new.latitude is null or new.longitude is null or new.accuracy_meters is null then
      raise exception 'Ubicacion requerida para registrar asistencia';
    end if;

    if public.device_info_has_blocking_warnings(new.device_info) then
      raise exception 'Ubicacion no valida: senales de ubicacion simulada detectadas';
    end if;

    if new.action = 'check_in' then
      v_max_acc := 20;
    elsif new.action = 'check_out' then
      v_max_acc := 25;
    else
      raise exception 'Accion invalida: %', new.action;
    end if;

    v_radius := v_site.checkin_radius_meters;
    v_accuracy := new.accuracy_meters::double precision;

    if v_accuracy > v_max_acc then
      raise exception 'Precision GPS insuficiente: %m (maximo %m)', round(v_accuracy), v_max_acc;
    end if;

    v_distance := public.haversine_m(new.latitude, new.longitude, v_site.latitude, v_site.longitude);

    if (v_distance + v_accuracy) > v_radius then
      raise exception 'Fuera de rango: %m (precision %m) > radio %m',
        round(v_distance), round(v_accuracy), v_radius;
    end if;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."enforce_attendance_geofence"() OWNER TO "postgres";

--
-- Name: enforce_attendance_sequence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."enforce_attendance_sequence"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_last_action text;
  v_last_site_id uuid;
  v_last_occurred_at timestamptz;
begin
  -- Serializa operaciones por empleado (evita doble insert concurrente)
  perform pg_advisory_xact_lock(hashtext(new.employee_id::text)::bigint);

  -- Validar acción (por si entra algo raro)
  if new.action not in ('check_in','check_out') then
    raise exception 'Acción inválida: %', new.action;
  end if;

  -- Tomar el último evento del empleado (global, no solo "hoy")
  select action, site_id, occurred_at
    into v_last_action, v_last_site_id, v_last_occurred_at
  from public.attendance_logs
  where employee_id = new.employee_id
  order by occurred_at desc, created_at desc
  limit 1;

  if v_last_action is null then
    -- Primer evento debe ser check_in
    if new.action <> 'check_in' then
      raise exception 'Secuencia inválida: el primer registro debe ser check_in';
    end if;

    return new;
  end if;

  -- (Opcional pero recomendado) evitar inserts "hacia atrás" en el tiempo
  if new.occurred_at < v_last_occurred_at then
    raise exception 'Secuencia inválida: occurred_at no puede ser menor al último registro';
  end if;

  -- No permitir dos acciones iguales seguidas
  if new.action = v_last_action then
    raise exception 'Secuencia inválida: no puedes registrar % dos veces seguidas', new.action;
  end if;

  -- Si es check_out, debe cerrar el mismo sitio del check_in anterior
  if new.action = 'check_out' and v_last_action = 'check_in' then
    if new.site_id <> v_last_site_id then
      raise exception 'Secuencia inválida: el check_out debe ser en la misma sede del check_in anterior';
    end if;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."enforce_attendance_sequence"() OWNER TO "postgres";

--
-- Name: enforce_employee_role_site(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."enforce_employee_role_site"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  st public.site_type;
begin
  select s.site_type into st
  from public.sites s
  where s.id = new.site_id;

  if st is null then
    raise exception 'site_id invalido o sede sin site_type';
  end if;

  if not exists (
    select 1
    from public.role_site_type_rules r
    where r.role = new.role
      and r.site_type = st
      and r.is_allowed = true
  ) then
    raise exception 'Rol "%" no permitido para site_type="%"', new.role, st;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."enforce_employee_role_site"() OWNER TO "postgres";

--
-- Name: enforce_inventory_location_parent_same_site(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."enforce_inventory_location_parent_same_site"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  if new.parent_location_id is null then
    return new;
  end if;

  -- no puede ser su propio padre
  if new.parent_location_id = new.id then
    raise exception 'inventory_locations: parent_location_id cannot equal id';
  end if;

  -- el padre debe pertenecer al mismo site_id
  if not exists (
    select 1
    from public.inventory_locations p
    where p.id = new.parent_location_id
      and p.site_id = new.site_id
  ) then
    raise exception 'inventory_locations: parent_location_id must belong to the same site_id';
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."enforce_inventory_location_parent_same_site"() OWNER TO "postgres";

--
-- Name: generate_inventory_sku("text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."generate_inventory_sku"("p_product_type" "text" DEFAULT NULL::"text", "p_inventory_kind" "text" DEFAULT NULL::"text", "p_name" "text" DEFAULT NULL::"text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_type text;
  v_name text;
  v_seq bigint;
begin
  v_type := case
    when lower(coalesce(trim(p_inventory_kind), '')) = 'asset' then 'EQP'
    when lower(coalesce(trim(p_product_type), '')) = 'venta' then 'VEN'
    when lower(coalesce(trim(p_product_type), '')) = 'preparacion' then 'PRE'
    else 'INS'
  end;

  v_name := upper(coalesce(trim(p_name), ''));
  v_name := translate(v_name,
    'ÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑÇáàäâãéèëêíìïîóòöôõúùüûñç',
    'AAAAAEEEEIIIIOOOOOUUUUNCaaaaaeeeeiiiiooooouuuunc'
  );
  v_name := regexp_replace(v_name, '[^A-Z0-9]+', '', 'g');
  v_name := left(nullif(v_name, ''), 6);
  if v_name is null then
    v_name := 'ITEM';
  end if;

  v_seq := nextval('public.inventory_sku_seq');

  return v_type || '-' || v_name || '-' || lpad(v_seq::text, 6, '0');
end;
$$;


ALTER FUNCTION "public"."generate_inventory_sku"("p_product_type" "text", "p_inventory_kind" "text", "p_name" "text") OWNER TO "postgres";

--
-- Name: generate_location_code("text", "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."generate_location_code"("p_site_code" "text", "p_zone" "text", "p_aisle" "text" DEFAULT NULL::"text", "p_level" "text" DEFAULT NULL::"text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
  v_code TEXT;
BEGIN
  v_code := 'LOC-' || UPPER(p_site_code) || '-' || UPPER(p_zone);
  IF p_aisle IS NOT NULL THEN
    v_code := v_code || '-' || UPPER(p_aisle);
  END IF;
  IF p_level IS NOT NULL THEN
    v_code := v_code || '-' || UPPER(p_level);
  END IF;
  RETURN v_code;
END;
$$;


ALTER FUNCTION "public"."generate_location_code"("p_site_code" "text", "p_zone" "text", "p_aisle" "text", "p_level" "text") OWNER TO "postgres";

--
-- Name: generate_lpn_code("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."generate_lpn_code"("p_site_code" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_year_month TEXT;
  v_seq INT;
BEGIN
  v_year_month := TO_CHAR(NOW(), 'YYMM');
  v_seq := NEXTVAL('lpn_sequence');
  RETURN 'LPN-' || UPPER(p_site_code) || '-' || v_year_month || '-' || LPAD(v_seq::TEXT, 4, '0');
END;
$$;


ALTER FUNCTION "public"."generate_lpn_code"("p_site_code" "text") OWNER TO "postgres";

--
-- Name: generate_product_sku("text", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."generate_product_sku"("p_product_type" "text", "p_site_id" "uuid" DEFAULT NULL::"uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_site_id uuid;
  v_brand_code text;
  v_type_code text;
  v_next integer;
begin
  v_site_id := coalesce(
    p_site_id,
    public.current_employee_selected_site_id(),
    public.current_employee_primary_site_id()
  );

  if v_site_id is null then
    select s.id into v_site_id
    from public.sites s
    where s.site_kind = 'hq'
    order by s.created_at
    limit 1;
  end if;

  if v_site_id is null then
    select s.id into v_site_id
    from public.sites s
    order by s.created_at
    limit 1;
  end if;

  if v_site_id is null then
    raise exception 'No site available to generate SKU';
  end if;

  v_brand_code := public.resolve_product_sku_brand_code(v_site_id);
  if v_brand_code is null or v_brand_code = '' then
    raise exception 'No brand code available for site %', v_site_id;
  end if;

  v_type_code := public.resolve_product_sku_type_code(p_product_type);
  if v_type_code is null or v_type_code = '' then
    v_type_code := 'GEN';
  end if;

  insert into public.product_sku_sequences (brand_code, type_code, last_value, updated_at)
  values (v_brand_code, v_type_code, 1, now())
  on conflict (brand_code, type_code)
  do update
    set last_value = public.product_sku_sequences.last_value + 1,
        updated_at = now()
  returning last_value into v_next;

  return v_brand_code || '-' || v_type_code || '-' || lpad(v_next::text, 5, '0');
end;
$$;


ALTER FUNCTION "public"."generate_product_sku"("p_product_type" "text", "p_site_id" "uuid") OWNER TO "postgres";

--
-- Name: grant_loyalty_points("uuid", integer, "text", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."grant_loyalty_points"("p_user_id" "uuid", "p_points" integer, "p_description" "text" DEFAULT NULL::"text", "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_current_balance integer;
  v_new_balance integer;
  v_transaction_id uuid;
begin
  -- ✅ Solo staff activo
  if not is_active_staff() then
    return jsonb_build_object('success', false, 'error', 'No autorizado (staff requerido)');
  end if;

  if p_user_id is null then
    return jsonb_build_object('success', false, 'error', 'user_id es requerido');
  end if;

  if p_points is null or p_points <= 0 then
    return jsonb_build_object('success', false, 'error', 'p_points debe ser mayor a 0');
  end if;

  -- ✅ Lock para evitar race conditions
  select u.loyalty_points
    into v_current_balance
  from public.users u
  where u.id = p_user_id
  for update;

  if v_current_balance is null then
    return jsonb_build_object('success', false, 'error', 'Usuario no encontrado');
  end if;

  v_new_balance := coalesce(v_current_balance, 0) + p_points;

  insert into public.loyalty_transactions (
    user_id,
    kind,
    points_delta,
    description,
    metadata
  ) values (
    p_user_id,
    'earn',
    p_points,
    coalesce(p_description, 'Puntos otorgados'),
    coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('staff_user_id', auth.uid())
  )
  returning id into v_transaction_id;

  -- Mantengo tu update explícito (misma conducta que hoy)
  update public.users
  set loyalty_points = v_new_balance,
      updated_at = now()
  where id = p_user_id;

  return jsonb_build_object(
    'success', true,
    'new_balance', v_new_balance,
    'points_awarded', p_points,
    'transaction_id', v_transaction_id
  );

exception
  when others then
    return jsonb_build_object('success', false, 'error', sqlerrm);
end;
$$;


ALTER FUNCTION "public"."grant_loyalty_points"("p_user_id" "uuid", "p_points" integer, "p_description" "text", "p_metadata" "jsonb") OWNER TO "postgres";

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, loyalty_points)
  VALUES (new.id, new.email, '', 0)
  ON CONFLICT (id) DO NOTHING; -- Evita errores si ya existe
  RETURN new;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

--
-- Name: has_permission("text", "uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."has_permission"("p_permission_code" "text", "p_site_id" "uuid" DEFAULT NULL::"uuid", "p_area_id" "uuid" DEFAULT NULL::"uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_employee_id uuid;
  v_role text;
  v_permission_id uuid;
  v_site_id uuid;
  v_area_id uuid;
  v_denied boolean;
  v_allowed boolean;
begin
  v_employee_id := auth.uid();
  if v_employee_id is null then
    return false;
  end if;

  select e.role into v_role
  from public.employees e
  where e.id = v_employee_id
    and e.is_active = true;

  if v_role is null then
    return false;
  end if;

  select ap.id into v_permission_id
  from public.app_permissions ap
  join public.apps a on a.id = ap.app_id
  where (a.code || '.' || ap.code) = p_permission_code
    and a.is_active = true
    and ap.is_active = true;

  if v_permission_id is null then
    return false;
  end if;

  v_site_id := coalesce(p_site_id, public.current_employee_site_id());
  v_area_id := p_area_id;

  select exists (
    select 1
    from public.employee_permissions ep
    where ep.employee_id = v_employee_id
      and ep.permission_id = v_permission_id
      and ep.is_allowed = false
      and public.permission_scope_matches(
        ep.scope_type,
        v_site_id,
        v_area_id,
        ep.scope_site_id,
        ep.scope_area_id,
        ep.scope_site_type,
        ep.scope_area_kind
      )
  ) into v_denied;

  if v_denied then
    return false;
  end if;

  select exists (
    select 1
    from public.employee_permissions ep
    where ep.employee_id = v_employee_id
      and ep.permission_id = v_permission_id
      and ep.is_allowed = true
      and public.permission_scope_matches(
        ep.scope_type,
        v_site_id,
        v_area_id,
        ep.scope_site_id,
        ep.scope_area_id,
        ep.scope_site_type,
        ep.scope_area_kind
      )
  ) into v_allowed;

  if v_allowed then
    return true;
  end if;

  select exists (
    select 1
    from public.role_permissions rp
    where rp.role = v_role
      and rp.permission_id = v_permission_id
      and rp.is_allowed = true
      and public.permission_scope_matches(
        rp.scope_type,
        v_site_id,
        v_area_id,
        null,
        null,
        rp.scope_site_type,
        rp.scope_area_kind
      )
  ) into v_allowed;

  return coalesce(v_allowed, false);
end;
$$;


ALTER FUNCTION "public"."has_permission"("p_permission_code" "text", "p_site_id" "uuid", "p_area_id" "uuid") OWNER TO "postgres";

--
-- Name: haversine_m(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."haversine_m"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) RETURNS double precision
    LANGUAGE "sql" IMMUTABLE
    AS $$
  select 2 * 6371000::double precision *
    asin(
      sqrt(
        power(sin((((lat2::double precision - lat1::double precision) * pi()) / 180) / 2), 2) +
        cos((lat1::double precision * pi()) / 180) *
        cos((lat2::double precision * pi()) / 180) *
        power(sin((((lon2::double precision - lon1::double precision) * pi()) / 180) / 2), 2)
      )
    );
$$;


ALTER FUNCTION "public"."haversine_m"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) OWNER TO "postgres";

--
-- Name: is_active_staff(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_active_staff"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select public.is_employee();
$$;


ALTER FUNCTION "public"."is_active_staff"() OWNER TO "postgres";

--
-- Name: is_employee(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_employee"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select exists (
    select 1
    from public.employees e
    where e.id = auth.uid()
      and coalesce(e.is_active, true) = true
  );
$$;


ALTER FUNCTION "public"."is_employee"() OWNER TO "postgres";

--
-- Name: is_global_manager(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_global_manager"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select public.current_employee_role() = 'gerente_general';
$$;


ALTER FUNCTION "public"."is_global_manager"() OWNER TO "postgres";

--
-- Name: is_manager(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_manager"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select public.current_employee_role() = 'gerente';
$$;


ALTER FUNCTION "public"."is_manager"() OWNER TO "postgres";

--
-- Name: is_manager_or_owner(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_manager_or_owner"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select public.current_employee_role() in ('propietario', 'gerente', 'gerente_general');
$$;


ALTER FUNCTION "public"."is_manager_or_owner"() OWNER TO "postgres";

--
-- Name: is_owner(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_owner"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "row_security" TO 'off'
    AS $$
  select public.current_employee_role() = 'propietario';
$$;


ALTER FUNCTION "public"."is_owner"() OWNER TO "postgres";

--
-- Name: permission_scope_matches("public"."permission_scope_type", "uuid", "uuid", "uuid", "uuid", "public"."site_type", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."permission_scope_matches"("p_scope_type" "public"."permission_scope_type", "p_context_site_id" "uuid", "p_context_area_id" "uuid", "p_scope_site_id" "uuid", "p_scope_area_id" "uuid", "p_scope_site_type" "public"."site_type", "p_scope_area_kind" "text") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_site_type public.site_type;
  v_area_kind text;
begin
  if p_scope_type = 'global' then
    return true;
  end if;

  if p_scope_type = 'site' then
    if p_context_site_id is null then
      return false;
    end if;
    if p_scope_site_id is not null and p_scope_site_id <> p_context_site_id then
      return false;
    end if;
    return public.can_access_site(p_context_site_id);
  end if;

  if p_scope_type = 'site_type' then
    if p_context_site_id is null then
      return false;
    end if;
    if not public.can_access_site(p_context_site_id) then
      return false;
    end if;
    select site_type into v_site_type from public.sites where id = p_context_site_id;
    return v_site_type = p_scope_site_type;
  end if;

  if p_scope_type = 'area' then
    if p_context_area_id is null then
      return false;
    end if;
    if p_scope_area_id is not null and p_scope_area_id <> p_context_area_id then
      return false;
    end if;
    return public.can_access_area(p_context_area_id);
  end if;

  if p_scope_type = 'area_kind' then
    if p_context_area_id is null then
      return false;
    end if;
    if not public.can_access_area(p_context_area_id) then
      return false;
    end if;
    select kind into v_area_kind from public.areas where id = p_context_area_id;
    return v_area_kind = p_scope_area_kind;
  end if;

  return false;
end;
$$;


ALTER FUNCTION "public"."permission_scope_matches"("p_scope_type" "public"."permission_scope_type", "p_context_site_id" "uuid", "p_context_area_id" "uuid", "p_scope_site_id" "uuid", "p_scope_area_id" "uuid", "p_scope_site_type" "public"."site_type", "p_scope_area_kind" "text") OWNER TO "postgres";

--
-- Name: process_loyalty_earning("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."process_loyalty_earning"("p_order_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  POINT_CONVERSION_RATE constant integer := 1000; -- 1 punto por cada X pesos
  v_order record;
  v_points integer;
begin
  -- Obtener y bloquear la orden
  select
    o.id,
    o.client_id,
    o.payment_status,
    o.loyalty_processed,
    o.total_amount,           -- TODO: cambia al campo real de monto
    o.loyalty_points_awarded  -- TODO: cambia al campo real de puntos ganados
  into v_order
  from public.orders o
  where o.id = p_order_id
  for update;

  if not found then
    raise exception 'Order % not found', p_order_id using errcode = 'P0001';
  end if;

  if v_order.payment_status <> 'paid' then
    raise exception 'Order % is not paid', p_order_id using errcode = 'P0001';
  end if;

  if v_order.loyalty_processed then
    raise exception 'Order % already processed for loyalty', p_order_id using errcode = 'P0001';
  end if;

  v_points := floor(coalesce(v_order.total_amount, 0) / POINT_CONVERSION_RATE);

  -- Si no hay puntos, solo marcamos procesada
  if v_points <= 0 then
    update public.orders
      set loyalty_processed = true,
          loyalty_points_awarded = 0
    where id = p_order_id;
    return;
  end if;

  insert into public.loyalty_transactions (
    user_id,
    order_id,
    kind,
    points_delta,
    description
  ) values (
    v_order.client_id,
    p_order_id,
    'earn',
    v_points,
    'Order paid: loyalty earning'
  );

  update public.users
    set loyalty_points = coalesce(loyalty_points, 0) + v_points
  where id = v_order.client_id;

  update public.orders
    set loyalty_processed = true,
        loyalty_points_awarded = v_points
  where id = p_order_id;
end;
$$;


ALTER FUNCTION "public"."process_loyalty_earning"("p_order_id" "uuid") OWNER TO "postgres";

--
-- Name: process_order_payment("uuid", "uuid", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."process_order_payment"("p_order_id" "uuid", "p_site_id" "uuid", "p_payment_method" "text", "p_payment_reference" "text" DEFAULT NULL::"text") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
DECLARE
  v_order RECORD;
  v_loyalty_points INT := 0;
  v_result JSON;
BEGIN
  -- Obtener la orden
  SELECT * INTO v_order FROM orders WHERE id = p_order_id;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Orden no encontrada');
  END IF;
  
  -- Calcular puntos de lealtad (1 punto por cada $1000 COP)
  v_loyalty_points := FLOOR(v_order.total_amount / 1000);
  
  -- Actualizar estado de la orden
  UPDATE orders 
  SET 
    status = 'completed',
    payment_status = 'paid',
    loyalty_processed = true,
    loyalty_points_awarded = v_loyalty_points,
    updated_at = NOW()
  WHERE id = p_order_id;
  
  -- Registrar el pago en pos_payments
  INSERT INTO pos_payments (
    order_id, 
    payment_method, 
    amount, 
    reference,
    created_at
  ) VALUES (
    p_order_id,
    p_payment_method,
    v_order.total_amount,
    p_payment_reference,
    NOW()
  );
  
  -- Si el cliente tiene ID, actualizar puntos de lealtad
  IF v_order.client_id IS NOT NULL AND v_loyalty_points > 0 THEN
    UPDATE users 
    SET loyalty_points = COALESCE(loyalty_points, 0) + v_loyalty_points
    WHERE id = v_order.client_id;
    
    -- Registrar transacción de lealtad
    INSERT INTO loyalty_transactions (
      user_id,
      order_id,
      points,
      type,
      created_at
    ) VALUES (
      v_order.client_id,
      p_order_id,
      v_loyalty_points,
      'earned',
      NOW()
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'order_id', p_order_id,
    'loyalty_points_awarded', v_loyalty_points
  );
END;
$_$;


ALTER FUNCTION "public"."process_order_payment"("p_order_id" "uuid", "p_site_id" "uuid", "p_payment_method" "text", "p_payment_reference" "text") OWNER TO "postgres";

--
-- Name: receive_purchase_order("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."receive_purchase_order"("p_purchase_order_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_po record;
  v_item record;

  v_purchase_unit_size numeric;
  v_received_base_qty numeric;

  v_prev_total_qty numeric;          -- stock TOTAL antes de recibir
  v_existing_cost numeric;
  v_received_unit_cost_base numeric;
  v_new_cost numeric;

  v_line_total numeric;
  v_total_amount numeric := 0;
BEGIN
  -- Lock PO
  SELECT *
  INTO v_po
  FROM public.purchase_orders
  WHERE id = p_purchase_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Purchase order % no existe', p_purchase_order_id;
  END IF;

  IF v_po.status IN ('received', 'completed') THEN
    RAISE EXCEPTION 'Purchase order % ya está recibida (status=%)', p_purchase_order_id, v_po.status;
  END IF;

  -- Procesar items recibidos
  FOR v_item IN
    SELECT *
    FROM public.purchase_order_items
    WHERE purchase_order_id = p_purchase_order_id
    ORDER BY created_at ASC
  LOOP
    IF v_item.quantity_received IS NULL OR v_item.quantity_received <= 0 THEN
      CONTINUE;
    END IF;

    -- purchase_unit_size por proveedor+producto
    SELECT ps.purchase_unit_size
    INTO v_purchase_unit_size
    FROM public.product_suppliers ps
    WHERE ps.supplier_id = v_po.supplier_id
      AND ps.product_id = v_item.product_id
    LIMIT 1;

    IF v_purchase_unit_size IS NULL OR v_purchase_unit_size <= 0 THEN
      RAISE EXCEPTION
        'Falta purchase_unit_size en product_suppliers para supplier_id=% product_id=% (PO=%)',
        v_po.supplier_id, v_item.product_id, p_purchase_order_id;
    END IF;

    -- Convertir a unidad base
    v_received_base_qty := v_item.quantity_received * v_purchase_unit_size;

    -- 1) Capturar stock total PREVIO (antes de sumar lo recibido)
    SELECT COALESCE(SUM(current_qty), 0)
    INTO v_prev_total_qty
    FROM public.inventory_stock_by_site
    WHERE product_id = v_item.product_id;

    -- 2) Costo actual (promedio anterior)
    SELECT COALESCE(cost, 0)
    INTO v_existing_cost
    FROM public.products
    WHERE id = v_item.product_id;

    -- 3) Costo recibido en unidad base
    v_received_unit_cost_base := v_item.unit_cost / v_purchase_unit_size;

    -- 4) Nuevo costo promedio ponderado (usando stock previo real)
    IF (v_prev_total_qty + v_received_base_qty) > 0 THEN
      v_new_cost :=
        (
          (v_existing_cost * v_prev_total_qty) +
          (v_received_unit_cost_base * v_received_base_qty)
        )
        / (v_prev_total_qty + v_received_base_qty);
    ELSE
      v_new_cost := v_received_unit_cost_base;
    END IF;

    -- Kardex
    INSERT INTO public.inventory_movements (
      site_id,
      product_id,
      movement_type,
      quantity,
      note,
      related_purchase_order_id,
      related_order_id
    )
    VALUES (
      v_po.site_id,
      v_item.product_id,
      'purchase_in',
      v_received_base_qty,
      'Recepción OC ' || p_purchase_order_id::text,
      p_purchase_order_id,
      NULL
    );

    -- Stock por sede
    INSERT INTO public.inventory_stock_by_site (site_id, product_id, current_qty, updated_at)
    VALUES (v_po.site_id, v_item.product_id, v_received_base_qty, now())
    ON CONFLICT (site_id, product_id)
    DO UPDATE SET
      current_qty = public.inventory_stock_by_site.current_qty + EXCLUDED.current_qty,
      updated_at = now();

    -- Actualizar costo del producto
    UPDATE public.products
    SET cost = v_new_cost,
        updated_at = now()
    WHERE id = v_item.product_id;

    -- Totales PO
    v_line_total := v_item.unit_cost * v_item.quantity_received;
    v_total_amount := v_total_amount + COALESCE(v_line_total, 0);

    UPDATE public.purchase_order_items
    SET line_total = v_line_total
    WHERE id = v_item.id;
  END LOOP;

  UPDATE public.purchase_orders
  SET status = 'received',
      received_at = now(),
      total_amount = v_total_amount
  WHERE id = p_purchase_order_id;

END;
$$;


ALTER FUNCTION "public"."receive_purchase_order"("p_purchase_order_id" "uuid") OWNER TO "postgres";

--
-- Name: register_shift_departure_event("uuid", integer, integer, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."register_shift_departure_event"("p_site_id" "uuid", "p_distance_meters" integer, "p_accuracy_meters" integer DEFAULT NULL::integer, "p_source" "text" DEFAULT 'mobile'::"text", "p_notes" "text" DEFAULT NULL::"text", "p_occurred_at" timestamp with time zone DEFAULT "now"()) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_employee_id uuid := auth.uid();
  v_employee public.employees%rowtype;
  v_shift_site_id uuid;
  v_shift_start_at timestamptz;
  v_event_id uuid;
  v_distance integer := greatest(coalesce(p_distance_meters, 0), 0);
  v_accuracy integer := case
    when p_accuracy_meters is null then null
    else greatest(p_accuracy_meters, 0)
  end;
  v_event_time timestamptz := coalesce(p_occurred_at, now());
begin
  if v_employee_id is null then
    raise exception 'No autenticado';
  end if;

  select *
    into v_employee
  from public.employees
  where id = v_employee_id;

  if not found then
    raise exception 'Empleado no encontrado';
  end if;

  if coalesce(v_employee.is_active, false) is false then
    raise exception 'Empleado inactivo';
  end if;

  select al.site_id, al.occurred_at
    into v_shift_site_id, v_shift_start_at
  from public.attendance_logs al
  where al.employee_id = v_employee_id
    and al.action = 'check_in'
    and not exists (
      select 1
      from public.attendance_logs ao
      where ao.employee_id = al.employee_id
        and ao.action = 'check_out'
        and ao.occurred_at > al.occurred_at
    )
  order by al.occurred_at desc, al.created_at desc
  limit 1;

  if v_shift_start_at is null then
    return jsonb_build_object('inserted', false, 'reason', 'no_open_shift');
  end if;

  if p_site_id is not null and p_site_id is distinct from v_shift_site_id then
    return jsonb_build_object('inserted', false, 'reason', 'site_mismatch');
  end if;

  if exists (
    select 1
    from public.attendance_breaks b
    where b.employee_id = v_employee_id
      and b.ended_at is null
  ) then
    return jsonb_build_object('inserted', false, 'reason', 'on_break');
  end if;

  insert into public.attendance_shift_events (
    employee_id,
    site_id,
    shift_start_at,
    event_type,
    occurred_at,
    distance_meters,
    accuracy_meters,
    source,
    notes
  )
  values (
    v_employee_id,
    coalesce(p_site_id, v_shift_site_id),
    v_shift_start_at,
    'left_site_open_shift',
    v_event_time,
    v_distance,
    v_accuracy,
    coalesce(p_source, 'mobile'),
    p_notes
  )
  on conflict (employee_id, shift_start_at, event_type) do nothing
  returning id
    into v_event_id;

  if v_event_id is null then
    return jsonb_build_object('inserted', false, 'reason', 'already_recorded');
  end if;

  return jsonb_build_object(
    'inserted', true,
    'event_id', v_event_id,
    'shift_start_at', v_shift_start_at
  );
end;
$$;


ALTER FUNCTION "public"."register_shift_departure_event"("p_site_id" "uuid", "p_distance_meters" integer, "p_accuracy_meters" integer, "p_source" "text", "p_notes" "text", "p_occurred_at" timestamp with time zone) OWNER TO "postgres";

--
-- Name: resolve_product_sku_brand_code("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."resolve_product_sku_brand_code"("p_site_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_site_type text;
  v_site_code text;
begin
  select s.type, s.code
    into v_site_type, v_site_code
  from public.sites s
  where s.id = p_site_id;

  if v_site_type is not null then
    case lower(v_site_type)
      when 'vento_group' then return 'VGR';
      when 'vento_cafe' then return 'VCF';
      when 'saudo' then return 'SAU';
      when 'vaila_vainilla' then return 'VAI';
      when 'catering' then return 'CAT';
    end case;
  end if;

  if v_site_code is null then
    return null;
  end if;

  return upper(regexp_replace(v_site_code, '[^A-Za-z0-9]', '', 'g'));
end;
$$;


ALTER FUNCTION "public"."resolve_product_sku_brand_code"("p_site_id" "uuid") OWNER TO "postgres";

--
-- Name: resolve_product_sku_type_code("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."resolve_product_sku_type_code"("p_product_type" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
declare
  v_raw text;
  v_clean text;
begin
  v_raw := coalesce(p_product_type, '');
  v_clean := lower(v_raw);

  if v_clean like '%venta%' then
    return 'VEN';
  elsif v_clean like '%insum%' then
    return 'INS';
  elsif v_clean like '%prepar%' then
    return 'PRE';
  elsif v_clean like '%empa%' then
    return 'EMP';
  elsif v_clean like '%limp%' then
    return 'LIM';
  elsif v_clean like '%mant%' then
    return 'MAN';
  elsif v_clean like '%acti%' then
    return 'ACT';
  end if;

  v_clean := regexp_replace(v_clean, '[^a-z0-9]', '', 'g');
  if v_clean = '' then
    return 'GEN';
  end if;

  return upper(substr(v_clean, 1, 3));
end;
$$;


ALTER FUNCTION "public"."resolve_product_sku_type_code"("p_product_type" "text") OWNER TO "postgres";

--
-- Name: run_nexo_inventory_reset("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."run_nexo_inventory_reset"("p_confirm" "text" DEFAULT ''::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
declare
  v_expected constant text := 'RESET_NEXO_INVENTORY';
  v_deleted_products integer := 0;
  v_preserved_products integer := 0;
  r record;
begin
  if p_confirm <> v_expected then
    raise exception 'Confirmacion invalida. Ejecuta run_nexo_inventory_reset(''%s'') para continuar.', v_expected;
  end if;

  create temporary table if not exists tmp_preserve_products (
    product_id uuid primary key
  ) on commit drop;
  truncate table tmp_preserve_products;

  create temporary table if not exists tmp_reset_products (
    product_id uuid primary key
  ) on commit drop;
  truncate table tmp_reset_products;

  /*
    Preserve products used by Vento Pass reward redemption.
    - If loyalty_rewards.metadata stores product_id in known paths, keep those ids.
    - If metadata stores sku/code, keep products that match by sku.
  */
  if to_regclass('public.loyalty_rewards') is not null then
    insert into tmp_preserve_products(product_id)
    select distinct raw_product_id::uuid
    from (
      select trim(v.raw_value) as raw_product_id
      from public.loyalty_rewards lr
      cross join lateral (
        values
          (lr.metadata ->> 'product_id'),
          (lr.metadata ->> 'inventory_product_id'),
          (lr.metadata ->> 'catalog_product_id'),
          (lr.metadata ->> 'product_uuid'),
          (lr.metadata ->> 'productId'),
          (lr.metadata ->> 'product_id_uuid'),
          (lr.metadata -> 'product' ->> 'id'),
          (lr.metadata -> 'item' ->> 'product_id')
      ) as v(raw_value)
    ) candidates
    where raw_product_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
    on conflict (product_id) do nothing;

    insert into tmp_preserve_products(product_id)
    select distinct p.id
    from public.products p
    join public.loyalty_rewards lr
      on lower(coalesce(p.sku, '')) in (
        lower(coalesce(lr.code, '')),
        lower(coalesce(lr.metadata ->> 'sku', '')),
        lower(coalesce(lr.metadata ->> 'product_sku', ''))
      )
    where p.sku is not null
      and btrim(p.sku) <> ''
    on conflict (product_id) do nothing;
  end if;

  /*
    Products to delete: everything in products except reward-redemption preserves.
    This leaves Nexo inventory fully clean.
  */
  insert into tmp_reset_products(product_id)
  select p.id
  from public.products p
  where not exists (
    select 1
    from tmp_preserve_products keep
    where keep.product_id = p.id
  );

  select count(*) into v_preserved_products from tmp_preserve_products;

  -- Inventory transactional cleanup.
  if to_regclass('public.inventory_movements') is not null then
    delete from public.inventory_movements;
  end if;
  if to_regclass('public.inventory_stock_by_location') is not null then
    delete from public.inventory_stock_by_location;
  end if;
  if to_regclass('public.inventory_stock_by_site') is not null then
    delete from public.inventory_stock_by_site;
  end if;
  if to_regclass('public.inventory_entry_items') is not null then
    delete from public.inventory_entry_items;
  end if;
  if to_regclass('public.inventory_entries') is not null then
    delete from public.inventory_entries;
  end if;
  if to_regclass('public.inventory_transfer_items') is not null then
    delete from public.inventory_transfer_items;
  end if;
  if to_regclass('public.inventory_transfers') is not null then
    delete from public.inventory_transfers;
  end if;
  if to_regclass('public.restock_request_items') is not null then
    delete from public.restock_request_items;
  end if;
  if to_regclass('public.restock_requests') is not null then
    delete from public.restock_requests;
  end if;
  if to_regclass('public.inventory_count_lines') is not null then
    delete from public.inventory_count_lines;
  end if;
  if to_regclass('public.inventory_count_sessions') is not null then
    delete from public.inventory_count_sessions;
  end if;
  if to_regclass('public.production_batches') is not null then
    delete from public.production_batches;
  end if;

  -- Cleanup all FK dependencies that point to products(id) for target product ids.
  for r in
    select
      n.nspname as schema_name,
      c.relname as table_name,
      a.attname as column_name
    from pg_constraint fk
    join pg_class c
      on c.oid = fk.conrelid
    join pg_namespace n
      on n.oid = c.relnamespace
    join unnest(fk.conkey) with ordinality as ck(attnum, ord)
      on true
    join unnest(fk.confkey) with ordinality as rk(attnum, ord)
      on rk.ord = ck.ord
    join pg_attribute a
      on a.attrelid = fk.conrelid
     and a.attnum = ck.attnum
    where fk.contype = 'f'
      and fk.confrelid = 'public.products'::regclass
      and n.nspname = 'public'
      and array_length(fk.conkey, 1) = 1
  loop
    execute format(
      'delete from %I.%I where %I in (select product_id from tmp_reset_products)',
      r.schema_name,
      r.table_name,
      r.column_name
    );
  end loop;

  delete from public.products p
  using tmp_reset_products t
  where p.id = t.product_id;

  get diagnostics v_deleted_products = row_count;

  raise notice 'Inventory reset done. Deleted products: %, preserved reward products: %.',
    v_deleted_products,
    v_preserved_products;
end;
$_$;


ALTER FUNCTION "public"."run_nexo_inventory_reset"("p_confirm" "text") OWNER TO "postgres";

--
-- Name: FUNCTION "run_nexo_inventory_reset"("p_confirm" "text"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."run_nexo_inventory_reset"("p_confirm" "text") IS 'Reset for Nexo inventory domain. Preserves products linked to Vento Pass reward redemption. Requires exact confirmation: RESET_NEXO_INVENTORY.';


--
-- Name: set_product_sku(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."set_product_sku"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.sku is null or btrim(new.sku) = '' then
    new.sku := public.generate_product_sku(new.product_type, null);
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."set_product_sku"() OWNER TO "postgres";

--
-- Name: set_production_batch_code(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."set_production_batch_code"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  if new.id is null then
    new.id := gen_random_uuid();
  end if;

  if new.batch_code is null or btrim(new.batch_code) = '' then
    new.batch_code := 'BATCH-' || upper(substr(replace(new.id::text, '-', ''), 1, 8));
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."set_production_batch_code"() OWNER TO "postgres";

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";

--
-- Name: start_attendance_break("uuid", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."start_attendance_break"("p_site_id" "uuid", "p_source" "text" DEFAULT 'mobile'::"text", "p_notes" "text" DEFAULT NULL::"text") RETURNS "public"."attendance_breaks"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_employee public.employees%rowtype;
  v_last_action text;
  v_last_site_id uuid;
  v_result public.attendance_breaks%rowtype;
begin
  if auth.uid() is null then
    raise exception 'No autenticado';
  end if;

  select *
    into v_employee
  from public.employees
  where id = auth.uid();

  if not found then
    raise exception 'Empleado no encontrado';
  end if;

  if coalesce(v_employee.is_active, false) is false then
    raise exception 'Empleado inactivo';
  end if;

  select action, site_id
    into v_last_action, v_last_site_id
  from public.attendance_logs
  where employee_id = v_employee.id
  order by occurred_at desc, created_at desc
  limit 1;

  if v_last_action is distinct from 'check_in' then
    raise exception 'No hay un turno activo para iniciar descanso';
  end if;

  if p_site_id is not null and p_site_id is distinct from v_last_site_id then
    raise exception 'La sede del descanso no coincide con el turno activo';
  end if;

  if exists (
    select 1
    from public.attendance_breaks b
    where b.employee_id = v_employee.id
      and b.ended_at is null
  ) then
    raise exception 'Ya tienes un descanso activo';
  end if;

  insert into public.attendance_breaks (
    employee_id,
    site_id,
    started_at,
    start_source,
    start_notes
  )
  values (
    v_employee.id,
    coalesce(p_site_id, v_last_site_id),
    now(),
    coalesce(p_source, 'mobile'),
    p_notes
  )
  returning *
    into v_result;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."start_attendance_break"("p_site_id" "uuid", "p_source" "text", "p_notes" "text") OWNER TO "postgres";

--
-- Name: tg_set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."tg_set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at := now();
  return new;
end $$;


ALTER FUNCTION "public"."tg_set_updated_at"() OWNER TO "postgres";

--
-- Name: update_employee_shifts_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_employee_shifts_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_employee_shifts_updated_at"() OWNER TO "postgres";

--
-- Name: update_loyalty_balance(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_loyalty_balance"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Si insertamos una transacción, sumamos/restamos al saldo del usuario
  IF (TG_OP = 'INSERT') THEN
    UPDATE public.users
    SET loyalty_points = loyalty_points + NEW.points_delta,
        updated_at = now()
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_loyalty_balance"() OWNER TO "postgres";

--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at"() OWNER TO "postgres";

--
-- Name: upsert_inventory_stock_by_location("uuid", "uuid", numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."upsert_inventory_stock_by_location"("p_location_id" "uuid", "p_product_id" "uuid", "p_delta" numeric) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_site_id uuid;
begin
  select site_id into v_site_id
  from public.inventory_locations
  where id = p_location_id;

  if v_site_id is null then
    raise exception 'location not found';
  end if;

  if not (
    public.has_permission('nexo.inventory.stock', v_site_id)
    or public.has_permission('nexo.inventory.remissions.prepare', v_site_id)
    or public.has_permission('nexo.inventory.remissions.receive', v_site_id)
    or public.has_permission('nexo.inventory.entries', v_site_id)
    or public.has_permission('nexo.inventory.entries_emergency', v_site_id)
    or public.has_permission('nexo.inventory.transfers', v_site_id)
    or public.has_permission('nexo.inventory.withdraw', v_site_id)
    or public.has_permission('nexo.inventory.counts', v_site_id)
    or public.has_permission('nexo.inventory.adjustments', v_site_id)
    or public.has_permission('origo.procurement.receipts', v_site_id)
    or public.has_permission('fogo.production.batches', v_site_id)
  ) then
    raise exception 'permission denied';
  end if;

  insert into public.inventory_stock_by_location (location_id, product_id, current_qty, updated_at)
  values (p_location_id, p_product_id, p_delta, now())
  on conflict (location_id, product_id) do update
    set current_qty = public.inventory_stock_by_location.current_qty + excluded.current_qty,
        updated_at = now();
end;
$$;


ALTER FUNCTION "public"."upsert_inventory_stock_by_location"("p_location_id" "uuid", "p_product_id" "uuid", "p_delta" numeric) OWNER TO "postgres";

--
-- Name: util_column_usage("regclass"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."util_column_usage"("p_table" "regclass") RETURNS TABLE("column_name" "text", "non_null_count" bigint, "total_count" bigint, "pct_non_null" numeric)
    LANGUAGE "plpgsql"
    AS $$
declare
  col record;
  total bigint;
begin
  execute format('select count(*) from %s', p_table) into total;

  for col in
    select a.attname as column_name
    from pg_attribute a
    where a.attrelid = p_table
      and a.attnum > 0
      and not a.attisdropped
  loop
    return query execute format(
      'select %L::text,
              count(%I)::bigint,
              %s::bigint,
              round((count(%I)::numeric / nullif(%s,0))*100, 2)
       from %s',
      col.column_name,
      col.column_name,
      total,
      col.column_name,
      total,
      p_table
    );
  end loop;
end $$;


ALTER FUNCTION "public"."util_column_usage"("p_table" "regclass") OWNER TO "postgres";

--
-- Name: account_deletion_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."account_deletion_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" "text" NOT NULL,
    "requested_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "processed_at" timestamp with time zone,
    "processed_by" "text",
    "notes" "text",
    "user_id" "uuid",
    "request_type" "text" DEFAULT 'full_account'::"text" NOT NULL,
    "requested_via" "text" DEFAULT 'in_app'::"text" NOT NULL,
    "execute_after" timestamp with time zone,
    "canceled_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "confirmation" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "error_message" "text",
    CONSTRAINT "account_deletion_requests_request_type_check" CHECK (("request_type" = ANY (ARRAY['full_account'::"text", 'data_cleanup'::"text"]))),
    CONSTRAINT "account_deletion_requests_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'processing'::"text", 'completed'::"text", 'rejected'::"text", 'canceled'::"text", 'failed'::"text"])))
);


ALTER TABLE "public"."account_deletion_requests" OWNER TO "postgres";

--
-- Name: TABLE "account_deletion_requests"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."account_deletion_requests" IS 'Solicitudes de eliminación de cuenta/datos para Vento Pass. URL pública en app y tiendas.';


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."announcements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "tag" "text" DEFAULT 'INFO'::"text" NOT NULL,
    "published_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "display_order" integer DEFAULT 0 NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "announcements_body_not_empty" CHECK (("length"(TRIM(BOTH FROM "body")) > 0)),
    CONSTRAINT "announcements_tag_valid" CHECK (("tag" = ANY (ARRAY['IMPORTANTE'::"text", 'INFO'::"text", 'ALERTA'::"text"]))),
    CONSTRAINT "announcements_title_not_empty" CHECK (("length"(TRIM(BOTH FROM "title")) > 0))
);


ALTER TABLE "public"."announcements" OWNER TO "postgres";

--
-- Name: app_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."app_permissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "app_id" "uuid" NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."app_permissions" OWNER TO "postgres";

--
-- Name: TABLE "app_permissions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."app_permissions" IS 'Catalogo de permisos por app (vistas/acciones).';


--
-- Name: app_update_policies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."app_update_policies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "app_key" "text" NOT NULL,
    "platform" "text" NOT NULL,
    "min_version" "text" DEFAULT '0.0.0'::"text" NOT NULL,
    "latest_version" "text",
    "force_update" boolean DEFAULT false NOT NULL,
    "store_url" "text",
    "title" "text",
    "message" "text",
    "is_enabled" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "app_update_policies_platform_check" CHECK (("platform" = ANY (ARRAY['ios'::"text", 'android'::"text"])))
);


ALTER TABLE "public"."app_update_policies" OWNER TO "postgres";

--
-- Name: apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."apps" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."apps" OWNER TO "postgres";

--
-- Name: TABLE "apps"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."apps" IS 'Catalogo de aplicaciones Vento OS.';


--
-- Name: area_kinds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."area_kinds" (
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."area_kinds" OWNER TO "postgres";

--
-- Name: TABLE "area_kinds"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."area_kinds" IS 'Catalogo canonico de tipos de area para produccion y remisiones.';


--
-- Name: areas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."areas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "kind" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."areas" OWNER TO "postgres";

--
-- Name: TABLE "areas"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."areas" IS 'Core – tabla canónica para áreas dentro de un site. Usa para segmentar zonas de servicio/operación dentro de cada site.';


--
-- Name: asistencia_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."asistencia_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "empleado_nombre" "text",
    "empleado_id" "text" NOT NULL,
    "fecha_hora" timestamp with time zone NOT NULL,
    "sucursal" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."asistencia_logs" OWNER TO "postgres";

--
-- Name: attendance_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."attendance_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "site_id" "uuid" NOT NULL,
    "action" "text" NOT NULL,
    "source" "text" DEFAULT 'web'::"text" NOT NULL,
    "occurred_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "latitude" numeric(10,7),
    "longitude" numeric(10,7),
    "accuracy_meters" numeric(6,1),
    "device_info" "jsonb" DEFAULT '{}'::"jsonb",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "attendance_logs_action_check" CHECK (("action" = ANY (ARRAY['check_in'::"text", 'check_out'::"text"]))),
    CONSTRAINT "attendance_logs_source_check" CHECK (("source" = ANY (ARRAY['mobile'::"text", 'web'::"text", 'kiosk'::"text", 'system'::"text"])))
);


ALTER TABLE "public"."attendance_logs" OWNER TO "postgres";

--
-- Name: TABLE "attendance_logs"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."attendance_logs" IS 'Registro de check-in/check-out de empleados (ANIMA)';


--
-- Name: COLUMN "attendance_logs"."action"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attendance_logs"."action" IS 'Tipo de acción: check_in o check_out';


--
-- Name: COLUMN "attendance_logs"."source"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attendance_logs"."source" IS 'Origen del registro: mobile, web, kiosk, system';


--
-- Name: COLUMN "attendance_logs"."accuracy_meters"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attendance_logs"."accuracy_meters" IS 'Precisión del GPS en metros';


--
-- Name: attendance_shift_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."attendance_shift_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "site_id" "uuid" NOT NULL,
    "shift_start_at" timestamp with time zone NOT NULL,
    "event_type" "text" NOT NULL,
    "occurred_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "distance_meters" integer,
    "accuracy_meters" integer,
    "source" "text" DEFAULT 'mobile'::"text" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "attendance_shift_events_accuracy_check" CHECK ((("accuracy_meters" IS NULL) OR ("accuracy_meters" >= 0))),
    CONSTRAINT "attendance_shift_events_distance_check" CHECK ((("distance_meters" IS NULL) OR ("distance_meters" >= 0))),
    CONSTRAINT "attendance_shift_events_event_type_check" CHECK (("event_type" = ANY (ARRAY['left_site_open_shift'::"text"]))),
    CONSTRAINT "attendance_shift_events_source_check" CHECK (("source" = ANY (ARRAY['mobile'::"text", 'web'::"text", 'kiosk'::"text", 'system'::"text"])))
);


ALTER TABLE "public"."attendance_shift_events" OWNER TO "postgres";

--
-- Name: cost_centers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."cost_centers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid",
    "name" "text" NOT NULL,
    "monthly_budget" numeric DEFAULT 0,
    "current_month_spend" numeric DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."cost_centers" OWNER TO "postgres";

--
-- Name: TABLE "cost_centers"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."cost_centers" IS 'Core – tabla canónica para centros de costo. Organización financiera por site para asociar compras y presupuestos.';


--
-- Name: document_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."document_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "scope" "public"."document_scope" DEFAULT 'employee'::"public"."document_scope" NOT NULL,
    "requires_expiry" boolean DEFAULT false NOT NULL,
    "validity_months" integer,
    "reminder_days" integer DEFAULT 7 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "display_order" integer DEFAULT 999 NOT NULL
);


ALTER TABLE "public"."document_types" OWNER TO "postgres";

--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."documents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "scope" "public"."document_scope" NOT NULL,
    "owner_employee_id" "uuid" NOT NULL,
    "target_employee_id" "uuid",
    "site_id" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "status" "public"."document_status" DEFAULT 'pending_review'::"public"."document_status" NOT NULL,
    "approved_by" "uuid",
    "approved_at" timestamp with time zone,
    "rejected_reason" "text",
    "storage_path" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_size_bytes" integer,
    "file_mime" "text" DEFAULT 'application/pdf'::"text",
    "expiry_date" "date",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "document_type_id" "uuid",
    "issue_date" "date",
    CONSTRAINT "documents_scope_site_check" CHECK (((("scope" = 'site'::"public"."document_scope") AND ("site_id" IS NOT NULL)) OR ("scope" <> 'site'::"public"."document_scope"))),
    CONSTRAINT "documents_scope_target_check" CHECK (((("scope" = 'employee'::"public"."document_scope") AND ("target_employee_id" IS NOT NULL)) OR ("scope" <> 'employee'::"public"."document_scope")))
);


ALTER TABLE "public"."documents" OWNER TO "postgres";

--
-- Name: employee_areas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employee_areas" (
    "employee_id" "uuid" NOT NULL,
    "area_id" "uuid" NOT NULL,
    "is_primary" boolean DEFAULT false NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."employee_areas" OWNER TO "postgres";

--
-- Name: employee_attendance_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."employee_attendance_status" AS
 SELECT DISTINCT ON ("employee_id") "employee_id",
    "action" AS "current_status",
    "occurred_at" AS "last_action_at",
    "site_id" AS "last_site_id"
   FROM "public"."attendance_logs"
  ORDER BY "employee_id", "occurred_at" DESC;


ALTER VIEW "public"."employee_attendance_status" OWNER TO "postgres";

--
-- Name: VIEW "employee_attendance_status"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW "public"."employee_attendance_status" IS 'Estado actual de asistencia por empleado (último check-in/out)';


--
-- Name: employee_devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employee_devices" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "expo_push_token" "text" NOT NULL,
    "platform" "text",
    "device_label" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."employee_devices" OWNER TO "postgres";

--
-- Name: employee_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employee_permissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "permission_id" "uuid" NOT NULL,
    "is_allowed" boolean DEFAULT true NOT NULL,
    "scope_type" "public"."permission_scope_type" DEFAULT 'site'::"public"."permission_scope_type" NOT NULL,
    "scope_site_id" "uuid",
    "scope_area_id" "uuid",
    "scope_site_type" "public"."site_type",
    "scope_area_kind" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."employee_permissions" OWNER TO "postgres";

--
-- Name: TABLE "employee_permissions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."employee_permissions" IS 'Overrides de permisos por empleado.';


--
-- Name: employee_push_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employee_push_tokens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "platform" "text",
    "device_id" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "last_seen" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."employee_push_tokens" OWNER TO "postgres";

--
-- Name: employee_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employee_settings" (
    "employee_id" "uuid" NOT NULL,
    "selected_site_id" "uuid",
    "selected_area_id" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."employee_settings" OWNER TO "postgres";

--
-- Name: employee_shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employee_shifts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "site_id" "uuid" NOT NULL,
    "shift_date" "date" NOT NULL,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    "break_minutes" integer DEFAULT 0,
    "notes" "text",
    "status" "text" DEFAULT 'scheduled'::"text" NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "employee_shifts_status_check" CHECK (("status" = ANY (ARRAY['scheduled'::"text", 'confirmed'::"text", 'completed'::"text", 'cancelled'::"text", 'no_show'::"text"])))
);


ALTER TABLE "public"."employee_shifts" OWNER TO "postgres";

--
-- Name: TABLE "employee_shifts"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."employee_shifts" IS 'Turnos programados de empleados - ANIMA';


--
-- Name: COLUMN "employee_shifts"."shift_date"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."employee_shifts"."shift_date" IS 'Fecha del turno';


--
-- Name: COLUMN "employee_shifts"."start_time"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."employee_shifts"."start_time" IS 'Hora de inicio programada';


--
-- Name: COLUMN "employee_shifts"."end_time"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."employee_shifts"."end_time" IS 'Hora de fin programada';


--
-- Name: COLUMN "employee_shifts"."break_minutes"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."employee_shifts"."break_minutes" IS 'Minutos de descanso dentro del turno';


--
-- Name: COLUMN "employee_shifts"."status"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."employee_shifts"."status" IS 'scheduled=programado, confirmed=confirmado, completed=completado, cancelled=cancelado, no_show=no se presentó';


--
-- Name: employee_sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employee_sites" (
    "employee_id" "uuid" NOT NULL,
    "site_id" "uuid" NOT NULL,
    "is_primary" boolean DEFAULT false NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."employee_sites" OWNER TO "postgres";

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."employees" (
    "id" "uuid" NOT NULL,
    "site_id" "uuid" NOT NULL,
    "role" "text" NOT NULL,
    "permissions" "jsonb" DEFAULT '{}'::"jsonb",
    "full_name" "text" NOT NULL,
    "alias" "text",
    "pin_code" "text",
    "is_active" boolean DEFAULT true,
    "joined_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "area_id" "uuid"
);


ALTER TABLE "public"."employees" OWNER TO "postgres";

--
-- Name: TABLE "employees"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."employees" IS 'Core – tabla canónica para empleados/staff. Gestión de personal por site, roles y permisos operativos.';


--
-- Name: inventory_cost_policies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_cost_policies" (
    "site_id" "uuid" NOT NULL,
    "cost_basis" "text" DEFAULT 'net'::"text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "updated_by" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "inventory_cost_policies_cost_basis_chk" CHECK (("cost_basis" = ANY (ARRAY['net'::"text", 'gross'::"text"])))
);


ALTER TABLE "public"."inventory_cost_policies" OWNER TO "postgres";

--
-- Name: inventory_count_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_count_lines" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "session_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity_counted" numeric DEFAULT 0 NOT NULL,
    "current_qty_at_close" numeric,
    "quantity_delta" numeric,
    "adjustment_applied_at" timestamp with time zone,
    CONSTRAINT "inventory_count_lines_quantity_counted_check" CHECK (("quantity_counted" >= (0)::numeric))
);


ALTER TABLE "public"."inventory_count_lines" OWNER TO "postgres";

--
-- Name: TABLE "inventory_count_lines"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_count_lines" IS 'Líneas de conteo por sesión; quantity_delta = quantity_counted - current_qty_at_close al cerrar';


--
-- Name: inventory_count_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_count_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'open'::"text" NOT NULL,
    "scope_type" "text" DEFAULT 'site'::"text" NOT NULL,
    "scope_zone" "text",
    "scope_location_id" "uuid",
    "name" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "closed_at" timestamp with time zone,
    "closed_by" "uuid",
    CONSTRAINT "inventory_count_sessions_scope_type_check" CHECK (("scope_type" = ANY (ARRAY['site'::"text", 'zone'::"text", 'loc'::"text"]))),
    CONSTRAINT "inventory_count_sessions_status_check" CHECK (("status" = ANY (ARRAY['open'::"text", 'closed'::"text"])))
);


ALTER TABLE "public"."inventory_count_sessions" OWNER TO "postgres";

--
-- Name: TABLE "inventory_count_sessions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_count_sessions" IS 'Sesiones de conteo cíclico; open=en curso, closed=cerrada con diferencias calculadas';


--
-- Name: inventory_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_entries" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "supplier_name" "text" NOT NULL,
    "invoice_number" "text",
    "received_at" timestamp with time zone DEFAULT "now"(),
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "supplier_id" "uuid",
    "purchase_order_id" "uuid",
    "source_app" "text" DEFAULT 'origo'::"text" NOT NULL,
    "entry_mode" "text" DEFAULT 'normal'::"text" NOT NULL,
    "emergency_reason" "text",
    CONSTRAINT "inventory_entries_emergency_reason_chk" CHECK ((("entry_mode" <> 'emergency'::"text") OR (NULLIF(TRIM(BOTH FROM "emergency_reason"), ''::"text") IS NOT NULL))),
    CONSTRAINT "inventory_entries_entry_mode_chk" CHECK (("entry_mode" = ANY (ARRAY['normal'::"text", 'emergency'::"text"]))),
    CONSTRAINT "inventory_entries_source_app_chk" CHECK (("source_app" = ANY (ARRAY['origo'::"text", 'nexo'::"text"])))
);


ALTER TABLE "public"."inventory_entries" OWNER TO "postgres";

--
-- Name: inventory_entry_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_entry_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "entry_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity_declared" numeric NOT NULL,
    "quantity_received" numeric NOT NULL,
    "unit" "text",
    "notes" "text",
    "discrepancy" numeric GENERATED ALWAYS AS (("quantity_received" - "quantity_declared")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "location_id" "uuid",
    "input_qty" numeric,
    "input_unit_code" "text",
    "conversion_factor_to_stock" numeric,
    "stock_unit_code" "text",
    "input_unit_cost" numeric,
    "stock_unit_cost" numeric,
    "line_total_cost" numeric,
    "cost_source" "text",
    "currency" "text" DEFAULT 'COP'::"text",
    "purchase_order_item_id" "uuid",
    CONSTRAINT "inventory_entry_items_cost_source_chk" CHECK ((("cost_source" IS NULL) OR ("cost_source" = ANY (ARRAY['manual'::"text", 'po_prefill'::"text", 'fallback_product_cost'::"text"]))))
);


ALTER TABLE "public"."inventory_entry_items" OWNER TO "postgres";

--
-- Name: inventory_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_locations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "code" "text" NOT NULL,
    "zone" "text" NOT NULL,
    "aisle" "text",
    "level" "text",
    "description" "text",
    "is_active" boolean DEFAULT true,
    "capacity_units" numeric(10,2),
    "location_type" "text" DEFAULT 'storage'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "parent_location_id" "uuid",
    CONSTRAINT "inventory_locations_location_type_check" CHECK (("location_type" = ANY (ARRAY['storage'::"text", 'picking'::"text", 'receiving'::"text", 'staging'::"text", 'production'::"text"])))
);


ALTER TABLE "public"."inventory_locations" OWNER TO "postgres";

--
-- Name: TABLE "inventory_locations"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_locations" IS 'Ubicaciones físicas en almacén (LOC)';


--
-- Name: COLUMN "inventory_locations"."code"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."inventory_locations"."code" IS 'Código único LOC-{SEDE}-{ZONA}-{PASILLO}-{NIVEL}';


--
-- Name: inventory_lpn_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_lpn_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "lpn_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity" numeric(10,2) DEFAULT 0 NOT NULL,
    "unit" "text" DEFAULT 'unidad'::"text" NOT NULL,
    "lot_number" "text",
    "expiry_date" "date",
    "received_at" timestamp with time zone DEFAULT "now"(),
    "cost_per_unit" numeric(12,2),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."inventory_lpn_items" OWNER TO "postgres";

--
-- Name: TABLE "inventory_lpn_items"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_lpn_items" IS 'Contenido de cada LPN con lote y vencimiento';


--
-- Name: inventory_lpns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_lpns" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "code" "text" NOT NULL,
    "location_id" "uuid",
    "status" "text" DEFAULT 'active'::"text",
    "container_type" "text" DEFAULT 'box'::"text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "label" "text",
    CONSTRAINT "inventory_lpns_container_type_check" CHECK (("container_type" = ANY (ARRAY['box'::"text", 'pallet'::"text", 'bag'::"text", 'tray'::"text", 'bin'::"text", 'other'::"text"]))),
    CONSTRAINT "inventory_lpns_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'empty'::"text", 'consumed'::"text", 'damaged'::"text"])))
);


ALTER TABLE "public"."inventory_lpns" OWNER TO "postgres";

--
-- Name: TABLE "inventory_lpns"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_lpns" IS 'License Plate Numbers - Contenedores/Cajas identificables';


--
-- Name: COLUMN "inventory_lpns"."code"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."inventory_lpns"."code" IS 'Código único LPN-{SEDE}-{AAMM}-{SEQ}';


--
-- Name: inventory_movement_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_movement_types" (
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "affects_stock" smallint NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "inventory_movement_types_affects_stock_check" CHECK (("affects_stock" = ANY (ARRAY['-1'::integer, 0, 1])))
);


ALTER TABLE "public"."inventory_movement_types" OWNER TO "postgres";

--
-- Name: inventory_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_movements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "movement_type" "text" NOT NULL,
    "quantity" numeric NOT NULL,
    "note" "text",
    "related_order_id" "uuid",
    "related_production_request_id" "uuid",
    "related_restock_request_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "related_purchase_order_id" "uuid",
    "unit_cost" numeric,
    "related_production_batch_id" "uuid",
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "input_qty" numeric,
    "input_unit_code" "text",
    "conversion_factor_to_stock" numeric,
    "stock_unit_code" "text",
    "stock_unit_cost" numeric,
    "line_total_cost" numeric
);


ALTER TABLE "public"."inventory_movements" OWNER TO "postgres";

--
-- Name: TABLE "inventory_movements"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_movements" IS 'Core – tabla canónica para movimientos de inventario. Registra entradas/salidas y relaciones con orders/production/restock para auditoría y conciliación.';


--
-- Name: inventory_sku_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE IF NOT EXISTS "public"."inventory_sku_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."inventory_sku_seq" OWNER TO "postgres";

--
-- Name: inventory_stock_by_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_stock_by_location" (
    "location_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "current_qty" numeric DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."inventory_stock_by_location" OWNER TO "postgres";

--
-- Name: inventory_stock_by_site; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_stock_by_site" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "current_qty" numeric DEFAULT '0'::numeric NOT NULL,
    "min_qty" numeric DEFAULT '0'::numeric NOT NULL,
    "max_qty" numeric DEFAULT '0'::numeric NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "avg_unit_cost" numeric
);


ALTER TABLE "public"."inventory_stock_by_site" OWNER TO "postgres";

--
-- Name: TABLE "inventory_stock_by_site"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_stock_by_site" IS 'Core – tabla canónica para stock por sitio. Registra cantidades actuales y umbrales por site+product; usar para consultas de disponibilidad y reabastecimiento.';


--
-- Name: inventory_transfer_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_transfer_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "transfer_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity" numeric NOT NULL,
    "unit" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "input_qty" numeric,
    "input_unit_code" "text",
    "conversion_factor_to_stock" numeric,
    "stock_unit_code" "text"
);


ALTER TABLE "public"."inventory_transfer_items" OWNER TO "postgres";

--
-- Name: inventory_transfers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_transfers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "from_loc_id" "uuid" NOT NULL,
    "to_loc_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'completed'::"text" NOT NULL,
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."inventory_transfers" OWNER TO "postgres";

--
-- Name: inventory_unit_aliases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_unit_aliases" (
    "alias" "text" NOT NULL,
    "unit_code" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."inventory_unit_aliases" OWNER TO "postgres";

--
-- Name: TABLE "inventory_unit_aliases"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_unit_aliases" IS 'Aliases para mapear variantes de captura (ej. litro, lts, unidad) hacia una unidad canonica.';


--
-- Name: inventory_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."inventory_units" (
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "family" "text" NOT NULL,
    "factor_to_base" numeric NOT NULL,
    "symbol" "text",
    "display_decimals" integer DEFAULT 2 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "inventory_units_display_decimals_check" CHECK ((("display_decimals" >= 0) AND ("display_decimals" <= 6))),
    CONSTRAINT "inventory_units_factor_to_base_check" CHECK (("factor_to_base" > (0)::numeric)),
    CONSTRAINT "inventory_units_family_check" CHECK (("family" = ANY (ARRAY['volume'::"text", 'mass'::"text", 'count'::"text"])))
);


ALTER TABLE "public"."inventory_units" OWNER TO "postgres";

--
-- Name: TABLE "inventory_units"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."inventory_units" IS 'Catalogo canonic de unidades de inventario para conversion entre unidades de la misma familia.';


--
-- Name: loyalty_external_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."loyalty_external_sales" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "amount_cop" numeric NOT NULL,
    "points_awarded" integer NOT NULL,
    "external_ref" "text" NOT NULL,
    "source_app" "text" DEFAULT 'pulso'::"text" NOT NULL,
    "awarded_by" "uuid" NOT NULL,
    "loyalty_transaction_id" "uuid",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "loyalty_external_sales_amount_cop_check" CHECK (("amount_cop" > (0)::numeric)),
    CONSTRAINT "loyalty_external_sales_external_ref_chk" CHECK (("btrim"("external_ref") <> ''::"text")),
    CONSTRAINT "loyalty_external_sales_points_awarded_check" CHECK (("points_awarded" > 0))
);


ALTER TABLE "public"."loyalty_external_sales" OWNER TO "postgres";

--
-- Name: loyalty_redemptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."loyalty_redemptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "order_id" "uuid",
    "reward_id" "uuid" NOT NULL,
    "points_spent" integer NOT NULL,
    "qr_code" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "validated_at" timestamp with time zone,
    "site_id" "uuid",
    CONSTRAINT "loyalty_redemptions_points_spent_check" CHECK (("points_spent" > 0)),
    CONSTRAINT "loyalty_redemptions_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'validated'::"text", 'cancelled'::"text"])))
);


ALTER TABLE "public"."loyalty_redemptions" OWNER TO "postgres";

--
-- Name: TABLE "loyalty_redemptions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."loyalty_redemptions" IS 'Core – tabla canónica para redenciones de lealtad. Registro de canjes/validaciones y estado asociado a orders y usuarios.';


--
-- Name: loyalty_rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."loyalty_rewards" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "points_cost" integer NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "site_id" "uuid",
    CONSTRAINT "loyalty_rewards_points_cost_check" CHECK (("points_cost" > 0))
);


ALTER TABLE "public"."loyalty_rewards" OWNER TO "postgres";

--
-- Name: TABLE "loyalty_rewards"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."loyalty_rewards" IS 'Core – tabla canónica para recompensas de lealtad. Catálogo de recompensas canónicas que los usuarios pueden canjear.';


--
-- Name: loyalty_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."loyalty_transactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "order_id" "uuid",
    "kind" "text" NOT NULL,
    "points_delta" integer NOT NULL,
    "description" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "loyalty_transactions_kind_check" CHECK (("kind" = ANY (ARRAY['earn'::"text", 'spend'::"text", 'adjust'::"text"]))),
    CONSTRAINT "loyalty_transactions_points_delta_check" CHECK (("points_delta" <> 0))
);


ALTER TABLE "public"."loyalty_transactions" OWNER TO "postgres";

--
-- Name: TABLE "loyalty_transactions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."loyalty_transactions" IS 'Core – tabla canónica para transacciones de lealtad. Registro de puntos ganados/gastados por user y relación con orders.';


--
-- Name: lpn_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE IF NOT EXISTS "public"."lpn_sequence"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."lpn_sequence" OWNER TO "postgres";

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT '1'::numeric NOT NULL,
    "unit_price" numeric DEFAULT '0'::numeric NOT NULL,
    "total_amount" numeric DEFAULT '0'::numeric NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "seat_number" integer,
    "course" "text" DEFAULT 'main'::"text",
    "status" "text" DEFAULT 'pending'::"text",
    "sent_at" timestamp with time zone,
    "allergy_alert" "text",
    "is_comped" boolean DEFAULT false,
    "comp_reason" "text"
);


ALTER TABLE "public"."order_items" OWNER TO "postgres";

--
-- Name: TABLE "order_items"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."order_items" IS 'Core – tabla canónica para líneas de pedido. Detalle de productos, cantidades y precios asociados a cada order.';


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "client_id" "uuid",
    "order_type" "text" DEFAULT 'dine_in'::"text" NOT NULL,
    "source" "text" DEFAULT 'vento_os'::"text" NOT NULL,
    "table_number" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "payment_status" "text" DEFAULT 'unpaid'::"text" NOT NULL,
    "total_amount" numeric DEFAULT '0'::numeric NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "inventory_processed" boolean DEFAULT false NOT NULL,
    "loyalty_processed" boolean DEFAULT false NOT NULL,
    "loyalty_points_awarded" integer DEFAULT 0 NOT NULL,
    "guest_info" "jsonb" DEFAULT '{}'::"jsonb",
    "site_id" "uuid",
    "session_id" "uuid",
    "server_id" "uuid",
    "split_type" "text",
    "discount_amount" numeric DEFAULT 0,
    "discount_reason" "text",
    "voided_at" timestamp with time zone,
    "voided_by" "uuid",
    "void_reason" "text"
);


ALTER TABLE "public"."orders" OWNER TO "postgres";

--
-- Name: TABLE "orders"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."orders" IS 'Core – tabla canónica para pedidos de clientes. Registro maestro de órdenes de venta/consumo (dine-in/takeaway) y su estado en el sistema.';


--
-- Name: pass_satellites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pass_satellites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "subtitle" "text",
    "tags" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "site_id" "uuid" NOT NULL,
    "logo_url" "text",
    "watermark_icon" "text",
    "gradient_start" "text",
    "gradient_end" "text",
    "accent_color" "text",
    "primary_color" "text",
    "background_color" "text",
    "text_color" "text",
    "text_secondary_color" "text",
    "card_color" "text",
    "border_color" "text",
    "indicator_color" "text",
    "loading_color" "text",
    "review_url" "text",
    "maps_url" "text",
    "address_override" "text",
    "latitude_override" double precision,
    "longitude_override" double precision,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "card_logo_url" "text",
    "header_logo_url" "text"
);


ALTER TABLE "public"."pass_satellites" OWNER TO "postgres";

--
-- Name: pos_cash_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_cash_movements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shift_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "amount" numeric NOT NULL,
    "payment_method" "text",
    "reference" "text",
    "description" "text",
    "order_id" "uuid",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_cash_movements" OWNER TO "postgres";

--
-- Name: pos_cash_shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_cash_shifts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'open'::"text" NOT NULL,
    "opened_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "closed_at" timestamp with time zone,
    "opening_amount" numeric DEFAULT 0 NOT NULL,
    "expected_amount" numeric,
    "counted_amount" numeric,
    "difference" numeric,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_cash_shifts" OWNER TO "postgres";

--
-- Name: pos_modifier_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_modifier_options" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "modifier_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "price_adjustment" numeric DEFAULT 0,
    "display_order" integer DEFAULT 0,
    "is_default" boolean DEFAULT false,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_modifier_options" OWNER TO "postgres";

--
-- Name: pos_modifiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_modifiers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid",
    "name" "text" NOT NULL,
    "type" "text" DEFAULT 'single'::"text" NOT NULL,
    "is_required" boolean DEFAULT false,
    "min_selections" integer DEFAULT 0,
    "max_selections" integer DEFAULT 1,
    "display_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_modifiers" OWNER TO "postgres";

--
-- Name: pos_order_item_modifiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_order_item_modifiers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_item_id" "uuid" NOT NULL,
    "modifier_id" "uuid" NOT NULL,
    "modifier_option_id" "uuid",
    "price_adjustment" numeric DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_order_item_modifiers" OWNER TO "postgres";

--
-- Name: pos_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "session_id" "uuid",
    "shift_id" "uuid",
    "payment_method" "text" NOT NULL,
    "amount" numeric NOT NULL,
    "tip_amount" numeric DEFAULT 0,
    "reference" "text",
    "status" "text" DEFAULT 'completed'::"text" NOT NULL,
    "processed_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_payments" OWNER TO "postgres";

--
-- Name: pos_product_modifiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_product_modifiers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "modifier_id" "uuid" NOT NULL,
    "display_order" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_product_modifiers" OWNER TO "postgres";

--
-- Name: pos_session_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_session_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "session_id" "uuid" NOT NULL,
    "order_id" "uuid" NOT NULL,
    "seat_number" integer,
    "course" "text" DEFAULT 'main'::"text",
    "course_status" "text" DEFAULT 'pending'::"text",
    "fired_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_session_orders" OWNER TO "postgres";

--
-- Name: pos_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "table_id" "uuid" NOT NULL,
    "server_id" "uuid",
    "status" "text" DEFAULT 'open'::"text" NOT NULL,
    "pax" integer DEFAULT 1,
    "opened_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "closed_at" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_sessions" OWNER TO "postgres";

--
-- Name: pos_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_tables" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "zone_id" "uuid",
    "name" "text" NOT NULL,
    "table_number" integer,
    "shape" "text" DEFAULT 'square'::"text" NOT NULL,
    "capacity" integer DEFAULT 4 NOT NULL,
    "position_x" numeric DEFAULT 0 NOT NULL,
    "position_y" numeric DEFAULT 0 NOT NULL,
    "rotation" numeric DEFAULT 0,
    "width" numeric DEFAULT 80,
    "height" numeric DEFAULT 80,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_tables" OWNER TO "postgres";

--
-- Name: pos_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."pos_zones" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "color" "text" DEFAULT '#00d4ff'::"text",
    "display_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."pos_zones" OWNER TO "postgres";

--
-- Name: procurement_agreed_prices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."procurement_agreed_prices" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "agreed_price" numeric NOT NULL,
    "currency" "text" DEFAULT 'COP'::"text",
    "valid_from" timestamp with time zone DEFAULT "now"(),
    "valid_until" timestamp with time zone,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."procurement_agreed_prices" OWNER TO "postgres";

--
-- Name: TABLE "procurement_agreed_prices"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."procurement_agreed_prices" IS 'Core – tabla canónica para precios acordados con proveedores. Almacena tarifas vigentes por supplier+product para negociar/planificar compras.';


--
-- Name: procurement_reception_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."procurement_reception_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reception_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity_declared" numeric NOT NULL,
    "quantity_received" numeric NOT NULL,
    "discrepancy" numeric GENERATED ALWAYS AS (("quantity_received" - "quantity_declared")) STORED
);


ALTER TABLE "public"."procurement_reception_items" OWNER TO "postgres";

--
-- Name: TABLE "procurement_reception_items"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."procurement_reception_items" IS 'Core – tabla canónica para ítems de recepción de compra. Detalle de cantidades recibidas y discrepancias por recepción.';


--
-- Name: procurement_receptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."procurement_receptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "purchase_order_id" "uuid" NOT NULL,
    "received_by" "uuid" NOT NULL,
    "received_at" timestamp with time zone DEFAULT "now"(),
    "site_id" "uuid",
    "evidence_photo_url" "text" NOT NULL,
    "weight_source" "text" DEFAULT 'MANUAL'::"text",
    "notes" "text",
    "geolocation" "jsonb"
);


ALTER TABLE "public"."procurement_receptions" OWNER TO "postgres";

--
-- Name: TABLE "procurement_receptions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."procurement_receptions" IS 'Core – tabla canónica para recepciones de compras. Registra el acto de recepción físico/fecha/evidencia por purchase_order.';


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text",
    "description" "text",
    "display_order" integer,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "domain" "text",
    "parent_id" "uuid",
    "updated_at" timestamp with time zone,
    "site_id" "uuid",
    "applies_to_kinds" "text"[] DEFAULT ARRAY['insumo'::"text", 'preparacion'::"text", 'venta'::"text", 'equipo'::"text"] NOT NULL,
    CONSTRAINT "product_categories_applies_to_kinds_allowed_chk" CHECK (("applies_to_kinds" <@ ARRAY['insumo'::"text", 'preparacion'::"text", 'venta'::"text", 'equipo'::"text"])),
    CONSTRAINT "product_categories_applies_to_kinds_nonempty_chk" CHECK (("cardinality"("applies_to_kinds") > 0)),
    CONSTRAINT "product_categories_domain_requires_venta_chk" CHECK (((NULLIF(TRIM(BOTH FROM "domain"), ''::"text") IS NULL) OR ("applies_to_kinds" @> ARRAY['venta'::"text"])))
);


ALTER TABLE "public"."product_categories" OWNER TO "postgres";

--
-- Name: TABLE "product_categories"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."product_categories" IS 'Core – tabla canónica para categorías de productos. Clasificación canónica usada por products (referenciar por category_id) en nuevas implementaciones.';


--
-- Name: COLUMN "product_categories"."description"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_categories"."description" IS 'Descripcion operativa de referencia para clasificar items. Opcional para categorias de venta.';


--
-- Name: COLUMN "product_categories"."site_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_categories"."site_id" IS 'Sede específica de la categoría. NULL = categoría global compartida entre todas las sedes';


--
-- Name: COLUMN "product_categories"."applies_to_kinds"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_categories"."applies_to_kinds" IS 'Tipos logicos donde aplica la categoria: insumo, preparacion, venta, equipo.';


--
-- Name: product_cost_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_cost_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "site_id" "uuid",
    "source" "text" NOT NULL,
    "source_entry_id" "uuid",
    "source_adjust_movement_id" "uuid",
    "qty_before" numeric DEFAULT 0 NOT NULL,
    "qty_in" numeric DEFAULT 0 NOT NULL,
    "cost_before" numeric DEFAULT 0 NOT NULL,
    "cost_in" numeric DEFAULT 0 NOT NULL,
    "cost_after" numeric DEFAULT 0 NOT NULL,
    "basis" "text" DEFAULT 'net'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    CONSTRAINT "product_cost_events_basis_chk" CHECK (("basis" = ANY (ARRAY['net'::"text", 'gross'::"text"]))),
    CONSTRAINT "product_cost_events_source_chk" CHECK (("source" = ANY (ARRAY['entry'::"text", 'adjust'::"text", 'production'::"text"])))
);


ALTER TABLE "public"."product_cost_events" OWNER TO "postgres";

--
-- Name: product_inventory_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_inventory_profiles" (
    "product_id" "uuid" NOT NULL,
    "track_inventory" boolean DEFAULT true NOT NULL,
    "inventory_kind" "text" DEFAULT 'unclassified'::"text" NOT NULL,
    "default_unit" "text",
    "lot_tracking" boolean DEFAULT false NOT NULL,
    "expiry_tracking" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "unit_family" "text",
    "costing_mode" "text" DEFAULT 'auto_primary_supplier'::"text" NOT NULL,
    CONSTRAINT "product_inventory_profiles_costing_mode_chk" CHECK (("costing_mode" = ANY (ARRAY['auto_primary_supplier'::"text", 'manual'::"text"]))),
    CONSTRAINT "product_inventory_profiles_kind_chk" CHECK (("inventory_kind" = ANY (ARRAY['ingredient'::"text", 'finished'::"text", 'resale'::"text", 'packaging'::"text", 'asset'::"text", 'unclassified'::"text"]))),
    CONSTRAINT "product_inventory_profiles_unit_family_chk" CHECK ((("unit_family" = ANY (ARRAY['volume'::"text", 'mass'::"text", 'count'::"text"])) OR ("unit_family" IS NULL)))
);


ALTER TABLE "public"."product_inventory_profiles" OWNER TO "postgres";

--
-- Name: product_site_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_site_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "default_area_kind" "text",
    "audience" "text" DEFAULT 'BOTH'::"text" NOT NULL,
    "min_stock_qty" numeric,
    "min_stock_input_mode" "text",
    "min_stock_purchase_qty" numeric,
    "min_stock_purchase_unit_code" "text",
    "min_stock_purchase_to_base_factor" numeric,
    CONSTRAINT "product_site_settings_audience_chk" CHECK (("audience" = ANY (ARRAY['SAUDO'::"text", 'VCF'::"text", 'BOTH'::"text", 'INTERNAL'::"text"]))),
    CONSTRAINT "product_site_settings_min_stock_input_mode_chk" CHECK ((("min_stock_input_mode" IS NULL) OR ("min_stock_input_mode" = ANY (ARRAY['base'::"text", 'purchase'::"text"])))),
    CONSTRAINT "product_site_settings_min_stock_mode_consistency_chk" CHECK ((("min_stock_input_mode" IS NULL) OR ("min_stock_input_mode" = 'base'::"text") OR (("min_stock_input_mode" = 'purchase'::"text") AND ("min_stock_purchase_qty" IS NOT NULL) AND ("min_stock_purchase_unit_code" IS NOT NULL) AND ("min_stock_purchase_to_base_factor" IS NOT NULL)))),
    CONSTRAINT "product_site_settings_min_stock_purchase_qty_chk" CHECK ((("min_stock_purchase_qty" IS NULL) OR ("min_stock_purchase_qty" >= (0)::numeric))),
    CONSTRAINT "product_site_settings_min_stock_purchase_to_base_factor_chk" CHECK ((("min_stock_purchase_to_base_factor" IS NULL) OR ("min_stock_purchase_to_base_factor" > (0)::numeric))),
    CONSTRAINT "product_site_settings_min_stock_qty_chk" CHECK ((("min_stock_qty" IS NULL) OR ("min_stock_qty" >= (0)::numeric)))
);


ALTER TABLE "public"."product_site_settings" OWNER TO "postgres";

--
-- Name: TABLE "product_site_settings"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."product_site_settings" IS 'Catalogo activo por sede para productos (sin depender de stock).';


--
-- Name: COLUMN "product_site_settings"."default_area_kind"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_site_settings"."default_area_kind" IS 'Area de solicitud sugerida para remisiones.';


--
-- Name: COLUMN "product_site_settings"."min_stock_input_mode"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_site_settings"."min_stock_input_mode" IS 'Modo de captura del minimo: base o purchase. El calculo operativo siempre usa min_stock_qty en unidad base.';


--
-- Name: COLUMN "product_site_settings"."min_stock_purchase_qty"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_site_settings"."min_stock_purchase_qty" IS 'Cantidad de minimo capturada en unidad de compra.';


--
-- Name: COLUMN "product_site_settings"."min_stock_purchase_unit_code"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_site_settings"."min_stock_purchase_unit_code" IS 'Codigo de la unidad de compra usada para capturar el minimo.';


--
-- Name: COLUMN "product_site_settings"."min_stock_purchase_to_base_factor"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."product_site_settings"."min_stock_purchase_to_base_factor" IS 'Factor de conversion de unidad de compra a unidad base (base por 1 unidad de compra).';


--
-- Name: product_sku_aliases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_sku_aliases" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "sku" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."product_sku_aliases" OWNER TO "postgres";

--
-- Name: product_sku_sequences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_sku_sequences" (
    "brand_code" "text" NOT NULL,
    "type_code" "text" NOT NULL,
    "last_value" integer DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."product_sku_sequences" OWNER TO "postgres";

--
-- Name: product_suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_suppliers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "supplier_sku" "text",
    "purchase_unit" "text",
    "purchase_unit_size" numeric,
    "purchase_price" numeric,
    "currency" "text" DEFAULT 'COP'::"text" NOT NULL,
    "lead_time_days" integer,
    "min_order_qty" numeric,
    "is_primary" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "purchase_pack_qty" numeric,
    "purchase_pack_unit_code" "text",
    CONSTRAINT "product_suppliers_purchase_pack_qty_chk" CHECK ((("purchase_pack_qty" IS NULL) OR ("purchase_pack_qty" > (0)::numeric)))
);


ALTER TABLE "public"."product_suppliers" OWNER TO "postgres";

--
-- Name: TABLE "product_suppliers"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."product_suppliers" IS 'Core – tabla canónica para relación producto↔proveedor. Define proveedores asociados a productos, SKUs proveedor y condiciones de compra.';


--
-- Name: product_uom_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_uom_profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "label" "text" NOT NULL,
    "input_unit_code" "text" NOT NULL,
    "qty_in_input_unit" numeric NOT NULL,
    "qty_in_stock_unit" numeric NOT NULL,
    "is_default" boolean DEFAULT false NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "source" "text" DEFAULT 'manual'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "usage_context" "text" DEFAULT 'general'::"text" NOT NULL,
    CONSTRAINT "product_uom_profiles_qty_input_chk" CHECK (("qty_in_input_unit" > (0)::numeric)),
    CONSTRAINT "product_uom_profiles_qty_stock_chk" CHECK (("qty_in_stock_unit" > (0)::numeric)),
    CONSTRAINT "product_uom_profiles_source_chk" CHECK (("source" = ANY (ARRAY['manual'::"text", 'supplier_primary'::"text"]))),
    CONSTRAINT "product_uom_profiles_usage_context_chk" CHECK (("usage_context" = ANY (ARRAY['general'::"text", 'purchase'::"text", 'remission'::"text"])))
);


ALTER TABLE "public"."product_uom_profiles" OWNER TO "postgres";

--
-- Name: production_batch_consumptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."production_batch_consumptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "batch_id" "uuid" NOT NULL,
    "ingredient_product_id" "uuid" NOT NULL,
    "location_id" "uuid" NOT NULL,
    "required_qty" numeric DEFAULT 0 NOT NULL,
    "consumed_qty" numeric DEFAULT 0 NOT NULL,
    "stock_unit_code" "text" NOT NULL,
    "movement_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    CONSTRAINT "production_batch_consumptions_consumed_qty_chk" CHECK (("consumed_qty" >= (0)::numeric)),
    CONSTRAINT "production_batch_consumptions_required_qty_chk" CHECK (("required_qty" >= (0)::numeric))
);


ALTER TABLE "public"."production_batch_consumptions" OWNER TO "postgres";

--
-- Name: production_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."production_batches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "recipe_card_id" "uuid",
    "produced_qty" numeric NOT NULL,
    "produced_unit" "text" NOT NULL,
    "total_cost" numeric,
    "unit_cost" numeric,
    "status" "text" DEFAULT 'posted'::"text" NOT NULL,
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "batch_code" "text",
    "expires_at" timestamp with time zone,
    "destination_location_id" "uuid",
    "recipe_consumed" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."production_batches" OWNER TO "postgres";

--
-- Name: production_request_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."production_request_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "request_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "recipe_id" "uuid",
    "quantity" numeric DEFAULT '0'::numeric,
    "unit" "text",
    "requested_quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "produced_quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "loaded_quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "received_quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "stage_status" "text" DEFAULT '''pending'''::"text" NOT NULL,
    "production_area_kind" "text" DEFAULT 'general'::"text"
);


ALTER TABLE "public"."production_request_items" OWNER TO "postgres";

--
-- Name: TABLE "production_request_items"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."production_request_items" IS 'Core – tabla canónica para ítems de producción. Detalle de productos/recetas y cantidades asociadas a cada producción.';


--
-- Name: production_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."production_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "from_location" "text" NOT NULL,
    "to_location" "text" NOT NULL,
    "status" "text" DEFAULT '''pending'''::"text" NOT NULL,
    "needed_for_date" "date",
    "notes" "text",
    "from_site_id" "uuid",
    "to_site_id" "uuid"
);


ALTER TABLE "public"."production_requests" OWNER TO "postgres";

--
-- Name: TABLE "production_requests"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."production_requests" IS 'Core – tabla canónica para solicitudes de producción. Coordina producción interna desde inventario/recetas entre sitios.';


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "sku" "text",
    "price" numeric,
    "cost" numeric,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "product_type" "text" DEFAULT 'venta'::"text" NOT NULL,
    "category_id" "uuid" NOT NULL,
    "unit" "text" NOT NULL,
    "cost_original" numeric,
    "production_area_kind" "text" DEFAULT 'general'::"text",
    "image_url" "text",
    "catalog_image_url" "text",
    "stock_unit_code" "text",
    CONSTRAINT "products_product_type_check" CHECK (("product_type" = ANY (ARRAY['venta'::"text", 'insumo'::"text", 'preparacion'::"text"])))
);


ALTER TABLE "public"."products" OWNER TO "postgres";

--
-- Name: TABLE "products"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."products" IS 'Core – tabla canónica para catálogo maestro de productos y preparaciones. Catálogo maestro de productos de venta, insumos y preparaciones; usar en todo el código nuevo.';


--
-- Name: COLUMN "products"."unit"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."products"."unit" IS 'Unidad base del producto/insumo (ej: "g", "kg", "ml", "L", "unidades"). 
Migrado desde inventory.unit (legacy).';


--
-- Name: COLUMN "products"."image_url"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."products"."image_url" IS 'URL de la foto del producto (ficha maestra).';


--
-- Name: COLUMN "products"."catalog_image_url"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."products"."catalog_image_url" IS 'URL de la foto de catálogo (listados, reportes).';


--
-- Name: purchase_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."purchase_order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "purchase_order_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity_ordered" numeric NOT NULL,
    "quantity_received" numeric,
    "unit_cost" numeric NOT NULL,
    "line_total" numeric,
    "unit" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."purchase_order_items" OWNER TO "postgres";

--
-- Name: TABLE "purchase_order_items"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."purchase_order_items" IS 'Core – tabla canónica para líneas de órdenes de compra. Detalle de productos, cantidades y costos por purchase_order.';


--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."purchase_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "site_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expected_at" timestamp with time zone,
    "received_at" timestamp with time zone,
    "total_amount" numeric,
    "currency" "text" DEFAULT 'COP'::"text" NOT NULL,
    "notes" "text",
    "cost_center_id" "uuid",
    "approved_by" "uuid",
    "approval_date" timestamp with time zone,
    "created_by" "uuid" DEFAULT "auth"."uid"()
);


ALTER TABLE "public"."purchase_orders" OWNER TO "postgres";

--
-- Name: TABLE "purchase_orders"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."purchase_orders" IS 'Core – tabla canónica para órdenes de compra a proveedores. Registra pedidos, estado y metadatos para recepción y pagos.';


--
-- Name: recipe_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."recipe_cards" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "yield_qty" numeric DEFAULT 1 NOT NULL,
    "yield_unit" "text" NOT NULL,
    "portion_size" numeric,
    "portion_unit" "text",
    "prep_time_minutes" integer,
    "shelf_life_days" integer,
    "area" "text",
    "difficulty" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "site_id" "uuid",
    "area_id" "uuid",
    "recipe_description" "text",
    "cover_image_path" "text",
    "video_path" "text",
    "status" "public"."recipe_status" DEFAULT 'draft'::"public"."recipe_status" NOT NULL,
    CONSTRAINT "recipe_cards_yield_qty_positive" CHECK (("yield_qty" > (0)::numeric))
);


ALTER TABLE "public"."recipe_cards" OWNER TO "postgres";

--
-- Name: COLUMN "recipe_cards"."status"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."recipe_cards"."status" IS 'Recipe workflow status: draft (work in progress), published (visible to staff), archived (hidden)';


--
-- Name: recipe_steps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."recipe_steps" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "recipe_card_id" "uuid" NOT NULL,
    "step_number" integer NOT NULL,
    "description" "text" NOT NULL,
    "tip" "text",
    "time_minutes" integer,
    "image_path" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "step_image_url" "text",
    "step_video_url" "text",
    CONSTRAINT "recipe_steps_step_number_positive" CHECK (("step_number" > 0)),
    CONSTRAINT "recipe_steps_time_minutes_positive" CHECK ((("time_minutes" IS NULL) OR ("time_minutes" >= 0)))
);


ALTER TABLE "public"."recipe_steps" OWNER TO "postgres";

--
-- Name: COLUMN "recipe_steps"."step_image_url"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."recipe_steps"."step_image_url" IS 'Foto opcional para documentar visualmente el paso de la receta.';


--
-- Name: COLUMN "recipe_steps"."step_video_url"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."recipe_steps"."step_video_url" IS 'URL opcional de video para el paso de la receta (YouTube, Drive u origen interno).';


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."recipes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ingredient_product_id" "uuid"
);


ALTER TABLE "public"."recipes" OWNER TO "postgres";

--
-- Name: TABLE "recipes"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."recipes" IS 'Core – tabla canónica para recetas/consumos. Define relaciones producto→insumo (inventory) y cantidades necesarias para producción.';


--
-- Name: COLUMN "recipes"."product_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."recipes"."product_id" IS 'ID del producto final (pizza, bebida, preparación terminada).';


--
-- Name: COLUMN "recipes"."ingredient_product_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."recipes"."ingredient_product_id" IS 'Producto usado como ingrediente (FK a products.id). 
El producto debe tener product_type = ''insumo''. 
Este es el campo canónico que reemplaza a inventory_id (legacy).';


--
-- Name: restock_request_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."restock_request_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "request_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "unit" "text",
    "transfer_unit_price" numeric,
    "transfer_currency" "text",
    "transfer_total" numeric,
    "production_area_kind" "text" DEFAULT 'general'::"text",
    "prepared_quantity" numeric DEFAULT 0 NOT NULL,
    "shipped_quantity" numeric DEFAULT 0 NOT NULL,
    "received_quantity" numeric DEFAULT 0 NOT NULL,
    "shortage_quantity" numeric DEFAULT 0 NOT NULL,
    "item_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "notes" "text",
    "input_qty" numeric,
    "input_unit_code" "text",
    "conversion_factor_to_stock" numeric,
    "stock_unit_code" "text",
    "source_location_id" "uuid"
);


ALTER TABLE "public"."restock_request_items" OWNER TO "postgres";

--
-- Name: TABLE "restock_request_items"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."restock_request_items" IS 'Core – tabla canónica para ítems de reabastecimiento. Detalle de productos y cantidades solicitadas en cada restock_request.';


--
-- Name: restock_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."restock_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "from_location" "text" NOT NULL,
    "to_location" "text" NOT NULL,
    "status" "text" DEFAULT '''pending'''::"text" NOT NULL,
    "expected_date" "date",
    "notes" "text",
    "from_site_id" "uuid",
    "to_site_id" "uuid",
    "pricing_mode" "text" DEFAULT 'none'::"text" NOT NULL,
    "pricing_status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "internal_supplier_site_id" "uuid",
    "request_code" "text",
    "requested_by_site_id" "uuid",
    "status_updated_at" timestamp with time zone DEFAULT "now"(),
    "prepared_at" timestamp with time zone,
    "prepared_by" "uuid",
    "in_transit_at" timestamp with time zone,
    "in_transit_by" "uuid",
    "received_at" timestamp with time zone,
    "received_by" "uuid",
    "cancelled_at" timestamp with time zone,
    "closed_at" timestamp with time zone,
    "priority" "text" DEFAULT 'normal'::"text",
    "request_type" "text" DEFAULT 'internal'::"text"
);


ALTER TABLE "public"."restock_requests" OWNER TO "postgres";

--
-- Name: TABLE "restock_requests"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."restock_requests" IS 'Core – tabla canónica para solicitudes de reabastecimiento. Gestiona pedidos internos de re-stock entre ubicaciones o hacia proveedores.';


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "role" "text" NOT NULL,
    "permission_id" "uuid" NOT NULL,
    "scope_type" "public"."permission_scope_type" DEFAULT 'site'::"public"."permission_scope_type" NOT NULL,
    "scope_site_type" "public"."site_type",
    "scope_area_kind" "text",
    "is_allowed" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";

--
-- Name: TABLE "role_permissions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."role_permissions" IS 'Permisos base por rol.';


--
-- Name: role_site_type_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."role_site_type_rules" (
    "role" "text" NOT NULL,
    "site_type" "public"."site_type" NOT NULL,
    "is_allowed" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."role_site_type_rules" OWNER TO "postgres";

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."roles" (
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";

--
-- Name: TABLE "roles"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."roles" IS 'Catalogo canonico de roles de staff.';


--
-- Name: sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."sites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "type" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "address" "text",
    "site_type" "public"."site_type" DEFAULT 'satellite'::"public"."site_type" NOT NULL,
    "site_kind" "text" NOT NULL,
    "checkin_radius_meters" integer DEFAULT 50,
    "is_public" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."sites" OWNER TO "postgres";

--
-- Name: TABLE "sites"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."sites" IS 'Core – tabla canónica para ubicaciones (sites). Define locales/almacenes donde hay stock, movimientos y operaciones.';


--
-- Name: COLUMN "sites"."latitude"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."sites"."latitude" IS 'Latitud de la sede para LiveMap';


--
-- Name: COLUMN "sites"."longitude"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."sites"."longitude" IS 'Longitud de la sede para LiveMap';


--
-- Name: COLUMN "sites"."address"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."sites"."address" IS 'Dirección física de la sede';


--
-- Name: COLUMN "sites"."checkin_radius_meters"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."sites"."checkin_radius_meters" IS 'Radio en metros para validar check-in GPS (default 50m)';


--
-- Name: shift_calendar_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."shift_calendar_view" AS
 SELECT "s"."id",
    "s"."employee_id",
    "e"."full_name" AS "employee_name",
    "e"."alias" AS "employee_alias",
    "s"."site_id",
    "si"."name" AS "site_name",
    "s"."shift_date",
    "s"."start_time",
    "s"."end_time",
    "s"."break_minutes",
    "s"."notes",
    "s"."status",
    ((EXTRACT(epoch FROM ("s"."end_time" - "s"."start_time")) / (3600)::numeric) - (("s"."break_minutes")::numeric / 60.0)) AS "scheduled_hours",
    ( SELECT "al"."occurred_at"
           FROM "public"."attendance_logs" "al"
          WHERE (("al"."employee_id" = "s"."employee_id") AND ("al"."site_id" = "s"."site_id") AND ("al"."action" = 'check_in'::"text") AND ("date"("al"."occurred_at") = "s"."shift_date"))
          ORDER BY "al"."occurred_at"
         LIMIT 1) AS "actual_check_in",
    ( SELECT "al"."occurred_at"
           FROM "public"."attendance_logs" "al"
          WHERE (("al"."employee_id" = "s"."employee_id") AND ("al"."site_id" = "s"."site_id") AND ("al"."action" = 'check_out'::"text") AND ("date"("al"."occurred_at") = "s"."shift_date"))
          ORDER BY "al"."occurred_at" DESC
         LIMIT 1) AS "actual_check_out",
    "s"."created_at",
    "s"."updated_at"
   FROM (("public"."employee_shifts" "s"
     JOIN "public"."employees" "e" ON (("e"."id" = "s"."employee_id")))
     JOIN "public"."sites" "si" ON (("si"."id" = "s"."site_id")));


ALTER VIEW "public"."shift_calendar_view" OWNER TO "postgres";

--
-- Name: site_production_pick_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."site_production_pick_order" (
    "site_id" "uuid" NOT NULL,
    "location_id" "uuid" NOT NULL,
    "priority" integer DEFAULT 100 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "site_production_pick_order_priority_chk" CHECK (("priority" > 0))
);


ALTER TABLE "public"."site_production_pick_order" OWNER TO "postgres";

--
-- Name: site_supply_routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."site_supply_routes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "requesting_site_id" "uuid" NOT NULL,
    "fulfillment_site_id" "uuid" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."site_supply_routes" OWNER TO "postgres";

--
-- Name: TABLE "site_supply_routes"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."site_supply_routes" IS 'Mapa de sede solicitante -> sede que abastece remisiones.';


--
-- Name: staff_invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."staff_invitations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "token" "text" NOT NULL,
    "email" "text",
    "full_name" "text",
    "staff_site_id" "uuid",
    "staff_role" "text",
    "staff_area" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "expires_at" timestamp with time zone,
    "accepted_at" timestamp with time zone,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."staff_invitations" OWNER TO "postgres";

--
-- Name: TABLE "staff_invitations"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."staff_invitations" IS 'Core – tabla canónica para invitaciones de staff. Gestiona invitaciones a empleados/colaboradores y su onboarding.';


--
-- Name: staging_insumos_import; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."staging_insumos_import" (
    "fecha" "text",
    "area" "text",
    "proveedor" "text",
    "producto" "text",
    "presentacion_raw" "text",
    "purchase_unit" "text",
    "purchase_unit_size" "text",
    "base_unit" "text",
    "unit_token" "text",
    "precio_raw" "text",
    "precio_cop" "text",
    "issues" "text"
);


ALTER TABLE "public"."staging_insumos_import" OWNER TO "postgres";

--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."suppliers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "tax_id" "text",
    "contact_name" "text",
    "phone" "text",
    "email" "text",
    "address" "text",
    "notes" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."suppliers" OWNER TO "postgres";

--
-- Name: TABLE "suppliers"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."suppliers" IS 'Core – tabla canónica para proveedores. Datos maestros de proveedores usados en compras y acuerdos de suministro.';


--
-- Name: support_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."support_messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ticket_id" "uuid" NOT NULL,
    "author_id" "uuid" NOT NULL,
    "body" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."support_messages" OWNER TO "postgres";

--
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."support_tickets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "site_id" "uuid",
    "category" "text" DEFAULT 'attendance'::"text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "status" "public"."support_ticket_status" DEFAULT 'open'::"public"."support_ticket_status" NOT NULL,
    "assigned_to" "uuid",
    "resolved_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."support_tickets" OWNER TO "postgres";

--
-- Name: user_favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_favorites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "reward_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_favorites" OWNER TO "postgres";

--
-- Name: TABLE "user_favorites"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."user_favorites" IS 'Tabla de productos favoritos marcados por usuarios';


--
-- Name: COLUMN "user_favorites"."user_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."user_favorites"."user_id" IS 'ID del usuario que marcó el favorito';


--
-- Name: COLUMN "user_favorites"."reward_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."user_favorites"."reward_id" IS 'ID del producto (reward) marcado como favorito';


--
-- Name: COLUMN "user_favorites"."created_at"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."user_favorites"."created_at" IS 'Fecha y hora en que se marcó como favorito';


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_feedback" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "site_id" "uuid",
    "rating" integer NOT NULL,
    "feedback_text" "text",
    "category" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "reviewed_by" "uuid",
    "reviewed_at" timestamp with time zone,
    "resolution_notes" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "user_feedback_rating_check" CHECK ((("rating" >= 1) AND ("rating" <= 5)))
);


ALTER TABLE "public"."user_feedback" OWNER TO "postgres";

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "full_name" "text",
    "document_id" "text",
    "phone" "text",
    "role" "text" DEFAULT 'client'::"text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "loyalty_points" integer DEFAULT 0 NOT NULL,
    "email" "text",
    "document_type" "text",
    "birth_date" "date",
    "is_client" boolean DEFAULT true NOT NULL,
    "marketing_opt_in" boolean DEFAULT false NOT NULL,
    "has_reviewed_google" boolean DEFAULT false,
    "last_review_prompt_date" timestamp with time zone
);


ALTER TABLE "public"."users" OWNER TO "postgres";

--
-- Name: TABLE "users"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."users" IS 'Core – tabla canónica para usuarios/clients. Registro de clientes/usuarios del sistema, sus datos y relación con pedidos y lealtad.';


--
-- Name: v_inventory_catalog; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."v_inventory_catalog" AS
 SELECT "p"."id",
    "p"."name",
    "p"."description",
    "p"."sku",
    "p"."price",
    "p"."cost",
    "p"."unit",
    "p"."product_type",
    "p"."category_id",
    "pc"."name" AS "category_name",
    "p"."is_active",
    "p"."created_at",
    "p"."updated_at"
   FROM ("public"."products" "p"
     LEFT JOIN "public"."product_categories" "pc" ON (("p"."category_id" = "pc"."id")));


ALTER VIEW "public"."v_inventory_catalog" OWNER TO "postgres";

--
-- Name: v_inventory_stock_by_location; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."v_inventory_stock_by_location" AS
 SELECT "loc"."id" AS "location_id",
    "loc"."code" AS "location_code",
    "loc"."zone",
    "loc"."site_id",
    "s"."name" AS "site_name",
    "p"."id" AS "product_id",
    "p"."name" AS "product_name",
    "p"."sku",
    "isl"."current_qty" AS "total_quantity",
    "p"."unit"
   FROM ((("public"."inventory_stock_by_location" "isl"
     JOIN "public"."inventory_locations" "loc" ON (("loc"."id" = "isl"."location_id")))
     JOIN "public"."sites" "s" ON (("s"."id" = "loc"."site_id")))
     JOIN "public"."products" "p" ON (("p"."id" = "isl"."product_id")))
  WHERE ("loc"."is_active" = true);


ALTER VIEW "public"."v_inventory_stock_by_location" OWNER TO "postgres";

--
-- Name: v_procurement_price_book; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."v_procurement_price_book" AS
 SELECT "s"."id" AS "supplier_id",
    "s"."name" AS "supplier_name",
    "p"."id" AS "product_id",
    "p"."name" AS "product_name",
    "p"."unit",
    "pap"."agreed_price",
    "pap"."valid_from",
    "pap"."valid_until",
    "pc"."name" AS "category_name"
   FROM ((("public"."procurement_agreed_prices" "pap"
     JOIN "public"."suppliers" "s" ON (("pap"."supplier_id" = "s"."id")))
     JOIN "public"."products" "p" ON (("pap"."product_id" = "p"."id")))
     LEFT JOIN "public"."product_categories" "pc" ON (("p"."category_id" = "pc"."id")))
  WHERE (("pap"."is_active" = true) AND ("s"."is_active" = true) AND ("p"."is_active" = true));


ALTER VIEW "public"."v_procurement_price_book" OWNER TO "postgres";

--
-- Name: wallet_devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."wallet_devices" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "device_library_identifier" "text" NOT NULL,
    "pass_type_identifier" "text" NOT NULL,
    "serial_number" "text" NOT NULL,
    "push_token" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."wallet_devices" OWNER TO "postgres";

--
-- Name: wallet_passes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."wallet_passes" (
    "serial_number" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "pass_type_identifier" "text" NOT NULL,
    "auth_token" "text" NOT NULL,
    "data_hash" "text",
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."wallet_passes" OWNER TO "postgres";

--
-- Name: account_deletion_requests account_deletion_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."account_deletion_requests"
    ADD CONSTRAINT "account_deletion_requests_pkey" PRIMARY KEY ("id");


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_pkey" PRIMARY KEY ("id");


--
-- Name: app_permissions app_permissions_app_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."app_permissions"
    ADD CONSTRAINT "app_permissions_app_id_code_key" UNIQUE ("app_id", "code");


--
-- Name: app_permissions app_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."app_permissions"
    ADD CONSTRAINT "app_permissions_pkey" PRIMARY KEY ("id");


--
-- Name: app_update_policies app_update_policies_app_platform_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."app_update_policies"
    ADD CONSTRAINT "app_update_policies_app_platform_unique" UNIQUE ("app_key", "platform");


--
-- Name: app_update_policies app_update_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."app_update_policies"
    ADD CONSTRAINT "app_update_policies_pkey" PRIMARY KEY ("id");


--
-- Name: apps apps_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."apps"
    ADD CONSTRAINT "apps_code_key" UNIQUE ("code");


--
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."apps"
    ADD CONSTRAINT "apps_pkey" PRIMARY KEY ("id");


--
-- Name: area_kinds area_kinds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."area_kinds"
    ADD CONSTRAINT "area_kinds_pkey" PRIMARY KEY ("code");


--
-- Name: areas areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."areas"
    ADD CONSTRAINT "areas_pkey" PRIMARY KEY ("id");


--
-- Name: asistencia_logs asistencia_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."asistencia_logs"
    ADD CONSTRAINT "asistencia_logs_pkey" PRIMARY KEY ("id");


--
-- Name: attendance_breaks attendance_breaks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_breaks"
    ADD CONSTRAINT "attendance_breaks_pkey" PRIMARY KEY ("id");


--
-- Name: attendance_logs attendance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_logs"
    ADD CONSTRAINT "attendance_logs_pkey" PRIMARY KEY ("id");


--
-- Name: attendance_shift_events attendance_shift_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_shift_events"
    ADD CONSTRAINT "attendance_shift_events_pkey" PRIMARY KEY ("id");


--
-- Name: cost_centers cost_centers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."cost_centers"
    ADD CONSTRAINT "cost_centers_pkey" PRIMARY KEY ("id");


--
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."document_types"
    ADD CONSTRAINT "document_types_pkey" PRIMARY KEY ("id");


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_pkey" PRIMARY KEY ("id");


--
-- Name: employee_areas employee_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_areas"
    ADD CONSTRAINT "employee_areas_pkey" PRIMARY KEY ("employee_id", "area_id");


--
-- Name: employee_devices employee_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_devices"
    ADD CONSTRAINT "employee_devices_pkey" PRIMARY KEY ("id");


--
-- Name: employee_devices employee_devices_unique_token; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_devices"
    ADD CONSTRAINT "employee_devices_unique_token" UNIQUE ("expo_push_token");


--
-- Name: employee_permissions employee_permissions_employee_id_permission_id_scope_type_s_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_permissions"
    ADD CONSTRAINT "employee_permissions_employee_id_permission_id_scope_type_s_key" UNIQUE ("employee_id", "permission_id", "scope_type", "scope_site_id", "scope_area_id", "scope_site_type", "scope_area_kind");


--
-- Name: employee_permissions employee_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_permissions"
    ADD CONSTRAINT "employee_permissions_pkey" PRIMARY KEY ("id");


--
-- Name: employee_push_tokens employee_push_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_push_tokens"
    ADD CONSTRAINT "employee_push_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: employee_settings employee_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_settings"
    ADD CONSTRAINT "employee_settings_pkey" PRIMARY KEY ("employee_id");


--
-- Name: employee_shifts employee_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_shifts"
    ADD CONSTRAINT "employee_shifts_pkey" PRIMARY KEY ("id");


--
-- Name: employee_sites employee_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_sites"
    ADD CONSTRAINT "employee_sites_pkey" PRIMARY KEY ("employee_id", "site_id");


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_cost_policies inventory_cost_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_cost_policies"
    ADD CONSTRAINT "inventory_cost_policies_pkey" PRIMARY KEY ("site_id");


--
-- Name: inventory_count_lines inventory_count_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_lines"
    ADD CONSTRAINT "inventory_count_lines_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_count_lines inventory_count_lines_session_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_lines"
    ADD CONSTRAINT "inventory_count_lines_session_id_product_id_key" UNIQUE ("session_id", "product_id");


--
-- Name: inventory_count_sessions inventory_count_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_sessions"
    ADD CONSTRAINT "inventory_count_sessions_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_entries inventory_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entries"
    ADD CONSTRAINT "inventory_entries_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_entry_items inventory_entry_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entry_items"
    ADD CONSTRAINT "inventory_entry_items_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_locations inventory_locations_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_locations"
    ADD CONSTRAINT "inventory_locations_code_key" UNIQUE ("code");


--
-- Name: inventory_locations inventory_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_locations"
    ADD CONSTRAINT "inventory_locations_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_lpn_items inventory_lpn_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpn_items"
    ADD CONSTRAINT "inventory_lpn_items_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_lpns inventory_lpns_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpns"
    ADD CONSTRAINT "inventory_lpns_code_key" UNIQUE ("code");


--
-- Name: inventory_lpns inventory_lpns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpns"
    ADD CONSTRAINT "inventory_lpns_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_movement_types inventory_movement_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movement_types"
    ADD CONSTRAINT "inventory_movement_types_pkey" PRIMARY KEY ("code");


--
-- Name: inventory_movements inventory_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_stock_by_location inventory_stock_by_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_stock_by_location"
    ADD CONSTRAINT "inventory_stock_by_location_pkey" PRIMARY KEY ("location_id", "product_id");


--
-- Name: inventory_stock_by_site inventory_stock_by_site_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_stock_by_site"
    ADD CONSTRAINT "inventory_stock_by_site_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_stock_by_site inventory_stock_by_site_site_product_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_stock_by_site"
    ADD CONSTRAINT "inventory_stock_by_site_site_product_unique" UNIQUE ("site_id", "product_id");


--
-- Name: inventory_transfer_items inventory_transfer_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfer_items"
    ADD CONSTRAINT "inventory_transfer_items_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_transfers inventory_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfers"
    ADD CONSTRAINT "inventory_transfers_pkey" PRIMARY KEY ("id");


--
-- Name: inventory_unit_aliases inventory_unit_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_unit_aliases"
    ADD CONSTRAINT "inventory_unit_aliases_pkey" PRIMARY KEY ("alias");


--
-- Name: inventory_units inventory_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_units"
    ADD CONSTRAINT "inventory_units_pkey" PRIMARY KEY ("code");


--
-- Name: loyalty_external_sales loyalty_external_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_external_sales"
    ADD CONSTRAINT "loyalty_external_sales_pkey" PRIMARY KEY ("id");


--
-- Name: loyalty_redemptions loyalty_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_redemptions"
    ADD CONSTRAINT "loyalty_redemptions_pkey" PRIMARY KEY ("id");


--
-- Name: loyalty_rewards loyalty_rewards_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_rewards"
    ADD CONSTRAINT "loyalty_rewards_code_key" UNIQUE ("code");


--
-- Name: loyalty_rewards loyalty_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_rewards"
    ADD CONSTRAINT "loyalty_rewards_pkey" PRIMARY KEY ("id");


--
-- Name: loyalty_transactions loyalty_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_transactions"
    ADD CONSTRAINT "loyalty_transactions_pkey" PRIMARY KEY ("id");


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_pkey" PRIMARY KEY ("id");


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");


--
-- Name: pass_satellites pass_satellites_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pass_satellites"
    ADD CONSTRAINT "pass_satellites_code_key" UNIQUE ("code");


--
-- Name: pass_satellites pass_satellites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pass_satellites"
    ADD CONSTRAINT "pass_satellites_pkey" PRIMARY KEY ("id");


--
-- Name: pos_cash_movements pos_cash_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_cash_movements"
    ADD CONSTRAINT "pos_cash_movements_pkey" PRIMARY KEY ("id");


--
-- Name: pos_cash_shifts pos_cash_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_cash_shifts"
    ADD CONSTRAINT "pos_cash_shifts_pkey" PRIMARY KEY ("id");


--
-- Name: pos_modifier_options pos_modifier_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_modifier_options"
    ADD CONSTRAINT "pos_modifier_options_pkey" PRIMARY KEY ("id");


--
-- Name: pos_modifiers pos_modifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_modifiers"
    ADD CONSTRAINT "pos_modifiers_pkey" PRIMARY KEY ("id");


--
-- Name: pos_order_item_modifiers pos_order_item_modifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_order_item_modifiers"
    ADD CONSTRAINT "pos_order_item_modifiers_pkey" PRIMARY KEY ("id");


--
-- Name: pos_payments pos_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_payments"
    ADD CONSTRAINT "pos_payments_pkey" PRIMARY KEY ("id");


--
-- Name: pos_product_modifiers pos_product_modifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_product_modifiers"
    ADD CONSTRAINT "pos_product_modifiers_pkey" PRIMARY KEY ("id");


--
-- Name: pos_product_modifiers pos_product_modifiers_product_id_modifier_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_product_modifiers"
    ADD CONSTRAINT "pos_product_modifiers_product_id_modifier_id_key" UNIQUE ("product_id", "modifier_id");


--
-- Name: pos_session_orders pos_session_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_session_orders"
    ADD CONSTRAINT "pos_session_orders_pkey" PRIMARY KEY ("id");


--
-- Name: pos_sessions pos_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_sessions"
    ADD CONSTRAINT "pos_sessions_pkey" PRIMARY KEY ("id");


--
-- Name: pos_tables pos_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_tables"
    ADD CONSTRAINT "pos_tables_pkey" PRIMARY KEY ("id");


--
-- Name: pos_zones pos_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_zones"
    ADD CONSTRAINT "pos_zones_pkey" PRIMARY KEY ("id");


--
-- Name: procurement_agreed_prices procurement_agreed_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_agreed_prices"
    ADD CONSTRAINT "procurement_agreed_prices_pkey" PRIMARY KEY ("id");


--
-- Name: procurement_reception_items procurement_reception_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_reception_items"
    ADD CONSTRAINT "procurement_reception_items_pkey" PRIMARY KEY ("id");


--
-- Name: procurement_receptions procurement_receptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_receptions"
    ADD CONSTRAINT "procurement_receptions_pkey" PRIMARY KEY ("id");


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_categories"
    ADD CONSTRAINT "product_categories_pkey" PRIMARY KEY ("id");


--
-- Name: product_cost_events product_cost_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_cost_events"
    ADD CONSTRAINT "product_cost_events_pkey" PRIMARY KEY ("id");


--
-- Name: product_inventory_profiles product_inventory_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_inventory_profiles"
    ADD CONSTRAINT "product_inventory_profiles_pkey" PRIMARY KEY ("product_id");


--
-- Name: product_site_settings product_site_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_site_settings"
    ADD CONSTRAINT "product_site_settings_pkey" PRIMARY KEY ("id");


--
-- Name: product_site_settings product_site_settings_site_product_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_site_settings"
    ADD CONSTRAINT "product_site_settings_site_product_uniq" UNIQUE ("site_id", "product_id");


--
-- Name: product_sku_aliases product_sku_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_sku_aliases"
    ADD CONSTRAINT "product_sku_aliases_pkey" PRIMARY KEY ("id");


--
-- Name: product_sku_sequences product_sku_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_sku_sequences"
    ADD CONSTRAINT "product_sku_sequences_pkey" PRIMARY KEY ("brand_code", "type_code");


--
-- Name: product_suppliers product_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_suppliers"
    ADD CONSTRAINT "product_suppliers_pkey" PRIMARY KEY ("id");


--
-- Name: product_uom_profiles product_uom_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_uom_profiles"
    ADD CONSTRAINT "product_uom_profiles_pkey" PRIMARY KEY ("id");


--
-- Name: production_batch_consumptions production_batch_consumptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batch_consumptions"
    ADD CONSTRAINT "production_batch_consumptions_pkey" PRIMARY KEY ("id");


--
-- Name: production_batches production_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batches"
    ADD CONSTRAINT "production_batches_pkey" PRIMARY KEY ("id");


--
-- Name: production_request_items production_request_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_request_items"
    ADD CONSTRAINT "production_request_items_pkey" PRIMARY KEY ("id");


--
-- Name: production_requests production_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_requests"
    ADD CONSTRAINT "production_requests_pkey" PRIMARY KEY ("id");


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");


--
-- Name: products products_sku_format_chk; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products"
    ADD CONSTRAINT "products_sku_format_chk" CHECK ((("sku" IS NULL) OR (TRIM(BOTH FROM "sku") = ''::"text") OR ("upper"(TRIM(BOTH FROM "sku")) ~ '^[A-Z0-9]+(-[A-Z0-9]+)*$'::"text"))) NOT VALID;


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_sku_key" UNIQUE ("sku");


--
-- Name: purchase_order_items purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_pkey" PRIMARY KEY ("id");


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id");


--
-- Name: recipe_cards recipe_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_cards"
    ADD CONSTRAINT "recipe_cards_pkey" PRIMARY KEY ("id");


--
-- Name: recipe_cards recipe_cards_product_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_cards"
    ADD CONSTRAINT "recipe_cards_product_id_key" UNIQUE ("product_id");


--
-- Name: recipe_steps recipe_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_steps"
    ADD CONSTRAINT "recipe_steps_pkey" PRIMARY KEY ("id");


--
-- Name: recipe_steps recipe_steps_unique_step; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_steps"
    ADD CONSTRAINT "recipe_steps_unique_step" UNIQUE ("recipe_card_id", "step_number");


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipes"
    ADD CONSTRAINT "recipes_pkey" PRIMARY KEY ("id");


--
-- Name: restock_request_items restock_request_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_request_items"
    ADD CONSTRAINT "restock_request_items_pkey" PRIMARY KEY ("id");


--
-- Name: restock_requests restock_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_pkey" PRIMARY KEY ("id");


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id");


--
-- Name: role_permissions role_permissions_role_permission_id_scope_type_scope_site_t_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_permission_id_scope_type_scope_site_t_key" UNIQUE ("role", "permission_id", "scope_type", "scope_site_type", "scope_area_kind");


--
-- Name: role_site_type_rules role_site_type_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_site_type_rules"
    ADD CONSTRAINT "role_site_type_rules_pkey" PRIMARY KEY ("role", "site_type");


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("code");


--
-- Name: site_production_pick_order site_production_pick_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."site_production_pick_order"
    ADD CONSTRAINT "site_production_pick_order_pkey" PRIMARY KEY ("site_id", "location_id");


--
-- Name: site_supply_routes site_supply_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."site_supply_routes"
    ADD CONSTRAINT "site_supply_routes_pkey" PRIMARY KEY ("id");


--
-- Name: site_supply_routes site_supply_routes_requesting_site_id_fulfillment_site_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."site_supply_routes"
    ADD CONSTRAINT "site_supply_routes_requesting_site_id_fulfillment_site_id_key" UNIQUE ("requesting_site_id", "fulfillment_site_id");


--
-- Name: sites sites_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sites"
    ADD CONSTRAINT "sites_code_key" UNIQUE ("code");


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sites"
    ADD CONSTRAINT "sites_pkey" PRIMARY KEY ("id");


--
-- Name: staff_invitations staff_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."staff_invitations"
    ADD CONSTRAINT "staff_invitations_pkey" PRIMARY KEY ("id");


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."suppliers"
    ADD CONSTRAINT "suppliers_pkey" PRIMARY KEY ("id");


--
-- Name: support_messages support_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."support_messages"
    ADD CONSTRAINT "support_messages_pkey" PRIMARY KEY ("id");


--
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."support_tickets"
    ADD CONSTRAINT "support_tickets_pkey" PRIMARY KEY ("id");


--
-- Name: employee_shifts unique_employee_shift_per_day; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_shifts"
    ADD CONSTRAINT "unique_employee_shift_per_day" UNIQUE ("employee_id", "site_id", "shift_date", "start_time");


--
-- Name: user_favorites user_favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_favorites"
    ADD CONSTRAINT "user_favorites_pkey" PRIMARY KEY ("id");


--
-- Name: user_favorites user_favorites_user_id_reward_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_favorites"
    ADD CONSTRAINT "user_favorites_user_id_reward_id_key" UNIQUE ("user_id", "reward_id");


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_feedback"
    ADD CONSTRAINT "user_feedback_pkey" PRIMARY KEY ("id");


--
-- Name: users users_document_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_document_id_key" UNIQUE ("document_id");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: wallet_devices wallet_devices_device_library_identifier_pass_type_identifi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."wallet_devices"
    ADD CONSTRAINT "wallet_devices_device_library_identifier_pass_type_identifi_key" UNIQUE ("device_library_identifier", "pass_type_identifier", "serial_number");


--
-- Name: wallet_devices wallet_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."wallet_devices"
    ADD CONSTRAINT "wallet_devices_pkey" PRIMARY KEY ("id");


--
-- Name: wallet_passes wallet_passes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."wallet_passes"
    ADD CONSTRAINT "wallet_passes_pkey" PRIMARY KEY ("serial_number");


--
-- Name: announcements_active_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "announcements_active_order_idx" ON "public"."announcements" USING "btree" ("is_active", "display_order", "published_at" DESC);


--
-- Name: app_update_policies_app_platform_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "app_update_policies_app_platform_uidx" ON "public"."app_update_policies" USING "btree" ("app_key", "platform");


--
-- Name: app_update_policies_enabled_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "app_update_policies_enabled_idx" ON "public"."app_update_policies" USING "btree" ("app_key", "platform", "is_enabled");


--
-- Name: areas_site_code_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "areas_site_code_unique" ON "public"."areas" USING "btree" ("site_id", "code");


--
-- Name: areas_site_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "areas_site_id_idx" ON "public"."areas" USING "btree" ("site_id");


--
-- Name: asistencia_logs_employee_fecha_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "asistencia_logs_employee_fecha_unique" ON "public"."asistencia_logs" USING "btree" ("empleado_id", "fecha_hora");


--
-- Name: attendance_breaks_employee_started_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "attendance_breaks_employee_started_idx" ON "public"."attendance_breaks" USING "btree" ("employee_id", "started_at" DESC);


--
-- Name: attendance_breaks_one_open_per_employee_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "attendance_breaks_one_open_per_employee_idx" ON "public"."attendance_breaks" USING "btree" ("employee_id") WHERE ("ended_at" IS NULL);


--
-- Name: attendance_breaks_site_started_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "attendance_breaks_site_started_idx" ON "public"."attendance_breaks" USING "btree" ("site_id", "started_at" DESC);


--
-- Name: attendance_logs_employee_occurred_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "attendance_logs_employee_occurred_at_idx" ON "public"."attendance_logs" USING "btree" ("employee_id", "occurred_at" DESC);


--
-- Name: attendance_shift_events_employee_shift_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "attendance_shift_events_employee_shift_idx" ON "public"."attendance_shift_events" USING "btree" ("employee_id", "shift_start_at" DESC);


--
-- Name: attendance_shift_events_site_occurred_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "attendance_shift_events_site_occurred_idx" ON "public"."attendance_shift_events" USING "btree" ("site_id", "occurred_at" DESC);


--
-- Name: attendance_shift_events_unique_shift_event_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "attendance_shift_events_unique_shift_event_idx" ON "public"."attendance_shift_events" USING "btree" ("employee_id", "shift_start_at", "event_type");


--
-- Name: document_types_display_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "document_types_display_order_idx" ON "public"."document_types" USING "btree" ("display_order", "name");


--
-- Name: document_types_name_scope_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "document_types_name_scope_idx" ON "public"."document_types" USING "btree" ("name", "scope");


--
-- Name: documents_expiry_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_expiry_idx" ON "public"."documents" USING "btree" ("expiry_date");


--
-- Name: documents_owner_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_owner_idx" ON "public"."documents" USING "btree" ("owner_employee_id");


--
-- Name: documents_site_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_site_idx" ON "public"."documents" USING "btree" ("site_id");


--
-- Name: documents_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_status_idx" ON "public"."documents" USING "btree" ("status");


--
-- Name: documents_target_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_target_idx" ON "public"."documents" USING "btree" ("target_employee_id");


--
-- Name: employee_areas_employee_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "employee_areas_employee_idx" ON "public"."employee_areas" USING "btree" ("employee_id");


--
-- Name: employee_areas_one_primary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "employee_areas_one_primary" ON "public"."employee_areas" USING "btree" ("employee_id") WHERE ("is_primary" = true);


--
-- Name: employee_push_tokens_employee_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "employee_push_tokens_employee_idx" ON "public"."employee_push_tokens" USING "btree" ("employee_id");


--
-- Name: employee_push_tokens_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "employee_push_tokens_token_idx" ON "public"."employee_push_tokens" USING "btree" ("token");


--
-- Name: employee_sites_employee_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "employee_sites_employee_idx" ON "public"."employee_sites" USING "btree" ("employee_id");


--
-- Name: employee_sites_one_primary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "employee_sites_one_primary" ON "public"."employee_sites" USING "btree" ("employee_id") WHERE ("is_primary" = true);


--
-- Name: employees_area_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "employees_area_id_idx" ON "public"."employees" USING "btree" ("area_id");


--
-- Name: idx_account_deletion_requests_status_execute; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_account_deletion_requests_status_execute" ON "public"."account_deletion_requests" USING "btree" ("status", "execute_after");


--
-- Name: idx_account_deletion_requests_user_status_execute; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_account_deletion_requests_user_status_execute" ON "public"."account_deletion_requests" USING "btree" ("user_id", "status", "execute_after");


--
-- Name: idx_attendance_logs_employee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attendance_logs_employee" ON "public"."attendance_logs" USING "btree" ("employee_id");


--
-- Name: idx_attendance_logs_employee_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attendance_logs_employee_date" ON "public"."attendance_logs" USING "btree" ("employee_id", "occurred_at" DESC);


--
-- Name: idx_attendance_logs_occurred; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attendance_logs_occurred" ON "public"."attendance_logs" USING "btree" ("occurred_at" DESC);


--
-- Name: idx_attendance_logs_site_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attendance_logs_site_date" ON "public"."attendance_logs" USING "btree" ("site_id", "occurred_at" DESC);


--
-- Name: idx_count_lines_session; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_count_lines_session" ON "public"."inventory_count_lines" USING "btree" ("session_id");


--
-- Name: idx_count_sessions_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_count_sessions_created_at" ON "public"."inventory_count_sessions" USING "btree" ("created_at" DESC);


--
-- Name: idx_count_sessions_site_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_count_sessions_site_status" ON "public"."inventory_count_sessions" USING "btree" ("site_id", "status");


--
-- Name: idx_employee_shifts_date_range; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_employee_shifts_date_range" ON "public"."employee_shifts" USING "btree" ("shift_date", "site_id");


--
-- Name: idx_employee_shifts_employee_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_employee_shifts_employee_date" ON "public"."employee_shifts" USING "btree" ("employee_id", "shift_date" DESC);


--
-- Name: idx_employee_shifts_site_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_employee_shifts_site_date" ON "public"."employee_shifts" USING "btree" ("site_id", "shift_date" DESC);


--
-- Name: idx_employee_shifts_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_employee_shifts_status" ON "public"."employee_shifts" USING "btree" ("status") WHERE ("status" = 'scheduled'::"text");


--
-- Name: idx_inv_locations_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_locations_code" ON "public"."inventory_locations" USING "btree" ("code");


--
-- Name: idx_inv_locations_site; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_locations_site" ON "public"."inventory_locations" USING "btree" ("site_id");


--
-- Name: idx_inv_locations_zone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_locations_zone" ON "public"."inventory_locations" USING "btree" ("zone");


--
-- Name: idx_inv_lpn_items_expiry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpn_items_expiry" ON "public"."inventory_lpn_items" USING "btree" ("expiry_date");


--
-- Name: idx_inv_lpn_items_lot; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpn_items_lot" ON "public"."inventory_lpn_items" USING "btree" ("lot_number");


--
-- Name: idx_inv_lpn_items_lpn; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpn_items_lpn" ON "public"."inventory_lpn_items" USING "btree" ("lpn_id");


--
-- Name: idx_inv_lpn_items_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpn_items_product" ON "public"."inventory_lpn_items" USING "btree" ("product_id");


--
-- Name: idx_inv_lpns_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpns_code" ON "public"."inventory_lpns" USING "btree" ("code");


--
-- Name: idx_inv_lpns_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpns_location" ON "public"."inventory_lpns" USING "btree" ("location_id");


--
-- Name: idx_inv_lpns_site; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpns_site" ON "public"."inventory_lpns" USING "btree" ("site_id");


--
-- Name: idx_inv_lpns_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inv_lpns_status" ON "public"."inventory_lpns" USING "btree" ("status");


--
-- Name: idx_inventory_entries_purchase_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entries_purchase_order_id" ON "public"."inventory_entries" USING "btree" ("purchase_order_id");


--
-- Name: idx_inventory_entries_site; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entries_site" ON "public"."inventory_entries" USING "btree" ("site_id");


--
-- Name: idx_inventory_entries_source_mode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entries_source_mode" ON "public"."inventory_entries" USING "btree" ("source_app", "entry_mode", "created_at" DESC);


--
-- Name: idx_inventory_entries_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entries_status" ON "public"."inventory_entries" USING "btree" ("status");


--
-- Name: idx_inventory_entries_supplier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entries_supplier" ON "public"."inventory_entries" USING "btree" ("supplier_id");


--
-- Name: idx_inventory_entry_items_entry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entry_items_entry" ON "public"."inventory_entry_items" USING "btree" ("entry_id");


--
-- Name: idx_inventory_entry_items_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entry_items_location" ON "public"."inventory_entry_items" USING "btree" ("location_id");


--
-- Name: idx_inventory_entry_items_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entry_items_product" ON "public"."inventory_entry_items" USING "btree" ("product_id");


--
-- Name: idx_inventory_entry_items_stock_unit_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_entry_items_stock_unit_code" ON "public"."inventory_entry_items" USING "btree" ("stock_unit_code");


--
-- Name: idx_inventory_movements_movement_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_movements_movement_type" ON "public"."inventory_movements" USING "btree" ("movement_type");


--
-- Name: idx_inventory_movements_stock_unit_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_movements_stock_unit_code" ON "public"."inventory_movements" USING "btree" ("stock_unit_code");


--
-- Name: idx_inventory_stock_by_location_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_stock_by_location_location" ON "public"."inventory_stock_by_location" USING "btree" ("location_id");


--
-- Name: idx_inventory_stock_by_location_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_stock_by_location_product" ON "public"."inventory_stock_by_location" USING "btree" ("product_id");


--
-- Name: idx_inventory_transfer_items_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_transfer_items_product" ON "public"."inventory_transfer_items" USING "btree" ("product_id");


--
-- Name: idx_inventory_transfer_items_stock_unit_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_transfer_items_stock_unit_code" ON "public"."inventory_transfer_items" USING "btree" ("stock_unit_code");


--
-- Name: idx_inventory_transfer_items_transfer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_transfer_items_transfer" ON "public"."inventory_transfer_items" USING "btree" ("transfer_id");


--
-- Name: idx_inventory_transfers_from; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_transfers_from" ON "public"."inventory_transfers" USING "btree" ("from_loc_id");


--
-- Name: idx_inventory_transfers_site; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_transfers_site" ON "public"."inventory_transfers" USING "btree" ("site_id");


--
-- Name: idx_inventory_transfers_to; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_transfers_to" ON "public"."inventory_transfers" USING "btree" ("to_loc_id");


--
-- Name: idx_inventory_units_family; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_inventory_units_family" ON "public"."inventory_units" USING "btree" ("family", "is_active");


--
-- Name: idx_loyalty_external_sales_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_loyalty_external_sales_user_created" ON "public"."loyalty_external_sales" USING "btree" ("user_id", "created_at" DESC);


--
-- Name: idx_orders_table_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_orders_table_status" ON "public"."orders" USING "btree" ("table_number", "status") WHERE ("status" <> 'paid'::"text");


--
-- Name: idx_product_categories_applies_to_kinds; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_categories_applies_to_kinds" ON "public"."product_categories" USING "gin" ("applies_to_kinds");


--
-- Name: idx_product_categories_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_categories_domain" ON "public"."product_categories" USING "btree" (COALESCE(NULLIF(TRIM(BOTH FROM "domain"), ''::"text"), '*'::"text"));


--
-- Name: idx_product_categories_domain_site_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_categories_domain_site_id" ON "public"."product_categories" USING "btree" ("domain", "site_id");


--
-- Name: idx_product_categories_scope_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_categories_scope_parent" ON "public"."product_categories" USING "btree" ("site_id", "parent_id");


--
-- Name: idx_product_categories_site_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_categories_site_id" ON "public"."product_categories" USING "btree" ("site_id");


--
-- Name: idx_product_cost_events_product_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_cost_events_product_created" ON "public"."product_cost_events" USING "btree" ("product_id", "created_at" DESC);


--
-- Name: idx_product_inventory_profiles_unit_family; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_inventory_profiles_unit_family" ON "public"."product_inventory_profiles" USING "btree" ("unit_family", "costing_mode");


--
-- Name: idx_product_site_settings_site_active_audience; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_site_settings_site_active_audience" ON "public"."product_site_settings" USING "btree" ("site_id", "is_active", "audience");


--
-- Name: idx_product_site_settings_site_active_min; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_site_settings_site_active_min" ON "public"."product_site_settings" USING "btree" ("site_id", "is_active", "min_stock_qty");


--
-- Name: idx_product_suppliers_pack_unit; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_suppliers_pack_unit" ON "public"."product_suppliers" USING "btree" ("product_id", "purchase_pack_unit_code");


--
-- Name: idx_product_uom_profiles_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_uom_profiles_product" ON "public"."product_uom_profiles" USING "btree" ("product_id");


--
-- Name: idx_product_uom_profiles_product_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_uom_profiles_product_active" ON "public"."product_uom_profiles" USING "btree" ("product_id", "is_active", "is_default");


--
-- Name: idx_product_uom_profiles_product_context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_product_uom_profiles_product_context" ON "public"."product_uom_profiles" USING "btree" ("product_id", "usage_context", "is_active", "is_default");


--
-- Name: idx_production_batch_consumptions_batch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_production_batch_consumptions_batch" ON "public"."production_batch_consumptions" USING "btree" ("batch_id");


--
-- Name: idx_production_batch_consumptions_ingredient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_production_batch_consumptions_ingredient" ON "public"."production_batch_consumptions" USING "btree" ("ingredient_product_id", "created_at" DESC);


--
-- Name: idx_production_batch_consumptions_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_production_batch_consumptions_location" ON "public"."production_batch_consumptions" USING "btree" ("location_id");


--
-- Name: idx_products_stock_unit_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_products_stock_unit_code" ON "public"."products" USING "btree" ("stock_unit_code");


--
-- Name: idx_recipe_cards_area_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_recipe_cards_area_id" ON "public"."recipe_cards" USING "btree" ("area_id");


--
-- Name: idx_recipe_cards_site_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_recipe_cards_site_id" ON "public"."recipe_cards" USING "btree" ("site_id");


--
-- Name: idx_recipe_cards_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_recipe_cards_status" ON "public"."recipe_cards" USING "btree" ("status");


--
-- Name: idx_recipe_steps_recipe_card_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_recipe_steps_recipe_card_id" ON "public"."recipe_steps" USING "btree" ("recipe_card_id");


--
-- Name: idx_recipes_ingredient_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_recipes_ingredient_product_id" ON "public"."recipes" USING "btree" ("ingredient_product_id");


--
-- Name: idx_restock_request_items_source_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_restock_request_items_source_location" ON "public"."restock_request_items" USING "btree" ("source_location_id");


--
-- Name: idx_restock_request_items_stock_unit_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_restock_request_items_stock_unit_code" ON "public"."restock_request_items" USING "btree" ("stock_unit_code");


--
-- Name: idx_site_production_pick_order_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_site_production_pick_order_active" ON "public"."site_production_pick_order" USING "btree" ("site_id", "is_active", "priority");


--
-- Name: idx_sites_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_sites_location" ON "public"."sites" USING "btree" ("latitude", "longitude") WHERE (("latitude" IS NOT NULL) AND ("longitude" IS NOT NULL));


--
-- Name: idx_user_favorites_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_favorites_created_at" ON "public"."user_favorites" USING "btree" ("created_at" DESC);


--
-- Name: idx_user_favorites_reward_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_favorites_reward_id" ON "public"."user_favorites" USING "btree" ("reward_id");


--
-- Name: idx_user_favorites_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_favorites_user_id" ON "public"."user_favorites" USING "btree" ("user_id");


--
-- Name: idx_user_feedback_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_feedback_created_at" ON "public"."user_feedback" USING "btree" ("created_at" DESC);


--
-- Name: idx_user_feedback_rating; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_feedback_rating" ON "public"."user_feedback" USING "btree" ("rating");


--
-- Name: idx_user_feedback_site_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_feedback_site_id" ON "public"."user_feedback" USING "btree" ("site_id");


--
-- Name: idx_user_feedback_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_feedback_status" ON "public"."user_feedback" USING "btree" ("status");


--
-- Name: idx_user_feedback_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_feedback_user_id" ON "public"."user_feedback" USING "btree" ("user_id");


--
-- Name: inventory_locations_parent_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "inventory_locations_parent_id_idx" ON "public"."inventory_locations" USING "btree" ("parent_location_id");


--
-- Name: inventory_locations_site_code_uniq; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "inventory_locations_site_code_uniq" ON "public"."inventory_locations" USING "btree" ("site_id", "code");


--
-- Name: inventory_movements_related_purchase_order_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "inventory_movements_related_purchase_order_id_idx" ON "public"."inventory_movements" USING "btree" ("related_purchase_order_id");


--
-- Name: inventory_stock_by_site_site_product_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "inventory_stock_by_site_site_product_uidx" ON "public"."inventory_stock_by_site" USING "btree" ("site_id", "product_id");


--
-- Name: inventory_stock_by_site_unique_site_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "inventory_stock_by_site_unique_site_product" ON "public"."inventory_stock_by_site" USING "btree" ("site_id", "product_id");


--
-- Name: loyalty_redemptions_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loyalty_redemptions_order_idx" ON "public"."loyalty_redemptions" USING "btree" ("order_id");


--
-- Name: loyalty_redemptions_reward_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loyalty_redemptions_reward_idx" ON "public"."loyalty_redemptions" USING "btree" ("reward_id");


--
-- Name: loyalty_redemptions_site_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loyalty_redemptions_site_idx" ON "public"."loyalty_redemptions" USING "btree" ("site_id");


--
-- Name: loyalty_redemptions_user_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loyalty_redemptions_user_created_idx" ON "public"."loyalty_redemptions" USING "btree" ("user_id", "created_at" DESC);


--
-- Name: loyalty_transactions_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loyalty_transactions_order_idx" ON "public"."loyalty_transactions" USING "btree" ("order_id");


--
-- Name: loyalty_transactions_user_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loyalty_transactions_user_created_idx" ON "public"."loyalty_transactions" USING "btree" ("user_id", "created_at" DESC);


--
-- Name: pass_satellites_active_sort_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "pass_satellites_active_sort_idx" ON "public"."pass_satellites" USING "btree" ("is_active", "sort_order", "name");


--
-- Name: pass_satellites_code_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "pass_satellites_code_uidx" ON "public"."pass_satellites" USING "btree" ("code");


--
-- Name: pass_satellites_site_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "pass_satellites_site_idx" ON "public"."pass_satellites" USING "btree" ("site_id");


--
-- Name: product_categories_domain_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "product_categories_domain_idx" ON "public"."product_categories" USING "btree" ("domain");


--
-- Name: product_categories_domain_parent_slug_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "product_categories_domain_parent_slug_uidx" ON "public"."product_categories" USING "btree" ("domain", COALESCE("parent_id", '00000000-0000-0000-0000-000000000000'::"uuid"), "slug");


--
-- Name: product_categories_parent_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "product_categories_parent_id_idx" ON "public"."product_categories" USING "btree" ("parent_id");


--
-- Name: product_site_settings_product_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "product_site_settings_product_id_idx" ON "public"."product_site_settings" USING "btree" ("product_id");


--
-- Name: product_site_settings_site_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "product_site_settings_site_id_idx" ON "public"."product_site_settings" USING "btree" ("site_id");


--
-- Name: product_sku_aliases_product_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "product_sku_aliases_product_id_idx" ON "public"."product_sku_aliases" USING "btree" ("product_id");


--
-- Name: product_sku_aliases_sku_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "product_sku_aliases_sku_key" ON "public"."product_sku_aliases" USING "btree" ("sku");


--
-- Name: purchase_orders_created_by_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "purchase_orders_created_by_idx" ON "public"."purchase_orders" USING "btree" ("created_by");


--
-- Name: staff_invitations_token_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "staff_invitations_token_key" ON "public"."staff_invitations" USING "btree" ("token");


--
-- Name: support_tickets_assigned_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "support_tickets_assigned_idx" ON "public"."support_tickets" USING "btree" ("assigned_to");


--
-- Name: support_tickets_site_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "support_tickets_site_idx" ON "public"."support_tickets" USING "btree" ("site_id");


--
-- Name: support_tickets_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "support_tickets_status_idx" ON "public"."support_tickets" USING "btree" ("status");


--
-- Name: uq_loyalty_external_sales_site_ref; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "uq_loyalty_external_sales_site_ref" ON "public"."loyalty_external_sales" USING "btree" ("site_id", "lower"("btrim"("external_ref")));


--
-- Name: ux_product_categories_scope_parent_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ux_product_categories_scope_parent_name" ON "public"."product_categories" USING "btree" (COALESCE("site_id", '00000000-0000-0000-0000-000000000000'::"uuid"), COALESCE("parent_id", '00000000-0000-0000-0000-000000000000'::"uuid"), COALESCE(NULLIF(TRIM(BOTH FROM "domain"), ''::"text"), '*'::"text"), "lower"(TRIM(BOTH FROM "name")));


--
-- Name: ux_product_categories_scope_parent_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ux_product_categories_scope_parent_slug" ON "public"."product_categories" USING "btree" (COALESCE("site_id", '00000000-0000-0000-0000-000000000000'::"uuid"), COALESCE("parent_id", '00000000-0000-0000-0000-000000000000'::"uuid"), COALESCE(NULLIF(TRIM(BOTH FROM "domain"), ''::"text"), '*'::"text"), "lower"(TRIM(BOTH FROM "slug"))) WHERE (("slug" IS NOT NULL) AND (TRIM(BOTH FROM "slug") <> ''::"text"));


--
-- Name: ux_product_site_settings_product_site; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ux_product_site_settings_product_site" ON "public"."product_site_settings" USING "btree" ("product_id", "site_id");


--
-- Name: ux_product_uom_profiles_default_per_product_context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ux_product_uom_profiles_default_per_product_context" ON "public"."product_uom_profiles" USING "btree" ("product_id", "usage_context") WHERE (("is_default" = true) AND ("is_active" = true));


--
-- Name: ux_production_batch_consumptions_batch_ingredient_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ux_production_batch_consumptions_batch_ingredient_location" ON "public"."production_batch_consumptions" USING "btree" ("batch_id", "ingredient_product_id", "location_id");


--
-- Name: ux_products_sku_unique_global; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ux_products_sku_unique_global" ON "public"."products" USING "btree" ("lower"(TRIM(BOTH FROM "sku"))) WHERE (("sku" IS NOT NULL) AND (TRIM(BOTH FROM "sku") <> ''::"text"));


--
-- Name: app_update_policies app_update_policies_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "app_update_policies_set_updated_at" BEFORE UPDATE ON "public"."app_update_policies" FOR EACH ROW EXECUTE FUNCTION "public"."_set_updated_at"();


--
-- Name: attendance_breaks attendance_breaks_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "attendance_breaks_set_updated_at" BEFORE UPDATE ON "public"."attendance_breaks" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();


--
-- Name: attendance_logs attendance_logs_00_geofence; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "attendance_logs_00_geofence" BEFORE INSERT ON "public"."attendance_logs" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_attendance_geofence"();


--
-- Name: attendance_logs attendance_logs_enforce_sequence; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "attendance_logs_enforce_sequence" BEFORE INSERT ON "public"."attendance_logs" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_attendance_sequence"();


--
-- Name: attendance_shift_events attendance_shift_events_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "attendance_shift_events_set_updated_at" BEFORE UPDATE ON "public"."attendance_shift_events" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();


--
-- Name: documents documents_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "documents_set_updated_at" BEFORE UPDATE ON "public"."documents" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();


--
-- Name: employee_devices employee_devices_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "employee_devices_set_updated_at" BEFORE UPDATE ON "public"."employee_devices" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();


--
-- Name: loyalty_transactions on_loyalty_transaction_created; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_loyalty_transaction_created" AFTER INSERT ON "public"."loyalty_transactions" FOR EACH ROW EXECUTE FUNCTION "public"."update_loyalty_balance"();


--
-- Name: pass_satellites pass_satellites_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "pass_satellites_set_updated_at" BEFORE UPDATE ON "public"."pass_satellites" FOR EACH ROW EXECUTE FUNCTION "public"."_set_updated_at"();


--
-- Name: document_types set_document_types_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "set_document_types_updated_at" BEFORE UPDATE ON "public"."document_types" FOR EACH ROW EXECUTE FUNCTION "public"."_set_updated_at"();


--
-- Name: employee_push_tokens set_employee_push_tokens_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "set_employee_push_tokens_updated_at" BEFORE UPDATE ON "public"."employee_push_tokens" FOR EACH ROW EXECUTE FUNCTION "public"."_set_updated_at"();


--
-- Name: product_inventory_profiles set_updated_at_product_inventory_profiles; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "set_updated_at_product_inventory_profiles" BEFORE UPDATE ON "public"."product_inventory_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg_set_updated_at"();


--
-- Name: support_tickets support_tickets_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "support_tickets_set_updated_at" BEFORE UPDATE ON "public"."support_tickets" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();


--
-- Name: employees trg_enforce_employee_role_site; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_enforce_employee_role_site" BEFORE INSERT OR UPDATE OF "role", "site_id" ON "public"."employees" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_employee_role_site"();


--
-- Name: inventory_locations trg_inventory_locations_parent_same_site; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_inventory_locations_parent_same_site" BEFORE INSERT OR UPDATE OF "parent_location_id", "site_id" ON "public"."inventory_locations" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_inventory_location_parent_same_site"();


--
-- Name: inventory_units trg_inventory_units_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_inventory_units_updated_at" BEFORE UPDATE ON "public"."inventory_units" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();


--
-- Name: product_categories trg_product_categories_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_product_categories_updated_at" BEFORE UPDATE ON "public"."product_categories" FOR EACH ROW EXECUTE FUNCTION "public"."_set_updated_at"();


--
-- Name: product_site_settings trg_product_site_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_product_site_settings_updated_at" BEFORE UPDATE ON "public"."product_site_settings" FOR EACH ROW EXECUTE FUNCTION "public"."_set_updated_at"();


--
-- Name: products trg_set_product_sku; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_set_product_sku" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."set_product_sku"();


--
-- Name: production_batches trg_set_production_batch_code; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_set_production_batch_code" BEFORE INSERT ON "public"."production_batches" FOR EACH ROW EXECUTE FUNCTION "public"."set_production_batch_code"();


--
-- Name: employee_shifts trigger_employee_shifts_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_employee_shifts_updated_at" BEFORE UPDATE ON "public"."employee_shifts" FOR EACH ROW EXECUTE FUNCTION "public"."update_employee_shifts_updated_at"();


--
-- Name: inventory_entries update_inventory_entries_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_inventory_entries_updated_at" BEFORE UPDATE ON "public"."inventory_entries" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();


--
-- Name: inventory_locations update_inventory_locations_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_inventory_locations_updated_at" BEFORE UPDATE ON "public"."inventory_locations" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();


--
-- Name: inventory_lpn_items update_inventory_lpn_items_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_inventory_lpn_items_updated_at" BEFORE UPDATE ON "public"."inventory_lpn_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();


--
-- Name: inventory_lpns update_inventory_lpns_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_inventory_lpns_updated_at" BEFORE UPDATE ON "public"."inventory_lpns" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();


--
-- Name: inventory_transfers update_inventory_transfers_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_inventory_transfers_updated_at" BEFORE UPDATE ON "public"."inventory_transfers" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();


--
-- Name: account_deletion_requests account_deletion_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."account_deletion_requests"
    ADD CONSTRAINT "account_deletion_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: announcements announcements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: app_permissions app_permissions_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."app_permissions"
    ADD CONSTRAINT "app_permissions_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "public"."apps"("id") ON DELETE CASCADE;


--
-- Name: areas areas_kind_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."areas"
    ADD CONSTRAINT "areas_kind_fkey" FOREIGN KEY ("kind") REFERENCES "public"."area_kinds"("code");


--
-- Name: areas areas_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."areas"
    ADD CONSTRAINT "areas_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: attendance_breaks attendance_breaks_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_breaks"
    ADD CONSTRAINT "attendance_breaks_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: attendance_breaks attendance_breaks_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_breaks"
    ADD CONSTRAINT "attendance_breaks_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE RESTRICT;


--
-- Name: attendance_logs attendance_logs_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_logs"
    ADD CONSTRAINT "attendance_logs_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: attendance_logs attendance_logs_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_logs"
    ADD CONSTRAINT "attendance_logs_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE RESTRICT;


--
-- Name: attendance_shift_events attendance_shift_events_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_shift_events"
    ADD CONSTRAINT "attendance_shift_events_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: attendance_shift_events attendance_shift_events_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attendance_shift_events"
    ADD CONSTRAINT "attendance_shift_events_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE RESTRICT;


--
-- Name: cost_centers cost_centers_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."cost_centers"
    ADD CONSTRAINT "cost_centers_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: documents documents_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "public"."employees"("id") ON DELETE SET NULL;


--
-- Name: documents documents_document_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_document_type_id_fkey" FOREIGN KEY ("document_type_id") REFERENCES "public"."document_types"("id") ON DELETE SET NULL;


--
-- Name: documents documents_owner_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_owner_employee_id_fkey" FOREIGN KEY ("owner_employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: documents documents_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE SET NULL;


--
-- Name: documents documents_target_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_target_employee_id_fkey" FOREIGN KEY ("target_employee_id") REFERENCES "public"."employees"("id") ON DELETE SET NULL;


--
-- Name: employee_areas employee_areas_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_areas"
    ADD CONSTRAINT "employee_areas_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "public"."areas"("id") ON DELETE CASCADE;


--
-- Name: employee_areas employee_areas_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_areas"
    ADD CONSTRAINT "employee_areas_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: employee_devices employee_devices_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_devices"
    ADD CONSTRAINT "employee_devices_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: employee_permissions employee_permissions_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_permissions"
    ADD CONSTRAINT "employee_permissions_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: employee_permissions employee_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_permissions"
    ADD CONSTRAINT "employee_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "public"."app_permissions"("id") ON DELETE CASCADE;


--
-- Name: employee_permissions employee_permissions_scope_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_permissions"
    ADD CONSTRAINT "employee_permissions_scope_area_id_fkey" FOREIGN KEY ("scope_area_id") REFERENCES "public"."areas"("id");


--
-- Name: employee_permissions employee_permissions_scope_area_kind_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_permissions"
    ADD CONSTRAINT "employee_permissions_scope_area_kind_fkey" FOREIGN KEY ("scope_area_kind") REFERENCES "public"."area_kinds"("code");


--
-- Name: employee_permissions employee_permissions_scope_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_permissions"
    ADD CONSTRAINT "employee_permissions_scope_site_id_fkey" FOREIGN KEY ("scope_site_id") REFERENCES "public"."sites"("id");


--
-- Name: employee_push_tokens employee_push_tokens_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_push_tokens"
    ADD CONSTRAINT "employee_push_tokens_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: employee_settings employee_settings_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_settings"
    ADD CONSTRAINT "employee_settings_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: employee_settings employee_settings_selected_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_settings"
    ADD CONSTRAINT "employee_settings_selected_area_id_fkey" FOREIGN KEY ("selected_area_id") REFERENCES "public"."areas"("id");


--
-- Name: employee_settings employee_settings_selected_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_settings"
    ADD CONSTRAINT "employee_settings_selected_site_id_fkey" FOREIGN KEY ("selected_site_id") REFERENCES "public"."sites"("id");


--
-- Name: employee_shifts employee_shifts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_shifts"
    ADD CONSTRAINT "employee_shifts_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id");


--
-- Name: employee_shifts employee_shifts_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_shifts"
    ADD CONSTRAINT "employee_shifts_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: employee_shifts employee_shifts_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_shifts"
    ADD CONSTRAINT "employee_shifts_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: employee_sites employee_sites_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_sites"
    ADD CONSTRAINT "employee_sites_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: employee_sites employee_sites_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employee_sites"
    ADD CONSTRAINT "employee_sites_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: employees employees_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "public"."areas"("id") ON DELETE SET NULL;


--
-- Name: employees employees_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: employees employees_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_role_fkey" FOREIGN KEY ("role") REFERENCES "public"."roles"("code");


--
-- Name: employees employees_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: inventory_cost_policies inventory_cost_policies_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_cost_policies"
    ADD CONSTRAINT "inventory_cost_policies_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: inventory_cost_policies inventory_cost_policies_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_cost_policies"
    ADD CONSTRAINT "inventory_cost_policies_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: inventory_count_lines inventory_count_lines_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_lines"
    ADD CONSTRAINT "inventory_count_lines_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: inventory_count_lines inventory_count_lines_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_lines"
    ADD CONSTRAINT "inventory_count_lines_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."inventory_count_sessions"("id") ON DELETE CASCADE;


--
-- Name: inventory_count_sessions inventory_count_sessions_closed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_sessions"
    ADD CONSTRAINT "inventory_count_sessions_closed_by_fkey" FOREIGN KEY ("closed_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: inventory_count_sessions inventory_count_sessions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_sessions"
    ADD CONSTRAINT "inventory_count_sessions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: inventory_count_sessions inventory_count_sessions_scope_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_sessions"
    ADD CONSTRAINT "inventory_count_sessions_scope_location_id_fkey" FOREIGN KEY ("scope_location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE SET NULL;


--
-- Name: inventory_count_sessions inventory_count_sessions_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_count_sessions"
    ADD CONSTRAINT "inventory_count_sessions_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: inventory_entries inventory_entries_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entries"
    ADD CONSTRAINT "inventory_entries_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id") ON DELETE SET NULL;


--
-- Name: inventory_entries inventory_entries_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entries"
    ADD CONSTRAINT "inventory_entries_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "public"."purchase_orders"("id") ON DELETE SET NULL;


--
-- Name: inventory_entries inventory_entries_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entries"
    ADD CONSTRAINT "inventory_entries_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: inventory_entries inventory_entries_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entries"
    ADD CONSTRAINT "inventory_entries_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id") ON DELETE SET NULL;


--
-- Name: inventory_entry_items inventory_entry_items_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entry_items"
    ADD CONSTRAINT "inventory_entry_items_entry_id_fkey" FOREIGN KEY ("entry_id") REFERENCES "public"."inventory_entries"("id") ON DELETE CASCADE;


--
-- Name: inventory_entry_items inventory_entry_items_input_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entry_items"
    ADD CONSTRAINT "inventory_entry_items_input_unit_code_fkey" FOREIGN KEY ("input_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: inventory_entry_items inventory_entry_items_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entry_items"
    ADD CONSTRAINT "inventory_entry_items_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE SET NULL;


--
-- Name: inventory_entry_items inventory_entry_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entry_items"
    ADD CONSTRAINT "inventory_entry_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: inventory_entry_items inventory_entry_items_purchase_order_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entry_items"
    ADD CONSTRAINT "inventory_entry_items_purchase_order_item_id_fkey" FOREIGN KEY ("purchase_order_item_id") REFERENCES "public"."purchase_order_items"("id") ON DELETE SET NULL;


--
-- Name: inventory_entry_items inventory_entry_items_stock_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_entry_items"
    ADD CONSTRAINT "inventory_entry_items_stock_unit_code_fkey" FOREIGN KEY ("stock_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: inventory_locations inventory_locations_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_locations"
    ADD CONSTRAINT "inventory_locations_parent_fkey" FOREIGN KEY ("parent_location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE SET NULL;


--
-- Name: inventory_locations inventory_locations_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_locations"
    ADD CONSTRAINT "inventory_locations_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: inventory_lpn_items inventory_lpn_items_lpn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpn_items"
    ADD CONSTRAINT "inventory_lpn_items_lpn_id_fkey" FOREIGN KEY ("lpn_id") REFERENCES "public"."inventory_lpns"("id") ON DELETE CASCADE;


--
-- Name: inventory_lpn_items inventory_lpn_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpn_items"
    ADD CONSTRAINT "inventory_lpn_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: inventory_lpns inventory_lpns_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpns"
    ADD CONSTRAINT "inventory_lpns_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id") ON DELETE SET NULL;


--
-- Name: inventory_lpns inventory_lpns_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpns"
    ADD CONSTRAINT "inventory_lpns_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE SET NULL;


--
-- Name: inventory_lpns inventory_lpns_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_lpns"
    ADD CONSTRAINT "inventory_lpns_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: inventory_movements inventory_movements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id");


--
-- Name: inventory_movements inventory_movements_input_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_input_unit_code_fkey" FOREIGN KEY ("input_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: inventory_movements inventory_movements_movement_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_movement_type_fkey" FOREIGN KEY ("movement_type") REFERENCES "public"."inventory_movement_types"("code");


--
-- Name: inventory_movements inventory_movements_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: inventory_movements inventory_movements_production_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_production_batch_id_fkey" FOREIGN KEY ("related_production_batch_id") REFERENCES "public"."production_batches"("id");


--
-- Name: inventory_movements inventory_movements_related_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_related_order_id_fkey" FOREIGN KEY ("related_order_id") REFERENCES "public"."orders"("id");


--
-- Name: inventory_movements inventory_movements_related_production_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_related_production_request_id_fkey" FOREIGN KEY ("related_production_request_id") REFERENCES "public"."production_requests"("id");


--
-- Name: inventory_movements inventory_movements_related_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_related_purchase_order_id_fkey" FOREIGN KEY ("related_purchase_order_id") REFERENCES "public"."purchase_orders"("id") ON DELETE SET NULL;


--
-- Name: inventory_movements inventory_movements_related_restock_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_related_restock_request_id_fkey" FOREIGN KEY ("related_restock_request_id") REFERENCES "public"."restock_requests"("id");


--
-- Name: inventory_movements inventory_movements_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: inventory_movements inventory_movements_stock_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_movements"
    ADD CONSTRAINT "inventory_movements_stock_unit_code_fkey" FOREIGN KEY ("stock_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: inventory_stock_by_location inventory_stock_by_location_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_stock_by_location"
    ADD CONSTRAINT "inventory_stock_by_location_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE CASCADE;


--
-- Name: inventory_stock_by_location inventory_stock_by_location_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_stock_by_location"
    ADD CONSTRAINT "inventory_stock_by_location_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: inventory_stock_by_site inventory_stock_by_site_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_stock_by_site"
    ADD CONSTRAINT "inventory_stock_by_site_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: inventory_stock_by_site inventory_stock_by_site_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_stock_by_site"
    ADD CONSTRAINT "inventory_stock_by_site_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: inventory_transfer_items inventory_transfer_items_input_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfer_items"
    ADD CONSTRAINT "inventory_transfer_items_input_unit_code_fkey" FOREIGN KEY ("input_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: inventory_transfer_items inventory_transfer_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfer_items"
    ADD CONSTRAINT "inventory_transfer_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: inventory_transfer_items inventory_transfer_items_stock_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfer_items"
    ADD CONSTRAINT "inventory_transfer_items_stock_unit_code_fkey" FOREIGN KEY ("stock_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: inventory_transfer_items inventory_transfer_items_transfer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfer_items"
    ADD CONSTRAINT "inventory_transfer_items_transfer_id_fkey" FOREIGN KEY ("transfer_id") REFERENCES "public"."inventory_transfers"("id") ON DELETE CASCADE;


--
-- Name: inventory_transfers inventory_transfers_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfers"
    ADD CONSTRAINT "inventory_transfers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id") ON DELETE SET NULL;


--
-- Name: inventory_transfers inventory_transfers_from_loc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfers"
    ADD CONSTRAINT "inventory_transfers_from_loc_id_fkey" FOREIGN KEY ("from_loc_id") REFERENCES "public"."inventory_locations"("id");


--
-- Name: inventory_transfers inventory_transfers_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfers"
    ADD CONSTRAINT "inventory_transfers_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: inventory_transfers inventory_transfers_to_loc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_transfers"
    ADD CONSTRAINT "inventory_transfers_to_loc_id_fkey" FOREIGN KEY ("to_loc_id") REFERENCES "public"."inventory_locations"("id");


--
-- Name: inventory_unit_aliases inventory_unit_aliases_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."inventory_unit_aliases"
    ADD CONSTRAINT "inventory_unit_aliases_unit_code_fkey" FOREIGN KEY ("unit_code") REFERENCES "public"."inventory_units"("code") ON DELETE CASCADE;


--
-- Name: loyalty_external_sales loyalty_external_sales_awarded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_external_sales"
    ADD CONSTRAINT "loyalty_external_sales_awarded_by_fkey" FOREIGN KEY ("awarded_by") REFERENCES "public"."employees"("id") ON DELETE RESTRICT;


--
-- Name: loyalty_external_sales loyalty_external_sales_loyalty_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_external_sales"
    ADD CONSTRAINT "loyalty_external_sales_loyalty_transaction_id_fkey" FOREIGN KEY ("loyalty_transaction_id") REFERENCES "public"."loyalty_transactions"("id") ON DELETE SET NULL;


--
-- Name: loyalty_external_sales loyalty_external_sales_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_external_sales"
    ADD CONSTRAINT "loyalty_external_sales_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE RESTRICT;


--
-- Name: loyalty_external_sales loyalty_external_sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_external_sales"
    ADD CONSTRAINT "loyalty_external_sales_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE RESTRICT;


--
-- Name: loyalty_redemptions loyalty_redemptions_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_redemptions"
    ADD CONSTRAINT "loyalty_redemptions_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE SET NULL;


--
-- Name: loyalty_redemptions loyalty_redemptions_reward_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_redemptions"
    ADD CONSTRAINT "loyalty_redemptions_reward_id_fkey" FOREIGN KEY ("reward_id") REFERENCES "public"."loyalty_rewards"("id") ON DELETE RESTRICT;


--
-- Name: loyalty_redemptions loyalty_redemptions_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_redemptions"
    ADD CONSTRAINT "loyalty_redemptions_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE SET NULL;


--
-- Name: loyalty_redemptions loyalty_redemptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_redemptions"
    ADD CONSTRAINT "loyalty_redemptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;


--
-- Name: loyalty_rewards loyalty_rewards_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_rewards"
    ADD CONSTRAINT "loyalty_rewards_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: loyalty_transactions loyalty_transactions_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_transactions"
    ADD CONSTRAINT "loyalty_transactions_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE SET NULL;


--
-- Name: loyalty_transactions loyalty_transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."loyalty_transactions"
    ADD CONSTRAINT "loyalty_transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id");


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: orders orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."users"("id") ON UPDATE RESTRICT ON DELETE SET NULL;


--
-- Name: orders orders_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_server_id_fkey" FOREIGN KEY ("server_id") REFERENCES "public"."employees"("id");


--
-- Name: orders orders_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."pos_sessions"("id");


--
-- Name: orders orders_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: orders orders_voided_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_voided_by_fkey" FOREIGN KEY ("voided_by") REFERENCES "public"."employees"("id");


--
-- Name: pass_satellites pass_satellites_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pass_satellites"
    ADD CONSTRAINT "pass_satellites_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pos_cash_movements pos_cash_movements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_cash_movements"
    ADD CONSTRAINT "pos_cash_movements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id");


--
-- Name: pos_cash_movements pos_cash_movements_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_cash_movements"
    ADD CONSTRAINT "pos_cash_movements_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id");


--
-- Name: pos_cash_movements pos_cash_movements_shift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_cash_movements"
    ADD CONSTRAINT "pos_cash_movements_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "public"."pos_cash_shifts"("id");


--
-- Name: pos_cash_shifts pos_cash_shifts_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_cash_shifts"
    ADD CONSTRAINT "pos_cash_shifts_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id");


--
-- Name: pos_cash_shifts pos_cash_shifts_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_cash_shifts"
    ADD CONSTRAINT "pos_cash_shifts_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: pos_modifier_options pos_modifier_options_modifier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_modifier_options"
    ADD CONSTRAINT "pos_modifier_options_modifier_id_fkey" FOREIGN KEY ("modifier_id") REFERENCES "public"."pos_modifiers"("id");


--
-- Name: pos_modifiers pos_modifiers_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_modifiers"
    ADD CONSTRAINT "pos_modifiers_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: pos_order_item_modifiers pos_order_item_modifiers_modifier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_order_item_modifiers"
    ADD CONSTRAINT "pos_order_item_modifiers_modifier_id_fkey" FOREIGN KEY ("modifier_id") REFERENCES "public"."pos_modifiers"("id");


--
-- Name: pos_order_item_modifiers pos_order_item_modifiers_modifier_option_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_order_item_modifiers"
    ADD CONSTRAINT "pos_order_item_modifiers_modifier_option_id_fkey" FOREIGN KEY ("modifier_option_id") REFERENCES "public"."pos_modifier_options"("id");


--
-- Name: pos_order_item_modifiers pos_order_item_modifiers_order_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_order_item_modifiers"
    ADD CONSTRAINT "pos_order_item_modifiers_order_item_id_fkey" FOREIGN KEY ("order_item_id") REFERENCES "public"."order_items"("id");


--
-- Name: pos_payments pos_payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_payments"
    ADD CONSTRAINT "pos_payments_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id");


--
-- Name: pos_payments pos_payments_processed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_payments"
    ADD CONSTRAINT "pos_payments_processed_by_fkey" FOREIGN KEY ("processed_by") REFERENCES "public"."employees"("id");


--
-- Name: pos_payments pos_payments_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_payments"
    ADD CONSTRAINT "pos_payments_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."pos_sessions"("id");


--
-- Name: pos_payments pos_payments_shift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_payments"
    ADD CONSTRAINT "pos_payments_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "public"."pos_cash_shifts"("id");


--
-- Name: pos_product_modifiers pos_product_modifiers_modifier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_product_modifiers"
    ADD CONSTRAINT "pos_product_modifiers_modifier_id_fkey" FOREIGN KEY ("modifier_id") REFERENCES "public"."pos_modifiers"("id");


--
-- Name: pos_product_modifiers pos_product_modifiers_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_product_modifiers"
    ADD CONSTRAINT "pos_product_modifiers_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: pos_session_orders pos_session_orders_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_session_orders"
    ADD CONSTRAINT "pos_session_orders_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id");


--
-- Name: pos_session_orders pos_session_orders_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_session_orders"
    ADD CONSTRAINT "pos_session_orders_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."pos_sessions"("id");


--
-- Name: pos_sessions pos_sessions_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_sessions"
    ADD CONSTRAINT "pos_sessions_server_id_fkey" FOREIGN KEY ("server_id") REFERENCES "public"."employees"("id");


--
-- Name: pos_sessions pos_sessions_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_sessions"
    ADD CONSTRAINT "pos_sessions_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: pos_sessions pos_sessions_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_sessions"
    ADD CONSTRAINT "pos_sessions_table_id_fkey" FOREIGN KEY ("table_id") REFERENCES "public"."pos_tables"("id");


--
-- Name: pos_tables pos_tables_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_tables"
    ADD CONSTRAINT "pos_tables_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: pos_tables pos_tables_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_tables"
    ADD CONSTRAINT "pos_tables_zone_id_fkey" FOREIGN KEY ("zone_id") REFERENCES "public"."pos_zones"("id");


--
-- Name: pos_zones pos_zones_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."pos_zones"
    ADD CONSTRAINT "pos_zones_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: procurement_agreed_prices procurement_agreed_prices_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_agreed_prices"
    ADD CONSTRAINT "procurement_agreed_prices_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: procurement_agreed_prices procurement_agreed_prices_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_agreed_prices"
    ADD CONSTRAINT "procurement_agreed_prices_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id");


--
-- Name: procurement_reception_items procurement_reception_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_reception_items"
    ADD CONSTRAINT "procurement_reception_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: procurement_reception_items procurement_reception_items_reception_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_reception_items"
    ADD CONSTRAINT "procurement_reception_items_reception_id_fkey" FOREIGN KEY ("reception_id") REFERENCES "public"."procurement_receptions"("id");


--
-- Name: procurement_receptions procurement_receptions_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_receptions"
    ADD CONSTRAINT "procurement_receptions_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "public"."purchase_orders"("id");


--
-- Name: procurement_receptions procurement_receptions_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_receptions"
    ADD CONSTRAINT "procurement_receptions_received_by_fkey" FOREIGN KEY ("received_by") REFERENCES "auth"."users"("id");


--
-- Name: procurement_receptions procurement_receptions_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."procurement_receptions"
    ADD CONSTRAINT "procurement_receptions_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: product_categories product_categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_categories"
    ADD CONSTRAINT "product_categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."product_categories"("id") ON DELETE SET NULL;


--
-- Name: product_categories product_categories_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_categories"
    ADD CONSTRAINT "product_categories_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE SET NULL;


--
-- Name: product_cost_events product_cost_events_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_cost_events"
    ADD CONSTRAINT "product_cost_events_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: product_cost_events product_cost_events_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_cost_events"
    ADD CONSTRAINT "product_cost_events_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: product_cost_events product_cost_events_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_cost_events"
    ADD CONSTRAINT "product_cost_events_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE SET NULL;


--
-- Name: product_cost_events product_cost_events_source_adjust_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_cost_events"
    ADD CONSTRAINT "product_cost_events_source_adjust_movement_id_fkey" FOREIGN KEY ("source_adjust_movement_id") REFERENCES "public"."inventory_movements"("id") ON DELETE SET NULL;


--
-- Name: product_cost_events product_cost_events_source_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_cost_events"
    ADD CONSTRAINT "product_cost_events_source_entry_id_fkey" FOREIGN KEY ("source_entry_id") REFERENCES "public"."inventory_entries"("id") ON DELETE SET NULL;


--
-- Name: product_inventory_profiles product_inventory_profiles_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_inventory_profiles"
    ADD CONSTRAINT "product_inventory_profiles_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: product_site_settings product_site_settings_default_area_kind_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_site_settings"
    ADD CONSTRAINT "product_site_settings_default_area_kind_fkey" FOREIGN KEY ("default_area_kind") REFERENCES "public"."area_kinds"("code");


--
-- Name: product_site_settings product_site_settings_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_site_settings"
    ADD CONSTRAINT "product_site_settings_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: product_site_settings product_site_settings_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_site_settings"
    ADD CONSTRAINT "product_site_settings_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: product_sku_aliases product_sku_aliases_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_sku_aliases"
    ADD CONSTRAINT "product_sku_aliases_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: product_suppliers product_suppliers_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_suppliers"
    ADD CONSTRAINT "product_suppliers_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: product_suppliers product_suppliers_purchase_pack_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_suppliers"
    ADD CONSTRAINT "product_suppliers_purchase_pack_unit_code_fkey" FOREIGN KEY ("purchase_pack_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: product_suppliers product_suppliers_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_suppliers"
    ADD CONSTRAINT "product_suppliers_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id");


--
-- Name: product_uom_profiles product_uom_profiles_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_uom_profiles"
    ADD CONSTRAINT "product_uom_profiles_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: production_batch_consumptions production_batch_consumptions_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batch_consumptions"
    ADD CONSTRAINT "production_batch_consumptions_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "public"."production_batches"("id") ON DELETE CASCADE;


--
-- Name: production_batch_consumptions production_batch_consumptions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batch_consumptions"
    ADD CONSTRAINT "production_batch_consumptions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: production_batch_consumptions production_batch_consumptions_ingredient_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batch_consumptions"
    ADD CONSTRAINT "production_batch_consumptions_ingredient_product_id_fkey" FOREIGN KEY ("ingredient_product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: production_batch_consumptions production_batch_consumptions_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batch_consumptions"
    ADD CONSTRAINT "production_batch_consumptions_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE RESTRICT;


--
-- Name: production_batch_consumptions production_batch_consumptions_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batch_consumptions"
    ADD CONSTRAINT "production_batch_consumptions_movement_id_fkey" FOREIGN KEY ("movement_id") REFERENCES "public"."inventory_movements"("id") ON DELETE SET NULL;


--
-- Name: production_batch_consumptions production_batch_consumptions_stock_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batch_consumptions"
    ADD CONSTRAINT "production_batch_consumptions_stock_unit_code_fkey" FOREIGN KEY ("stock_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: production_batches production_batches_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batches"
    ADD CONSTRAINT "production_batches_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id");


--
-- Name: production_batches production_batches_destination_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batches"
    ADD CONSTRAINT "production_batches_destination_location_id_fkey" FOREIGN KEY ("destination_location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE SET NULL;


--
-- Name: production_batches production_batches_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batches"
    ADD CONSTRAINT "production_batches_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: production_batches production_batches_recipe_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batches"
    ADD CONSTRAINT "production_batches_recipe_card_id_fkey" FOREIGN KEY ("recipe_card_id") REFERENCES "public"."recipe_cards"("id");


--
-- Name: production_batches production_batches_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_batches"
    ADD CONSTRAINT "production_batches_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: production_request_items production_request_items_area_kind_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_request_items"
    ADD CONSTRAINT "production_request_items_area_kind_fkey" FOREIGN KEY ("production_area_kind") REFERENCES "public"."area_kinds"("code");


--
-- Name: production_request_items production_request_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_request_items"
    ADD CONSTRAINT "production_request_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: production_request_items production_request_items_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_request_items"
    ADD CONSTRAINT "production_request_items_recipe_id_fkey" FOREIGN KEY ("recipe_id") REFERENCES "public"."recipes"("id");


--
-- Name: production_request_items production_request_items_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_request_items"
    ADD CONSTRAINT "production_request_items_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "public"."production_requests"("id");


--
-- Name: production_requests production_requests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_requests"
    ADD CONSTRAINT "production_requests_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");


--
-- Name: production_requests production_requests_from_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_requests"
    ADD CONSTRAINT "production_requests_from_site_id_fkey" FOREIGN KEY ("from_site_id") REFERENCES "public"."sites"("id");


--
-- Name: production_requests production_requests_to_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."production_requests"
    ADD CONSTRAINT "production_requests_to_site_id_fkey" FOREIGN KEY ("to_site_id") REFERENCES "public"."sites"("id");


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."product_categories"("id");


--
-- Name: products products_production_area_kind_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_production_area_kind_fkey" FOREIGN KEY ("production_area_kind") REFERENCES "public"."area_kinds"("code");


--
-- Name: products products_stock_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_stock_unit_code_fkey" FOREIGN KEY ("stock_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: purchase_order_items purchase_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: purchase_order_items purchase_order_items_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "public"."purchase_orders"("id");


--
-- Name: purchase_orders purchase_orders_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "auth"."users"("id");


--
-- Name: purchase_orders purchase_orders_cost_center_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_cost_center_id_fkey" FOREIGN KEY ("cost_center_id") REFERENCES "public"."cost_centers"("id");


--
-- Name: purchase_orders purchase_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id") ON DELETE SET NULL;


--
-- Name: purchase_orders purchase_orders_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: purchase_orders purchase_orders_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id");


--
-- Name: recipe_cards recipe_cards_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_cards"
    ADD CONSTRAINT "recipe_cards_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "public"."areas"("id");


--
-- Name: recipe_cards recipe_cards_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_cards"
    ADD CONSTRAINT "recipe_cards_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: recipe_cards recipe_cards_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_cards"
    ADD CONSTRAINT "recipe_cards_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: recipe_steps recipe_steps_recipe_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipe_steps"
    ADD CONSTRAINT "recipe_steps_recipe_card_id_fkey" FOREIGN KEY ("recipe_card_id") REFERENCES "public"."recipe_cards"("id") ON DELETE CASCADE;


--
-- Name: recipes recipes_ingredient_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipes"
    ADD CONSTRAINT "recipes_ingredient_product_id_fkey" FOREIGN KEY ("ingredient_product_id") REFERENCES "public"."products"("id");


--
-- Name: recipes recipes_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."recipes"
    ADD CONSTRAINT "recipes_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: restock_request_items restock_request_items_area_kind_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_request_items"
    ADD CONSTRAINT "restock_request_items_area_kind_fkey" FOREIGN KEY ("production_area_kind") REFERENCES "public"."area_kinds"("code");


--
-- Name: restock_request_items restock_request_items_input_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_request_items"
    ADD CONSTRAINT "restock_request_items_input_unit_code_fkey" FOREIGN KEY ("input_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: restock_request_items restock_request_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_request_items"
    ADD CONSTRAINT "restock_request_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: restock_request_items restock_request_items_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_request_items"
    ADD CONSTRAINT "restock_request_items_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "public"."restock_requests"("id");


--
-- Name: restock_request_items restock_request_items_source_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_request_items"
    ADD CONSTRAINT "restock_request_items_source_location_id_fkey" FOREIGN KEY ("source_location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE SET NULL;


--
-- Name: restock_request_items restock_request_items_stock_unit_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_request_items"
    ADD CONSTRAINT "restock_request_items_stock_unit_code_fkey" FOREIGN KEY ("stock_unit_code") REFERENCES "public"."inventory_units"("code");


--
-- Name: restock_requests restock_requests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");


--
-- Name: restock_requests restock_requests_from_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_from_site_id_fkey" FOREIGN KEY ("from_site_id") REFERENCES "public"."sites"("id");


--
-- Name: restock_requests restock_requests_in_transit_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_in_transit_by_fkey" FOREIGN KEY ("in_transit_by") REFERENCES "public"."employees"("id");


--
-- Name: restock_requests restock_requests_internal_supplier_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_internal_supplier_site_id_fkey" FOREIGN KEY ("internal_supplier_site_id") REFERENCES "public"."sites"("id");


--
-- Name: restock_requests restock_requests_prepared_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_prepared_by_fkey" FOREIGN KEY ("prepared_by") REFERENCES "public"."employees"("id");


--
-- Name: restock_requests restock_requests_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_received_by_fkey" FOREIGN KEY ("received_by") REFERENCES "public"."employees"("id");


--
-- Name: restock_requests restock_requests_requested_by_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_requested_by_site_id_fkey" FOREIGN KEY ("requested_by_site_id") REFERENCES "public"."sites"("id");


--
-- Name: restock_requests restock_requests_to_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."restock_requests"
    ADD CONSTRAINT "restock_requests_to_site_id_fkey" FOREIGN KEY ("to_site_id") REFERENCES "public"."sites"("id");


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "public"."app_permissions"("id") ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_fkey" FOREIGN KEY ("role") REFERENCES "public"."roles"("code") ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_scope_area_kind_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_scope_area_kind_fkey" FOREIGN KEY ("scope_area_kind") REFERENCES "public"."area_kinds"("code");


--
-- Name: role_site_type_rules role_site_type_rules_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_site_type_rules"
    ADD CONSTRAINT "role_site_type_rules_role_fkey" FOREIGN KEY ("role") REFERENCES "public"."roles"("code") ON DELETE CASCADE;


--
-- Name: site_production_pick_order site_production_pick_order_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."site_production_pick_order"
    ADD CONSTRAINT "site_production_pick_order_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."inventory_locations"("id") ON DELETE CASCADE;


--
-- Name: site_production_pick_order site_production_pick_order_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."site_production_pick_order"
    ADD CONSTRAINT "site_production_pick_order_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE CASCADE;


--
-- Name: site_supply_routes site_supply_routes_fulfillment_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."site_supply_routes"
    ADD CONSTRAINT "site_supply_routes_fulfillment_site_id_fkey" FOREIGN KEY ("fulfillment_site_id") REFERENCES "public"."sites"("id");


--
-- Name: site_supply_routes site_supply_routes_requesting_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."site_supply_routes"
    ADD CONSTRAINT "site_supply_routes_requesting_site_id_fkey" FOREIGN KEY ("requesting_site_id") REFERENCES "public"."sites"("id");


--
-- Name: staff_invitations staff_invitations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."staff_invitations"
    ADD CONSTRAINT "staff_invitations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");


--
-- Name: staff_invitations staff_invitations_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."staff_invitations"
    ADD CONSTRAINT "staff_invitations_role_fkey" FOREIGN KEY ("staff_role") REFERENCES "public"."roles"("code");


--
-- Name: staff_invitations staff_invitations_staff_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."staff_invitations"
    ADD CONSTRAINT "staff_invitations_staff_site_id_fkey" FOREIGN KEY ("staff_site_id") REFERENCES "public"."sites"("id");


--
-- Name: support_messages support_messages_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."support_messages"
    ADD CONSTRAINT "support_messages_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: support_messages support_messages_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."support_messages"
    ADD CONSTRAINT "support_messages_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "public"."support_tickets"("id") ON DELETE CASCADE;


--
-- Name: support_tickets support_tickets_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."support_tickets"
    ADD CONSTRAINT "support_tickets_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."employees"("id") ON DELETE SET NULL;


--
-- Name: support_tickets support_tickets_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."support_tickets"
    ADD CONSTRAINT "support_tickets_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("id") ON DELETE CASCADE;


--
-- Name: support_tickets support_tickets_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."support_tickets"
    ADD CONSTRAINT "support_tickets_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id") ON DELETE SET NULL;


--
-- Name: user_favorites user_favorites_reward_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_favorites"
    ADD CONSTRAINT "user_favorites_reward_id_fkey" FOREIGN KEY ("reward_id") REFERENCES "public"."loyalty_rewards"("id") ON DELETE CASCADE;


--
-- Name: user_favorites user_favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_favorites"
    ADD CONSTRAINT "user_favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: user_feedback user_feedback_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_feedback"
    ADD CONSTRAINT "user_feedback_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "public"."employees"("id");


--
-- Name: user_feedback user_feedback_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_feedback"
    ADD CONSTRAINT "user_feedback_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("id");


--
-- Name: user_feedback user_feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_feedback"
    ADD CONSTRAINT "user_feedback_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;


--
-- Name: wallet_devices wallet_devices_serial_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."wallet_devices"
    ADD CONSTRAINT "wallet_devices_serial_number_fkey" FOREIGN KEY ("serial_number") REFERENCES "public"."wallet_passes"("serial_number") ON DELETE CASCADE;


--
-- Name: inventory_movement_types Anyone can read movement types; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can read movement types" ON "public"."inventory_movement_types" FOR SELECT TO "authenticated" USING (true);


--
-- Name: inventory_lpn_items Employees can view LPN items of their sites; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Employees can view LPN items of their sites" ON "public"."inventory_lpn_items" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."inventory_lpns" "lpn"
     JOIN "public"."employee_sites" "es" ON (("lpn"."site_id" = "es"."site_id")))
  WHERE (("lpn"."id" = "inventory_lpn_items"."lpn_id") AND ("es"."employee_id" = "auth"."uid"())))));


--
-- Name: user_feedback Employees can view all feedback; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Employees can view all feedback" ON "public"."user_feedback" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE ("employees"."id" = "auth"."uid"()))));


--
-- Name: user_feedback Owners can update feedback; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Owners can update feedback" ON "public"."user_feedback" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = 'propietario'::"text")))));


--
-- Name: inventory_lpn_items Staff can manage LPN items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Staff can manage LPN items" ON "public"."inventory_lpn_items" USING ((EXISTS ( SELECT 1
   FROM (("public"."inventory_lpns" "lpn"
     JOIN "public"."employees" "e" ON (("e"."id" = "auth"."uid"())))
     JOIN "public"."employee_sites" "es" ON ((("e"."id" = "es"."employee_id") AND ("lpn"."site_id" = "es"."site_id"))))
  WHERE ("lpn"."id" = "inventory_lpn_items"."lpn_id"))));


--
-- Name: user_favorites Users can delete their own favorites; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete their own favorites" ON "public"."user_favorites" FOR DELETE USING (("auth"."uid"() = "user_id"));


--
-- Name: user_favorites Users can insert their own favorites; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own favorites" ON "public"."user_favorites" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: user_feedback Users can insert their own feedback; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own feedback" ON "public"."user_feedback" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: loyalty_redemptions Users can insert their own redemptions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own redemptions" ON "public"."loyalty_redemptions" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: loyalty_transactions Users can insert their own transactions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own transactions" ON "public"."loyalty_transactions" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: user_favorites Users can view their own favorites; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own favorites" ON "public"."user_favorites" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: user_feedback Users can view their own feedback; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own feedback" ON "public"."user_feedback" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--
-- Name: account_deletion_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."account_deletion_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: account_deletion_requests account_deletion_requests_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "account_deletion_requests_select_own" ON "public"."account_deletion_requests" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));


--
-- Name: account_deletion_requests account_deletion_requests_service_role; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "account_deletion_requests_service_role" ON "public"."account_deletion_requests" TO "service_role" USING (true) WITH CHECK (true);


--
-- Name: announcements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."announcements" ENABLE ROW LEVEL SECURITY;

--
-- Name: announcements announcements_select_authenticated; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "announcements_select_authenticated" ON "public"."announcements" FOR SELECT TO "authenticated" USING (("is_active" = true));


--
-- Name: announcements announcements_write_management; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "announcements_write_management" ON "public"."announcements" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text", 'gerente'::"text"])))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text", 'gerente'::"text"]))))));


--
-- Name: app_permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."app_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: app_permissions app_permissions_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "app_permissions_manage_owner" ON "public"."app_permissions" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: app_permissions app_permissions_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "app_permissions_select_all" ON "public"."app_permissions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: app_update_policies; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."app_update_policies" ENABLE ROW LEVEL SECURITY;

--
-- Name: app_update_policies app_update_policies_select_public; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "app_update_policies_select_public" ON "public"."app_update_policies" FOR SELECT TO "authenticated", "anon" USING (("is_enabled" = true));


--
-- Name: apps; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."apps" ENABLE ROW LEVEL SECURITY;

--
-- Name: apps apps_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "apps_manage_owner" ON "public"."apps" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: apps apps_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "apps_select_all" ON "public"."apps" FOR SELECT TO "authenticated" USING (true);


--
-- Name: area_kinds; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."area_kinds" ENABLE ROW LEVEL SECURITY;

--
-- Name: area_kinds area_kinds_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "area_kinds_manage_owner" ON "public"."area_kinds" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: area_kinds area_kinds_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "area_kinds_select_all" ON "public"."area_kinds" FOR SELECT TO "authenticated" USING (true);


--
-- Name: areas; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."areas" ENABLE ROW LEVEL SECURITY;

--
-- Name: areas areas_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "areas_select_staff" ON "public"."areas" FOR SELECT USING (("public"."can_access_area"("id") OR (("public"."current_employee_role"() = ANY (ARRAY['gerente'::"text", 'bodeguero'::"text"])) AND "public"."can_access_site"("site_id"))));


--
-- Name: areas areas_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "areas_write_owner" ON "public"."areas" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: attendance_breaks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."attendance_breaks" ENABLE ROW LEVEL SECURITY;

--
-- Name: attendance_breaks attendance_breaks_select_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "attendance_breaks_select_manager" ON "public"."attendance_breaks" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text"])) AND (("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"])) OR ("e"."site_id" = "attendance_breaks"."site_id"))))));


--
-- Name: attendance_breaks attendance_breaks_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "attendance_breaks_select_self" ON "public"."attendance_breaks" FOR SELECT TO "authenticated" USING (("employee_id" = "auth"."uid"()));


--
-- Name: attendance_logs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."attendance_logs" ENABLE ROW LEVEL SECURITY;

--
-- Name: attendance_logs attendance_logs_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "attendance_logs_insert_self" ON "public"."attendance_logs" FOR INSERT TO "authenticated" WITH CHECK (("employee_id" = "auth"."uid"()));


--
-- Name: attendance_logs attendance_logs_select_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "attendance_logs_select_manager" ON "public"."attendance_logs" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text"])) AND (("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"])) OR ("e"."site_id" = "attendance_logs"."site_id"))))));


--
-- Name: attendance_logs attendance_logs_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "attendance_logs_select_self" ON "public"."attendance_logs" FOR SELECT TO "authenticated" USING (("employee_id" = "auth"."uid"()));


--
-- Name: attendance_shift_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."attendance_shift_events" ENABLE ROW LEVEL SECURITY;

--
-- Name: attendance_shift_events attendance_shift_events_select_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "attendance_shift_events_select_manager" ON "public"."attendance_shift_events" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text"])) AND (("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"])) OR ("e"."site_id" = "attendance_shift_events"."site_id"))))));


--
-- Name: attendance_shift_events attendance_shift_events_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "attendance_shift_events_select_self" ON "public"."attendance_shift_events" FOR SELECT TO "authenticated" USING (("employee_id" = "auth"."uid"()));


--
-- Name: cost_centers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."cost_centers" ENABLE ROW LEVEL SECURITY;

--
-- Name: document_types; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."document_types" ENABLE ROW LEVEL SECURITY;

--
-- Name: document_types document_types_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "document_types_select" ON "public"."document_types" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));


--
-- Name: document_types document_types_write_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "document_types_write_admin" ON "public"."document_types" USING (("public"."is_owner"() OR "public"."is_global_manager"() OR ("public"."current_employee_role"() = 'gerente'::"text"))) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"() OR ("public"."current_employee_role"() = 'gerente'::"text")));


--
-- Name: documents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."documents" ENABLE ROW LEVEL SECURITY;

--
-- Name: documents documents_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_delete" ON "public"."documents" FOR DELETE USING (("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ((("scope" = 'site'::"public"."document_scope") AND ("site_id" = ( SELECT "me"."site_id"
   FROM "public"."employees" "me"
  WHERE ("me"."id" = "auth"."uid"())))) OR (("scope" = 'employee'::"public"."document_scope") AND ("target_employee_id" IN ( SELECT "e"."id"
   FROM "public"."employees" "e"
  WHERE ("e"."site_id" = ( SELECT "me"."site_id"
           FROM "public"."employees" "me"
          WHERE ("me"."id" = "auth"."uid"())))))) OR ("scope" = 'group'::"public"."document_scope")))));


--
-- Name: documents documents_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_insert" ON "public"."documents" FOR INSERT WITH CHECK ((("public"."is_owner"() OR "public"."is_global_manager"() OR ("public"."current_employee_role"() = 'gerente'::"text")) AND ((("scope" = 'employee'::"public"."document_scope") AND ("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ("target_employee_id" IN ( SELECT "e"."id"
   FROM "public"."employees" "e"
  WHERE ("e"."site_id" = ( SELECT "me"."site_id"
           FROM "public"."employees" "me"
          WHERE ("me"."id" = "auth"."uid"())))))))) OR (("scope" = 'site'::"public"."document_scope") AND ("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ("site_id" = ( SELECT "me"."site_id"
   FROM "public"."employees" "me"
  WHERE ("me"."id" = "auth"."uid"())))))) OR (("scope" = 'group'::"public"."document_scope") AND ("public"."is_owner"() OR "public"."is_global_manager"())))));


--
-- Name: documents documents_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_select" ON "public"."documents" FOR SELECT USING (("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ((("scope" = 'site'::"public"."document_scope") AND ("site_id" = ( SELECT "me"."site_id"
   FROM "public"."employees" "me"
  WHERE ("me"."id" = "auth"."uid"())))) OR (("scope" = 'employee'::"public"."document_scope") AND ("target_employee_id" IN ( SELECT "e"."id"
   FROM "public"."employees" "e"
  WHERE ("e"."site_id" = ( SELECT "me"."site_id"
           FROM "public"."employees" "me"
          WHERE ("me"."id" = "auth"."uid"())))))) OR ("scope" = 'group'::"public"."document_scope"))) OR ((("scope" = 'employee'::"public"."document_scope") AND ("target_employee_id" = "auth"."uid"())) OR (("scope" = 'site'::"public"."document_scope") AND ("site_id" IN ( SELECT "employees"."site_id"
   FROM "public"."employees"
  WHERE ("employees"."id" = "auth"."uid"())
UNION
 SELECT "es"."site_id"
   FROM "public"."employee_sites" "es"
  WHERE (("es"."employee_id" = "auth"."uid"()) AND ("es"."is_active" = true))))))));


--
-- Name: documents documents_update_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_update_owner" ON "public"."documents" FOR UPDATE USING ((("owner_employee_id" = "auth"."uid"()) AND ("status" = 'pending_review'::"public"."document_status"))) WITH CHECK ((("owner_employee_id" = "auth"."uid"()) AND ("status" = 'pending_review'::"public"."document_status")));


--
-- Name: documents documents_update_review; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_update_review" ON "public"."documents" FOR UPDATE USING (((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"]))))) OR (EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."employee_sites" "es" ON (("es"."employee_id" = "e"."id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = 'gerente'::"text") AND ("es"."site_id" = "documents"."site_id") AND ("es"."is_active" = true)))))) WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"]))))) OR (EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."employee_sites" "es" ON (("es"."employee_id" = "e"."id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = 'gerente'::"text") AND ("es"."site_id" = "documents"."site_id") AND ("es"."is_active" = true))))));


--
-- Name: documents documents_write_restrict_delete_owner_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_write_restrict_delete_owner_manager" ON "public"."documents" AS RESTRICTIVE FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text", 'gerente'::"text"]))))));


--
-- Name: documents documents_write_restrict_insert_owner_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_write_restrict_insert_owner_manager" ON "public"."documents" AS RESTRICTIVE FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text", 'gerente'::"text"]))))));


--
-- Name: documents documents_write_restrict_update_owner_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "documents_write_restrict_update_owner_manager" ON "public"."documents" AS RESTRICTIVE FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text", 'gerente'::"text"])))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text", 'gerente'::"text"]))))));


--
-- Name: employee_areas; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employee_areas" ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_areas employee_areas_select_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_areas_select_owner" ON "public"."employee_areas" FOR SELECT USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_areas employee_areas_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_areas_select_self" ON "public"."employee_areas" FOR SELECT USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_areas employee_areas_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_areas_write_owner" ON "public"."employee_areas" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_devices; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employee_devices" ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_devices employee_devices_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_devices_insert" ON "public"."employee_devices" FOR INSERT WITH CHECK (("employee_id" = "auth"."uid"()));


--
-- Name: employee_devices employee_devices_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_devices_select" ON "public"."employee_devices" FOR SELECT USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_devices employee_devices_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_devices_update" ON "public"."employee_devices" FOR UPDATE USING (("employee_id" = "auth"."uid"())) WITH CHECK (("employee_id" = "auth"."uid"()));


--
-- Name: employee_permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employee_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_permissions employee_permissions_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_permissions_manage_owner" ON "public"."employee_permissions" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_permissions employee_permissions_select_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_permissions_select_owner" ON "public"."employee_permissions" FOR SELECT TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_permissions employee_permissions_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_permissions_select_self" ON "public"."employee_permissions" FOR SELECT TO "authenticated" USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_push_tokens; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employee_push_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_push_tokens employee_push_tokens_delete_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_push_tokens_delete_self" ON "public"."employee_push_tokens" FOR DELETE USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_push_tokens employee_push_tokens_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_push_tokens_insert_self" ON "public"."employee_push_tokens" FOR INSERT WITH CHECK (("employee_id" = "auth"."uid"()));


--
-- Name: employee_push_tokens employee_push_tokens_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_push_tokens_select_self" ON "public"."employee_push_tokens" FOR SELECT USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_push_tokens employee_push_tokens_update_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_push_tokens_update_self" ON "public"."employee_push_tokens" FOR UPDATE USING (("employee_id" = "auth"."uid"())) WITH CHECK (("employee_id" = "auth"."uid"()));


--
-- Name: employee_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employee_settings" ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_settings employee_settings_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_settings_insert_self" ON "public"."employee_settings" FOR INSERT WITH CHECK ((("employee_id" = "auth"."uid"()) AND (("selected_site_id" IS NULL) OR "public"."can_access_site"("selected_site_id")) AND (("selected_area_id" IS NULL) OR "public"."can_access_area"("selected_area_id"))));


--
-- Name: employee_settings employee_settings_select_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_settings_select_owner" ON "public"."employee_settings" FOR SELECT USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_settings employee_settings_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_settings_select_self" ON "public"."employee_settings" FOR SELECT USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_settings employee_settings_update_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_settings_update_self" ON "public"."employee_settings" FOR UPDATE USING (("employee_id" = "auth"."uid"())) WITH CHECK ((("employee_id" = "auth"."uid"()) AND (("selected_site_id" IS NULL) OR "public"."can_access_site"("selected_site_id")) AND (("selected_area_id" IS NULL) OR "public"."can_access_area"("selected_area_id"))));


--
-- Name: employee_shifts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employee_shifts" ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_shifts employee_shifts_select_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_shifts_select_manager" ON "public"."employee_shifts" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['gerente'::"text"])) AND ("e"."site_id" = "employee_shifts"."site_id")))));


--
-- Name: employee_shifts employee_shifts_select_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_shifts_select_owner" ON "public"."employee_shifts" FOR SELECT USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_shifts employee_shifts_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_shifts_select_self" ON "public"."employee_shifts" FOR SELECT USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_shifts employee_shifts_write_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_shifts_write_manager" ON "public"."employee_shifts" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['gerente'::"text"])) AND ("e"."site_id" = "employee_shifts"."site_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['gerente'::"text"])) AND ("e"."site_id" = "employee_shifts"."site_id")))));


--
-- Name: employee_shifts employee_shifts_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_shifts_write_owner" ON "public"."employee_shifts" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_sites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employee_sites" ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_sites employee_sites_read_management; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_sites_read_management" ON "public"."employee_sites" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "me"
  WHERE (("me"."id" = "auth"."uid"()) AND ("me"."is_active" IS TRUE) AND ("me"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text"]))))));


--
-- Name: employee_sites employee_sites_read_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_sites_read_self" ON "public"."employee_sites" FOR SELECT TO "authenticated" USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_sites employee_sites_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_sites_select" ON "public"."employee_sites" FOR SELECT USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ("employee_id" IN ( SELECT "e"."id"
   FROM "public"."employees" "e"
  WHERE ("e"."site_id" = ( SELECT "me"."site_id"
           FROM "public"."employees" "me"
          WHERE ("me"."id" = "auth"."uid"())))))) OR ("employee_id" = "auth"."uid"()))));


--
-- Name: employee_sites employee_sites_select_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_sites_select_owner" ON "public"."employee_sites" FOR SELECT USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_sites employee_sites_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_sites_select_self" ON "public"."employee_sites" FOR SELECT USING (("employee_id" = "auth"."uid"()));


--
-- Name: employee_sites employee_sites_write_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_sites_write_admin" ON "public"."employee_sites" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employee_sites employee_sites_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employee_sites_write_owner" ON "public"."employee_sites" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: employees; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."employees" ENABLE ROW LEVEL SECURITY;

--
-- Name: purchase_orders employees_crud_purchase_orders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_crud_purchase_orders" ON "public"."purchase_orders" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE ("employees"."id" = "auth"."uid"()))));


--
-- Name: employees employees_insert_owner_global_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_insert_owner_global_manager" ON "public"."employees" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_owner"() OR ("public"."is_global_manager"() AND ("role" <> ALL (ARRAY['propietario'::"text", 'gerente_general'::"text"])))));


--
-- Name: procurement_agreed_prices employees_read_agreed_prices; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_read_agreed_prices" ON "public"."procurement_agreed_prices" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE ("employees"."id" = "auth"."uid"()))));


--
-- Name: cost_centers employees_read_cost_centers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_read_cost_centers" ON "public"."cost_centers" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE ("employees"."id" = "auth"."uid"()))));


--
-- Name: suppliers employees_read_suppliers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_read_suppliers" ON "public"."suppliers" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE ("employees"."id" = "auth"."uid"()))));


--
-- Name: employees employees_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_select" ON "public"."employees" FOR SELECT USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ("site_id" = "public"."current_employee_site_id"())) OR ("id" = "auth"."uid"()))));


--
-- Name: employees employees_select_area; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_select_area" ON "public"."employees" FOR SELECT USING ((("area_id" IS NOT NULL) AND "public"."can_access_area"("area_id") AND ("public"."is_owner"() OR "public"."is_global_manager"() OR ("public"."current_employee_role"() <> 'gerente'::"text") OR ("site_id" = "public"."current_employee_site_id"()))));


--
-- Name: employees employees_select_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_select_manager" ON "public"."employees" FOR SELECT USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ("site_id" = "public"."current_employee_site_id"())) OR (("public"."current_employee_role"() = 'bodeguero'::"text") AND "public"."can_access_site"("site_id")))));


--
-- Name: employees employees_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_select_self" ON "public"."employees" FOR SELECT USING (("auth"."uid"() = "id"));


--
-- Name: employees employees_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "employees_update" ON "public"."employees" FOR UPDATE USING (("public"."is_owner"() OR "public"."is_global_manager"() OR (("public"."current_employee_role"() = 'gerente'::"text") AND ("site_id" = "public"."current_employee_site_id"())) OR ("id" = "auth"."uid"()))) WITH CHECK (("public"."is_owner"() OR ("public"."is_global_manager"() AND ("role" <> ALL (ARRAY['propietario'::"text", 'gerente_general'::"text"]))) OR (("public"."current_employee_role"() = 'gerente'::"text") AND ("role" <> ALL (ARRAY['propietario'::"text", 'gerente_general'::"text", 'gerente'::"text"])) AND ("site_id" = "public"."current_employee_site_id"())) OR (("id" = "auth"."uid"()) AND ("role" = "public"."current_employee_role"()))));


--
-- Name: inventory_entries; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_entries" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_entries inventory_entries_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entries_delete_permission" ON "public"."inventory_entries" FOR DELETE TO "authenticated" USING (("public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id")));


--
-- Name: inventory_entries inventory_entries_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entries_insert_permission" ON "public"."inventory_entries" FOR INSERT TO "authenticated" WITH CHECK (("public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id")));


--
-- Name: inventory_entries inventory_entries_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entries_select_permission" ON "public"."inventory_entries" FOR SELECT TO "authenticated" USING (("public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.stock'::"text", "site_id")));


--
-- Name: inventory_entries inventory_entries_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entries_update_permission" ON "public"."inventory_entries" FOR UPDATE TO "authenticated" USING (("public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id"))) WITH CHECK (("public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id")));


--
-- Name: inventory_entry_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_entry_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_entry_items inventory_entry_items_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entry_items_delete_permission" ON "public"."inventory_entry_items" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_entries" "ie"
  WHERE (("ie"."id" = "inventory_entry_items"."entry_id") AND ("public"."has_permission"('nexo.inventory.entries'::"text", "ie"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "ie"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "ie"."site_id"))))));


--
-- Name: inventory_entry_items inventory_entry_items_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entry_items_insert_permission" ON "public"."inventory_entry_items" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."inventory_entries" "ie"
  WHERE (("ie"."id" = "inventory_entry_items"."entry_id") AND ("public"."has_permission"('nexo.inventory.entries'::"text", "ie"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "ie"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "ie"."site_id"))))));


--
-- Name: inventory_entry_items inventory_entry_items_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entry_items_select_permission" ON "public"."inventory_entry_items" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_entries" "ie"
  WHERE (("ie"."id" = "inventory_entry_items"."entry_id") AND ("public"."has_permission"('nexo.inventory.entries'::"text", "ie"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "ie"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "ie"."site_id") OR "public"."has_permission"('nexo.inventory.stock'::"text", "ie"."site_id"))))));


--
-- Name: inventory_entry_items inventory_entry_items_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_entry_items_update_permission" ON "public"."inventory_entry_items" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_entries" "ie"
  WHERE (("ie"."id" = "inventory_entry_items"."entry_id") AND ("public"."has_permission"('nexo.inventory.entries'::"text", "ie"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "ie"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "ie"."site_id")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."inventory_entries" "ie"
  WHERE (("ie"."id" = "inventory_entry_items"."entry_id") AND ("public"."has_permission"('nexo.inventory.entries'::"text", "ie"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "ie"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "ie"."site_id"))))));


--
-- Name: inventory_locations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_locations" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_locations inventory_locations_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_locations_delete_permission" ON "public"."inventory_locations" FOR DELETE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.locations'::"text", "site_id"));


--
-- Name: inventory_locations inventory_locations_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_locations_insert_permission" ON "public"."inventory_locations" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('nexo.inventory.locations'::"text", "site_id"));


--
-- Name: inventory_locations inventory_locations_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_locations_select_permission" ON "public"."inventory_locations" FOR SELECT TO "authenticated" USING (("public"."has_permission"('nexo.inventory.locations'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "site_id")));


--
-- Name: inventory_locations inventory_locations_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_locations_update_permission" ON "public"."inventory_locations" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.locations'::"text", "site_id")) WITH CHECK ("public"."has_permission"('nexo.inventory.locations'::"text", "site_id"));


--
-- Name: inventory_lpn_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_lpn_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_lpns; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_lpns" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_lpns inventory_lpns_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_lpns_delete_permission" ON "public"."inventory_lpns" FOR DELETE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.lpns'::"text", "site_id"));


--
-- Name: inventory_lpns inventory_lpns_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_lpns_insert_permission" ON "public"."inventory_lpns" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('nexo.inventory.lpns'::"text", "site_id"));


--
-- Name: inventory_lpns inventory_lpns_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_lpns_select_permission" ON "public"."inventory_lpns" FOR SELECT TO "authenticated" USING ("public"."has_permission"('nexo.inventory.lpns'::"text", "site_id"));


--
-- Name: inventory_lpns inventory_lpns_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_lpns_update_permission" ON "public"."inventory_lpns" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.lpns'::"text", "site_id")) WITH CHECK ("public"."has_permission"('nexo.inventory.lpns'::"text", "site_id"));


--
-- Name: inventory_movement_types; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_movement_types" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_movements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_movements" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_movements inventory_movements_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_movements_insert_permission" ON "public"."inventory_movements" FOR INSERT TO "authenticated" WITH CHECK (("public"."has_permission"('nexo.inventory.movements'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.transfers'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.counts'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.adjustments'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id") OR "public"."has_permission"('fogo.production.batches'::"text", "site_id")));


--
-- Name: inventory_movements inventory_movements_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_movements_select_permission" ON "public"."inventory_movements" FOR SELECT TO "authenticated" USING ("public"."has_permission"('nexo.inventory.movements'::"text", "site_id"));


--
-- Name: inventory_stock_by_location; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_stock_by_location" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_stock_by_location inventory_stock_by_location_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_stock_by_location_delete_permission" ON "public"."inventory_stock_by_location" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_locations" "loc"
  WHERE (("loc"."id" = "inventory_stock_by_location"."location_id") AND "public"."has_permission"('nexo.inventory.stock'::"text", "loc"."site_id")))));


--
-- Name: inventory_stock_by_location inventory_stock_by_location_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_stock_by_location_insert_permission" ON "public"."inventory_stock_by_location" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."inventory_locations" "loc"
  WHERE (("loc"."id" = "inventory_stock_by_location"."location_id") AND ("public"."has_permission"('nexo.inventory.stock'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.entries'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.transfers'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.counts'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.adjustments'::"text", "loc"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "loc"."site_id") OR "public"."has_permission"('fogo.production.batches'::"text", "loc"."site_id"))))));


--
-- Name: inventory_stock_by_location inventory_stock_by_location_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_stock_by_location_select_permission" ON "public"."inventory_stock_by_location" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_locations" "loc"
  WHERE (("loc"."id" = "inventory_stock_by_location"."location_id") AND ("public"."has_permission"('nexo.inventory.stock'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "loc"."site_id"))))));


--
-- Name: inventory_stock_by_location inventory_stock_by_location_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_stock_by_location_update_permission" ON "public"."inventory_stock_by_location" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_locations" "loc"
  WHERE (("loc"."id" = "inventory_stock_by_location"."location_id") AND ("public"."has_permission"('nexo.inventory.stock'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.entries'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.transfers'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.counts'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.adjustments'::"text", "loc"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "loc"."site_id") OR "public"."has_permission"('fogo.production.batches'::"text", "loc"."site_id")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."inventory_locations" "loc"
  WHERE (("loc"."id" = "inventory_stock_by_location"."location_id") AND ("public"."has_permission"('nexo.inventory.stock'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.entries'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.transfers'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.counts'::"text", "loc"."site_id") OR "public"."has_permission"('nexo.inventory.adjustments'::"text", "loc"."site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "loc"."site_id") OR "public"."has_permission"('fogo.production.batches'::"text", "loc"."site_id"))))));


--
-- Name: inventory_stock_by_site; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_stock_by_site" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_stock_by_site inventory_stock_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_stock_insert_permission" ON "public"."inventory_stock_by_site" FOR INSERT TO "authenticated" WITH CHECK (("public"."has_permission"('nexo.inventory.stock'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.transfers'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.counts'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.adjustments'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id") OR "public"."has_permission"('fogo.production.batches'::"text", "site_id")));


--
-- Name: inventory_stock_by_site inventory_stock_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_stock_select_permission" ON "public"."inventory_stock_by_site" FOR SELECT TO "authenticated" USING (("public"."has_permission"('nexo.inventory.stock'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "site_id")));


--
-- Name: inventory_stock_by_site inventory_stock_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_stock_update_permission" ON "public"."inventory_stock_by_site" FOR UPDATE TO "authenticated" USING (("public"."has_permission"('nexo.inventory.stock'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.transfers'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.counts'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.adjustments'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id") OR "public"."has_permission"('fogo.production.batches'::"text", "site_id"))) WITH CHECK (("public"."has_permission"('nexo.inventory.stock'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.entries_emergency'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.transfers'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.withdraw'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.counts'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.adjustments'::"text", "site_id") OR "public"."has_permission"('origo.procurement.receipts'::"text", "site_id") OR "public"."has_permission"('fogo.production.batches'::"text", "site_id")));


--
-- Name: inventory_transfer_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_transfer_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_transfer_items inventory_transfer_items_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfer_items_delete_permission" ON "public"."inventory_transfer_items" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_transfers" "it"
  WHERE (("it"."id" = "inventory_transfer_items"."transfer_id") AND "public"."has_permission"('nexo.inventory.transfers'::"text", "it"."site_id")))));


--
-- Name: inventory_transfer_items inventory_transfer_items_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfer_items_insert_permission" ON "public"."inventory_transfer_items" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."inventory_transfers" "it"
  WHERE (("it"."id" = "inventory_transfer_items"."transfer_id") AND "public"."has_permission"('nexo.inventory.transfers'::"text", "it"."site_id")))));


--
-- Name: inventory_transfer_items inventory_transfer_items_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfer_items_select_permission" ON "public"."inventory_transfer_items" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_transfers" "it"
  WHERE (("it"."id" = "inventory_transfer_items"."transfer_id") AND ("public"."has_permission"('nexo.inventory.transfers'::"text", "it"."site_id") OR "public"."has_permission"('nexo.inventory.stock'::"text", "it"."site_id"))))));


--
-- Name: inventory_transfer_items inventory_transfer_items_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfer_items_update_permission" ON "public"."inventory_transfer_items" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."inventory_transfers" "it"
  WHERE (("it"."id" = "inventory_transfer_items"."transfer_id") AND "public"."has_permission"('nexo.inventory.transfers'::"text", "it"."site_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."inventory_transfers" "it"
  WHERE (("it"."id" = "inventory_transfer_items"."transfer_id") AND "public"."has_permission"('nexo.inventory.transfers'::"text", "it"."site_id")))));


--
-- Name: inventory_transfers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."inventory_transfers" ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_transfers inventory_transfers_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfers_delete_permission" ON "public"."inventory_transfers" FOR DELETE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.transfers'::"text", "site_id"));


--
-- Name: inventory_transfers inventory_transfers_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfers_insert_permission" ON "public"."inventory_transfers" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('nexo.inventory.transfers'::"text", "site_id"));


--
-- Name: inventory_transfers inventory_transfers_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfers_select_permission" ON "public"."inventory_transfers" FOR SELECT TO "authenticated" USING (("public"."has_permission"('nexo.inventory.transfers'::"text", "site_id") OR "public"."has_permission"('nexo.inventory.stock'::"text", "site_id")));


--
-- Name: inventory_transfers inventory_transfers_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "inventory_transfers_update_permission" ON "public"."inventory_transfers" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.transfers'::"text", "site_id")) WITH CHECK ("public"."has_permission"('nexo.inventory.transfers'::"text", "site_id"));


--
-- Name: loyalty_external_sales; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."loyalty_external_sales" ENABLE ROW LEVEL SECURITY;

--
-- Name: loyalty_external_sales loyalty_external_sales_insert_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "loyalty_external_sales_insert_staff" ON "public"."loyalty_external_sales" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_staff"() AND "public"."has_permission"('pulso.pos.main'::"text", "site_id", NULL::"uuid") AND ("awarded_by" = "auth"."uid"())));


--
-- Name: loyalty_external_sales loyalty_external_sales_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "loyalty_external_sales_select_staff" ON "public"."loyalty_external_sales" FOR SELECT TO "authenticated" USING (("public"."is_active_staff"() AND "public"."has_permission"('pulso.pos.main'::"text", "site_id", NULL::"uuid")));


--
-- Name: loyalty_redemptions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."loyalty_redemptions" ENABLE ROW LEVEL SECURITY;

--
-- Name: loyalty_redemptions loyalty_redemptions_select_cashier; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "loyalty_redemptions_select_cashier" ON "public"."loyalty_redemptions" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."loyalty_rewards" "r" ON (("r"."id" = "loyalty_redemptions"."reward_id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text", 'cajero'::"text", 'mesero'::"text"])) AND (("e"."site_id" = "r"."site_id") OR (EXISTS ( SELECT 1
           FROM "public"."employee_sites" "es"
          WHERE (("es"."employee_id" = "e"."id") AND ("es"."is_active" = true) AND ("es"."site_id" = "r"."site_id")))))))));


--
-- Name: loyalty_redemptions loyalty_redemptions_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "loyalty_redemptions_select_own" ON "public"."loyalty_redemptions" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));


--
-- Name: loyalty_redemptions loyalty_redemptions_validate_cashier; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "loyalty_redemptions_validate_cashier" ON "public"."loyalty_redemptions" FOR UPDATE TO "authenticated" USING ((("status" = 'pending'::"text") AND (EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."loyalty_rewards" "r" ON (("r"."id" = "loyalty_redemptions"."reward_id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text", 'cajero'::"text", 'mesero'::"text"])) AND (("e"."site_id" = "r"."site_id") OR (EXISTS ( SELECT 1
           FROM "public"."employee_sites" "es"
          WHERE (("es"."employee_id" = "e"."id") AND ("es"."is_active" = true) AND ("es"."site_id" = "r"."site_id")))))))))) WITH CHECK ((("status" = 'validated'::"text") AND (EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."loyalty_rewards" "r" ON (("r"."id" = "loyalty_redemptions"."reward_id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text", 'cajero'::"text", 'mesero'::"text"])) AND (("e"."site_id" = "r"."site_id") OR (EXISTS ( SELECT 1
           FROM "public"."employee_sites" "es"
          WHERE (("es"."employee_id" = "e"."id") AND ("es"."is_active" = true) AND ("es"."site_id" = "r"."site_id"))))))))));


--
-- Name: loyalty_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."loyalty_transactions" ENABLE ROW LEVEL SECURITY;

--
-- Name: loyalty_transactions loyalty_transactions_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "loyalty_transactions_select_own" ON "public"."loyalty_transactions" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));


--
-- Name: order_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."order_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_items order_items_delete_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "order_items_delete_owner" ON "public"."order_items" FOR DELETE USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: order_items order_items_insert_client; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "order_items_insert_client" ON "public"."order_items" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND ("o"."client_id" = "auth"."uid"())))));


--
-- Name: order_items order_items_insert_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "order_items_insert_staff" ON "public"."order_items" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND "public"."is_employee"() AND "public"."can_access_site"("o"."site_id")))));


--
-- Name: order_items order_items_select_client; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "order_items_select_client" ON "public"."order_items" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND ("o"."client_id" = "auth"."uid"())))));


--
-- Name: order_items order_items_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "order_items_select_staff" ON "public"."order_items" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND "public"."is_employee"() AND "public"."can_access_site"("o"."site_id")))));


--
-- Name: order_items order_items_update_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "order_items_update_staff" ON "public"."order_items" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND "public"."is_employee"() AND "public"."can_access_site"("o"."site_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND "public"."is_employee"() AND "public"."can_access_site"("o"."site_id")))));


--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders orders_delete_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "orders_delete_owner" ON "public"."orders" FOR DELETE USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: orders orders_insert_client; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "orders_insert_client" ON "public"."orders" FOR INSERT WITH CHECK ((("client_id" = "auth"."uid"()) AND ("source" = 'vento_pass'::"text")));


--
-- Name: orders orders_insert_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "orders_insert_staff" ON "public"."orders" FOR INSERT WITH CHECK (("public"."is_employee"() AND "public"."can_access_site"("site_id")));


--
-- Name: orders orders_select_client; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "orders_select_client" ON "public"."orders" FOR SELECT USING (("client_id" = "auth"."uid"()));


--
-- Name: orders orders_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "orders_select_staff" ON "public"."orders" FOR SELECT USING (("public"."is_employee"() AND "public"."can_access_site"("site_id")));


--
-- Name: orders orders_update_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "orders_update_staff" ON "public"."orders" FOR UPDATE USING (("public"."is_employee"() AND "public"."can_access_site"("site_id"))) WITH CHECK (("public"."is_employee"() AND "public"."can_access_site"("site_id")));


--
-- Name: pass_satellites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."pass_satellites" ENABLE ROW LEVEL SECURITY;

--
-- Name: pass_satellites pass_satellites_delete_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "pass_satellites_delete_admin" ON "public"."pass_satellites" FOR DELETE TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: pass_satellites pass_satellites_insert_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "pass_satellites_insert_admin" ON "public"."pass_satellites" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: pass_satellites pass_satellites_select_active; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "pass_satellites_select_active" ON "public"."pass_satellites" FOR SELECT TO "authenticated", "anon" USING (("is_active" = true));


--
-- Name: pass_satellites pass_satellites_select_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "pass_satellites_select_admin" ON "public"."pass_satellites" FOR SELECT TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: pass_satellites pass_satellites_update_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "pass_satellites_update_admin" ON "public"."pass_satellites" FOR UPDATE TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: procurement_agreed_prices; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."procurement_agreed_prices" ENABLE ROW LEVEL SECURITY;

--
-- Name: procurement_reception_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."procurement_reception_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: procurement_reception_items procurement_reception_items_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_reception_items_delete_permission" ON "public"."procurement_reception_items" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."procurement_receptions" "pr"
  WHERE (("pr"."id" = "procurement_reception_items"."reception_id") AND "public"."has_permission"('nexo.inventory.stock'::"text", "pr"."site_id")))));


--
-- Name: procurement_reception_items procurement_reception_items_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_reception_items_insert_permission" ON "public"."procurement_reception_items" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."procurement_receptions" "pr"
  WHERE (("pr"."id" = "procurement_reception_items"."reception_id") AND "public"."has_permission"('nexo.inventory.stock'::"text", "pr"."site_id")))));


--
-- Name: procurement_reception_items procurement_reception_items_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_reception_items_select_permission" ON "public"."procurement_reception_items" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."procurement_receptions" "pr"
  WHERE (("pr"."id" = "procurement_reception_items"."reception_id") AND "public"."has_permission"('nexo.inventory.stock'::"text", "pr"."site_id")))));


--
-- Name: procurement_reception_items procurement_reception_items_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_reception_items_update_permission" ON "public"."procurement_reception_items" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."procurement_receptions" "pr"
  WHERE (("pr"."id" = "procurement_reception_items"."reception_id") AND "public"."has_permission"('nexo.inventory.stock'::"text", "pr"."site_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."procurement_receptions" "pr"
  WHERE (("pr"."id" = "procurement_reception_items"."reception_id") AND "public"."has_permission"('nexo.inventory.stock'::"text", "pr"."site_id")))));


--
-- Name: procurement_receptions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."procurement_receptions" ENABLE ROW LEVEL SECURITY;

--
-- Name: procurement_receptions procurement_receptions_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_receptions_delete_permission" ON "public"."procurement_receptions" FOR DELETE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.stock'::"text", "site_id"));


--
-- Name: procurement_receptions procurement_receptions_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_receptions_insert_permission" ON "public"."procurement_receptions" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('nexo.inventory.stock'::"text", "site_id"));


--
-- Name: procurement_receptions procurement_receptions_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_receptions_select_permission" ON "public"."procurement_receptions" FOR SELECT TO "authenticated" USING ("public"."has_permission"('nexo.inventory.stock'::"text", "site_id"));


--
-- Name: procurement_receptions procurement_receptions_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "procurement_receptions_update_permission" ON "public"."procurement_receptions" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('nexo.inventory.stock'::"text", "site_id")) WITH CHECK ("public"."has_permission"('nexo.inventory.stock'::"text", "site_id"));


--
-- Name: product_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_categories" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_categories product_categories_select_client; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_categories_select_client" ON "public"."product_categories" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM "public"."users" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."is_client" = true)))) AND ("is_active" = true)));


--
-- Name: product_categories product_categories_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_categories_select_staff" ON "public"."product_categories" FOR SELECT USING ("public"."is_employee"());


--
-- Name: product_categories product_categories_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_categories_write_owner" ON "public"."product_categories" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: product_inventory_profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_inventory_profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_inventory_profiles product_inventory_profiles_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_inventory_profiles_select_staff" ON "public"."product_inventory_profiles" FOR SELECT USING ("public"."is_employee"());


--
-- Name: product_inventory_profiles product_inventory_profiles_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_inventory_profiles_write_owner" ON "public"."product_inventory_profiles" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: product_site_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_site_settings" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_site_settings product_site_settings_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_site_settings_select_staff" ON "public"."product_site_settings" FOR SELECT USING ("public"."is_employee"());


--
-- Name: product_site_settings product_site_settings_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_site_settings_write_owner" ON "public"."product_site_settings" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: product_sku_aliases; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_sku_aliases" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_sku_aliases product_sku_aliases_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_sku_aliases_select_staff" ON "public"."product_sku_aliases" FOR SELECT TO "authenticated" USING ("public"."is_employee"());


--
-- Name: product_sku_sequences; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_sku_sequences" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_suppliers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_suppliers" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_suppliers product_suppliers_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_suppliers_select_staff" ON "public"."product_suppliers" FOR SELECT USING ("public"."is_employee"());


--
-- Name: product_suppliers product_suppliers_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "product_suppliers_write_owner" ON "public"."product_suppliers" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: production_batches; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."production_batches" ENABLE ROW LEVEL SECURITY;

--
-- Name: production_batches production_batches_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_batches_select_staff" ON "public"."production_batches" FOR SELECT USING ("public"."is_employee"());


--
-- Name: production_batches production_batches_write_production; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_batches_write_production" ON "public"."production_batches" USING ((("public"."current_employee_role"() = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text", 'barista'::"text", 'cocinero'::"text", 'panadero'::"text", 'repostero'::"text", 'pastelero'::"text"])) AND (("public"."current_employee_role"() = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text"])) OR ("site_id" = "public"."current_employee_site_id"())))) WITH CHECK ((("public"."current_employee_role"() = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text", 'barista'::"text", 'cocinero'::"text", 'panadero'::"text", 'repostero'::"text", 'pastelero'::"text"])) AND (("public"."current_employee_role"() = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text"])) OR ("site_id" = "public"."current_employee_site_id"()))));


--
-- Name: production_request_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."production_request_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: production_request_items production_request_items_insert_site; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_request_items_insert_site" ON "public"."production_request_items" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."production_requests" "r"
  WHERE (("r"."id" = "production_request_items"."request_id") AND "public"."is_employee"() AND ("public"."can_access_site"("r"."from_site_id") OR "public"."can_access_site"("r"."to_site_id"))))));


--
-- Name: production_request_items production_request_items_select_site; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_request_items_select_site" ON "public"."production_request_items" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."production_requests" "r"
  WHERE (("r"."id" = "production_request_items"."request_id") AND "public"."is_employee"() AND ("public"."can_access_site"("r"."from_site_id") OR "public"."can_access_site"("r"."to_site_id"))))));


--
-- Name: production_request_items production_request_items_update_site; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_request_items_update_site" ON "public"."production_request_items" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."production_requests" "r"
  WHERE (("r"."id" = "production_request_items"."request_id") AND "public"."is_employee"() AND ("public"."can_access_site"("r"."from_site_id") OR "public"."can_access_site"("r"."to_site_id")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."production_requests" "r"
  WHERE (("r"."id" = "production_request_items"."request_id") AND "public"."is_employee"() AND ("public"."can_access_site"("r"."from_site_id") OR "public"."can_access_site"("r"."to_site_id"))))));


--
-- Name: production_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."production_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: production_requests production_requests_delete_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_requests_delete_owner" ON "public"."production_requests" FOR DELETE USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: production_requests production_requests_insert_site; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_requests_insert_site" ON "public"."production_requests" FOR INSERT WITH CHECK (("public"."is_employee"() AND ("public"."can_access_site"("from_site_id") OR "public"."can_access_site"("to_site_id"))));


--
-- Name: production_requests production_requests_select_site; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_requests_select_site" ON "public"."production_requests" FOR SELECT USING (("public"."is_employee"() AND ("public"."can_access_site"("from_site_id") OR "public"."can_access_site"("to_site_id"))));


--
-- Name: production_requests production_requests_update_site; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "production_requests_update_site" ON "public"."production_requests" FOR UPDATE USING (("public"."is_employee"() AND ("public"."can_access_site"("from_site_id") OR "public"."can_access_site"("to_site_id")))) WITH CHECK (("public"."is_employee"() AND ("public"."can_access_site"("from_site_id") OR "public"."can_access_site"("to_site_id"))));


--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;

--
-- Name: products products_select_client; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "products_select_client" ON "public"."products" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM "public"."users" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."is_client" = true)))) AND ("is_active" = true) AND ("product_type" = 'sale'::"text")));


--
-- Name: products products_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "products_select_staff" ON "public"."products" FOR SELECT USING ("public"."is_employee"());


--
-- Name: products products_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "products_write_owner" ON "public"."products" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: product_site_settings pss_select_authenticated; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "pss_select_authenticated" ON "public"."product_site_settings" FOR SELECT TO "authenticated" USING (true);


--
-- Name: product_site_settings pss_write_authenticated; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "pss_write_authenticated" ON "public"."product_site_settings" TO "authenticated" USING (true) WITH CHECK (true);


--
-- Name: purchase_orders; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."purchase_orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: recipe_cards; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."recipe_cards" ENABLE ROW LEVEL SECURITY;

--
-- Name: recipe_cards recipe_cards_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "recipe_cards_select_staff" ON "public"."recipe_cards" FOR SELECT USING ("public"."can_access_recipe_scope"("site_id", "area_id"));


--
-- Name: recipe_cards recipe_cards_write_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "recipe_cards_write_manager" ON "public"."recipe_cards" USING ((("public"."is_owner"() OR "public"."is_manager"()) AND "public"."can_access_recipe_scope"("site_id", "area_id"))) WITH CHECK ((("public"."is_owner"() OR "public"."is_manager"()) AND "public"."can_access_recipe_scope"("site_id", "area_id")));


--
-- Name: recipe_steps; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."recipe_steps" ENABLE ROW LEVEL SECURITY;

--
-- Name: recipe_steps recipe_steps_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "recipe_steps_select_staff" ON "public"."recipe_steps" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."recipe_cards" "rc"
  WHERE (("rc"."id" = "recipe_steps"."recipe_card_id") AND "public"."can_access_recipe_scope"("rc"."site_id", "rc"."area_id")))));


--
-- Name: recipe_steps recipe_steps_write_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "recipe_steps_write_manager" ON "public"."recipe_steps" USING (("public"."is_owner"() OR "public"."is_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_manager"()));


--
-- Name: recipes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."recipes" ENABLE ROW LEVEL SECURITY;

--
-- Name: recipes recipes_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "recipes_select_staff" ON "public"."recipes" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."recipe_cards" "rc"
  WHERE (("rc"."product_id" = "recipes"."product_id") AND "public"."can_access_recipe_scope"("rc"."site_id", "rc"."area_id")))));


--
-- Name: recipes recipes_write_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "recipes_write_manager" ON "public"."recipes" USING (("public"."is_owner"() OR "public"."is_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_manager"()));


--
-- Name: restock_request_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."restock_request_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: restock_request_items restock_request_items_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "restock_request_items_insert_permission" ON "public"."restock_request_items" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."restock_requests" "r"
  WHERE (("r"."id" = "restock_request_items"."request_id") AND ("public"."has_permission"('nexo.inventory.remissions.request'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "r"."from_site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.cancel'::"text"))))));


--
-- Name: restock_request_items restock_request_items_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "restock_request_items_select_permission" ON "public"."restock_request_items" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."restock_requests" "r"
  WHERE (("r"."id" = "restock_request_items"."request_id") AND ("public"."has_permission"('nexo.inventory.remissions'::"text", "r"."from_site_id") OR "public"."has_permission"('nexo.inventory.remissions'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "r"."from_site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.all_sites'::"text"))))));


--
-- Name: restock_request_items restock_request_items_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "restock_request_items_update_permission" ON "public"."restock_request_items" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."restock_requests" "r"
  WHERE (("r"."id" = "restock_request_items"."request_id") AND ("public"."has_permission"('nexo.inventory.remissions.request'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "r"."from_site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.cancel'::"text")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."restock_requests" "r"
  WHERE (("r"."id" = "restock_request_items"."request_id") AND ("public"."has_permission"('nexo.inventory.remissions.request'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "r"."from_site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "r"."to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.cancel'::"text"))))));


--
-- Name: restock_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."restock_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: restock_requests restock_requests_delete_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "restock_requests_delete_permission" ON "public"."restock_requests" FOR DELETE TO "authenticated" USING (("public"."has_permission"('nexo.inventory.remissions.cancel'::"text") OR (("created_by" = "auth"."uid"()) AND ("status" = ANY (ARRAY['pending'::"text", 'preparing'::"text"])))));


--
-- Name: restock_requests restock_requests_insert_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "restock_requests_insert_permission" ON "public"."restock_requests" FOR INSERT TO "authenticated" WITH CHECK ((("to_site_id" IS NOT NULL) AND "public"."has_permission"('nexo.inventory.remissions.request'::"text", "to_site_id")));


--
-- Name: restock_requests restock_requests_select_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "restock_requests_select_permission" ON "public"."restock_requests" FOR SELECT TO "authenticated" USING (("public"."has_permission"('nexo.inventory.remissions'::"text", "from_site_id") OR "public"."has_permission"('nexo.inventory.remissions'::"text", "to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "from_site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.all_sites'::"text")));


--
-- Name: restock_requests restock_requests_update_permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "restock_requests_update_permission" ON "public"."restock_requests" FOR UPDATE TO "authenticated" USING (("public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "from_site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.cancel'::"text") OR (("created_by" = "auth"."uid"()) AND ("status" = ANY (ARRAY['pending'::"text", 'preparing'::"text"]))))) WITH CHECK (("public"."has_permission"('nexo.inventory.remissions.prepare'::"text", "from_site_id") OR "public"."has_permission"('nexo.inventory.remissions.receive'::"text", "to_site_id") OR "public"."has_permission"('nexo.inventory.remissions.cancel'::"text") OR (("created_by" = "auth"."uid"()) AND ("status" = ANY (ARRAY['pending'::"text", 'preparing'::"text"])))));


--
-- Name: role_permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: role_permissions role_permissions_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "role_permissions_manage_owner" ON "public"."role_permissions" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: role_permissions role_permissions_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "role_permissions_select_all" ON "public"."role_permissions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: role_site_type_rules; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."role_site_type_rules" ENABLE ROW LEVEL SECURITY;

--
-- Name: role_site_type_rules role_site_type_rules_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "role_site_type_rules_manage_owner" ON "public"."role_site_type_rules" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: role_site_type_rules role_site_type_rules_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "role_site_type_rules_select_all" ON "public"."role_site_type_rules" FOR SELECT TO "authenticated" USING (true);


--
-- Name: roles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;

--
-- Name: roles roles_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "roles_manage_owner" ON "public"."roles" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: roles roles_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "roles_select" ON "public"."roles" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));


--
-- Name: roles roles_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "roles_select_all" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: site_supply_routes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."site_supply_routes" ENABLE ROW LEVEL SECURITY;

--
-- Name: site_supply_routes site_supply_routes_manage_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "site_supply_routes_manage_owner" ON "public"."site_supply_routes" TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: site_supply_routes site_supply_routes_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "site_supply_routes_select_all" ON "public"."site_supply_routes" FOR SELECT TO "authenticated" USING (true);


--
-- Name: sites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."sites" ENABLE ROW LEVEL SECURITY;

--
-- Name: sites sites_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "sites_select" ON "public"."sites" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));


--
-- Name: sites sites_select_owner_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "sites_select_owner_manager" ON "public"."sites" FOR SELECT TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: sites sites_select_public_vento_pass; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "sites_select_public_vento_pass" ON "public"."sites" FOR SELECT TO "authenticated", "anon" USING ((("is_active" = true) AND ("is_public" = true)));


--
-- Name: sites sites_select_staff; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "sites_select_staff" ON "public"."sites" FOR SELECT USING ("public"."can_access_site"("id"));


--
-- Name: sites sites_write_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "sites_write_owner" ON "public"."sites" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: loyalty_redemptions staff_select_all_redemptions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "staff_select_all_redemptions" ON "public"."loyalty_redemptions" FOR SELECT TO "authenticated" USING ("public"."is_active_staff"());


--
-- Name: users staff_select_all_users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "staff_select_all_users" ON "public"."users" FOR SELECT TO "authenticated" USING ("public"."is_active_staff"());


--
-- Name: loyalty_redemptions staff_validate_redemptions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "staff_validate_redemptions" ON "public"."loyalty_redemptions" FOR UPDATE TO "authenticated" USING (("public"."is_active_staff"() AND ("status" = 'pending'::"text"))) WITH CHECK (("public"."is_active_staff"() AND ("status" = 'validated'::"text")));


--
-- Name: suppliers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."suppliers" ENABLE ROW LEVEL SECURITY;

--
-- Name: suppliers suppliers_delete_owner_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "suppliers_delete_owner_manager" ON "public"."suppliers" FOR DELETE TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"() OR "public"."is_manager"()));


--
-- Name: suppliers suppliers_insert_owner_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "suppliers_insert_owner_manager" ON "public"."suppliers" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"() OR "public"."is_manager"()));


--
-- Name: suppliers suppliers_update_owner_manager; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "suppliers_update_owner_manager" ON "public"."suppliers" FOR UPDATE TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"() OR "public"."is_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"() OR "public"."is_manager"()));


--
-- Name: support_messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."support_messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: support_messages support_messages_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "support_messages_insert" ON "public"."support_messages" FOR INSERT WITH CHECK ((("author_id" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."support_tickets" "t"
  WHERE (("t"."id" = "support_messages"."ticket_id") AND (("t"."created_by" = "auth"."uid"()) OR ("t"."assigned_to" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees" "e"
          WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"]))))) OR (EXISTS ( SELECT 1
           FROM ("public"."employees" "e"
             JOIN "public"."employee_sites" "es" ON (("es"."employee_id" = "e"."id")))
          WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = 'gerente'::"text") AND ("es"."site_id" = "t"."site_id") AND ("es"."is_active" = true))))))))));


--
-- Name: support_messages support_messages_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "support_messages_select" ON "public"."support_messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."support_tickets" "t"
  WHERE (("t"."id" = "support_messages"."ticket_id") AND (("t"."created_by" = "auth"."uid"()) OR ("t"."assigned_to" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees" "e"
          WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"]))))) OR (EXISTS ( SELECT 1
           FROM ("public"."employees" "e"
             JOIN "public"."employee_sites" "es" ON (("es"."employee_id" = "e"."id")))
          WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = 'gerente'::"text") AND ("es"."site_id" = "t"."site_id") AND ("es"."is_active" = true)))))))));


--
-- Name: support_tickets; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."support_tickets" ENABLE ROW LEVEL SECURITY;

--
-- Name: support_tickets support_tickets_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "support_tickets_insert" ON "public"."support_tickets" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: support_tickets support_tickets_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "support_tickets_select" ON "public"."support_tickets" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR ("assigned_to" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"]))))) OR (EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."employee_sites" "es" ON (("es"."employee_id" = "e"."id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = 'gerente'::"text") AND ("es"."site_id" = "support_tickets"."site_id") AND ("es"."is_active" = true))))));


--
-- Name: support_tickets support_tickets_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "support_tickets_update" ON "public"."support_tickets" FOR UPDATE USING ((("created_by" = "auth"."uid"()) OR ("assigned_to" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"]))))) OR (EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."employee_sites" "es" ON (("es"."employee_id" = "e"."id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = 'gerente'::"text") AND ("es"."site_id" = "support_tickets"."site_id") AND ("es"."is_active" = true)))))) WITH CHECK ((("created_by" = "auth"."uid"()) OR ("assigned_to" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente_general'::"text"]))))) OR (EXISTS ( SELECT 1
   FROM ("public"."employees" "e"
     JOIN "public"."employee_sites" "es" ON (("es"."employee_id" = "e"."id")))
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."role" = 'gerente'::"text") AND ("es"."site_id" = "support_tickets"."site_id") AND ("es"."is_active" = true))))));


--
-- Name: user_favorites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_favorites" ENABLE ROW LEVEL SECURITY;

--
-- Name: user_feedback; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_feedback" ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_delete_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_delete_admin" ON "public"."users" FOR DELETE TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: users users_insert_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_insert_admin" ON "public"."users" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: users users_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_insert_self" ON "public"."users" FOR INSERT TO "authenticated" WITH CHECK (("id" = "auth"."uid"()));


--
-- Name: users users_select_cashier; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_select_cashier" ON "public"."users" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text", 'cajero'::"text", 'mesero'::"text"]))))));


--
-- Name: users users_select_cashier_for_qr; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_select_cashier_for_qr" ON "public"."users" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "e"
  WHERE (("e"."id" = "auth"."uid"()) AND ("e"."is_active" = true) AND ("e"."role" = ANY (ARRAY['propietario'::"text", 'gerente'::"text", 'gerente_general'::"text", 'cajero'::"text", 'mesero'::"text"]))))));


--
-- Name: users users_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_select_self" ON "public"."users" FOR SELECT TO "authenticated" USING (("id" = "auth"."uid"()));


--
-- Name: users users_update_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_update_admin" ON "public"."users" FOR UPDATE TO "authenticated" USING (("public"."is_owner"() OR "public"."is_global_manager"())) WITH CHECK (("public"."is_owner"() OR "public"."is_global_manager"()));


--
-- Name: users users_update_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users_update_self" ON "public"."users" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));


--
-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


--
-- Name: FUNCTION "_set_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."_set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."_set_updated_at"() TO "service_role";


--
-- Name: FUNCTION "_vento_norm"("input" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_vento_norm"("input" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_vento_norm"("input" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_vento_norm"("input" "text") TO "service_role";


--
-- Name: FUNCTION "_vento_slugify"("input" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_vento_slugify"("input" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_vento_slugify"("input" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_vento_slugify"("input" "text") TO "service_role";


--
-- Name: FUNCTION "_vento_uuid_from_text"("input" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_vento_uuid_from_text"("input" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_vento_uuid_from_text"("input" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_vento_uuid_from_text"("input" "text") TO "service_role";


--
-- Name: FUNCTION "anonymize_user_personal_data"("p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION "public"."anonymize_user_personal_data"("p_user_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."anonymize_user_personal_data"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."anonymize_user_personal_data"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."anonymize_user_personal_data"("p_user_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "apply_restock_receipt"("p_request_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."apply_restock_receipt"("p_request_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."apply_restock_receipt"("p_request_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_restock_receipt"("p_request_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "apply_restock_shipment"("p_request_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."apply_restock_shipment"("p_request_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."apply_restock_shipment"("p_request_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_restock_shipment"("p_request_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "award_loyalty_points_external"("p_user_id" "uuid", "p_site_id" "uuid", "p_amount_cop" numeric, "p_external_ref" "text", "p_description" "text", "p_metadata" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."award_loyalty_points_external"("p_user_id" "uuid", "p_site_id" "uuid", "p_amount_cop" numeric, "p_external_ref" "text", "p_description" "text", "p_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."award_loyalty_points_external"("p_user_id" "uuid", "p_site_id" "uuid", "p_amount_cop" numeric, "p_external_ref" "text", "p_description" "text", "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."award_loyalty_points_external"("p_user_id" "uuid", "p_site_id" "uuid", "p_amount_cop" numeric, "p_external_ref" "text", "p_description" "text", "p_metadata" "jsonb") TO "service_role";


--
-- Name: FUNCTION "can_access_area"("p_area_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."can_access_area"("p_area_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_area"("p_area_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_area"("p_area_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "can_access_recipe_scope"("p_site_id" "uuid", "p_area_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."can_access_recipe_scope"("p_site_id" "uuid", "p_area_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_recipe_scope"("p_site_id" "uuid", "p_area_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_recipe_scope"("p_site_id" "uuid", "p_area_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "can_access_site"("p_site_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."can_access_site"("p_site_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_site"("p_site_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_site"("p_site_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "check_nexo_permissions"("p_employee_id" "uuid", "p_site_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_nexo_permissions"("p_employee_id" "uuid", "p_site_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_nexo_permissions"("p_employee_id" "uuid", "p_site_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_nexo_permissions"("p_employee_id" "uuid", "p_site_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "close_open_attendance_day_end"("p_timezone" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."close_open_attendance_day_end"("p_timezone" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."close_open_attendance_day_end"("p_timezone" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."close_open_attendance_day_end"("p_timezone" "text") TO "service_role";


--
-- Name: FUNCTION "current_employee_area_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."current_employee_area_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_employee_area_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_employee_area_id"() TO "service_role";


--
-- Name: FUNCTION "current_employee_primary_site_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."current_employee_primary_site_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_employee_primary_site_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_employee_primary_site_id"() TO "service_role";


--
-- Name: FUNCTION "current_employee_role"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."current_employee_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_employee_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_employee_role"() TO "service_role";


--
-- Name: FUNCTION "current_employee_selected_area_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."current_employee_selected_area_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_employee_selected_area_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_employee_selected_area_id"() TO "service_role";


--
-- Name: FUNCTION "current_employee_selected_site_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."current_employee_selected_site_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_employee_selected_site_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_employee_selected_site_id"() TO "service_role";


--
-- Name: FUNCTION "current_employee_site_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."current_employee_site_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_employee_site_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_employee_site_id"() TO "service_role";


--
-- Name: FUNCTION "device_info_has_blocking_warnings"("di" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."device_info_has_blocking_warnings"("di" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."device_info_has_blocking_warnings"("di" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."device_info_has_blocking_warnings"("di" "jsonb") TO "service_role";


--
-- Name: TABLE "attendance_breaks"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."attendance_breaks" TO "anon";
GRANT ALL ON TABLE "public"."attendance_breaks" TO "authenticated";
GRANT ALL ON TABLE "public"."attendance_breaks" TO "service_role";


--
-- Name: FUNCTION "end_attendance_break"("p_source" "text", "p_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."end_attendance_break"("p_source" "text", "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."end_attendance_break"("p_source" "text", "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."end_attendance_break"("p_source" "text", "p_notes" "text") TO "service_role";


--
-- Name: FUNCTION "enforce_attendance_geofence"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."enforce_attendance_geofence"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_attendance_geofence"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_attendance_geofence"() TO "service_role";


--
-- Name: FUNCTION "enforce_attendance_sequence"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."enforce_attendance_sequence"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_attendance_sequence"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_attendance_sequence"() TO "service_role";


--
-- Name: FUNCTION "enforce_employee_role_site"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."enforce_employee_role_site"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_employee_role_site"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_employee_role_site"() TO "service_role";


--
-- Name: FUNCTION "enforce_inventory_location_parent_same_site"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."enforce_inventory_location_parent_same_site"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_inventory_location_parent_same_site"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_inventory_location_parent_same_site"() TO "service_role";


--
-- Name: FUNCTION "generate_inventory_sku"("p_product_type" "text", "p_inventory_kind" "text", "p_name" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."generate_inventory_sku"("p_product_type" "text", "p_inventory_kind" "text", "p_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_inventory_sku"("p_product_type" "text", "p_inventory_kind" "text", "p_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_inventory_sku"("p_product_type" "text", "p_inventory_kind" "text", "p_name" "text") TO "service_role";


--
-- Name: FUNCTION "generate_location_code"("p_site_code" "text", "p_zone" "text", "p_aisle" "text", "p_level" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."generate_location_code"("p_site_code" "text", "p_zone" "text", "p_aisle" "text", "p_level" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_location_code"("p_site_code" "text", "p_zone" "text", "p_aisle" "text", "p_level" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_location_code"("p_site_code" "text", "p_zone" "text", "p_aisle" "text", "p_level" "text") TO "service_role";


--
-- Name: FUNCTION "generate_lpn_code"("p_site_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."generate_lpn_code"("p_site_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_lpn_code"("p_site_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_lpn_code"("p_site_code" "text") TO "service_role";


--
-- Name: FUNCTION "generate_product_sku"("p_product_type" "text", "p_site_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."generate_product_sku"("p_product_type" "text", "p_site_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_product_sku"("p_product_type" "text", "p_site_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_product_sku"("p_product_type" "text", "p_site_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "grant_loyalty_points"("p_user_id" "uuid", "p_points" integer, "p_description" "text", "p_metadata" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."grant_loyalty_points"("p_user_id" "uuid", "p_points" integer, "p_description" "text", "p_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."grant_loyalty_points"("p_user_id" "uuid", "p_points" integer, "p_description" "text", "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."grant_loyalty_points"("p_user_id" "uuid", "p_points" integer, "p_description" "text", "p_metadata" "jsonb") TO "service_role";


--
-- Name: FUNCTION "handle_new_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";


--
-- Name: FUNCTION "has_permission"("p_permission_code" "text", "p_site_id" "uuid", "p_area_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_site_id" "uuid", "p_area_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_site_id" "uuid", "p_area_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_site_id" "uuid", "p_area_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "haversine_m"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."haversine_m"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."haversine_m"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."haversine_m"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) TO "service_role";


--
-- Name: FUNCTION "is_active_staff"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_active_staff"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_active_staff"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_active_staff"() TO "service_role";


--
-- Name: FUNCTION "is_employee"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_employee"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_employee"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_employee"() TO "service_role";


--
-- Name: FUNCTION "is_global_manager"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_global_manager"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_global_manager"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_global_manager"() TO "service_role";


--
-- Name: FUNCTION "is_manager"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_manager"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager"() TO "service_role";


--
-- Name: FUNCTION "is_manager_or_owner"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_manager_or_owner"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_or_owner"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_or_owner"() TO "service_role";


--
-- Name: FUNCTION "is_owner"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_owner"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_owner"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_owner"() TO "service_role";


--
-- Name: FUNCTION "permission_scope_matches"("p_scope_type" "public"."permission_scope_type", "p_context_site_id" "uuid", "p_context_area_id" "uuid", "p_scope_site_id" "uuid", "p_scope_area_id" "uuid", "p_scope_site_type" "public"."site_type", "p_scope_area_kind" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."permission_scope_matches"("p_scope_type" "public"."permission_scope_type", "p_context_site_id" "uuid", "p_context_area_id" "uuid", "p_scope_site_id" "uuid", "p_scope_area_id" "uuid", "p_scope_site_type" "public"."site_type", "p_scope_area_kind" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."permission_scope_matches"("p_scope_type" "public"."permission_scope_type", "p_context_site_id" "uuid", "p_context_area_id" "uuid", "p_scope_site_id" "uuid", "p_scope_area_id" "uuid", "p_scope_site_type" "public"."site_type", "p_scope_area_kind" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."permission_scope_matches"("p_scope_type" "public"."permission_scope_type", "p_context_site_id" "uuid", "p_context_area_id" "uuid", "p_scope_site_id" "uuid", "p_scope_area_id" "uuid", "p_scope_site_type" "public"."site_type", "p_scope_area_kind" "text") TO "service_role";


--
-- Name: FUNCTION "process_loyalty_earning"("p_order_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."process_loyalty_earning"("p_order_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."process_loyalty_earning"("p_order_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."process_loyalty_earning"("p_order_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "process_order_payment"("p_order_id" "uuid", "p_site_id" "uuid", "p_payment_method" "text", "p_payment_reference" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."process_order_payment"("p_order_id" "uuid", "p_site_id" "uuid", "p_payment_method" "text", "p_payment_reference" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."process_order_payment"("p_order_id" "uuid", "p_site_id" "uuid", "p_payment_method" "text", "p_payment_reference" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."process_order_payment"("p_order_id" "uuid", "p_site_id" "uuid", "p_payment_method" "text", "p_payment_reference" "text") TO "service_role";


--
-- Name: FUNCTION "receive_purchase_order"("p_purchase_order_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."receive_purchase_order"("p_purchase_order_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."receive_purchase_order"("p_purchase_order_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."receive_purchase_order"("p_purchase_order_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "register_shift_departure_event"("p_site_id" "uuid", "p_distance_meters" integer, "p_accuracy_meters" integer, "p_source" "text", "p_notes" "text", "p_occurred_at" timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."register_shift_departure_event"("p_site_id" "uuid", "p_distance_meters" integer, "p_accuracy_meters" integer, "p_source" "text", "p_notes" "text", "p_occurred_at" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."register_shift_departure_event"("p_site_id" "uuid", "p_distance_meters" integer, "p_accuracy_meters" integer, "p_source" "text", "p_notes" "text", "p_occurred_at" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."register_shift_departure_event"("p_site_id" "uuid", "p_distance_meters" integer, "p_accuracy_meters" integer, "p_source" "text", "p_notes" "text", "p_occurred_at" timestamp with time zone) TO "service_role";


--
-- Name: FUNCTION "resolve_product_sku_brand_code"("p_site_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."resolve_product_sku_brand_code"("p_site_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."resolve_product_sku_brand_code"("p_site_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."resolve_product_sku_brand_code"("p_site_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "resolve_product_sku_type_code"("p_product_type" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."resolve_product_sku_type_code"("p_product_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."resolve_product_sku_type_code"("p_product_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."resolve_product_sku_type_code"("p_product_type" "text") TO "service_role";


--
-- Name: FUNCTION "run_nexo_inventory_reset"("p_confirm" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."run_nexo_inventory_reset"("p_confirm" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."run_nexo_inventory_reset"("p_confirm" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."run_nexo_inventory_reset"("p_confirm" "text") TO "service_role";


--
-- Name: FUNCTION "set_product_sku"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."set_product_sku"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_product_sku"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_product_sku"() TO "service_role";


--
-- Name: FUNCTION "set_production_batch_code"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."set_production_batch_code"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_production_batch_code"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_production_batch_code"() TO "service_role";


--
-- Name: FUNCTION "set_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";


--
-- Name: FUNCTION "start_attendance_break"("p_site_id" "uuid", "p_source" "text", "p_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."start_attendance_break"("p_site_id" "uuid", "p_source" "text", "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."start_attendance_break"("p_site_id" "uuid", "p_source" "text", "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."start_attendance_break"("p_site_id" "uuid", "p_source" "text", "p_notes" "text") TO "service_role";


--
-- Name: FUNCTION "tg_set_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg_set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg_set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg_set_updated_at"() TO "service_role";


--
-- Name: FUNCTION "update_employee_shifts_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_employee_shifts_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_employee_shifts_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_employee_shifts_updated_at"() TO "service_role";


--
-- Name: FUNCTION "update_loyalty_balance"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_loyalty_balance"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_loyalty_balance"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_loyalty_balance"() TO "service_role";


--
-- Name: FUNCTION "update_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "service_role";


--
-- Name: FUNCTION "upsert_inventory_stock_by_location"("p_location_id" "uuid", "p_product_id" "uuid", "p_delta" numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."upsert_inventory_stock_by_location"("p_location_id" "uuid", "p_product_id" "uuid", "p_delta" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_inventory_stock_by_location"("p_location_id" "uuid", "p_product_id" "uuid", "p_delta" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_inventory_stock_by_location"("p_location_id" "uuid", "p_product_id" "uuid", "p_delta" numeric) TO "service_role";


--
-- Name: FUNCTION "util_column_usage"("p_table" "regclass"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."util_column_usage"("p_table" "regclass") TO "anon";
GRANT ALL ON FUNCTION "public"."util_column_usage"("p_table" "regclass") TO "authenticated";
GRANT ALL ON FUNCTION "public"."util_column_usage"("p_table" "regclass") TO "service_role";


--
-- Name: TABLE "account_deletion_requests"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."account_deletion_requests" TO "anon";
GRANT ALL ON TABLE "public"."account_deletion_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."account_deletion_requests" TO "service_role";


--
-- Name: TABLE "announcements"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."announcements" TO "anon";
GRANT ALL ON TABLE "public"."announcements" TO "authenticated";
GRANT ALL ON TABLE "public"."announcements" TO "service_role";


--
-- Name: TABLE "app_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."app_permissions" TO "anon";
GRANT ALL ON TABLE "public"."app_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."app_permissions" TO "service_role";


--
-- Name: TABLE "app_update_policies"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."app_update_policies" TO "anon";
GRANT ALL ON TABLE "public"."app_update_policies" TO "authenticated";
GRANT ALL ON TABLE "public"."app_update_policies" TO "service_role";


--
-- Name: TABLE "apps"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."apps" TO "anon";
GRANT ALL ON TABLE "public"."apps" TO "authenticated";
GRANT ALL ON TABLE "public"."apps" TO "service_role";


--
-- Name: TABLE "area_kinds"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."area_kinds" TO "anon";
GRANT ALL ON TABLE "public"."area_kinds" TO "authenticated";
GRANT ALL ON TABLE "public"."area_kinds" TO "service_role";


--
-- Name: TABLE "areas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."areas" TO "anon";
GRANT ALL ON TABLE "public"."areas" TO "authenticated";
GRANT ALL ON TABLE "public"."areas" TO "service_role";


--
-- Name: TABLE "asistencia_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."asistencia_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."asistencia_logs" TO "service_role";


--
-- Name: TABLE "attendance_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."attendance_logs" TO "anon";
GRANT ALL ON TABLE "public"."attendance_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."attendance_logs" TO "service_role";


--
-- Name: TABLE "attendance_shift_events"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."attendance_shift_events" TO "anon";
GRANT ALL ON TABLE "public"."attendance_shift_events" TO "authenticated";
GRANT ALL ON TABLE "public"."attendance_shift_events" TO "service_role";


--
-- Name: TABLE "cost_centers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."cost_centers" TO "anon";
GRANT ALL ON TABLE "public"."cost_centers" TO "authenticated";
GRANT ALL ON TABLE "public"."cost_centers" TO "service_role";


--
-- Name: TABLE "document_types"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."document_types" TO "anon";
GRANT ALL ON TABLE "public"."document_types" TO "authenticated";
GRANT ALL ON TABLE "public"."document_types" TO "service_role";


--
-- Name: TABLE "documents"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."documents" TO "anon";
GRANT ALL ON TABLE "public"."documents" TO "authenticated";
GRANT ALL ON TABLE "public"."documents" TO "service_role";


--
-- Name: TABLE "employee_areas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_areas" TO "anon";
GRANT ALL ON TABLE "public"."employee_areas" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_areas" TO "service_role";


--
-- Name: TABLE "employee_attendance_status"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_attendance_status" TO "anon";
GRANT ALL ON TABLE "public"."employee_attendance_status" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_attendance_status" TO "service_role";


--
-- Name: TABLE "employee_devices"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_devices" TO "anon";
GRANT ALL ON TABLE "public"."employee_devices" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_devices" TO "service_role";


--
-- Name: TABLE "employee_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_permissions" TO "anon";
GRANT ALL ON TABLE "public"."employee_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_permissions" TO "service_role";


--
-- Name: TABLE "employee_push_tokens"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_push_tokens" TO "anon";
GRANT ALL ON TABLE "public"."employee_push_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_push_tokens" TO "service_role";


--
-- Name: TABLE "employee_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_settings" TO "anon";
GRANT ALL ON TABLE "public"."employee_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_settings" TO "service_role";


--
-- Name: TABLE "employee_shifts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_shifts" TO "anon";
GRANT ALL ON TABLE "public"."employee_shifts" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_shifts" TO "service_role";


--
-- Name: TABLE "employee_sites"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employee_sites" TO "anon";
GRANT ALL ON TABLE "public"."employee_sites" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_sites" TO "service_role";


--
-- Name: TABLE "employees"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."employees" TO "anon";
GRANT ALL ON TABLE "public"."employees" TO "authenticated";
GRANT ALL ON TABLE "public"."employees" TO "service_role";


--
-- Name: TABLE "inventory_cost_policies"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_cost_policies" TO "anon";
GRANT ALL ON TABLE "public"."inventory_cost_policies" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_cost_policies" TO "service_role";


--
-- Name: TABLE "inventory_count_lines"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_count_lines" TO "anon";
GRANT ALL ON TABLE "public"."inventory_count_lines" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_count_lines" TO "service_role";


--
-- Name: TABLE "inventory_count_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_count_sessions" TO "anon";
GRANT ALL ON TABLE "public"."inventory_count_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_count_sessions" TO "service_role";


--
-- Name: TABLE "inventory_entries"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_entries" TO "anon";
GRANT ALL ON TABLE "public"."inventory_entries" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_entries" TO "service_role";


--
-- Name: TABLE "inventory_entry_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_entry_items" TO "anon";
GRANT ALL ON TABLE "public"."inventory_entry_items" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_entry_items" TO "service_role";


--
-- Name: TABLE "inventory_locations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_locations" TO "anon";
GRANT ALL ON TABLE "public"."inventory_locations" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_locations" TO "service_role";


--
-- Name: TABLE "inventory_lpn_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_lpn_items" TO "anon";
GRANT ALL ON TABLE "public"."inventory_lpn_items" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_lpn_items" TO "service_role";


--
-- Name: TABLE "inventory_lpns"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_lpns" TO "anon";
GRANT ALL ON TABLE "public"."inventory_lpns" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_lpns" TO "service_role";


--
-- Name: TABLE "inventory_movement_types"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_movement_types" TO "anon";
GRANT ALL ON TABLE "public"."inventory_movement_types" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_movement_types" TO "service_role";


--
-- Name: TABLE "inventory_movements"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_movements" TO "anon";
GRANT ALL ON TABLE "public"."inventory_movements" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_movements" TO "service_role";


--
-- Name: SEQUENCE "inventory_sku_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."inventory_sku_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."inventory_sku_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."inventory_sku_seq" TO "service_role";


--
-- Name: TABLE "inventory_stock_by_location"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_stock_by_location" TO "anon";
GRANT ALL ON TABLE "public"."inventory_stock_by_location" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_stock_by_location" TO "service_role";


--
-- Name: TABLE "inventory_stock_by_site"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_stock_by_site" TO "anon";
GRANT ALL ON TABLE "public"."inventory_stock_by_site" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_stock_by_site" TO "service_role";


--
-- Name: TABLE "inventory_transfer_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_transfer_items" TO "anon";
GRANT ALL ON TABLE "public"."inventory_transfer_items" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_transfer_items" TO "service_role";


--
-- Name: TABLE "inventory_transfers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_transfers" TO "anon";
GRANT ALL ON TABLE "public"."inventory_transfers" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_transfers" TO "service_role";


--
-- Name: TABLE "inventory_unit_aliases"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_unit_aliases" TO "anon";
GRANT ALL ON TABLE "public"."inventory_unit_aliases" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_unit_aliases" TO "service_role";


--
-- Name: TABLE "inventory_units"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."inventory_units" TO "anon";
GRANT ALL ON TABLE "public"."inventory_units" TO "authenticated";
GRANT ALL ON TABLE "public"."inventory_units" TO "service_role";


--
-- Name: TABLE "loyalty_external_sales"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."loyalty_external_sales" TO "anon";
GRANT ALL ON TABLE "public"."loyalty_external_sales" TO "authenticated";
GRANT ALL ON TABLE "public"."loyalty_external_sales" TO "service_role";


--
-- Name: TABLE "loyalty_redemptions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."loyalty_redemptions" TO "anon";
GRANT ALL ON TABLE "public"."loyalty_redemptions" TO "authenticated";
GRANT ALL ON TABLE "public"."loyalty_redemptions" TO "service_role";


--
-- Name: TABLE "loyalty_rewards"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,MAINTAIN ON TABLE "public"."loyalty_rewards" TO "anon";
GRANT ALL ON TABLE "public"."loyalty_rewards" TO "authenticated";
GRANT ALL ON TABLE "public"."loyalty_rewards" TO "service_role";


--
-- Name: TABLE "loyalty_transactions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."loyalty_transactions" TO "anon";
GRANT ALL ON TABLE "public"."loyalty_transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."loyalty_transactions" TO "service_role";


--
-- Name: SEQUENCE "lpn_sequence"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."lpn_sequence" TO "anon";
GRANT ALL ON SEQUENCE "public"."lpn_sequence" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."lpn_sequence" TO "service_role";


--
-- Name: TABLE "order_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."order_items" TO "anon";
GRANT ALL ON TABLE "public"."order_items" TO "authenticated";
GRANT ALL ON TABLE "public"."order_items" TO "service_role";


--
-- Name: TABLE "orders"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."orders" TO "anon";
GRANT ALL ON TABLE "public"."orders" TO "authenticated";
GRANT ALL ON TABLE "public"."orders" TO "service_role";


--
-- Name: TABLE "pass_satellites"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pass_satellites" TO "anon";
GRANT ALL ON TABLE "public"."pass_satellites" TO "authenticated";
GRANT ALL ON TABLE "public"."pass_satellites" TO "service_role";


--
-- Name: TABLE "pos_cash_movements"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_cash_movements" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_cash_movements" TO "service_role";


--
-- Name: TABLE "pos_cash_shifts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_cash_shifts" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_cash_shifts" TO "service_role";


--
-- Name: TABLE "pos_modifier_options"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_modifier_options" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_modifier_options" TO "service_role";


--
-- Name: TABLE "pos_modifiers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_modifiers" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_modifiers" TO "service_role";


--
-- Name: TABLE "pos_order_item_modifiers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_order_item_modifiers" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_order_item_modifiers" TO "service_role";


--
-- Name: TABLE "pos_payments"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_payments" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_payments" TO "service_role";


--
-- Name: TABLE "pos_product_modifiers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_product_modifiers" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_product_modifiers" TO "service_role";


--
-- Name: TABLE "pos_session_orders"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_session_orders" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_session_orders" TO "service_role";


--
-- Name: TABLE "pos_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_sessions" TO "service_role";


--
-- Name: TABLE "pos_tables"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_tables" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_tables" TO "service_role";


--
-- Name: TABLE "pos_zones"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pos_zones" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_zones" TO "service_role";


--
-- Name: TABLE "procurement_agreed_prices"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."procurement_agreed_prices" TO "anon";
GRANT ALL ON TABLE "public"."procurement_agreed_prices" TO "authenticated";
GRANT ALL ON TABLE "public"."procurement_agreed_prices" TO "service_role";


--
-- Name: TABLE "procurement_reception_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."procurement_reception_items" TO "anon";
GRANT ALL ON TABLE "public"."procurement_reception_items" TO "authenticated";
GRANT ALL ON TABLE "public"."procurement_reception_items" TO "service_role";


--
-- Name: TABLE "procurement_receptions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."procurement_receptions" TO "anon";
GRANT ALL ON TABLE "public"."procurement_receptions" TO "authenticated";
GRANT ALL ON TABLE "public"."procurement_receptions" TO "service_role";


--
-- Name: TABLE "product_categories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_categories" TO "anon";
GRANT ALL ON TABLE "public"."product_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."product_categories" TO "service_role";


--
-- Name: TABLE "product_cost_events"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_cost_events" TO "anon";
GRANT ALL ON TABLE "public"."product_cost_events" TO "authenticated";
GRANT ALL ON TABLE "public"."product_cost_events" TO "service_role";


--
-- Name: TABLE "product_inventory_profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_inventory_profiles" TO "anon";
GRANT ALL ON TABLE "public"."product_inventory_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."product_inventory_profiles" TO "service_role";


--
-- Name: TABLE "product_site_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_site_settings" TO "anon";
GRANT ALL ON TABLE "public"."product_site_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."product_site_settings" TO "service_role";


--
-- Name: TABLE "product_sku_aliases"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_sku_aliases" TO "anon";
GRANT ALL ON TABLE "public"."product_sku_aliases" TO "authenticated";
GRANT ALL ON TABLE "public"."product_sku_aliases" TO "service_role";


--
-- Name: TABLE "product_sku_sequences"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_sku_sequences" TO "anon";
GRANT ALL ON TABLE "public"."product_sku_sequences" TO "authenticated";
GRANT ALL ON TABLE "public"."product_sku_sequences" TO "service_role";


--
-- Name: TABLE "product_suppliers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_suppliers" TO "anon";
GRANT ALL ON TABLE "public"."product_suppliers" TO "authenticated";
GRANT ALL ON TABLE "public"."product_suppliers" TO "service_role";


--
-- Name: TABLE "product_uom_profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_uom_profiles" TO "anon";
GRANT ALL ON TABLE "public"."product_uom_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."product_uom_profiles" TO "service_role";


--
-- Name: TABLE "production_batch_consumptions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."production_batch_consumptions" TO "anon";
GRANT ALL ON TABLE "public"."production_batch_consumptions" TO "authenticated";
GRANT ALL ON TABLE "public"."production_batch_consumptions" TO "service_role";


--
-- Name: TABLE "production_batches"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."production_batches" TO "anon";
GRANT ALL ON TABLE "public"."production_batches" TO "authenticated";
GRANT ALL ON TABLE "public"."production_batches" TO "service_role";


--
-- Name: TABLE "production_request_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."production_request_items" TO "anon";
GRANT ALL ON TABLE "public"."production_request_items" TO "authenticated";
GRANT ALL ON TABLE "public"."production_request_items" TO "service_role";


--
-- Name: TABLE "production_requests"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."production_requests" TO "anon";
GRANT ALL ON TABLE "public"."production_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."production_requests" TO "service_role";


--
-- Name: TABLE "products"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";


--
-- Name: TABLE "purchase_order_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."purchase_order_items" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_order_items" TO "service_role";


--
-- Name: TABLE "purchase_orders"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."purchase_orders" TO "anon";
GRANT ALL ON TABLE "public"."purchase_orders" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_orders" TO "service_role";


--
-- Name: TABLE "recipe_cards"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."recipe_cards" TO "anon";
GRANT ALL ON TABLE "public"."recipe_cards" TO "authenticated";
GRANT ALL ON TABLE "public"."recipe_cards" TO "service_role";


--
-- Name: TABLE "recipe_steps"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."recipe_steps" TO "anon";
GRANT ALL ON TABLE "public"."recipe_steps" TO "authenticated";
GRANT ALL ON TABLE "public"."recipe_steps" TO "service_role";


--
-- Name: TABLE "recipes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."recipes" TO "anon";
GRANT ALL ON TABLE "public"."recipes" TO "authenticated";
GRANT ALL ON TABLE "public"."recipes" TO "service_role";


--
-- Name: TABLE "restock_request_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."restock_request_items" TO "anon";
GRANT ALL ON TABLE "public"."restock_request_items" TO "authenticated";
GRANT ALL ON TABLE "public"."restock_request_items" TO "service_role";


--
-- Name: TABLE "restock_requests"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."restock_requests" TO "anon";
GRANT ALL ON TABLE "public"."restock_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."restock_requests" TO "service_role";


--
-- Name: TABLE "role_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";


--
-- Name: TABLE "role_site_type_rules"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."role_site_type_rules" TO "anon";
GRANT ALL ON TABLE "public"."role_site_type_rules" TO "authenticated";
GRANT ALL ON TABLE "public"."role_site_type_rules" TO "service_role";


--
-- Name: TABLE "roles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";


--
-- Name: TABLE "sites"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,MAINTAIN ON TABLE "public"."sites" TO "anon";
GRANT ALL ON TABLE "public"."sites" TO "authenticated";
GRANT ALL ON TABLE "public"."sites" TO "service_role";


--
-- Name: TABLE "shift_calendar_view"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."shift_calendar_view" TO "anon";
GRANT ALL ON TABLE "public"."shift_calendar_view" TO "authenticated";
GRANT ALL ON TABLE "public"."shift_calendar_view" TO "service_role";


--
-- Name: TABLE "site_production_pick_order"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."site_production_pick_order" TO "anon";
GRANT ALL ON TABLE "public"."site_production_pick_order" TO "authenticated";
GRANT ALL ON TABLE "public"."site_production_pick_order" TO "service_role";


--
-- Name: TABLE "site_supply_routes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."site_supply_routes" TO "anon";
GRANT ALL ON TABLE "public"."site_supply_routes" TO "authenticated";
GRANT ALL ON TABLE "public"."site_supply_routes" TO "service_role";


--
-- Name: TABLE "staff_invitations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."staff_invitations" TO "authenticated";
GRANT ALL ON TABLE "public"."staff_invitations" TO "service_role";


--
-- Name: TABLE "staging_insumos_import"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."staging_insumos_import" TO "authenticated";
GRANT ALL ON TABLE "public"."staging_insumos_import" TO "service_role";


--
-- Name: TABLE "suppliers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."suppliers" TO "anon";
GRANT ALL ON TABLE "public"."suppliers" TO "authenticated";
GRANT ALL ON TABLE "public"."suppliers" TO "service_role";


--
-- Name: TABLE "support_messages"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."support_messages" TO "anon";
GRANT ALL ON TABLE "public"."support_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."support_messages" TO "service_role";


--
-- Name: TABLE "support_tickets"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."support_tickets" TO "anon";
GRANT ALL ON TABLE "public"."support_tickets" TO "authenticated";
GRANT ALL ON TABLE "public"."support_tickets" TO "service_role";


--
-- Name: TABLE "user_favorites"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_favorites" TO "anon";
GRANT ALL ON TABLE "public"."user_favorites" TO "authenticated";
GRANT ALL ON TABLE "public"."user_favorites" TO "service_role";


--
-- Name: TABLE "user_feedback"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_feedback" TO "anon";
GRANT ALL ON TABLE "public"."user_feedback" TO "authenticated";
GRANT ALL ON TABLE "public"."user_feedback" TO "service_role";


--
-- Name: TABLE "users"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";


--
-- Name: TABLE "v_inventory_catalog"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."v_inventory_catalog" TO "anon";
GRANT ALL ON TABLE "public"."v_inventory_catalog" TO "authenticated";
GRANT ALL ON TABLE "public"."v_inventory_catalog" TO "service_role";


--
-- Name: TABLE "v_inventory_stock_by_location"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."v_inventory_stock_by_location" TO "anon";
GRANT ALL ON TABLE "public"."v_inventory_stock_by_location" TO "authenticated";
GRANT ALL ON TABLE "public"."v_inventory_stock_by_location" TO "service_role";


--
-- Name: TABLE "v_procurement_price_book"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."v_procurement_price_book" TO "anon";
GRANT ALL ON TABLE "public"."v_procurement_price_book" TO "authenticated";
GRANT ALL ON TABLE "public"."v_procurement_price_book" TO "service_role";


--
-- Name: TABLE "wallet_devices"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."wallet_devices" TO "anon";
GRANT ALL ON TABLE "public"."wallet_devices" TO "authenticated";
GRANT ALL ON TABLE "public"."wallet_devices" TO "service_role";


--
-- Name: TABLE "wallet_passes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."wallet_passes" TO "anon";
GRANT ALL ON TABLE "public"."wallet_passes" TO "authenticated";
GRANT ALL ON TABLE "public"."wallet_passes" TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";


--
-- PostgreSQL database dump complete
--

-- \unrestrict 50Spi4jUlYKYoB1XLKjd40ksLLPlMnVvvEdqQF7e9Dvcs7syahxwc1Povbe5zha

