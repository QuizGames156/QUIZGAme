
-- GAMSHIG-4 ADMIN PANEL RPCs

create or replace function public.is_current_user_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = auth.uid()
  );
$$;

revoke all on function public.is_current_user_admin() from public;
grant execute on function public.is_current_user_admin() to authenticated;

create or replace function public.admin_list_promos()
returns table (
  code text,
  is_used boolean,
  used_email text,
  used_at timestamptz,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null or not exists (
    select 1 from public.admin_users where user_id = auth.uid()
  ) then
    raise exception 'Admin эрх байхгүй байна.';
  end if;

  return query
  select
    p.code,
    p.is_used,
    u.email::text as used_email,
    p.used_at,
    p.created_at
  from public.promo_codes p
  left join auth.users u on u.id = p.used_by
  order by p.created_at desc;
end;
$$;

revoke all on function public.admin_list_promos() from public;
grant execute on function public.admin_list_promos() to authenticated;
