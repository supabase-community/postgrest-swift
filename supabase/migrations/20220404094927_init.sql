create table todos (
    id uuid default uuid_generate_v4 () not null primary key,
    description text not null,
    is_complete boolean not null default false,
    tags text[],
    created_at timestamptz default (now() at time zone 'utc'::text) not null
);

create table users (
    id uuid default uuid_generate_v4 () not null primary key,
    email text not null,
    created_at timestamptz default (now() at time zone 'utc'::text) not null
);
