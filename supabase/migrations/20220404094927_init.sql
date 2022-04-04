create table todo (
    id uuid default uuid_generate_v4 () not null primary key,
    description text not null,
    is_complete boolean not null default false
);
