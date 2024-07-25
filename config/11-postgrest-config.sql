-- https://postgrest.org/en/v12/references/configuration.html

-- create a dedicated schema, hidden from the API
--create schema postgrest;
-- grant usage on this schema to the authenticator

CREATE ROLE authenticator LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER;
--CREATE ROLE anonymous NOLOGIN;
CREATE ROLE web_anon NOLOGIN;
CREATE ROLE web_user NOLOGIN;
GRANT web_anon TO authenticator;
GRANT web_user TO authenticator;

grant usage on schema basic_auth to authenticator;

-- the function can configure postgREST by using set_config
create or replace function basic_auth.pre_config()
returns void as $$
  select
    -- set_config('pgrst.db_schemas', 'api', true),
    set_config('pgrst.jwt_secret', '7u8f0HLDi5S6NKzNuo69cDEl3abvDP8YVfW3egLNubvy7uJFrP', FALSE),
    set_config('pgrst.db_schemas', string_agg(nspname, ','), true)
    from pg_namespace
    where nspname like '%_api' OR nspname like 'private_%';
$$ language sql;
