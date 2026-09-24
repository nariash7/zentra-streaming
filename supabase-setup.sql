-- Ejecuta este archivo una sola vez en Supabase > SQL Editor.
-- Después crea los administradores desde Authentication > Users.

create extension if not exists pgcrypto;

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.store_settings (
  id integer primary key default 1 check (id = 1),
  store_name text not null default 'ZENTRA STREAMING',
  whatsapp text not null default '51933320033',
  hero_title text not null default 'Todo tu contenido, en un solo lugar.',
  hero_text text not null default 'Explora las plataformas disponibles, elige la cantidad y consulta la activación directamente por WhatsApp.',
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null check (category in ('entretenimiento','musica','creatividad','aprendizaje')),
  specs text not null default '',
  price numeric(12,2) not null default 0 check (price >= 0),
  badge text not null default '',
  image_url text not null default '',
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.store_settings (id) values (1)
on conflict (id) do nothing;

insert into public.products (name, category, specs, price, badge, image_url, sort_order)
select * from (values
  ('Netflix','entretenimiento','Consulta disponibilidad y condiciones de activación',12,'Popular','',1),
  ('Crunchyroll','entretenimiento','Anime y entretenimiento',6,'','',2),
  ('Spotify','musica','Música y audio',10,'Música','',3),
  ('HBO Max','entretenimiento','Series y películas',8,'','',4),
  ('Prime Video','entretenimiento','Películas y series',8,'','',5),
  ('Paramount+','entretenimiento','Contenido y entretenimiento',6,'','',6),
  ('Disney Premium + ESPN','entretenimiento','Entretenimiento y deportes',10,'Con ESPN','',7),
  ('Disney Premium sin ESPN','entretenimiento','Entretenimiento familiar',8,'','',8),
  ('ViX','entretenimiento','Series, películas y contenido en español',5,'Económico','',9),
  ('Canva Pro','creatividad','Diseño y contenido visual',8,'Diseño','',10),
  ('IPTV','entretenimiento','Consulta disponibilidad y compatibilidad',8,'','',11),
  ('YouTube Premium','entretenimiento','Video y música',10,'','',12),
  ('ChatGPT Plus','creatividad','Herramientas de inteligencia artificial',20,'IA','',13),
  ('Apple TV+','entretenimiento','Series y películas',8,'','',14),
  ('Duolingo','aprendizaje','Aprendizaje de idiomas',10,'Aprende','',15),
  ('Gemini Pro','creatividad','Herramientas de inteligencia artificial',10,'IA','',16),
  ('CapCut Pro','creatividad','Edición de video y contenido',15,'Video','',17)
) as seed(name, category, specs, price, badge, image_url, sort_order)
where not exists (select 1 from public.products);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(select 1 from public.admins where user_id = auth.uid());
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

alter table public.admins enable row level security;
alter table public.store_settings enable row level security;
alter table public.products enable row level security;

drop policy if exists "admin puede verse" on public.admins;
create policy "admin puede verse" on public.admins
for select to authenticated using (user_id = auth.uid());

drop policy if exists "catalogo publico" on public.products;
create policy "catalogo publico" on public.products
for select to anon, authenticated using (active = true);

drop policy if exists "admin ve todos los productos" on public.products;
create policy "admin ve todos los productos" on public.products
for select to authenticated using (public.is_admin());

drop policy if exists "admin crea productos" on public.products;
create policy "admin crea productos" on public.products
for insert to authenticated with check (public.is_admin());

drop policy if exists "admin actualiza productos" on public.products;
create policy "admin actualiza productos" on public.products
for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin elimina productos" on public.products;
create policy "admin elimina productos" on public.products
for delete to authenticated using (public.is_admin());

drop policy if exists "ajustes publicos" on public.store_settings;
create policy "ajustes publicos" on public.store_settings
for select to anon, authenticated using (true);

drop policy if exists "admin actualiza ajustes" on public.store_settings;
create policy "admin actualiza ajustes" on public.store_settings
for update to authenticated using (public.is_admin()) with check (public.is_admin());

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do update set public = true;

drop policy if exists "imagenes publicas" on storage.objects;
create policy "imagenes publicas" on storage.objects
for select to public using (bucket_id = 'product-images');

drop policy if exists "admin sube imagenes" on storage.objects;
create policy "admin sube imagenes" on storage.objects
for insert to authenticated with check (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "admin actualiza imagenes" on storage.objects;
create policy "admin actualiza imagenes" on storage.objects
for update to authenticated using (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "admin elimina imagenes" on storage.objects;
create policy "admin elimina imagenes" on storage.objects
for delete to authenticated using (bucket_id = 'product-images' and public.is_admin());

-- Para autorizar un administrador, reemplaza el UUID y ejecuta esta línea:
-- insert into public.admins (user_id) values ('UUID_DEL_USUARIO');
