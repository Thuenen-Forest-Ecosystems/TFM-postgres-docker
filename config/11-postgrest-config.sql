-- https://postgrest.org/en/v12/references/configuration.html

-- create a dedicated schema, hidden from the API
create schema postgrest;
-- grant usage on this schema to the authenticator
grant usage on schema postgrest to authenticator;

-- the function can configure postgREST by using set_config
create or replace function postgrest.pre_config()
returns void as $$
  select
    -- set_config('pgrst.db_schemas', 'api', true),
    set_config('pgrst.jwt_secret', '7u8f0HLDi5S6NKzNuo69cDEl3abvDP8YVfW3egLNubvy7uJFrP', FALSE),
    set_config('pgrst.db_schemas', string_agg(nspname, ','), true)
    from pg_namespace
    where nspname like 'bwi_%' OR nspname like 'public_%' OR nspname = 'api';
$$ language sql;
