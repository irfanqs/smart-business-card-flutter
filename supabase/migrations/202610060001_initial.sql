-- Jalankan di SQL Editor Supabase setelah membuat proyek.
create extension if not exists pgcrypto;

create table public.accounts (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'user' check (role in ('user', 'admin')),
  status text not null default 'active' check (status in ('active', 'disabled')),
  must_change_password boolean not null default false,
  notifications_enabled boolean not null default true,
  created_at timestamptz not null default now()
);

create function public.handle_new_user() returns trigger language plpgsql security definer
set search_path = public as $$
begin
  insert into public.accounts(id, email) values (new.id, new.email);
  return new;
end;
$$;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create function public.can_use_app() returns boolean language sql stable security definer
set search_path = public as $$
  select exists(select 1 from accounts where id = auth.uid()
    and status = 'active' and must_change_password = false and role = 'user');
$$;

create table public.cards (
  owner_id uuid primary key references public.accounts(id) on delete cascade,
  full_name text not null check (length(trim(full_name)) > 0),
  job_title text not null default '',
  company text not null default '',
  industry text not null default '',
  city text not null default '',
  public_email text not null default '',
  phone text not null default '',
  linkedin text not null default '',
  bio text not null default '' check (length(bio) <= 160),
  photo_path text check (photo_path is null or photo_path like (owner_id::text || '/%')),
  is_public boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.share_links (
  token text primary key check (token ~ '^[a-f0-9]{64}$'),
  owner_id uuid not null references public.cards(owner_id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '24 hours'),
  check (expires_at = created_at + interval '24 hours')
);
create index share_links_owner_idx on public.share_links(owner_id);

create table public.share_events (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.accounts(id) on delete cascade,
  kind text not null check (kind in ('copy', 'share', 'download')),
  created_at timestamptz not null default now()
);

create table public.relations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.accounts(id) on delete cascade,
  source_owner_id uuid references public.cards(owner_id) on delete set null,
  full_name text not null check (length(trim(full_name)) > 0),
  job_title text not null default '',
  company text not null default '',
  email text not null default '',
  phone text not null default '',
  linkedin text not null default '',
  category text check (category in ('Partner', 'Klien', 'Prospek', 'Teman Profesional')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(owner_id, source_owner_id)
);
create index relations_owner_created_idx on public.relations(owner_id, created_at desc);

create table public.interactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.accounts(id) on delete cascade,
  relation_id uuid not null references public.relations(id) on delete cascade,
  happened_at timestamptz not null,
  location text not null default '',
  note text not null check (length(trim(note)) > 0),
  created_at timestamptz not null default now()
);
create index interactions_relation_idx on public.interactions(relation_id, happened_at desc);

create table public.reminders (
  relation_id uuid primary key references public.relations(id) on delete cascade,
  owner_id uuid not null references public.accounts(id) on delete cascade,
  remind_at timestamptz not null,
  updated_at timestamptz not null default now()
);
create index reminders_owner_time_idx on public.reminders(owner_id, remind_at);

create function public.relation_owned_by_me(relation uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from relations where id = relation and owner_id = auth.uid());
$$;

alter table public.accounts enable row level security;
alter table public.cards enable row level security;
alter table public.share_links enable row level security;
alter table public.share_events enable row level security;
alter table public.relations enable row level security;
alter table public.interactions enable row level security;
alter table public.reminders enable row level security;

revoke all on public.cards, public.share_links, public.share_events,
  public.relations, public.interactions, public.reminders from anon;
grant select, insert, update, delete on public.cards, public.share_links,
  public.share_events, public.relations, public.interactions,
  public.reminders to authenticated;
revoke all on public.share_links from authenticated;
grant select, insert (token, owner_id) on public.share_links to authenticated;
grant execute on function public.can_use_app() to authenticated;
grant execute on function public.relation_owned_by_me(uuid) to authenticated;

create policy account_self_read on public.accounts for select to authenticated
using (id = auth.uid());
create policy account_self_preferences on public.accounts for update to authenticated
using (id = auth.uid() and status = 'active')
with check (id = auth.uid() and status = 'active');

-- Sensitive account fields are protected by column grants, not just RLS.
revoke all on public.accounts from anon, authenticated;
grant select (id, email, role, status, must_change_password, notifications_enabled, created_at)
  on public.accounts to authenticated;
grant update (notifications_enabled) on public.accounts to authenticated;

create policy card_owner on public.cards for all to authenticated
using (owner_id = auth.uid() and public.can_use_app())
with check (owner_id = auth.uid() and public.can_use_app());
create policy link_owner on public.share_links for all to authenticated
using (owner_id = auth.uid() and public.can_use_app())
with check (owner_id = auth.uid() and public.can_use_app());
create policy event_owner on public.share_events for all to authenticated
using (owner_id = auth.uid() and public.can_use_app())
with check (owner_id = auth.uid() and public.can_use_app());
create policy relation_owner on public.relations for all to authenticated
using (owner_id = auth.uid() and public.can_use_app())
with check (owner_id = auth.uid() and public.can_use_app());
create policy interaction_owner on public.interactions for all to authenticated
using (owner_id = auth.uid() and public.can_use_app() and public.relation_owned_by_me(relation_id))
with check (owner_id = auth.uid() and public.can_use_app() and public.relation_owned_by_me(relation_id));
create policy reminder_owner on public.reminders for all to authenticated
using (owner_id = auth.uid() and public.can_use_app() and public.relation_owned_by_me(relation_id))
with check (owner_id = auth.uid() and public.can_use_app() and public.relation_owned_by_me(relation_id));

insert into storage.buckets(id, name, public, file_size_limit, allowed_mime_types)
values ('card-photos', 'card-photos', false, 2097152, array['image/jpeg', 'image/png'])
on conflict (id) do nothing;
create policy photo_owner_read on storage.objects for select to authenticated
using (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text and public.can_use_app());
create policy photo_owner_insert on storage.objects for insert to authenticated
with check (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text and public.can_use_app());
create policy photo_owner_update on storage.objects for update to authenticated
using (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text and public.can_use_app())
with check (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text and public.can_use_app());
create policy photo_owner_delete on storage.objects for delete to authenticated
using (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text and public.can_use_app());
