-- Katterums jaktlag v2.3.6
-- Kopplar befintliga Auth-konton utan team_memberships-rad till jaktlaget som Viewer.
-- Befintliga medlemskap och roller ändras inte.

insert into public.team_memberships (team_id, user_id, role, username, active)
select
  'katterums-jaktlag',
  u.id,
  'viewer',
  split_part(u.email, '@', 1),
  true
from auth.users u
where u.email like '%@katterums-jaktlag.invalid'
  and split_part(u.email, '@', 1) <> 'erik'
  and not exists (
    select 1
    from public.team_memberships tm
    where tm.team_id = 'katterums-jaktlag'
      and tm.user_id = u.id
  );

select team_id, user_id, username, role, active
from public.team_memberships
where team_id = 'katterums-jaktlag'
order by username;
