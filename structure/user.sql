CREATE ROLE monitor NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER LOGIN PASSWORD 'monitor';
COMMENT ON ROLE monitor IS 'Used by Thünen-Institut to monitor the data / is a read-only-everything user';
GRANT ci2027_user TO monitor;

--GRANT USAGE ON SCHEMA private_ci2027_001 TO monitor;
--ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT SELECT ON TABLES TO monitor;
--GRANT SELECT ON ALL TABLES IN SCHEMA private_ci2027_001 TO monitor;


CREATE ROLE country_admin NOLOGIN;
COMMENT ON ROLE country_admin IS 'Country administrator for CI2027';
GRANT ci2027_user TO country_admin;
GRANT web_anon TO country_admin;
GRANT country_admin TO authenticator;




CREATE ROLE state_admin NOLOGIN;
COMMENT ON ROLE state_admin IS 'State administrator for CI2027';
GRANT ci2027_user TO state_admin;
--REVOKE DELETE, INSERT ON cluster FROM state_admin;

CREATE ROLE ci2027_recording_troop NOLOGIN;
COMMENT ON ROLE ci2027_recording_troop IS 'Recording troop for CI2027';
GRANT ci2027_user TO ci2027_recording_troop;
--REVOKE DELETE, INSERT ON cluster FROM ci2027_recording_troop;

CREATE ROLE ci2027_control_troop NOLOGIN;
COMMENT ON ROLE ci2027_control_troop IS 'Control troop for CI2027';
GRANT ci2027_user TO ci2027_control_troop;
--REVOKE DELETE, INSERT ON cluster FROM ci2027_control_troop;

DO $$
DECLARE
    admin_user_id INTEGER;
BEGIN

    INSERT INTO basic_auth.users (email, pass, role) VALUES ('bundesinventurleiter', 'bundesinventurleiter', 'country_admin') RETURNING id INTO admin_user_id;
    INSERT INTO basic_auth.users (email, pass, role, administrator_user_id) VALUES ('analyst', 'analyst', 'monitor', admin_user_id);
    INSERT INTO basic_auth.users (email, pass, role, administrator_user_id) VALUES ('landesinventurleiter', 'landesinventurleiter', 'state_admin', admin_user_id) RETURNING id INTO admin_user_id;
    INSERT INTO basic_auth.users (email, pass, role, administrator_user_id) VALUES ('recording-troop', 'recording-troop', 'ci2027_recording_troop', admin_user_id);
    INSERT INTO basic_auth.users (email, pass, role, administrator_user_id) VALUES ('control-troop', 'control-troop', 'ci2027_control_troop', admin_user_id);

END $$;



-- Function users with current user id as administrator_user_id
GRANT USAGE ON SCHEMA basic_auth TO ci2027_user;
GRANT SELECT ON basic_auth.users TO ci2027_user;

CREATE OR REPLACE FUNCTION public_api.get_supervisor() RETURNS json AS $$
DECLARE
    current_user_record RECORD;
BEGIN
    -- Get the current user record
    SELECT * INTO current_user_record 
    FROM basic_auth.users
    WHERE basic_auth.users.email = current_setting('request.jwt.claims', true)::json->>'email';

    -- Return the administrator user record as JSON
    RETURN (
        SELECT COALESCE(json_agg(json_build_object(
            'id', admin_users.id,
            'role', admin_users.role,
            'email', admin_users.email
        )), '[]'::json)
        FROM basic_auth.users AS admin_users
        WHERE admin_users.id = current_user_record.administrator_user_id
    )::json;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public_api.get_supervisor IS 'Returns the email of the administrator of the current user';


CREATE OR REPLACE FUNCTION public_api.get_underling() RETURNS json AS $$
DECLARE
    current_user_record RECORD;
BEGIN
    -- Get the current user record
    SELECT * INTO current_user_record 
    FROM basic_auth.users
    WHERE basic_auth.users.email = current_setting('request.jwt.claims', true)::json->>'email';

    -- Return the administrator user record as JSON
    RETURN (
        SELECT COALESCE(json_agg(json_build_object(
            'id', admin_users.id,
            'role', admin_users.role,
            'email', admin_users.email
        )), '[]'::json)
        FROM basic_auth.users AS admin_users
        WHERE admin_users.administrator_user_id = current_user_record.id
    )::json;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public_api.get_underling IS 'Returns the email of the underling of the current user';