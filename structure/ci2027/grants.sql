SET search_path TO private_ci2027_001;


-- CREATE ROLES


CREATE ROLE ci2027_user;
GRANT ci2027_user TO authenticator;

GRANT web_anon TO ci2027_user;



--GRANT USAGE ON SCHEMA private_ci2027_001 TO web_anon;
GRANT USAGE ON SCHEMA private_ci2027_001 TO ci2027_user;


-- CREATE ROLE readonly_everything;
CREATE ROLE readonly_everything;
GRANT readonly_everything TO authenticator;
GRANT web_anon TO readonly_everything;

--GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE plot TO ci2027_user;
-- Default privileges for ci2027_user
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ci2027_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT SELECT ON TABLES TO readonly_everything;
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT EXECUTE ON FUNCTIONS TO ci2027_user, readonly_everything;
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT USAGE ON SEQUENCES TO ci2027_user, readonly_everything;
ALTER DEFAULT PRIVILEGES IN SCHEMA private_ci2027_001 GRANT USAGE ON TYPES TO ci2027_user, readonly_everything;