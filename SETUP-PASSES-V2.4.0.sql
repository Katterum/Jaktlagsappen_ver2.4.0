-- Katterums jaktlag v2.4.0 - passregister
-- Kor hela skriptet i Supabase SQL Editor innan appfilerna publiceras.

create table if not exists public.passes (
  id text primary key,
  team_id text not null,
  name text not null,
  area text,
  latitude double precision,
  longitude double precision,
  active boolean not null default true,
  marker_type text not null default 'pass'
);

alter table public.passes enable row level security;

drop policy if exists passes_select_team_member on public.passes;
create policy passes_select_team_member
on public.passes for select
to authenticated
using (
  exists (
    select 1 from public.team_memberships tm
    where tm.team_id = passes.team_id
      and tm.user_id = auth.uid()
      and tm.active = true
  )
);

drop policy if exists passes_write_admin_leader on public.passes;
create policy passes_write_admin_leader
on public.passes for all
to authenticated
using (
  exists (
    select 1 from public.team_memberships tm
    where tm.team_id = passes.team_id
      and tm.user_id = auth.uid()
      and tm.active = true
      and tm.role in ('admin','leader')
  )
)
with check (
  exists (
    select 1 from public.team_memberships tm
    where tm.team_id = passes.team_id
      and tm.user_id = auth.uid()
      and tm.active = true
      and tm.role in ('admin','leader')
  )
);

-- Testposten tas bort. Standardpassen skapas automatiskt av appen vid forsta admininloggningen.
delete from public.passes
where team_id = 'katterums-jaktlag'
  and (id = 'test' or name = 'Testpass');
