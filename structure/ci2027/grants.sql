SET search_path TO private_ci2027_001;


-- CREATE ROLES


CREATE ROLE ci2027_user;
GRANT ci2027_user TO authenticator;

GRANT web_anon TO ci2027_user;



GRANT USAGE ON SCHEMA private_ci2027_001 TO web_anon;



-- CREATE ROLE readonly_everything;
CREATE ROLE readonly_everything;
GRANT readonly_everything TO authenticator;
GRANT web_anon TO readonly_everything;


-- Default privileges for ci2027_user
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT SELECT, UPDATE, INSERT, DELETE ON TABLES TO ci2027_user, readonly_everything;
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT EXECUTE ON FUNCTIONS TO ci2027_user, readonly_everything;
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT USAGE ON SEQUENCES TO ci2027_user, readonly_everything;
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT USAGE ON TYPES TO ci2027_user, readonly_everything;


CREATE ROLE monitor NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER LOGIN ENCRYPTED PASSWORD 'monitor';
COMMENT ON ROLE monitor IS 'Read only access to all schemas';
GRANT monitor TO readonly_everything;