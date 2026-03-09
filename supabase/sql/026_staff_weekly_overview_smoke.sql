-- Vento Vital - APP-35 staff weekly overview smoke
-- Run after:
-- 1) 20260309201500_vital_football_academy_vertical_v1.sql applied

select set_config('request.jwt.claim.sub', '194649ee-3f1c-42ea-a44a-2abd87053c46', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

-- 0) Ensure one squad owned by current user and membership
with upsert_squad as (
  insert into vital.squads (owner_user_id, name, is_private)
  values (auth.uid(), 'Academia Vento Demo', true)
  on conflict (owner_user_id, name) do update set is_private = excluded.is_private
  returning id
)
insert into vital.squad_memberships (squad_id, user_id, role, active)
select id, auth.uid(), 'owner', true
from upsert_squad
on conflict (squad_id, user_id) do update
set role = excluded.role,
    active = excluded.active;

-- 1) Assign current user as head coach staff
insert into vital.academy_staff_assignments (squad_id, user_id, staff_role, active)
select s.id, auth.uid(), 'head_coach', true
from vital.squads s
where s.owner_user_id = auth.uid()
  and s.name = 'Academia Vento Demo'
on conflict (squad_id, user_id, staff_role) do update
set active = excluded.active,
    updated_at = now();

-- 2) Weekly staff overview
select *
from vital.staff_weekly_squad_overview(
  (
    select s.id
    from vital.squads s
    where s.owner_user_id = auth.uid()
      and s.name = 'Academia Vento Demo'
    limit 1
  ),
  current_date - ((extract(isodow from current_date)::int) - 1)
)
order by adherence_pct desc, training_load desc;
