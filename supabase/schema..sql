create extension if not exists pgcrypto;

create table if not exists public.tahsin_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  full_name text not null,
  role text not null default 'guru' check (role in ('admin','guru')),
  created_at timestamptz not null default now()
);
create table if not exists public.tahsin_classes (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);
create table if not exists public.tahsin_students (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  class_id uuid not null references public.tahsin_classes(id),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (full_name, class_id)
);
create table if not exists public.tahsin_sessions (
  id uuid primary key default gen_random_uuid(),
  attendance_date date not null,
  teacher_id uuid not null references public.tahsin_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(attendance_date, teacher_id)
);
create table if not exists public.tahsin_attendance (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.tahsin_sessions(id) on delete cascade,
  student_id uuid not null references public.tahsin_students(id),
  status text not null check(status in ('Hadir','Sakit','Izin','Alpha')),
  updated_at timestamptz not null default now(),
  unique(session_id, student_id)
);

create or replace function public.tahsin_is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.tahsin_profiles p where p.id=auth.uid() and p.role='admin'); $$;
grant execute on function public.tahsin_is_admin() to authenticated;

alter table public.tahsin_profiles enable row level security;
alter table public.tahsin_classes enable row level security;
alter table public.tahsin_students enable row level security;
alter table public.tahsin_sessions enable row level security;
alter table public.tahsin_attendance enable row level security;

drop policy if exists "tahsin profiles read authenticated" on public.tahsin_profiles;
create policy "tahsin profiles read authenticated" on public.tahsin_profiles for select to authenticated using (true);
drop policy if exists "tahsin admin insert profile" on public.tahsin_profiles;
create policy "tahsin admin insert profile" on public.tahsin_profiles for insert to authenticated with check (public.tahsin_is_admin());
drop policy if exists "tahsin admin update profile" on public.tahsin_profiles;
create policy "tahsin admin update profile" on public.tahsin_profiles for update to authenticated using (public.tahsin_is_admin()) with check (public.tahsin_is_admin());
drop policy if exists "tahsin classes read" on public.tahsin_classes;
create policy "tahsin classes read" on public.tahsin_classes for select to authenticated using (true);
drop policy if exists "tahsin admin manage classes" on public.tahsin_classes;
create policy "tahsin admin manage classes" on public.tahsin_classes for all to authenticated using (public.tahsin_is_admin()) with check (public.tahsin_is_admin());
drop policy if exists "tahsin students read" on public.tahsin_students;
create policy "tahsin students read" on public.tahsin_students for select to authenticated using (true);
drop policy if exists "tahsin admin manage students" on public.tahsin_students;
create policy "tahsin admin manage students" on public.tahsin_students for all to authenticated using (public.tahsin_is_admin()) with check (public.tahsin_is_admin());
drop policy if exists "tahsin sessions read" on public.tahsin_sessions;
create policy "tahsin sessions read" on public.tahsin_sessions for select to authenticated using (true);
drop policy if exists "tahsin teachers create sessions" on public.tahsin_sessions;
create policy "tahsin teachers create sessions" on public.tahsin_sessions for insert to authenticated with check (teacher_id=auth.uid() or public.tahsin_is_admin());
drop policy if exists "tahsin teachers update sessions" on public.tahsin_sessions;
create policy "tahsin teachers update sessions" on public.tahsin_sessions for update to authenticated using (teacher_id=auth.uid() or public.tahsin_is_admin()) with check (teacher_id=auth.uid() or public.tahsin_is_admin());
drop policy if exists "tahsin attendance read" on public.tahsin_attendance;
create policy "tahsin attendance read" on public.tahsin_attendance for select to authenticated using (true);
drop policy if exists "tahsin attendance insert" on public.tahsin_attendance;
create policy "tahsin attendance insert" on public.tahsin_attendance for insert to authenticated with check (exists(select 1 from public.tahsin_sessions s where s.id=session_id and (s.teacher_id=auth.uid() or public.tahsin_is_admin())));
drop policy if exists "tahsin attendance update" on public.tahsin_attendance;
create policy "tahsin attendance update" on public.tahsin_attendance for update to authenticated using (exists(select 1 from public.tahsin_sessions s where s.id=session_id and (s.teacher_id=auth.uid() or public.tahsin_is_admin()))) with check (exists(select 1 from public.tahsin_sessions s where s.id=session_id and (s.teacher_id=auth.uid() or public.tahsin_is_admin())));
drop policy if exists "tahsin attendance delete" on public.tahsin_attendance;
create policy "tahsin attendance delete" on public.tahsin_attendance for delete to authenticated using (exists(select 1 from public.tahsin_sessions s where s.id=session_id and (s.teacher_id=auth.uid() or public.tahsin_is_admin())));

-- Seed akun admin pertama setelah akun Auth admin@simtahsin.local dibuat:
insert into public.tahsin_profiles (id, username, full_name, role)
select id, 'admin', 'Administrator', 'admin'
from auth.users where email = 'admin@simtahsin.local'
on conflict (id) do update set username=excluded.username, full_name=excluded.full_name, role='admin';

-- Seed kelas dan 45 siswa awal dapat diimpor lewat menu Data Siswa atau CSV.

-- Explicit grants; Row Level Security above remains the access-control layer.
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.tahsin_profiles to authenticated;
grant select, insert, update, delete on public.tahsin_classes to authenticated;
grant select, insert, update, delete on public.tahsin_students to authenticated;
grant select, insert, update, delete on public.tahsin_sessions to authenticated;
grant select, insert, update, delete on public.tahsin_attendance to authenticated;
