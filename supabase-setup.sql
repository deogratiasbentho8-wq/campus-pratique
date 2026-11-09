-- Campus Pratique : à exécuter une fois dans Supabase > SQL Editor > New query.
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 2 and 70),
  category text not null check (char_length(category) between 2 and 40),
  campus text not null default 'Campus' check (char_length(campus) <= 45),
  price integer not null check (price > 0),
  description text not null default '' check (char_length(description) <= 180),
  whatsapp text not null check (char_length(whatsapp) between 8 and 24),
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists listings_public_recent_idx on public.listings (is_active, created_at desc);
create index if not exists listings_owner_idx on public.listings (owner_id, created_at desc);
alter table public.listings enable row level security;
grant select on public.listings to anon, authenticated;
grant insert, update, delete on public.listings to authenticated;
drop policy if exists "Anyone can view active listings" on public.listings;
create policy "Anyone can view active listings" on public.listings for select
using (is_active = true or owner_id = (select auth.uid()));
drop policy if exists "Members can publish their own listings" on public.listings;
create policy "Members can publish their own listings" on public.listings for insert to authenticated
with check (owner_id = (select auth.uid()));
drop policy if exists "Members can edit their own listings" on public.listings;
create policy "Members can edit their own listings" on public.listings for update to authenticated
using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
drop policy if exists "Members can delete their own listings" on public.listings;
create policy "Members can delete their own listings" on public.listings for delete to authenticated
using (owner_id = (select auth.uid()));
