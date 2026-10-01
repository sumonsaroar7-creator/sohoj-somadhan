-- Nizum Enterprise database schema for Supabase (PostgreSQL)
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'customer' check (role in ('admin','customer')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text,
  category text not null,
  price numeric(12,2) not null check (price >= 0),
  compare_at_price numeric(12,2) not null default 0 check (compare_at_price >= 0),
  cost_price numeric(12,2) not null default 0 check (cost_price >= 0),
  stock integer not null default 0 check (stock >= 0),
  image_urls text[] not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text unique not null default ('NE-' || upper(substr(encode(gen_random_bytes(6),'hex'),1,10))),
  customer_name text not null,
  phone text not null,
  district text not null,
  area text not null,
  address text not null,
  customer_note text,
  payment_method text not null default 'cod' check (payment_method in ('cod','bkash','nagad','online')),
  subtotal numeric(12,2) not null check (subtotal >= 0),
  delivery_charge numeric(12,2) not null default 0 check (delivery_charge >= 0),
  total numeric(12,2) not null check (total >= 0),
  status text not null default 'new' check (status in ('new','confirmed','processing','shipped','delivered','cancelled','returned')),
  courier_name text,
  tracking_number text,
  delivery_person text,
  delivery_phone text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  unit_cost numeric(12,2) not null default 0 check (unit_cost >= 0)
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null check (category in ('Advertising','Packaging','Carrying','Transportation','Delivery','Manpower','Other')),
  amount numeric(12,2) not null check (amount > 0),
  expense_date date not null default current_date,
  notes text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.expenses enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;

-- Customers may read active products. Only admins can manage products.
drop policy if exists "Public can view active products" on public.products;
create policy "Public can view active products" on public.products for select using (is_active=true or public.is_admin());
drop policy if exists "Admins manage products" on public.products;
create policy "Admins manage products" on public.products for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Customers cannot directly insert orders/items. Orders must use place_order RPC below.
drop policy if exists "Admins view orders" on public.orders;
create policy "Admins view orders" on public.orders for select to authenticated using (public.is_admin());
drop policy if exists "Admins update orders" on public.orders;
create policy "Admins update orders" on public.orders for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins view order items" on public.order_items;
create policy "Admins view order items" on public.order_items for select to authenticated using (public.is_admin());
drop policy if exists "Admins manage expenses" on public.expenses;
create policy "Admins manage expenses" on public.expenses for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Safe public checkout: server calculates prices and costs from database, locks stock, creates order.
create or replace function public.place_order(order_data jsonb)
returns jsonb language plpgsql security definer set search_path=public
as $$
declare
  new_order public.orders;
  item jsonb;
  p public.products;
  q integer;
  calculated_subtotal numeric(12,2):=0;
  requested_items jsonb;
begin
  if jsonb_typeof(order_data->'items') <> 'array' or jsonb_array_length(order_data->'items')=0 then
    raise exception 'Cart is empty';
  end if;
  if length(trim(coalesce(order_data->>'customer_name','')))<2
     or length(trim(coalesce(order_data->>'phone','')))<8
     or length(trim(coalesce(order_data->>'district','')))<2
     or length(trim(coalesce(order_data->>'area','')))<2
     or length(trim(coalesce(order_data->>'address','')))<5 then
    raise exception 'Please provide complete customer details';
  end if;
  requested_items:=order_data->'items';
  for item in select * from jsonb_array_elements(requested_items) loop
    q:=(item->>'quantity')::integer;
    if q<1 or q>50 then raise exception 'Invalid quantity'; end if;
    select * into p from public.products where id=(item->>'product_id')::uuid and is_active=true for update;
    if not found then raise exception 'Product unavailable'; end if;
    if p.stock<q then raise exception 'Insufficient stock for %',p.name; end if;
    calculated_subtotal:=calculated_subtotal+(p.price*q);
  end loop;
  insert into public.orders(customer_name,phone,district,area,address,customer_note,payment_method,subtotal,delivery_charge,total,status)
  values(trim(order_data->>'customer_name'),trim(order_data->>'phone'),trim(order_data->>'district'),trim(order_data->>'area'),trim(order_data->>'address'),left(coalesce(order_data->>'customer_note',''),300),'cod',calculated_subtotal,0,calculated_subtotal,'new')
  returning * into new_order;
  for item in select * from jsonb_array_elements(requested_items) loop
    q:=(item->>'quantity')::integer;
    select * into p from public.products where id=(item->>'product_id')::uuid for update;
    insert into public.order_items(order_id,product_id,product_name,quantity,unit_price,unit_cost)
    values(new_order.id,p.id,p.name,q,p.price,p.cost_price);
    update public.products set stock=stock-q,updated_at=now() where id=p.id;
  end loop;
  return jsonb_build_object('id',new_order.id,'order_number',new_order.order_number);
end;
$$;
revoke all on function public.place_order(jsonb) from public;
grant execute on function public.place_order(jsonb) to anon, authenticated;

-- Create profile record for new Auth users. New users are customers by default.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public
as $$ begin insert into public.profiles(id,role) values(new.id,'customer'); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- Product image bucket. Admin-only upload; public can read images.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('product-images','product-images',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict(id) do nothing;
drop policy if exists "Public read product images" on storage.objects;
create policy "Public read product images" on storage.objects for select using (bucket_id='product-images');
drop policy if exists "Admin upload product images" on storage.objects;
create policy "Admin upload product images" on storage.objects for insert to authenticated with check (bucket_id='product-images' and public.is_admin());
drop policy if exists "Admin update product images" on storage.objects;
create policy "Admin update product images" on storage.objects for update to authenticated using (bucket_id='product-images' and public.is_admin()) with check (bucket_id='product-images' and public.is_admin());
drop policy if exists "Admin delete product images" on storage.objects;
create policy "Admin delete product images" on storage.objects for delete to authenticated using (bucket_id='product-images' and public.is_admin());

-- IMPORTANT: after creating your first Supabase Auth user, promote ONLY your own user:
-- update public.profiles set role='admin' where id=(select id from auth.users where email='YOUR-ADMIN-EMAIL');
