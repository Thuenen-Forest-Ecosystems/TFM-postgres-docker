-- We put things inside the basic_auth schema to hide
-- them from public view. Certain public procs/views will
-- refer to helpers and tables inside.


CREATE SCHEMA IF NOT EXISTS basic_auth;

CREATE SCHEMA ext_pgcrypto;
ALTER SCHEMA ext_pgcrypto OWNER TO postgres;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA ext_pgcrypto;


CREATE SCHEMA ext_pgjwt;
ALTER SCHEMA ext_pgjwt OWNER TO postgres;
CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA ext_pgjwt;


CREATE FUNCTION basic_auth.pbkdf2(salt bytea, pw text, count integer, desired_length integer, algorithm text) RETURNS bytea
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
  hash_length integer;
  block_count integer;
  output bytea;
  the_last bytea;
  xorsum bytea;
  i_as_int32 bytea;
  i integer;
  j integer;
  k integer;
BEGIN
  algorithm := lower(algorithm);
  CASE algorithm
  WHEN 'md5' then
    hash_length := 16;
  WHEN 'sha1' then
    hash_length = 20;
  WHEN 'sha256' then
    hash_length = 32;
  WHEN 'sha512' then
    hash_length = 64;
  ELSE
    RAISE EXCEPTION 'Unknown algorithm "%"', algorithm;
  END CASE;
  --
  block_count := ceil(desired_length::real / hash_length::real);
  --
  FOR i in 1 .. block_count LOOP
    i_as_int32 := E'\\000\\000\\000'::bytea || chr(i)::bytea;
    i_as_int32 := substring(i_as_int32, length(i_as_int32) - 3);
    --
    the_last := salt::bytea || i_as_int32;
    --
    xorsum := ext_pgcrypto.HMAC(the_last, pw::bytea, algorithm);
    the_last := xorsum;
    --
    FOR j IN 2 .. count LOOP
      the_last := ext_pgcrypto.HMAC(the_last, pw::bytea, algorithm);

      -- xor the two
      FOR k IN 1 .. length(xorsum) LOOP
        xorsum := set_byte(xorsum, k - 1, get_byte(xorsum, k - 1) # get_byte(the_last, k - 1));
      END LOOP;
    END LOOP;
    --
    IF output IS NULL THEN
      output := xorsum;
    ELSE
      output := output || xorsum;
    END IF;
  END LOOP;
  --
  RETURN substring(output FROM 1 FOR desired_length);
END $$;

ALTER FUNCTION basic_auth.pbkdf2(salt bytea, pw text, count integer, desired_length integer, algorithm text) OWNER TO postgres;



CREATE FUNCTION basic_auth.check_user_pass(username text, password text) RETURNS name
    LANGUAGE sql
    AS
$$
  SELECT rolname AS username
  FROM pg_authid
  -- regexp-split scram hash:
  CROSS JOIN LATERAL regexp_match(rolpassword, '^SCRAM-SHA-256\$(.*):(.*)\$(.*):(.*)$') AS rm
  -- identify regexp groups with sane names:
  CROSS JOIN LATERAL (SELECT rm[1]::integer AS iteration_count, decode(rm[2], 'base64') as salt, decode(rm[3], 'base64') AS stored_key, decode(rm[4], 'base64') AS server_key, 32 AS digest_length) AS stored_password_part
  -- calculate pbkdf2-digest:
  CROSS JOIN LATERAL (SELECT basic_auth.pbkdf2(salt, check_user_pass.password, iteration_count, digest_length, 'sha256')) AS digest_key(digest_key)
  -- based on that, calculate hashed passwort part:
  CROSS JOIN LATERAL (SELECT ext_pgcrypto.digest(ext_pgcrypto.hmac('Client Key', digest_key, 'sha256'), 'sha256') AS stored_key, ext_pgcrypto.hmac('Server Key', digest_key, 'sha256') AS server_key) AS check_password_part
  WHERE rolpassword IS NOT NULL
    AND pg_authid.rolname = check_user_pass.username
    -- verify password:
    AND check_password_part.stored_key = stored_password_part.stored_key
    AND check_password_part.server_key = stored_password_part.server_key;
$$;

ALTER FUNCTION basic_auth.check_user_pass(username text, password text) OWNER TO postgres;


CREATE TYPE basic_auth.jwt_token AS (
  token text
);

-- if you are not using psql, you need to replace :DBNAME with the current database's name.
-- ALTER DATABASE :DBNAME SET "app.jwt_secret" to 'reallyreallyreallyreallyverysafe';


CREATE FUNCTION api.login(username text, password text) RETURNS basic_auth.jwt_token
    LANGUAGE plpgsql security definer
    AS $$
DECLARE
  _role name;
  result basic_auth.jwt_token;
BEGIN
  -- check email and password
  SELECT basic_auth.check_user_pass(username, password) INTO _role;
  IF _role IS NULL THEN
    RAISE invalid_password USING message = 'invalid user or password';
  END IF;
  --
  SELECT ext_pgjwt.sign(
      row_to_json(r), 'jd9LnBX7kTJxaZy7MtwvVz78T8qF6DDNFznNN4tWJvuzLVjAAGGFth3gSGM3AEDLjLfmsuHS5hc8VZbgehWztLX' --current_setting('app.jwt_secret')
    ) AS token
    FROM (
      SELECT login.username as role,
        extract(epoch FROM now())::integer + 60*60 AS exp
    ) r
    INTO result;
  RETURN result;
END;
$$;

ALTER FUNCTION api.login(username text, password text) OWNER TO postgres;


CREATE ROLE anon NOINHERIT;
CREATE role authenticator NOINHERIT LOGIN PASSWORD 'secret';
GRANT anon TO authenticator;

GRANT EXECUTE ON FUNCTION api.login(username text, password text) TO anon;


