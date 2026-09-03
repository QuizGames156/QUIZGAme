-- RUN THIS ONCE in Supabase SQL Editor
-- Adds a real 1-month access expiry and makes promo activation set/extend it.

alter table public.profiles
add column if not exists access_expires_at timestamptz;

-- Existing active accounts: give 1 month from the moment this SQL is run
-- only if they do not already have an expiry.
update public.profiles
set access_expires_at = now() + interval '1 month'
where is_active = true and access_expires_at is null;

create or replace function public.activate_promo(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_code text := upper(trim(p_code));
  v_exists boolean;
  v_used boolean;
  v_expiry timestamptz;
begin
  if v_uid is null then
    return jsonb_build_object('success',false,'message','Нэвтэрнэ үү.');
  end if;

  select true, is_used into v_exists, v_used
  from public.promo_codes
  where upper(code)=v_code
  for update;

  if coalesce(v_exists,false)=false then
    return jsonb_build_object('success',false,'message','Promo Code буруу байна.');
  end if;
  if v_used then
    return jsonb_build_object('success',false,'message','Энэ Promo Code аль хэдийн ашиглагдсан байна.');
  end if;

  update public.promo_codes
  set is_used=true, used_by=v_uid, used_at=now()
  where upper(code)=v_code;

  update public.profiles
  set is_active=true,
      access_expires_at =
        case
          when access_expires_at is not null and access_expires_at > now()
            then access_expires_at + interval '1 month'
          else now() + interval '1 month'
        end
  where id=v_uid
  returning access_expires_at into v_expiry;

  return jsonb_build_object(
    'success',true,
    'message','Эрх амжилттай идэвхжлээ. 1 сарын эрх нэмэгдлээ.',
    'access_expires_at',v_expiry
  );
end;
$$;

grant execute on function public.activate_promo(text) to authenticated;

-- Server-side expiry enforcement helper.
create or replace function public.check_my_access()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_expiry timestamptz;
  v_active boolean;
begin
  if v_uid is null then
    return jsonb_build_object('active',false);
  end if;

  select is_active, access_expires_at into v_active, v_expiry
  from public.profiles where id=v_uid;

  if v_expiry is not null and v_expiry <= now() then
    update public.profiles set is_active=false where id=v_uid and is_active=true;
    v_active := false;
  end if;

  return jsonb_build_object('active',coalesce(v_active,false),'access_expires_at',v_expiry);
end;
$$;

grant execute on function public.check_my_access() to authenticated;
