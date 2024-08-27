CREATE SCHEMA IF NOT EXISTS public_api;
COMMENT ON SCHEMA public_api IS 'Public API schema 1.0.0' ;

ALTER SCHEMA public_api OWNER TO postgres;
GRANT USAGE ON SCHEMA public_api TO web_anon;


-- LOGIN FUNCTION
CREATE FUNCTION public_api.login(email text, pass text) RETURNS basic_auth.jwt_token
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _role name;
  result basic_auth.jwt_token;
begin
  -- check email and password
  select basic_auth.user_role(email, pass) into _role;
  if _role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  select sign(
      row_to_json(r), '7u8f0HLDi5S6NKzNuo69cDEl3abvDP8YVfW3egLNubvy7uJFrP' --current_setting('pgrst.jwt_secret')
      
    ) as token
    from (
      select _role as role, login.email as email,
         extract(epoch from now())::integer + 60 * 60 * 24 as exp
    ) r
    into result;
  
  return result;
end;
$$;

ALTER FUNCTION public_api.login(email text, pass text) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public_api.login(username text, password text) TO web_anon;

-- schema view
CREATE OR REPLACE VIEW public_api.schemata
 AS
 SELECT a.schema_name, pg_description.description
   FROM ( SELECT schemata.schema_name
           FROM information_schema.schemata
          WHERE schemata.schema_name::name <> ALL (ARRAY['pg_catalog'::name, 'public'::name, 'information_schema'::name])) a
     LEFT JOIN pg_namespace ON pg_namespace.nspname = a.schema_name::name
     LEFT JOIN pg_description ON pg_description.objoid = pg_namespace.oid;

ALTER TABLE public_api.schemata OWNER TO postgres;
GRANT SELECT ON public_api.schemata TO web_anon;


-- Watch function
CREATE OR REPLACE FUNCTION pgrst_watch() RETURNS event_trigger
  LANGUAGE plpgsql
  AS $$
BEGIN
  NOTIFY pgrst, 'reload schema';
END;
$$;

-- This event trigger will fire after every ddl_command_end event
CREATE EVENT TRIGGER pgrst_watch
  ON ddl_command_end
  EXECUTE PROCEDURE pgrst_watch();



-- Function to return the current user's email and current_user
CREATE OR REPLACE FUNCTION public_api.get_current_user() RETURNS json AS $$
BEGIN
    -- Return the combined information as a JSON object
    RETURN current_setting('request.jwt.claims', true)::json;
END;
$$ LANGUAGE plpgsql;