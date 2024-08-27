-- https://postgrest.org/en/v12/references/configuration.html

-- create a dedicated schema, hidden from the API
--create schema postgrest;
-- grant usage on this schema to the authenticator

CREATE ROLE authenticator NOLOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER;

CREATE ROLE web_anon NOLOGIN;
GRANT web_anon TO authenticator;

----

GRANT usage ON schema basic_auth TO authenticator;

-- the function can configure postgREST by using set_config
create or replace function basic_auth.pre_config()
returns void as $$
  select
    -- set_config('pgrst.db_schemas', 'api', true),
    set_config('pgrst.jwt_secret', '7u8f0HLDi5S6NKzNuo69cDEl3abvDP8YVfW3egLNubvy7uJFrP', FALSE),
    set_config('pgrst.db_schemas', string_agg(nspname, ','), true),
    set_config('pgrst.version', '1.0.2', true)
    --set_config('app.current_user_email', 'gerrit.balindt@gruenecho.de', true)
    from pg_namespace
    where nspname like '%_api' OR nspname like 'private_%';
$$ language sql;
