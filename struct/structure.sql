--
-- PostgreSQL database dump
--

-- Dumped from database version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)

-- Started on 2024-05-14 17:15:51 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 14 (class 2615 OID 16400)
-- Name: api; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO postgres;

--
-- TOC entry 13 (class 2615 OID 16401)
-- Name: basic_auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA basic_auth;


ALTER SCHEMA basic_auth OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 16914)
-- Name: bwi_de_001_dev; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bwi_de_001_dev;


ALTER SCHEMA bwi_de_001_dev OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 17033)
-- Name: bwi_de_002_dev; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bwi_de_002_dev;


ALTER SCHEMA bwi_de_002_dev OWNER TO postgres;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: syslog
--
DROP SCHEMA IF EXISTS public;

CREATE SCHEMA public ;


ALTER SCHEMA public OWNER TO syslog;

--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: syslog
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 978 (class 1247 OID 16443)
-- Name: jwt_token; Type: TYPE; Schema: basic_auth; Owner: postgres
--

CREATE TYPE basic_auth.jwt_token AS (
	token text
);


ALTER TYPE basic_auth.jwt_token OWNER TO postgres;

--
-- TOC entry 338 (class 1255 OID 21517)
-- Name: check_permissions(integer); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.check_permissions(xtnr integer, OUT ok boolean) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    AS $$
	-- SELECT TRUE
	select ((Select count(b.tnr) from bwi_de_002_dev.b3_tnr_work as a inner join bwi_de_002_dev.b3_tnr_test as b
	on a.tnr=b.tnr
	where (xtnr= a.tnr AND a.workflow = 1 AND 'BIL' in (select "group" from basic_auth.users where email=current_setting('request.jwt.claims'::text, true)::json ->> 'email'::text)))>0)
	$$;


ALTER FUNCTION api.check_permissions(xtnr integer, OUT ok boolean) OWNER TO postgres;

--
-- TOC entry 335 (class 1255 OID 16444)
-- Name: delete_from_aaa_test_baeume_view(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.delete_from_aaa_test_baeume_view() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
		INSERT INTO api.aaa_test_baeume (dathoheit, tnr, enr, bnr, ba, bhd, hoehe, deleted)
		VALUES (CURRENT_USER, old.tnr, old.enr, old.bnr, old.ba, old.bhd, old.hoehe, 'TRUE');
        RETURN OLD;
    END;
$$;


ALTER FUNCTION api.delete_from_aaa_test_baeume_view() OWNER TO postgres;

--
-- TOC entry 363 (class 1255 OID 16445)
-- Name: generate_create_table_statement(character varying); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.generate_create_table_statement(p_table_name character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_table_ddl   text;
    column_record record;
BEGIN
    FOR column_record IN 
        SELECT 
            b.nspname as schema_name,
            b.relname as table_name,
            a.attname as column_name,
            pg_catalog.format_type(a.atttypid, a.atttypmod) as column_type,
            CASE WHEN 
                (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
                 FROM pg_catalog.pg_attrdef d
                 WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) IS NOT NULL THEN
                'DEFAULT '|| (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
                              FROM pg_catalog.pg_attrdef d
                              WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef)
            ELSE
                ''
            END as column_default_value,
            CASE WHEN a.attnotnull = true THEN 
                'NOT NULL'
            ELSE
                'NULL'
            END as column_not_null,
            a.attnum as attnum,
            e.max_attnum as max_attnum
        FROM 
            pg_catalog.pg_attribute a
            INNER JOIN 
             (SELECT c.oid,
                n.nspname,
                c.relname
              FROM pg_catalog.pg_class c
                   LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
              WHERE c.relname ~ ('^('||p_table_name||')$')
                AND pg_catalog.pg_table_is_visible(c.oid)
              ORDER BY 2, 3) b
            ON a.attrelid = b.oid
            INNER JOIN 
             (SELECT 
                  a.attrelid,
                  max(a.attnum) as max_attnum
              FROM pg_catalog.pg_attribute a
              WHERE a.attnum > 0 
                AND NOT a.attisdropped
              GROUP BY a.attrelid) e
            ON a.attrelid=e.attrelid
        WHERE a.attnum > 0 
          AND NOT a.attisdropped
        ORDER BY a.attnum
    LOOP
        IF column_record.attnum = 1 THEN
            v_table_ddl:='CREATE TABLE '||column_record.schema_name||'.'||column_record.table_name||' (';
        ELSE
            v_table_ddl:=v_table_ddl||',';
        END IF;

        IF column_record.attnum <= column_record.max_attnum THEN
            v_table_ddl:=v_table_ddl||chr(10)||
                     '    '||column_record.column_name||' '||column_record.column_type||' '||column_record.column_default_value||' '||column_record.column_not_null;
        END IF;
    END LOOP;

    v_table_ddl:=v_table_ddl||');';
    RETURN v_table_ddl;
END;
$_$;


ALTER FUNCTION api.generate_create_table_statement(p_table_name character varying) OWNER TO postgres;

--
-- TOC entry 355 (class 1255 OID 16446)
-- Name: insert_into_aaa_test_baeume_view(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.insert_into_aaa_test_baeume_view() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    	IF (select count (*) from (
				SELECT t1.bnr FROM api.aaa_test_baeume t1
  					WHERE t1.created_at = (( SELECT max(t2.created_at) AS max
           			FROM api.aaa_test_baeume t2
          		WHERE t2.tnr = t1.tnr AND t2.enr = t1.enr AND t2.bnr = t1.bnr)) AND t1.deleted = false AND t1.dathoheit::text = CURRENT_USER AND t1.bnr=new.bnr) vorhanden
		   ) = 0 
		 THEN
		INSERT INTO api.aaa_test_baeume (dathoheit, tnr, enr, bnr, ba, bhd, hoehe, deleted)
		VALUES (CURRENT_USER, new.tnr, new.enr, new.bnr, new.ba, new.bhd, new.hoehe, false);
		---else
		----Abbruch
		end if;
    	RETURN NEW;
END;
$$;


ALTER FUNCTION api.insert_into_aaa_test_baeume_view() OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 16447)
-- Name: login(text, text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.login(email text, pass text) RETURNS basic_auth.jwt_token
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
      row_to_json(r), 'XjFYeGSx2dzFYarQ1roQj5OSYkrBqfEQ'
    ) as token
    from (
      select _role as role, login.email as email,
         extract(epoch from now())::integer + 60*60 as exp
    ) r
    into result;
  return result;
end;
$$;


ALTER FUNCTION api.login(email text, pass text) OWNER TO postgres;

--
-- TOC entry 357 (class 1255 OID 16448)
-- Name: teapot(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.teapot() RETURNS json
    LANGUAGE plpgsql
    AS $$
begin
  perform set_config('response.status', '418', true);
  return json_build_object('message', 'The requested entity body is short and stout.',
                           'hint', 'Tip it over and pour it out.');
end;
$$;


ALTER FUNCTION api.teapot() OWNER TO postgres;

--
-- TOC entry 358 (class 1255 OID 16449)
-- Name: update_aaa_test_baeume_view(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.update_aaa_test_baeume_view() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
		INSERT INTO api.aaa_test_baeume (dathoheit, tnr, enr, bnr, ba, bhd, hoehe) VALUES (CURRENT_USER, new.tnr, new.enr, new.bnr, new.ba, new.bhd, new.hoehe);
        RETURN NEW;
    END;
$$;


ALTER FUNCTION api.update_aaa_test_baeume_view() OWNER TO postgres;

--
-- TOC entry 359 (class 1255 OID 16450)
-- Name: check_role_exists(); Type: FUNCTION; Schema: basic_auth; Owner: postgres
--

CREATE FUNCTION basic_auth.check_role_exists() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
    raise foreign_key_violation using message =
      'unknown database role: ' || new.role;
    return null;
  end if;
  return new;
end
$$;


ALTER FUNCTION basic_auth.check_role_exists() OWNER TO postgres;

--
-- TOC entry 362 (class 1255 OID 16451)
-- Name: encrypt_pass(); Type: FUNCTION; Schema: basic_auth; Owner: postgres
--

CREATE FUNCTION basic_auth.encrypt_pass() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if tg_op = 'INSERT' or new.pass <> old.pass then
    new.pass = crypt(new.pass, gen_salt('bf'));
  end if;
  return new;
end
$$;


ALTER FUNCTION basic_auth.encrypt_pass() OWNER TO postgres;

--
-- TOC entry 360 (class 1255 OID 16452)
-- Name: user_role(text, text); Type: FUNCTION; Schema: basic_auth; Owner: postgres
--

CREATE FUNCTION basic_auth.user_role(email text, pass text) RETURNS name
    LANGUAGE plpgsql
    AS $$
begin
  return (
  select role from basic_auth.users
   where users.email = user_role.email
     and users.pass = crypt(user_role.pass, users.pass)
  );
end;
$$;


ALTER FUNCTION basic_auth.user_role(email text, pass text) OWNER TO postgres;

--
-- TOC entry 367 (class 1255 OID 17105)
-- Name: b3_ecke_archive_old_at_update(); Type: FUNCTION; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE FUNCTION bwi_de_002_dev.b3_ecke_archive_old_at_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO bwi_de_002_dev.archiv_b3_ecke(ledituser, ledittime, dathoheit, datverwend, refkey, tnr,
	enr, vbl, bl, aufnbl, soll_rechtse, soll_hoche, soll_x_gk2, soll_y_gk2, soll_x_gk3, soll_y_gk3, soll_x_gk4,
	soll_y_gk4, soll_x_gk5, soll_y_gk5, soll_x_wgs84, soll_y_wgs84, soll_x_32n, soll_y_32n, soll_x_33n, soll_y_33n, wg, wb, hoenn, ags, atkis, dop, dlm)
VALUES (
	old.ledituser, old.ledittime, old.dathoheit, old.datverwend, old.refkey, old.tnr, old.enr, old.vbl,
	old.bl, old.aufnbl, old.soll_rechtse, old.soll_hoche, old.soll_x_gk2, old.soll_y_gk2, old.soll_x_gk3, old.soll_y_gk3,
	old.soll_x_gk4, old.soll_y_gk4, old.soll_x_gk5, old.soll_y_gk5, old.soll_x_wgs84, old.soll_y_wgs84, old.soll_x_32n,
	old.soll_y_32n, old.soll_x_33n, old.soll_y_33n, old.wg, old.wb, old.hoenn, old.ags, old.atkis, old.dop, old.dlm
	)
	;
	RETURN NEW;
END;
$$;


ALTER FUNCTION bwi_de_002_dev.b3_ecke_archive_old_at_update() OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 17063)
-- Name: b3_tnr_archive_old_at_update(); Type: FUNCTION; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE FUNCTION bwi_de_002_dev.b3_tnr_archive_old_at_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO bwi_de_002_dev.archiv_b3_tnr(
	ledituser, ledittime, dathoheit, datverwend, tnr, soll_re, soll_dre, soll_ho, soll_dho, soll_rechtst, soll_hocht, topkar, aufnbl, standardbl, laender, netz, netz64, ktg)
	VALUES (old.ledituser, old.ledittime, old.dathoheit, old.datverwend, old.tnr, old.soll_re, old.soll_dre, old.soll_ho, old.soll_dho, old.soll_rechtst, old.soll_hocht, old.topkar, old.aufnbl, old.standardbl, old.laender, old.netz, old.netz64, old.ktg)
	;
	RETURN NEW;
END;
$$;


ALTER FUNCTION bwi_de_002_dev.b3_tnr_archive_old_at_update() OWNER TO postgres;

--
-- TOC entry 370 (class 1255 OID 21518)
-- Name: check_permissions(integer); Type: FUNCTION; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE FUNCTION bwi_de_002_dev.check_permissions(xtnr integer, OUT ok boolean) RETURNS boolean
    LANGUAGE sql
    AS $$
	-- -- SELECT TRUE
	-- select ((Select count(a.tnr) from bwi_de_002_dev.b3_tnr_work as a
	-- -- inner join bwi_de_002_dev.b3_tnr_test as b
	-- -- on a.tnr=b.tnr
	-- where (xtnr= a.tnr AND a.workflow = 1 AND 'BIL' in (select "group" from basic_auth.users where email=current_setting('request.jwt.claims'::text, true)::json ->> 'email'::text)))>0)

	
select((select count(b.tnr) from
	bwi_de_002_dev.x_workflow_perm as a
	inner join bwi_de_002_dev.b3_tnr_work as b on a.icode = b.workflow
    inner join  basic_auth.users as c  on a.zustaendig_ist = c."group" and c.email =b."at"
	where b.tnr = xtnr ) =1);
	
-- probeaufruf
-- SELECT
--   set_config('request.jwt.claims', '{"email": "karsten@kdunger.de"}' ,true);
-- SELECT
--   current_setting('request.jwt.claims', true);
-- SELECT current_setting('request.jwt.claims', true)::json->>'email';
-- select bwi_de_002_dev.check_permissions(9999900);
-- select email, "group" from basic_auth.users where email= current_setting('request.jwt.claims', true)::json->>'email'
	
$$;


ALTER FUNCTION bwi_de_002_dev.check_permissions(xtnr integer, OUT ok boolean) OWNER TO postgres;

--
-- TOC entry 371 (class 1255 OID 21660)
-- Name: pruefe_rechte(integer); Type: FUNCTION; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE FUNCTION bwi_de_002_dev.pruefe_rechte(xtnr integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- 	select
-- 	b.tnr,b.workflow,a.zustaendig_ist,b.dathoheit,b.at
--  from
-- 	bwi_de_002_dev.x_workflow_perm as a
-- 	inner join bwi_de_002_dev.b3_tnr_work as b on a.icode = b.workflow
--  inner join (select email, "group","role" from basic_auth.users where email= current_setting('request.jwt.claims', true)::json->>'email') as c on a.zustaendig_ist = c."group" and b."at" = c."email"

	-- gerade gültige rolle auf Variable schreiben
   
	
	DECLARE
	rolle text;
	at text;
	wf integer;
	message character varying;
	  
	BEGIN

	rolle :=(	select a.zustaendig_ist from
	bwi_de_002_dev.x_workflow_perm as a
	inner join bwi_de_002_dev.b3_tnr_work as b on a.icode = b.workflow
    inner join  basic_auth.users as c  on a.zustaendig_ist = c."group" and c.email =b."at"
	where b.tnr = xtnr  );

	--wf :=(select b.workflow from bwi_de_002_dev.x_workflow_perm as a inner join bwi_de_002_dev.b3_tnr_work as b on a.icode = b.workflow inner join (select email, "group","role" from basic_auth.users where email= current_setting('request.jwt.claims', true)::json->>'email') as c on a.zustaendig_ist = c."group" and b."at" = c."email");
	--rolle :=(select "group" from basic_auth.users where email=current_setting('request.jwt.claims'::text, true)::json ->> 'email'::text);	
	--at :=(select "email" from basic_auth.users where email=current_setting('request.jwt.claims'::text, true)::json ->> 'email'::text); 
	
	message := 'Rolle= ' || rolle || ' Email=' || at;
		
	RAISE NOTICE '%', 'wf= ' || wf;
	--RAISE NOTICE '%', 'Rolle= ' || rolle || 'Email=' || at;
	RAISE NOTICE '%', message;

	case rolle
		   
		   when 'BIL' then
				RAISE NOTICE '%', 'Rolle= ' || rolle;
              	RETURN  TRUE;
		  --  when 'KT' then
				-- RAISE NOTICE '%', 'Rolle= ' || rolle;
    --           	RETURN  TRUE;
		   else
			   RAISE NOTICE '%', 'Rolle= ' || rolle;
	    	 	 RETURN  (select((select count(b.tnr) from
	bwi_de_002_dev.x_workflow_perm as a
	inner join bwi_de_002_dev.b3_tnr_work as b on a.icode = b.workflow
    inner join  basic_auth.users as c  on a.zustaendig_ist = c."group" and c.email =b."at"
	where b.tnr = xtnr ) =1));
		   end case;
		RETURN  FALSE;
	END
	
-- probeaufruf
-- SELECT
--   set_config('request.jwt.claims', '{"email": "karsten@kdunger.de"}' ,true);
-- SELECT
--   current_setting('request.jwt.claims', true);
-- SELECT current_setting('request.jwt.claims', true)::json->>'email';
-- select bwi_de_002_dev.pruefe_rechte(9999900);
-- select email, "group" from basic_auth.users where email= current_setting('request.jwt.claims', true)::json->>'email'
	
$$;


ALTER FUNCTION bwi_de_002_dev.pruefe_rechte(xtnr integer) OWNER TO postgres;

--
-- TOC entry 376 (class 1255 OID 21661)
-- Name: pruefe_rechte_bil(integer); Type: FUNCTION; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE FUNCTION bwi_de_002_dev.pruefe_rechte_bil(xtnr integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

	DECLARE
	rolle text;
	at text;
	wf integer;
	message character varying;
	  
	BEGIN
   
   wf:= (select b.workflow from
	bwi_de_002_dev.b3_tnr_work as b
    where b.tnr = xtnr);
   rolle:= CURRENT_USER;

	
	message := 'Rolle= ' || rolle || ' Email=' || at;
		
	RAISE NOTICE '%', 'wf= ' || wf;
	--RAISE NOTICE '%', 'Rolle= ' || rolle || 'Email=' || at;
	RAISE NOTICE '%', message;

	case rolle
		   --
		   when 'BIL' then
				RAISE NOTICE '%', 'Rolle= ' || rolle;
              	RETURN  (select((select count(b.tnr) from
	bwi_de_002_dev.b3_tnr_work as b
    where b.tnr = xtnr and b.workflow IN (0,8,9)) =1));
		  --  when 'KT' then
				-- RAISE NOTICE '%', 'Rolle= ' || rolle;
    --           	RETURN  TRUE;
		   else
			   RAISE NOTICE '%', 'Rolle= ' || rolle;
	    	 	 RETURN  FALSE;
		   end case;
		RETURN  FALSE;
	END
	
-- probeaufruf
-- select bwi_de_002_dev.pruefe_rechte_bil(9999900);
	
$$;


ALTER FUNCTION bwi_de_002_dev.pruefe_rechte_bil(xtnr integer) OWNER TO postgres;

--
-- TOC entry 339 (class 1255 OID 21510)
-- Name: update_ledittime_and_leditlogin_on_user_task(); Type: FUNCTION; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE FUNCTION bwi_de_002_dev.update_ledittime_and_leditlogin_on_user_task() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.ledittime = now();
	NEW.ledituser = current_setting('request.headers'::text, true)::text;
    RETURN NEW;
END;
$$;


ALTER FUNCTION bwi_de_002_dev.update_ledittime_and_leditlogin_on_user_task() OWNER TO postgres;

--
-- TOC entry 344 (class 1255 OID 17054)
-- Name: update_ledittime_and_ledituser_on_user_task(); Type: FUNCTION; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE FUNCTION bwi_de_002_dev.update_ledittime_and_ledituser_on_user_task() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.ledittime = now();
	NEW.ledituser = CURRENT_USER;
    RETURN NEW;
END;
$$;


ALTER FUNCTION bwi_de_002_dev.update_ledittime_and_ledituser_on_user_task() OWNER TO postgres;

--
-- TOC entry 352 (class 1255 OID 21641)
-- Name: pgrst_watch(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pgrst_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NOTIFY pgrst, 'reload schema';
END;
$$;


ALTER FUNCTION public.pgrst_watch() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 16454)
-- Name: aaa_test_baeume; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.aaa_test_baeume (
    dathoheit character(2) NOT NULL,
    tnr integer,
    enr smallint,
    bnr smallint NOT NULL,
    ba smallint NOT NULL,
    tnrenr_generated integer GENERATED ALWAYS AS (((tnr * 10) + enr)) STORED,
    bhd integer NOT NULL,
    hoehe integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE api.aaa_test_baeume OWNER TO postgres;

--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE aaa_test_baeume; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON TABLE api.aaa_test_baeume IS 'Testtabelle für Schreibtests

Entities description that
spans
multiple lines';


--
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.dathoheit; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.dathoheit IS 'Bundesland als 2 Buchstaben für RLS';


--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.tnr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.tnr IS 'Traktnummer';


--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.enr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.enr IS 'Eckennummer';


--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.bnr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.bnr IS 'Baumnummer';


--
-- TOC entry 3816 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.ba; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.ba IS 'Baumart (Fremdschlüssel zu x3_ba.icode)';


--
-- TOC entry 3817 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.tnrenr_generated; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.tnrenr_generated IS 'aut. gen. Hilfsspalte für Fremdschlüssel zu bv_ecke';


--
-- TOC entry 3818 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.bhd; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.bhd IS 'BHD';


--
-- TOC entry 3819 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN aaa_test_baeume.hoehe; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume.hoehe IS 'Höhe';


--
-- TOC entry 220 (class 1259 OID 16460)
-- Name: aaa_test_baeume_view; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.aaa_test_baeume_view AS
 SELECT t1.tnr,
    t1.enr,
    t1.bnr,
    t1.ba,
    t1.bhd,
    t1.hoehe
   FROM api.aaa_test_baeume t1
  WHERE ((t1.created_at = ( SELECT max(t2.created_at) AS max
           FROM api.aaa_test_baeume t2
          WHERE ((t2.tnr = t1.tnr) AND (t2.enr = t1.enr) AND (t2.bnr = t1.bnr)))) AND (t1.deleted = false) AND ((t1.dathoheit)::text = CURRENT_USER));


ALTER TABLE api.aaa_test_baeume_view OWNER TO postgres;

--
-- TOC entry 3821 (class 0 OID 0)
-- Dependencies: 220
-- Name: VIEW aaa_test_baeume_view; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON VIEW api.aaa_test_baeume_view IS 'Test-View für Schreibtests, basierend auf der entspr. Tabelle, aber ohne Spalten dathoheit und tnrenr_generated';


--
-- TOC entry 3822 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN aaa_test_baeume_view.tnr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume_view.tnr IS 'Traktnummer';


--
-- TOC entry 3823 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN aaa_test_baeume_view.enr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume_view.enr IS 'Eckennummer';


--
-- TOC entry 3824 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN aaa_test_baeume_view.bnr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume_view.bnr IS 'Baumnummer';


--
-- TOC entry 3825 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN aaa_test_baeume_view.ba; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume_view.ba IS 'Baumart (Fremdschlüssel zu x3_ba.icode)';


--
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN aaa_test_baeume_view.bhd; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume_view.bhd IS 'BHD';


--
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN aaa_test_baeume_view.hoehe; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.aaa_test_baeume_view.hoehe IS 'Höhe';


--
-- TOC entry 286 (class 1259 OID 21543)
-- Name: b3_tnr_test; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.b3_tnr_test (
    ledituser character varying DEFAULT CURRENT_USER NOT NULL,
    ledittime timestamp without time zone DEFAULT now() NOT NULL,
    dathoheit character varying,
    datverwend character varying,
    tnr integer NOT NULL,
    test smallint
);


ALTER TABLE api.b3_tnr_test OWNER TO postgres;

--
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE b3_tnr_test; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON TABLE api.b3_tnr_test IS 'testtabelle für Trakt
b3_tnr_test';


--
-- TOC entry 221 (class 1259 OID 16465)
-- Name: bv_ecke; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.bv_ecke (
    intkey character(12),
    datvon character(14),
    datbis character(14),
    ledituser character varying(50),
    ledittime timestamp(0) without time zone,
    dathoheit character(2),
    datverwend character varying(15),
    reftnr character(12),
    refenr character(12),
    refkey character(12),
    tnr integer,
    enr smallint,
    vbl smallint,
    ist_rechtse integer,
    ist_hoche integer,
    ist_x_gk2 integer,
    ist_y_gk2 integer,
    ist_x_gk3 integer,
    ist_y_gk3 integer,
    ist_x_gk4 integer,
    ist_y_gk4 integer,
    ist_x_gk5 integer,
    ist_y_gk5 integer,
    ist_x_wgs84 double precision,
    ist_y_wgs84 double precision,
    ist_x_32n double precision,
    ist_y_32n double precision,
    ist_x_33n double precision,
    ist_y_33n double precision,
    wa smallint,
    begehbar smallint,
    nathoe smallint,
    eg smallint,
    eggrkl smallint,
    biotop smallint,
    natwg_vk smallint,
    natwg_f smallint,
    wlt smallint,
    ne smallint,
    kartst smallint,
    lanu smallint,
    pflanzjahr smallint,
    datumfelde timestamp(0) without time zone,
    perm2002 smallint,
    perm2007 smallint,
    perm2008 smallint,
    perm2012 smallint,
    wa_lanu smallint,
    perm2017 smallint,
    perm2022 smallint,
    nutzart smallint,
    natwg_wlt smallint,
    wlt_wie smallint,
    wlt_vk smallint,
    wlt_vk_wie smallint,
    wlt_f smallint,
    wlt_f_wie smallint,
    wlt_w smallint,
    wlt_w_wie smallint,
    wlt_a smallint,
    wlt_listea character varying(30),
    wlt_listeb character varying(30),
    wlt_listec character varying(30),
    tnrenr_generated integer GENERATED ALWAYS AS (((tnr * 10) + enr)) STORED
);


ALTER TABLE api.bv_ecke OWNER TO postgres;

--
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE bv_ecke; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON TABLE api.bv_ecke IS 'BWI-Vorgänger: Initialisierungsdaten für Traktecke';


--
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.tnr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.tnr IS 'Traktnummer';


--
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.enr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.enr IS 'Trakteckennummer (1=A, 2=B, 3=C, 4=D)';


--
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_rechtse; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_rechtse IS 'RAUS: Ist-Gauß-Krüger-Rechtswert [m] für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_hoche; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_hoche IS 'RAUS: Ist-Gauß-Krüger-Hochwert [m] für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_x_gk2; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_x_gk2 IS 'RAUS: Ist-Gauß-Krüger-Rechtswert [m] (auf 2. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_y_gk2; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_y_gk2 IS 'RAUS: Ist-Gauß-Krüger-Hochwert [m] (auf 2. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_x_gk3; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_x_gk3 IS 'RAUS: Ist-Gauß-Krüger-Rechtswert [m] (auf 3. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_y_gk3; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_y_gk3 IS 'RAUS: Ist-Gauß-Krüger-Hochwert [m] (auf 3. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_x_gk4; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_x_gk4 IS 'RAUS: Ist-Gauß-Krüger-Rechtswert [m] (auf 4. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_y_gk4; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_y_gk4 IS 'RAUS: Ist-Gauß-Krüger-Hochwert [m] (auf 4. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_x_gk5; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_x_gk5 IS 'RAUS: Ist-Gauß-Krüger-Rechtswert [m] (auf 5. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_y_gk5; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_y_gk5 IS 'RAUS: Ist-Gauß-Krüger-Hochwert [m] (auf 5. Meridianstreifen umgerechnet) für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_x_wgs84; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_x_wgs84 IS 'RAUS: Ist-Ost-Koordinate WGS84 (Vorgängerinventur); auch Latitude oder Breitengrad genannt';


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_y_wgs84; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_y_wgs84 IS 'RAUS: Ist-Nord-Koordinate WGS84 für Traktecke (Vorgängerinventur), auch Longitude oder Längengrad genannt';


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_x_32n; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_x_32n IS 'RAUS: Ist-Ost-Koordinate UTM32 [m] für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_y_32n; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_y_32n IS 'RAUS: Ist-Nord-Koordinate UTM32 [m] für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_x_33n; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_x_33n IS 'RAUS: Ist-Ost-Koordinate UTM33 [m] für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ist_y_33n; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ist_y_33n IS 'RAUS: Ist-Nord-Koordinate UTM33 [m] für Traktecke (Vorgängerinventur)';


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wa; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wa IS 'Waldentscheid an der Traktecke bei Vorgängerinventur (CI2017), wenn der Datensatz fehlt, dann gilt 0=Nichtwald, SOFERN die Ecke zu beiden Zeitpunkten zum Inventurgebiet gehörte';


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.begehbar; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.begehbar IS 'Begehbarkeit der Traktecke bei Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.nathoe; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.nathoe IS 'Natürliche Höhenstufe bei Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.eg; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.eg IS 'Eigentumsart bei Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.eggrkl; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.eggrkl IS 'Eigentumsgrößenklasse bei Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.biotop; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.biotop IS 'Geschütztes Waldbiotop bei Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.natwg_vk; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.natwg_vk IS 'potentiellen natürliche Waldgesellschaft bei Vorklärung lt. Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.natwg_f; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.natwg_f IS 'potentielle natürliche Waldgesellschaft bei Feldaufnahme lt. Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt IS 'Waldlebensraumtyp der Vorgängerinventur lt. Feldaufnahme (BWI 2012); (Stand Erhebungsdatenbank 14.12.2015), Quelle [EW-Archiv].[bwineu_20151214].[dbo].[b3v_ecke_feld].[WLT]';


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.ne; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.ne IS 'Nutzungseinschränkung bei Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.kartst; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.kartst IS 'Standortmethode/Kartierung Vorgängerinventur (BWI 2011-2014) vorhanden?';


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.lanu; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.lanu IS 'Landnutzungsart bei Vorgängerinventur (BWI 2011-2014)';


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.pflanzjahr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.pflanzjahr IS 'Pflanzjahr für Bestockung (für CI2017 nicht relevant)';


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.perm2002; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.perm2002 IS 'Permanente Trakteckenmarkierung bei BWI2002';


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.perm2007; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.perm2007 IS 'Permanente Trakteckenmarkierung bei Landesinventur RP 2007';


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.perm2008; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.perm2008 IS 'Permanente Trakteckenmarkierung bei Inventurstudie / Landesinventur 2008';


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.perm2012; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.perm2012 IS 'Permanente Trakteckenmarkierung bei BWI2012 (BWI2011-2014)';


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wa_lanu; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wa_lanu IS 'Waldentscheid an der Traktecke bei Bezugsinventur für Landnutzungsänderung (hier Vorgängerinventur (BWI 2011-2014)), wenn der Datensatz fehlt, dann gilt 0=Nichtwald, sofern die Ecke zu beiden Zeitpunkten zum Inventurgebiet gehörte (vgl. b3_ecke.DOP=1)';


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.perm2017; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.perm2017 IS 'Permanente Trakteckenmarkierung bei Kohlenstoffinventur (CI2017)';


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.perm2022; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.perm2022 IS 'Permanente Trakteckenmarkierung bei BWI2022 (2021-2023)';


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.nutzart; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.nutzart IS 'Nutzungsart bei Kohlenstoffinventur CI2017';


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.natwg_wlt; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.natwg_wlt IS 'natürliche Waldgesellschaft für Bestimmung des Waldlebensraumtyps bei Vorgängerinventur 2012';


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_wie; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_wie IS 'Wie wurde der Waldlebensraumtyp (WLT_V) ermittelt?, Quelle [EW-Archiv].[bwineu_20151214].[dbo].[v3v_ecke_feld].[WLT_wie]';


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_vk; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_vk IS 'Waldlebensraumtyp lt. Vorklärung bei Vorgängerinventur (BWI 2012); (Stand Erhebungsdatenbank 14.12.2015), Quelle [EW-Archiv].[bwineu_20151214].[dbo].[b3f_ecke_vorkl].[WLT_V]';


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_vk_wie; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_vk_wie IS 'Wie wurde der Waldlebensraumtyp lt. Vorklärung (WLT_Vk_V) ermittelt?, Quelle [EW-Archiv].[bwineu_20151214].[dbo].[b3f_ecke_vorkl].[WLT_WieV]';


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_f; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_f IS 'Für Hochrechnungen verwendeter Waldlebensraumtyp bei Vorgängerinventur 2012, Felderhebung mit nachträgl. Korrekturen, Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLT_F (hergeleitet von Franz Kroiher)';


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_f_wie; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_f_wie IS 'Wie wurde der für Hochrechnungen verwendete Waldlebensraumtyp (WLT_F_V) ermittelt?, Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLT_F_Wie (hergeleitet von Franz Kroiher)';


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_w; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_w IS 'Waldlebensraumtyp, ursprünglich im Feld in Baden-Württemberg bei Vorgängerinventur (BWI 2012) ermittelt, Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLT_W (gesichert von Franz Kroiher)';


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_w_wie; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_w_wie IS 'Wie wurde der Waldlebensraumtyp ursprünglich in Baden-Württemberg (WLT_W_V) ermittelt?, Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLT_W_Wie (gesichert von Franz Kroiher)';


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_a; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_a IS 'Waldlebensraumtyp der Vorgängerinventur (BWI 2012), lt. reinem WLT-Algorithmusentscheid, Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLT (hergeleitet von Franz Kroiher)';


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_listea; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_listea IS 'WLT-Algorithmus: mögliche Waldlebensraumtypen nach Schritt A (Bestockungsanteile), ACHTUNG: teilweise wurde später x3_natWG.WLTListe reduziert; Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLTListeA (hergeleitet von Franz Kroiher)';


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_listeb; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_listeb IS 'WLT-Algorithmus: mögliche Waldlebensraumtypen nach Schritt B (mit Hilfsgrößen), ACHTUNG: teilweise wurde später x3_natWG.WLTListe reduziert; Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLTListeA (hergeleitet von Franz Kroiher)';


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN bv_ecke.wlt_listec; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.bv_ecke.wlt_listec IS 'WLT-Algorithmus: mögliche Waldlebensraumtypen nach Schritt C (ggf. notwendige Zusatzmerkmale, multipler Vergleich), ACHTUNG: teilweise wurde später x3_natWG.WLTListe reduziert; Quelle: [VDBWO01-EW\HR17].bwi.dat.b3_wlt.WLTListeC (hergeleitet von Franz Kroiher)';


--
-- TOC entry 222 (class 1259 OID 16469)
-- Name: getHeaders; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api."getHeaders" AS
 SELECT ((current_setting('request.headers'::text, true))::json ->> 'user-agent'::text) AS user_agent,
    ((current_setting('request.jwt.claims'::text, true))::json ->> 'email'::text) AS email,
    (current_setting('request.headers'::text, true))::json AS all_headers,
    CURRENT_USER AS "current_user";


ALTER TABLE api."getHeaders" OWNER TO postgres;

--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 222
-- Name: VIEW "getHeaders"; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON VIEW api."getHeaders" IS 'Get the headers of the request';


--
-- TOC entry 223 (class 1259 OID 16473)
-- Name: my_roles; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.my_roles AS
 WITH RECURSIVE cte AS (
         SELECT pg_roles.oid
           FROM pg_roles
          WHERE (pg_roles.rolname = CURRENT_USER)
        UNION ALL
         SELECT m.roleid
           FROM (cte cte_1
             JOIN pg_auth_members m ON ((m.member = cte_1.oid)))
        )
 SELECT ((cte.oid)::regrole)::text AS roles
   FROM cte;


ALTER TABLE api.my_roles OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16478)
-- Name: my_schemata; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.my_schemata AS
 SELECT schemata.schema_name
   FROM information_schema.schemata
  WHERE ((schemata.schema_name)::name <> ALL (ARRAY['pg_catalog'::name, 'public'::name, 'information_schema'::name]));


ALTER TABLE api.my_schemata OWNER TO postgres;

--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 224
-- Name: VIEW my_schemata; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON VIEW api.my_schemata IS 'Liste alle Schemata für den aktuellen Benutzer';


--
-- TOC entry 225 (class 1259 OID 16482)
-- Name: testtabelle; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.testtabelle (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    telefon character varying(25)
);


ALTER TABLE api.testtabelle OWNER TO postgres;

--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE testtabelle; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON TABLE api.testtabelle IS 'Entities summary

Entities description that
spans
multiple lines';


--
-- TOC entry 226 (class 1259 OID 16485)
-- Name: tokentest; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.tokentest (
    token text DEFAULT 'token'::text NOT NULL,
    tokendata text NOT NULL
);


ALTER TABLE api.tokentest OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16491)
-- Name: x3_ba; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.x3_ba (
    icode smallint NOT NULL,
    acode character(3),
    kurzd character varying(25),
    kurze character varying(25),
    langd character varying(100),
    lange character varying(100),
    sort smallint,
    farbe integer,
    zu_1 smallint,
    zu_2 smallint,
    zu_3 smallint,
    bfh_bemerkung character varying(255),
    konv_ba2_ba3 smallint,
    autokonv_ba2_ba3 smallint,
    gattung character varying(20),
    art character varying(50),
    bagr character(3),
    ba_str character(3),
    ba_tarif character(4),
    ba_ekh character(3),
    ba_ln character(1),
    ba_bwi1 character(3),
    zu_2k smallint,
    zu_2l smallint,
    zu_ba1 smallint,
    zu_ba2 smallint,
    zu_baeu smallint,
    zu_bastf smallint,
    zu_bafba smallint,
    zu_babwi smallint,
    zu_babwib smallint,
    zu_babwic smallint,
    zu_bastammhoehe smallint,
    zu_bawse smallint,
    zu_bawehamdf smallint,
    zu_bawehamw smallint,
    zu_babdat20 smallint,
    zu_baln smallint,
    konv_ba1_ba2 smallint,
    bart_bze character(3),
    bart_bze_genau character(3)
);


ALTER TABLE api.x3_ba OWNER TO postgres;

--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE x3_ba; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON TABLE api.x3_ba IS 'CodeBWI4: Baumart';


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.icode; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.icode IS 'Numerische Codierung';


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.acode; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.acode IS 'Alphanumerische Codierung';


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.kurzd; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.kurzd IS 'Kurzbezeichnung (deutsch)';


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.kurze; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.kurze IS 'Kurzbezeichnung (englisch)';


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.langd; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.langd IS 'Langbezeichnung (deutsch)';


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.lange; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.lange IS 'Langbezeichnung (englisch)';


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.sort; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.sort IS 'Sortierfolge in PopUp-Listen oder bei Ausgabe (wenn leer wie Icode)';


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.farbe; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.farbe IS 'Farbnummer';


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_1; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_1 IS 'Zugehörigkeit zu Inventur 2001/2002 (Null oder 0=nein, 1=ja), Beachte Zu_1 galt anfangs für BWI1 (1987-1989), nun aber für die Vor-Vorgängerinventur BWI2 (2001/2002)';


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_2; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_2 IS 'Zugehörigkeit zu Inventur 2011/2012  (Null oder 0=nein, 1=ja), Beachte Zu_2 galt anfangs für BWI2 (2001/2002), nun aber für die Vorgängerinventur BWI3 (2011/2012)';


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_3; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_3 IS 'Zugehörigkeit zu Inventur 2021/2022  (Null oder 0=nein, 1=ja), Beachte Zu_3 galt anfangs für BWI3 (2011/2012), nun aber für die aktuelle Inventur BWI4 (2021/2022)';


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.bfh_bemerkung; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.bfh_bemerkung IS 'Bemerkung der BFH';


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.konv_ba2_ba3; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.konv_ba2_ba3 IS 'Konvertierung zu BWI3-Baumartenschlüssel, ohne unzulässige Schlüssel (x3_Ba.Icode mit Zu_3=1)';


--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.autokonv_ba2_ba3; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.autokonv_ba2_ba3 IS 'Automatische Konvertierung zu BWI3-Baumartenschlüssel, inkl. unzulässiger Werte (x3_Ba.Icode mit Zu_3=1)';


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.gattung; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.gattung IS 'FEHLT: Langbezeichnung für x3_ba.gattung';


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.art; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.art IS 'FEHLT: Langbezeichnung für x3_ba.art';


--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.bagr; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.bagr IS 'Baumartengruppierung, Standard für BWI-Auswertungen (alphanumerische Codierung analog';


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.ba_str; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.ba_str IS 'FEHLT: Langbezeichnung für x3_ba.ba_str';


--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.ba_tarif; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.ba_tarif IS 'FEHLT: Langbezeichnung für x3_ba.ba_tarif';


--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.ba_ekh; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.ba_ekh IS 'FEHLT: Langbezeichnung für x3_ba.ba_ekh';


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.ba_ln; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.ba_ln IS 'FEHLT: Langbezeichnung für x3_ba.ba_ln';


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.ba_bwi1; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.ba_bwi1 IS 'FEHLT: Langbezeichnung für x3_ba.ba_bwi1';


--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_2k; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_2k IS 'Zugehörigkeit zu Inventur 2, kurze Liste (0=nein, 1=ja)';


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_2l; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_2l IS 'Zugehörigkeit zu Inventur 2, lange Liste (0=nein, 1=ja)';


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_ba1; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_ba1 IS 'FEHLT: Langbezeichnung für x3_ba.zu_ba1';


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_ba2; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_ba2 IS 'FEHLT: Langbezeichnung für x3_ba.zu_ba2';


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_baeu; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_baeu IS 'FEHLT: Langbezeichnung für x3_ba.zu_baeu';


--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_bastf; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_bastf IS 'FEHLT: Langbezeichnung für x3_ba.zu_bastf';


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_bafba; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_bafba IS 'FEHLT: Langbezeichnung für x3_ba.zu_bafba';


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_babwi; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_babwi IS 'FEHLT: Langbezeichnung für x3_ba.zu_babwi';


--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_babwib; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_babwib IS 'FEHLT: Langbezeichnung für x3_ba.zu_babwib';


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_babwic; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_babwic IS 'FEHLT: Langbezeichnung für x3_ba.zu_babwic';


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_bastammhoehe; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_bastammhoehe IS 'FEHLT: Langbezeichnung für x3_ba.zu_bastammhoehe';


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_bawse; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_bawse IS 'FEHLT: Langbezeichnung für x3_ba.zu_bawse';


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_bawehamdf; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_bawehamdf IS 'FEHLT: Langbezeichnung für x3_ba.zu_bawehamdf';


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_bawehamw; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_bawehamw IS 'FEHLT: Langbezeichnung für x3_ba.zu_bawehamw';


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_babdat20; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_babdat20 IS 'FEHLT: Langbezeichnung für x3_ba.zu_babdat20';


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.zu_baln; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.zu_baln IS 'FEHLT: Langbezeichnung für x3_ba.zu_baln';


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.konv_ba1_ba2; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.konv_ba1_ba2 IS 'FEHLT: Langbezeichnung für x3_ba.konv_ba1_ba2';


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.bart_bze; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.bart_bze IS 'FEHLT: Langbezeichnung für x3_ba.bart_bze';


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN x3_ba.bart_bze_genau; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON COLUMN api.x3_ba.bart_bze_genau IS 'FEHLT: Langbezeichnung für x3_ba.bart_bze_genau';


--
-- TOC entry 228 (class 1259 OID 16496)
-- Name: users; Type: TABLE; Schema: basic_auth; Owner: postgres
--

CREATE TABLE basic_auth.users (
    email text NOT NULL,
    pass text NOT NULL,
    role name NOT NULL,
    "group" name DEFAULT 'ND'::name NOT NULL,
    CONSTRAINT users_email_check CHECK ((email ~* '^.+@.+\..+$'::text)),
    CONSTRAINT users_pass_check CHECK ((length(pass) < 512)),
    CONSTRAINT users_role_check CHECK ((length((role)::text) < 512))
);


ALTER TABLE basic_auth.users OWNER TO postgres;

--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN users."group"; Type: COMMENT; Schema: basic_auth; Owner: postgres
--

COMMENT ON COLUMN basic_auth.users."group" IS 'Gruppe (ND, AT, KT, BIL oder LIL)';


--
-- TOC entry 260 (class 1259 OID 16922)
-- Name: b3_ecke; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.b3_ecke (
    dathoheit character(2),
    datverwend character varying(15),
    tnr integer NOT NULL,
    enr smallint NOT NULL,
    vbl smallint,
    bl smallint NOT NULL,
    aufnbl smallint NOT NULL,
    soll_rechtse integer,
    soll_hoche integer,
    soll_x_gk2 integer,
    soll_y_gk2 integer,
    soll_x_gk3 integer,
    soll_y_gk3 integer,
    soll_x_gk4 integer,
    soll_y_gk4 integer,
    soll_x_gk5 integer,
    soll_y_gk5 integer,
    soll_x_wgs84 double precision,
    soll_y_wgs84 double precision,
    soll_x_32n double precision,
    soll_y_32n double precision,
    soll_x_33n double precision,
    soll_y_33n double precision,
    wg smallint,
    wb smallint,
    hoenn smallint,
    ags character varying(8),
    atkis smallint,
    dop smallint,
    dlm smallint,
    id integer NOT NULL
);


ALTER TABLE bwi_de_001_dev.b3_ecke OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 16960)
-- Name: b3_ecke_id_seq; Type: SEQUENCE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE SEQUENCE bwi_de_001_dev.b3_ecke_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bwi_de_001_dev.b3_ecke_id_seq OWNER TO postgres;

--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 266
-- Name: b3_ecke_id_seq; Type: SEQUENCE OWNED BY; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER SEQUENCE bwi_de_001_dev.b3_ecke_id_seq OWNED BY bwi_de_001_dev.b3_ecke.id;


--
-- TOC entry 261 (class 1259 OID 16925)
-- Name: b3_tnr; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.b3_tnr (
    dathoheit character(2),
    datverwend character varying(15),
    tnr integer NOT NULL,
    soll_re smallint,
    soll_dre smallint,
    soll_ho smallint,
    soll_dho smallint,
    soll_rechtst integer,
    soll_hocht integer,
    topkar smallint,
    aufnbl smallint NOT NULL,
    standardbl smallint,
    laender character varying(10),
    netz smallint,
    netz64 smallint,
    ktg smallint,
    id integer NOT NULL
);


ALTER TABLE bwi_de_001_dev.b3_tnr OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 16952)
-- Name: b3_tnr_id_seq; Type: SEQUENCE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE SEQUENCE bwi_de_001_dev.b3_tnr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bwi_de_001_dev.b3_tnr_id_seq OWNER TO postgres;

--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 265
-- Name: b3_tnr_id_seq; Type: SEQUENCE OWNED BY; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER SEQUENCE bwi_de_001_dev.b3_tnr_id_seq OWNED BY bwi_de_001_dev.b3_tnr.id;


--
-- TOC entry 262 (class 1259 OID 16928)
-- Name: b3v_wzp; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.b3v_wzp (
    dathoheit character(2),
    datverwend character varying(15),
    tnr integer NOT NULL,
    enr smallint NOT NULL,
    vbl smallint,
    bnr smallint NOT NULL,
    perm smallint,
    pk smallint,
    azi smallint,
    hori smallint,
    ba smallint,
    m_bhd smallint,
    m_hbhd smallint,
    m_do smallint,
    m_hdo smallint,
    m_hoe smallint,
    m_sthoe smallint,
    mpos_azi smallint,
    mpos_hori smallint,
    al_ba smallint,
    kal smallint,
    kh smallint,
    kst smallint,
    bkl smallint,
    ast smallint,
    ast_hoe smallint,
    ges_hoe smallint,
    bz smallint,
    bs smallint,
    tot smallint,
    jschael smallint,
    aeschael smallint,
    ruecke smallint,
    pilz smallint,
    harz smallint,
    kaefer smallint,
    sstamm smallint,
    faulkon smallint,
    hoehle smallint,
    bizarr smallint,
    uralt smallint,
    horst smallint,
    mbiotop smallint,
    wz1 smallint,
    wz2 smallint,
    wz3 smallint,
    do_geraet smallint,
    k double precision,
    id integer NOT NULL
);


ALTER TABLE bwi_de_001_dev.b3v_wzp OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 16968)
-- Name: b3v_wzp_id_seq; Type: SEQUENCE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE SEQUENCE bwi_de_001_dev.b3v_wzp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bwi_de_001_dev.b3v_wzp_id_seq OWNER TO postgres;

--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 267
-- Name: b3v_wzp_id_seq; Type: SEQUENCE OWNED BY; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER SEQUENCE bwi_de_001_dev.b3v_wzp_id_seq OWNED BY bwi_de_001_dev.b3v_wzp.id;


--
-- TOC entry 272 (class 1259 OID 17029)
-- Name: bv_gps; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.bv_gps (
    dathoheit character(2),
    datverwend character varying(15),
    tnr integer NOT NULL,
    enr smallint NOT NULL,
    vbl smallint,
    k2_rw double precision,
    k2_hw double precision,
    k3_rw double precision,
    k3_hw double precision,
    rw_med double precision,
    hw_med double precision,
    lat_med double precision,
    lon_med double precision,
    lat_mean double precision,
    lon_mean double precision,
    anzahlmessungen smallint,
    hdop double precision,
    maxhdop double precision,
    numsat double precision,
    minnumsat double precision,
    rtcmalter double precision,
    hilfspunkt smallint NOT NULL,
    utcstartzeit character varying(20),
    utcstopzeit character varying(20),
    stddev double precision,
    gnss_qualitaet smallint,
    anzahlverwertmessungen smallint
);


ALTER TABLE bwi_de_001_dev.bv_gps OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 17021)
-- Name: schreibtest; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.schreibtest (
    id integer NOT NULL,
    inhalt text
);


ALTER TABLE bwi_de_001_dev.schreibtest OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 17020)
-- Name: schreibtest_id_seq; Type: SEQUENCE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE SEQUENCE bwi_de_001_dev.schreibtest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bwi_de_001_dev.schreibtest_id_seq OWNER TO postgres;

--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 270
-- Name: schreibtest_id_seq; Type: SEQUENCE OWNED BY; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER SEQUENCE bwi_de_001_dev.schreibtest_id_seq OWNED BY bwi_de_001_dev.schreibtest.id;


--
-- TOC entry 264 (class 1259 OID 16942)
-- Name: version; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.version (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE bwi_de_001_dev.version OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 16941)
-- Name: version_id_seq; Type: SEQUENCE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE SEQUENCE bwi_de_001_dev.version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bwi_de_001_dev.version_id_seq OWNER TO postgres;

--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 263
-- Name: version_id_seq; Type: SEQUENCE OWNED BY; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER SEQUENCE bwi_de_001_dev.version_id_seq OWNED BY bwi_de_001_dev.version.id;


--
-- TOC entry 268 (class 1259 OID 16993)
-- Name: x3_ba; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.x3_ba (
    icode smallint NOT NULL,
    acode character(3),
    kurzd character varying(25),
    kurze character varying(25),
    langd character varying(100),
    lange character varying(100),
    sort smallint,
    farbe integer,
    zu_1 smallint,
    zu_2 smallint,
    zu_3 smallint,
    bfh_bemerkung character varying(255),
    konv_ba2_ba3 smallint,
    autokonv_ba2_ba3 smallint,
    gattung character varying(20),
    art character varying(50),
    bagr character(3),
    ba_str character(3),
    ba_tarif character(4),
    ba_ekh character(3),
    ba_ln character(1),
    ba_bwi1 character(3),
    zu_2k smallint,
    zu_2l smallint,
    zu_ba1 smallint,
    zu_ba2 smallint,
    zu_baeu smallint,
    zu_bastf smallint,
    zu_bafba smallint,
    zu_babwi smallint,
    zu_babwib smallint,
    zu_babwic smallint,
    zu_bastammhoehe smallint,
    zu_bawse smallint,
    zu_bawehamdf smallint,
    zu_bawehamw smallint,
    zu_babdat20 smallint,
    zu_baln smallint,
    konv_ba1_ba2 smallint,
    bart_bze character(3),
    bart_bze_genau character(3)
);


ALTER TABLE bwi_de_001_dev.x3_ba OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 17008)
-- Name: x3_bl; Type: TABLE; Schema: bwi_de_001_dev; Owner: postgres
--

CREATE TABLE bwi_de_001_dev.x3_bl (
    icode smallint NOT NULL,
    acode character(3),
    kurzd character varying(25),
    kurze character varying(25),
    langd character varying(100),
    lange character varying(100),
    sort smallint,
    farbe integer,
    zu_1 smallint,
    zu_2 smallint,
    zu_3 smallint,
    zu_bl_aufn smallint NOT NULL,
    wie_blregionen character(3),
    wie_vbl character varying(5),
    grklvar character(1),
    gformvar character(1),
    bavar character(1),
    egvar character(1),
    lswfkt smallint,
    weg smallint,
    boden smallint,
    st_quelle character varying(10),
    st_b character varying(10),
    st_ks_hs character varying(10),
    st_ks_fs character varying(10),
    st_n character varying(10),
    st_nz character varying(10),
    st_wh_fg character varying(10),
    st_wh_fz character varying(10),
    st_wh_e character varying(10),
    st_var character varying(14),
    ez1 character varying(10),
    ez2 character varying(10),
    ez3 character varying(10),
    ez4 character varying(10),
    ez5 character varying(10),
    ez6 character varying(10),
    ez7 character varying(10),
    ez8 character varying(10),
    ez9 character varying(10),
    wz1 character varying(10),
    wz2 character varying(10),
    wz3 character varying(10),
    fakwzp_sthoehe smallint,
    fakwzp_mpos smallint,
    region smallint
);


ALTER TABLE bwi_de_001_dev.x3_bl OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 17091)
-- Name: archiv_b3_ecke; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.archiv_b3_ecke (
    ledituser character varying,
    ledittime timestamp without time zone NOT NULL,
    dathoheit character varying,
    datverwend character varying,
    refkey integer,
    tnr integer NOT NULL,
    enr smallint NOT NULL,
    vbl smallint,
    bl smallint NOT NULL,
    aufnbl smallint NOT NULL,
    soll_rechtse integer,
    soll_hoche integer,
    soll_x_gk2 integer,
    soll_y_gk2 integer,
    soll_x_gk3 integer,
    soll_y_gk3 integer,
    soll_x_gk4 integer,
    soll_y_gk4 integer,
    soll_x_gk5 integer,
    soll_y_gk5 integer,
    soll_x_wgs84 double precision,
    soll_y_wgs84 double precision,
    soll_x_32n double precision,
    soll_y_32n double precision,
    soll_x_33n double precision,
    soll_y_33n double precision,
    wg smallint,
    wb smallint,
    hoenn smallint,
    ags character varying,
    atkis smallint,
    dop smallint,
    dlm smallint
);


ALTER TABLE bwi_de_002_dev.archiv_b3_ecke OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 17056)
-- Name: archiv_b3_tnr; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.archiv_b3_tnr (
    ledituser character varying DEFAULT CURRENT_USER NOT NULL,
    ledittime timestamp without time zone DEFAULT now() NOT NULL,
    dathoheit character varying,
    datverwend character varying,
    tnr integer NOT NULL,
    soll_re smallint,
    soll_dre smallint,
    soll_ho smallint,
    soll_dho smallint,
    soll_rechtst integer,
    soll_hocht integer,
    topkar smallint,
    aufnbl smallint NOT NULL,
    standardbl smallint,
    laender character varying,
    netz smallint,
    netz64 smallint,
    ktg smallint
);


ALTER TABLE bwi_de_002_dev.archiv_b3_tnr OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 17076)
-- Name: b3_ecke; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.b3_ecke (
    ledituser character varying,
    ledittime timestamp without time zone NOT NULL,
    dathoheit character varying,
    datverwend character varying,
    refkey integer NOT NULL,
    tnr integer NOT NULL,
    enr smallint NOT NULL,
    vbl smallint,
    bl smallint NOT NULL,
    aufnbl smallint NOT NULL,
    soll_rechtse integer,
    soll_hoche integer,
    soll_x_gk2 integer,
    soll_y_gk2 integer,
    soll_x_gk3 integer,
    soll_y_gk3 integer,
    soll_x_gk4 integer,
    soll_y_gk4 integer,
    soll_x_gk5 integer,
    soll_y_gk5 integer,
    soll_x_wgs84 double precision,
    soll_y_wgs84 double precision,
    soll_x_32n double precision,
    soll_y_32n double precision,
    soll_x_33n double precision,
    soll_y_33n double precision,
    wg smallint,
    wb smallint,
    hoenn smallint,
    ags character varying,
    atkis smallint,
    dop smallint,
    dlm smallint
);


ALTER TABLE bwi_de_002_dev.b3_ecke OWNER TO postgres;

--
-- TOC entry 3955 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE b3_ecke; Type: COMMENT; Schema: bwi_de_002_dev; Owner: postgres
--

COMMENT ON TABLE bwi_de_002_dev.b3_ecke IS 'Initialisierungsdaten für Ecke
b3_ecke';


--
-- TOC entry 275 (class 1259 OID 17075)
-- Name: b3_ecke_refkey_seq; Type: SEQUENCE; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE bwi_de_002_dev.b3_ecke ALTER COLUMN refkey ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME bwi_de_002_dev.b3_ecke_refkey_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 273 (class 1259 OID 17039)
-- Name: b3_tnr; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.b3_tnr (
    ledituser character varying DEFAULT CURRENT_USER NOT NULL,
    ledittime timestamp without time zone DEFAULT now() NOT NULL,
    dathoheit character varying,
    datverwend character varying,
    tnr integer NOT NULL,
    soll_re smallint,
    soll_dre smallint,
    soll_ho smallint,
    soll_dho smallint,
    soll_rechtst integer,
    soll_hocht integer,
    topkar smallint,
    aufnbl smallint NOT NULL,
    standardbl smallint,
    laender character varying,
    netz smallint,
    netz64 smallint,
    ktg smallint
);


ALTER TABLE bwi_de_002_dev.b3_tnr OWNER TO postgres;

--
-- TOC entry 3984 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE b3_tnr; Type: COMMENT; Schema: bwi_de_002_dev; Owner: postgres
--

COMMENT ON TABLE bwi_de_002_dev.b3_tnr IS 'Initialisierungsdaten für Trakt
b3_tnr';


--
-- TOC entry 285 (class 1259 OID 21498)
-- Name: b3_tnr_test; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.b3_tnr_test (
    ledituser character varying DEFAULT CURRENT_USER NOT NULL,
    ledittime timestamp without time zone DEFAULT now() NOT NULL,
    dathoheit character varying,
    datverwend character varying,
    tnr integer NOT NULL,
    test smallint
);


ALTER TABLE bwi_de_002_dev.b3_tnr_test OWNER TO postgres;

--
-- TOC entry 4000 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE b3_tnr_test; Type: COMMENT; Schema: bwi_de_002_dev; Owner: postgres
--

COMMENT ON TABLE bwi_de_002_dev.b3_tnr_test IS 'testtabelle für Trakt
b3_tnr_test';


--
-- TOC entry 284 (class 1259 OID 21486)
-- Name: b3_tnr_work; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.b3_tnr_work (
    ledituser character varying DEFAULT CURRENT_USER NOT NULL,
    ledittime timestamp without time zone DEFAULT now() NOT NULL,
    dathoheit character varying,
    datverwend character varying,
    tnr integer NOT NULL,
    at name,
    workflow smallint DEFAULT 1 NOT NULL
);


ALTER TABLE bwi_de_002_dev.b3_tnr_work OWNER TO postgres;

--
-- TOC entry 4003 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE b3_tnr_work; Type: COMMENT; Schema: bwi_de_002_dev; Owner: postgres
--

COMMENT ON TABLE bwi_de_002_dev.b3_tnr_work IS 'Workflowdaten für Trakt
b3_tnr_work';


--
-- TOC entry 4004 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN b3_tnr_work.at; Type: COMMENT; Schema: bwi_de_002_dev; Owner: postgres
--

COMMENT ON COLUMN bwi_de_002_dev.b3_tnr_work.at IS 'Aufnahmetrupp';


--
-- TOC entry 4005 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN b3_tnr_work.workflow; Type: COMMENT; Schema: bwi_de_002_dev; Owner: postgres
--

COMMENT ON COLUMN bwi_de_002_dev.b3_tnr_work.workflow IS 'Workflow Status';


--
-- TOC entry 288 (class 1259 OID 21562)
-- Name: b3v_wzp; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.b3v_wzp (
    ledituser character varying(50) NOT NULL,
    ledittime timestamp(0) without time zone NOT NULL,
    dathoheit character(2) NOT NULL,
    datverwend character varying(15) NOT NULL,
    tnr integer NOT NULL,
    enr smallint NOT NULL,
    vbl smallint,
    bnr smallint NOT NULL,
    perm smallint,
    pk smallint,
    azi smallint,
    hori smallint,
    ba smallint,
    m_bhd smallint,
    m_hbhd smallint,
    m_do smallint,
    m_hdo smallint,
    m_hoe smallint,
    m_sthoe smallint,
    mpos_azi smallint,
    mpos_hori smallint,
    al_ba smallint,
    kal smallint,
    kh smallint,
    kst smallint,
    bkl smallint,
    ast smallint,
    ast_hoe smallint,
    ges_hoe smallint,
    bz smallint,
    bs smallint,
    tot smallint,
    jschael smallint,
    aeschael smallint,
    ruecke smallint,
    pilz smallint,
    harz smallint,
    kaefer smallint,
    sstamm smallint,
    faulkon smallint,
    hoehle smallint,
    bizarr smallint,
    uralt smallint,
    horst smallint,
    mbiotop smallint,
    wz1 smallint,
    wz2 smallint,
    wz3 smallint,
    do_geraet smallint,
    k double precision,
    refkey integer NOT NULL
);


ALTER TABLE bwi_de_002_dev.b3v_wzp OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 21565)
-- Name: b3v_wzp_refkey_seq; Type: SEQUENCE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE SEQUENCE bwi_de_002_dev.b3v_wzp_refkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bwi_de_002_dev.b3v_wzp_refkey_seq OWNER TO postgres;

--
-- TOC entry 4008 (class 0 OID 0)
-- Dependencies: 289
-- Name: b3v_wzp_refkey_seq; Type: SEQUENCE OWNED BY; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER SEQUENCE bwi_de_002_dev.b3v_wzp_refkey_seq OWNED BY bwi_de_002_dev.b3v_wzp.refkey;


--
-- TOC entry 287 (class 1259 OID 21555)
-- Name: x_workflow_perm; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.x_workflow_perm (
    icode smallint NOT NULL,
    kurzd character varying(25),
    zustaendig_ist name
);


ALTER TABLE bwi_de_002_dev.x_workflow_perm OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 21614)
-- Name: z3_col; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.z3_col (
    fddbname character varying(20),
    fdtabname character varying(50),
    fdvirttabname character varying(50),
    fdcolname character varying(50),
    fdvirtcolname character varying(50),
    fdnr smallint,
    fdkurzd character varying(120),
    fdlangd character varying(120),
    fdhinweisd character varying,
    fdkurze character varying(120),
    fdlange character varying(120),
    fdhinweise character varying,
    fdhid integer,
    fdls smallint,
    fdpflicht smallint,
    fdeindeutigkeit smallint,
    fdskalartyp character(1),
    fdart character(1),
    fdcodedb character varying(20),
    fdcodetab character varying(50),
    fdcodecol character varying(20),
    fdcodefilter character varying(80),
    fdintmass character varying(50),
    fdextmass character varying(10),
    fddez smallint,
    fdvon_err double precision,
    fdbis_err double precision,
    fdvon_warn double precision,
    fdbis_warn double precision,
    fderr integer,
    fdwarn integer,
    fderrmissing integer,
    fdfiltermissing character varying(150),
    fdok smallint,
    fdokbemerkung character varying(255),
    maskname character varying(6),
    maskansicht character varying(20),
    maskblock character varying(50),
    masksort smallint,
    maskchange timestamp without time zone,
    "Change" timestamp without time zone,
    maskbinaer smallint,
    fddefault character varying(10),
    errcolnr smallint
);


ALTER TABLE bwi_de_002_dev.z3_col OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 21619)
-- Name: z3_tab; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.z3_tab (
    tbdbname character varying(20),
    tbvirttabname character varying(50),
    tbtabname character varying(50),
    tbfilter character varying(50),
    tbls character varying(10),
    tblangd character varying(120),
    tbhinweisd character varying(255),
    tblange character varying(120),
    tbhinweise character varying(255),
    tbsort smallint,
    tbart character(1),
    tbmode character varying(4),
    tbinit smallint,
    tbkat character(1),
    tbobjekt character varying(20),
    tbsqlstring character varying,
    tbok smallint,
    tbokbemerkung character varying(255),
    tbnr integer,
    tbhid integer,
    tbokenn character(3)
);


ALTER TABLE bwi_de_002_dev.z3_tab OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 17117)
-- Name: z3_tab_safe; Type: TABLE; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TABLE bwi_de_002_dev.z3_tab_safe (
    tbtabname character varying(50) NOT NULL,
    tbfilter character varying(50),
    tbls character varying(10),
    tblangd character varying(120),
    tbhinweisd character varying(255),
    tblange character varying(120),
    tbhinweise character varying(255),
    tbsort smallint,
    tbart character(1),
    tbmode character varying(4),
    tbinit smallint,
    tbkat character(1),
    tbobjekt character varying(20),
    tbsqlstring character varying,
    tbok smallint,
    tbokbemerkung character varying(255),
    tbnr integer,
    tbhid integer,
    tbokenn character(3)
);


ALTER TABLE bwi_de_002_dev.z3_tab_safe OWNER TO postgres;

--
-- TOC entry 3507 (class 2604 OID 16961)
-- Name: b3_ecke id; Type: DEFAULT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_ecke ALTER COLUMN id SET DEFAULT nextval('bwi_de_001_dev.b3_ecke_id_seq'::regclass);


--
-- TOC entry 3508 (class 2604 OID 16953)
-- Name: b3_tnr id; Type: DEFAULT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_tnr ALTER COLUMN id SET DEFAULT nextval('bwi_de_001_dev.b3_tnr_id_seq'::regclass);


--
-- TOC entry 3509 (class 2604 OID 16969)
-- Name: b3v_wzp id; Type: DEFAULT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3v_wzp ALTER COLUMN id SET DEFAULT nextval('bwi_de_001_dev.b3v_wzp_id_seq'::regclass);


--
-- TOC entry 3511 (class 2604 OID 17024)
-- Name: schreibtest id; Type: DEFAULT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.schreibtest ALTER COLUMN id SET DEFAULT nextval('bwi_de_001_dev.schreibtest_id_seq'::regclass);


--
-- TOC entry 3510 (class 2604 OID 16945)
-- Name: version id; Type: DEFAULT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.version ALTER COLUMN id SET DEFAULT nextval('bwi_de_001_dev.version_id_seq'::regclass);


--
-- TOC entry 3523 (class 2604 OID 21566)
-- Name: b3v_wzp refkey; Type: DEFAULT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3v_wzp ALTER COLUMN refkey SET DEFAULT nextval('bwi_de_002_dev.b3v_wzp_refkey_seq'::regclass);


--
-- TOC entry 3571 (class 2606 OID 21551)
-- Name: b3_tnr_test b3_tnr_test_pkey; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.b3_tnr_test
    ADD CONSTRAINT b3_tnr_test_pkey PRIMARY KEY (tnr);


--
-- TOC entry 3535 (class 2606 OID 16609)
-- Name: x3_ba icode; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.x3_ba
    ADD CONSTRAINT icode UNIQUE (icode);


--
-- TOC entry 3533 (class 2606 OID 16611)
-- Name: testtabelle id; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.testtabelle
    ADD CONSTRAINT id PRIMARY KEY (id);


--
-- TOC entry 3529 (class 2606 OID 16613)
-- Name: bv_ecke tnrenr_generated; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.bv_ecke
    ADD CONSTRAINT tnrenr_generated UNIQUE (tnrenr_generated);


--
-- TOC entry 3527 (class 2606 OID 16615)
-- Name: aaa_test_baeume tnrenrbnrcreated_at; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.aaa_test_baeume
    ADD CONSTRAINT tnrenrbnrcreated_at UNIQUE (tnr, enr, bnr, created_at);


--
-- TOC entry 3531 (class 2606 OID 16617)
-- Name: bv_ecke tnrenrdathoheit; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.bv_ecke
    ADD CONSTRAINT tnrenrdathoheit UNIQUE (tnr, enr, dathoheit);


--
-- TOC entry 3537 (class 2606 OID 16619)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: basic_auth; Owner: postgres
--

ALTER TABLE ONLY basic_auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (email);


--
-- TOC entry 3539 (class 2606 OID 16963)
-- Name: b3_ecke b3_ecke_pkey; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_ecke
    ADD CONSTRAINT b3_ecke_pkey PRIMARY KEY (id);


--
-- TOC entry 3541 (class 2606 OID 16987)
-- Name: b3_ecke b3_ecke_tnr_enr_key; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_ecke
    ADD CONSTRAINT b3_ecke_tnr_enr_key UNIQUE (tnr, enr);


--
-- TOC entry 3543 (class 2606 OID 16955)
-- Name: b3_tnr b3_tnr_pkey; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_tnr
    ADD CONSTRAINT b3_tnr_pkey PRIMARY KEY (id);


--
-- TOC entry 3547 (class 2606 OID 16971)
-- Name: b3v_wzp b3v_wzp_pkey; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3v_wzp
    ADD CONSTRAINT b3v_wzp_pkey PRIMARY KEY (id);


--
-- TOC entry 3551 (class 2606 OID 16999)
-- Name: x3_ba icode; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.x3_ba
    ADD CONSTRAINT icode UNIQUE (icode);


--
-- TOC entry 3557 (class 2606 OID 17028)
-- Name: schreibtest schreibtest_pkey; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.schreibtest
    ADD CONSTRAINT schreibtest_pkey PRIMARY KEY (id);


--
-- TOC entry 3545 (class 2606 OID 16978)
-- Name: b3_tnr uk_tnr; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_tnr
    ADD CONSTRAINT uk_tnr UNIQUE (tnr);


--
-- TOC entry 3549 (class 2606 OID 16949)
-- Name: version version_pkey; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (id);


--
-- TOC entry 3553 (class 2606 OID 17002)
-- Name: x3_ba x3_ba_pkey; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.x3_ba
    ADD CONSTRAINT x3_ba_pkey PRIMARY KEY (icode);


--
-- TOC entry 3555 (class 2606 OID 17014)
-- Name: x3_bl x3_bl_pkey; Type: CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.x3_bl
    ADD CONSTRAINT x3_bl_pkey PRIMARY KEY (icode);


--
-- TOC entry 3561 (class 2606 OID 17082)
-- Name: b3_ecke b3_ecke_pkey; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3_ecke
    ADD CONSTRAINT b3_ecke_pkey PRIMARY KEY (refkey);


--
-- TOC entry 3559 (class 2606 OID 17045)
-- Name: b3_tnr b3_tnr_pkey; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3_tnr
    ADD CONSTRAINT b3_tnr_pkey PRIMARY KEY (tnr);


--
-- TOC entry 3569 (class 2606 OID 21506)
-- Name: b3_tnr_test b3_tnr_test_pkey; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3_tnr_test
    ADD CONSTRAINT b3_tnr_test_pkey PRIMARY KEY (tnr);


--
-- TOC entry 3567 (class 2606 OID 21494)
-- Name: b3_tnr_work b3_tnr_work_pkey; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3_tnr_work
    ADD CONSTRAINT b3_tnr_work_pkey PRIMARY KEY (tnr);


--
-- TOC entry 3575 (class 2606 OID 21568)
-- Name: b3v_wzp b3v_wzp_pkey; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3v_wzp
    ADD CONSTRAINT b3v_wzp_pkey PRIMARY KEY (refkey);


--
-- TOC entry 3573 (class 2606 OID 21561)
-- Name: x_workflow_perm pk_x_workflow_perm; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.x_workflow_perm
    ADD CONSTRAINT pk_x_workflow_perm PRIMARY KEY (icode) INCLUDE (icode);


--
-- TOC entry 3563 (class 2606 OID 21574)
-- Name: b3_ecke uk_tnr_enr; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3_ecke
    ADD CONSTRAINT uk_tnr_enr UNIQUE (tnr, enr);


--
-- TOC entry 3565 (class 2606 OID 17124)
-- Name: z3_tab_safe z3_tab_pkey; Type: CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.z3_tab_safe
    ADD CONSTRAINT z3_tab_pkey PRIMARY KEY (tbtabname);


--
-- TOC entry 3524 (class 1259 OID 16674)
-- Name: fki_tnrenr_generated; Type: INDEX; Schema: api; Owner: postgres
--

CREATE INDEX fki_tnrenr_generated ON api.aaa_test_baeume USING btree (tnrenr_generated);


--
-- TOC entry 3525 (class 1259 OID 16675)
-- Name: fki_tnrenrdathoheit_bv_ecke; Type: INDEX; Schema: api; Owner: postgres
--

CREATE INDEX fki_tnrenrdathoheit_bv_ecke ON api.aaa_test_baeume USING btree (tnr, enr, dathoheit);


--
-- TOC entry 3576 (class 1259 OID 21580)
-- Name: fki_k; Type: INDEX; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE INDEX fki_k ON bwi_de_002_dev.b3v_wzp USING btree (tnr, enr);


--
-- TOC entry 3588 (class 2620 OID 16686)
-- Name: aaa_test_baeume_view delete_from_aaa_test_baeume_view; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER delete_from_aaa_test_baeume_view INSTEAD OF DELETE ON api.aaa_test_baeume_view FOR EACH ROW EXECUTE FUNCTION api.delete_from_aaa_test_baeume_view();


--
-- TOC entry 3587 (class 2620 OID 16687)
-- Name: aaa_test_baeume_view insert_into_aaa_test_baeume_view; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER insert_into_aaa_test_baeume_view INSTEAD OF INSERT ON api.aaa_test_baeume_view FOR EACH ROW EXECUTE FUNCTION api.insert_into_aaa_test_baeume_view();


--
-- TOC entry 3586 (class 2620 OID 16688)
-- Name: aaa_test_baeume_view update_aaa_test_baeume_view; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER update_aaa_test_baeume_view INSTEAD OF UPDATE ON api.aaa_test_baeume_view FOR EACH ROW EXECUTE FUNCTION api.update_aaa_test_baeume_view();


--
-- TOC entry 3597 (class 2620 OID 21554)
-- Name: b3_tnr_test update_ledtime; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER update_ledtime BEFORE UPDATE ON api.b3_tnr_test FOR EACH ROW EXECUTE FUNCTION bwi_de_002_dev.update_ledittime_and_ledituser_on_user_task();


--
-- TOC entry 3589 (class 2620 OID 16904)
-- Name: users encrypt_pass; Type: TRIGGER; Schema: basic_auth; Owner: postgres
--

CREATE TRIGGER encrypt_pass BEFORE INSERT OR UPDATE ON basic_auth.users FOR EACH ROW EXECUTE FUNCTION basic_auth.encrypt_pass();


--
-- TOC entry 3590 (class 2620 OID 16690)
-- Name: users ensure_user_role_exists; Type: TRIGGER; Schema: basic_auth; Owner: postgres
--

CREATE CONSTRAINT TRIGGER ensure_user_role_exists AFTER INSERT OR UPDATE ON basic_auth.users NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE FUNCTION basic_auth.check_role_exists();


--
-- TOC entry 3593 (class 2620 OID 17106)
-- Name: b3_ecke archive_old; Type: TRIGGER; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TRIGGER archive_old BEFORE UPDATE ON bwi_de_002_dev.b3_ecke FOR EACH ROW EXECUTE FUNCTION bwi_de_002_dev.b3_ecke_archive_old_at_update();


--
-- TOC entry 3591 (class 2620 OID 17064)
-- Name: b3_tnr archive_old; Type: TRIGGER; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TRIGGER archive_old BEFORE UPDATE ON bwi_de_002_dev.b3_tnr FOR EACH ROW EXECUTE FUNCTION bwi_de_002_dev.b3_tnr_archive_old_at_update();


--
-- TOC entry 3594 (class 2620 OID 17098)
-- Name: b3_ecke update_ledtime; Type: TRIGGER; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TRIGGER update_ledtime BEFORE UPDATE ON bwi_de_002_dev.b3_ecke FOR EACH ROW EXECUTE FUNCTION bwi_de_002_dev.update_ledittime_and_ledituser_on_user_task();


--
-- TOC entry 3592 (class 2620 OID 17055)
-- Name: b3_tnr update_ledtime; Type: TRIGGER; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TRIGGER update_ledtime BEFORE UPDATE ON bwi_de_002_dev.b3_tnr FOR EACH ROW EXECUTE FUNCTION bwi_de_002_dev.update_ledittime_and_ledituser_on_user_task();


--
-- TOC entry 3596 (class 2620 OID 21512)
-- Name: b3_tnr_test update_ledtime; Type: TRIGGER; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TRIGGER update_ledtime BEFORE UPDATE ON bwi_de_002_dev.b3_tnr_test FOR EACH ROW EXECUTE FUNCTION bwi_de_002_dev.update_ledittime_and_ledituser_on_user_task();


--
-- TOC entry 3595 (class 2620 OID 21497)
-- Name: b3_tnr_work update_ledtime; Type: TRIGGER; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE TRIGGER update_ledtime BEFORE UPDATE ON bwi_de_002_dev.b3_tnr_work FOR EACH ROW EXECUTE FUNCTION bwi_de_002_dev.update_ledittime_and_ledituser_on_user_task();


--
-- TOC entry 3577 (class 2606 OID 16692)
-- Name: aaa_test_baeume ba; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.aaa_test_baeume
    ADD CONSTRAINT ba FOREIGN KEY (ba) REFERENCES api.x3_ba(icode);


--
-- TOC entry 3578 (class 2606 OID 16697)
-- Name: aaa_test_baeume tnrenr_generated; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.aaa_test_baeume
    ADD CONSTRAINT tnrenr_generated FOREIGN KEY (tnrenr_generated) REFERENCES api.bv_ecke(tnrenr_generated);


--
-- TOC entry 3579 (class 2606 OID 16702)
-- Name: aaa_test_baeume tnrenrdathoheit_bv_ecke; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.aaa_test_baeume
    ADD CONSTRAINT tnrenrdathoheit_bv_ecke FOREIGN KEY (tnr, enr, dathoheit) REFERENCES api.bv_ecke(tnr, enr, dathoheit);


--
-- TOC entry 4020 (class 0 OID 0)
-- Dependencies: 3579
-- Name: CONSTRAINT tnrenrdathoheit_bv_ecke ON aaa_test_baeume; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON CONSTRAINT tnrenrdathoheit_bv_ecke ON api.aaa_test_baeume IS 'wahrscheinlich nicht nötig wegen RLS-Policy new_write_filter oder nur als alternative Lösung denkbar';


--
-- TOC entry 3580 (class 2606 OID 16979)
-- Name: b3_ecke FK_TNR; Type: FK CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_ecke
    ADD CONSTRAINT "FK_TNR" FOREIGN KEY (tnr) REFERENCES bwi_de_001_dev.b3_tnr(tnr) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3581 (class 2606 OID 17015)
-- Name: b3_ecke b3_ecke_bl_fkey; Type: FK CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3_ecke
    ADD CONSTRAINT b3_ecke_bl_fkey FOREIGN KEY (bl) REFERENCES bwi_de_001_dev.x3_bl(icode);


--
-- TOC entry 3582 (class 2606 OID 17003)
-- Name: b3v_wzp b3v_wzp_ba_fkey; Type: FK CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3v_wzp
    ADD CONSTRAINT b3v_wzp_ba_fkey FOREIGN KEY (ba) REFERENCES bwi_de_001_dev.x3_ba(icode);


--
-- TOC entry 3583 (class 2606 OID 16988)
-- Name: b3v_wzp b3v_wzp_tnr_enr_fkey; Type: FK CONSTRAINT; Schema: bwi_de_001_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_001_dev.b3v_wzp
    ADD CONSTRAINT b3v_wzp_tnr_enr_fkey FOREIGN KEY (tnr, enr) REFERENCES bwi_de_001_dev.b3_ecke(tnr, enr);


--
-- TOC entry 3584 (class 2606 OID 17084)
-- Name: b3_ecke fk_tnr; Type: FK CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3_ecke
    ADD CONSTRAINT fk_tnr FOREIGN KEY (tnr) REFERENCES bwi_de_002_dev.b3_tnr(tnr) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3585 (class 2606 OID 21575)
-- Name: b3v_wzp fk_tnr_enr_ecke; Type: FK CONSTRAINT; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE ONLY bwi_de_002_dev.b3v_wzp
    ADD CONSTRAINT fk_tnr_enr_ecke FOREIGN KEY (tnr, enr) REFERENCES bwi_de_002_dev.b3_ecke(tnr, enr) NOT VALID;


--
-- TOC entry 3741 (class 0 OID 16454)
-- Dependencies: 219
-- Name: aaa_test_baeume; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.aaa_test_baeume ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3749 (class 0 OID 21543)
-- Dependencies: 286
-- Name: b3_tnr_test; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.b3_tnr_test ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3742 (class 0 OID 16465)
-- Dependencies: 221
-- Name: bv_ecke; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.bv_ecke ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3750 (class 3256 OID 16887)
-- Name: aaa_test_baeume new_write_filter; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY new_write_filter ON api.aaa_test_baeume USING (((EXISTS ( SELECT 1
   FROM api.bv_ecke ut
  WHERE ((ut.tnr = aaa_test_baeume.tnr) AND (ut.enr = aaa_test_baeume.enr)))) AND ((dathoheit)::text = CURRENT_USER)));


--
-- TOC entry 3763 (class 3256 OID 21552)
-- Name: b3_tnr_test read_datverwend; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY read_datverwend ON api.b3_tnr_test FOR SELECT USING ((POSITION((CURRENT_USER) IN ((datverwend)::text)) > 0));


--
-- TOC entry 3764 (class 3256 OID 21553)
-- Name: b3_tnr_test update_dathoheit; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY update_dathoheit ON api.b3_tnr_test FOR UPDATE USING (api.check_permissions(tnr)) WITH CHECK (api.check_permissions(tnr));


--
-- TOC entry 3751 (class 3256 OID 16888)
-- Name: aaa_test_baeume user_filter; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY user_filter ON api.aaa_test_baeume FOR SELECT USING ((CURRENT_USER = (dathoheit)::text));


--
-- TOC entry 3752 (class 3256 OID 16889)
-- Name: bv_ecke user_filter; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY user_filter ON api.bv_ecke FOR SELECT USING ((CURRENT_USER = (dathoheit)::text));


--
-- TOC entry 3746 (class 0 OID 17091)
-- Dependencies: 277
-- Name: archiv_b3_ecke; Type: ROW SECURITY; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE bwi_de_002_dev.archiv_b3_ecke ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3744 (class 0 OID 17056)
-- Dependencies: 274
-- Name: archiv_b3_tnr; Type: ROW SECURITY; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE bwi_de_002_dev.archiv_b3_tnr ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3745 (class 0 OID 17076)
-- Dependencies: 276
-- Name: b3_ecke; Type: ROW SECURITY; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE bwi_de_002_dev.b3_ecke ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3743 (class 0 OID 17039)
-- Dependencies: 273
-- Name: b3_tnr; Type: ROW SECURITY; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE bwi_de_002_dev.b3_tnr ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3748 (class 0 OID 21498)
-- Dependencies: 285
-- Name: b3_tnr_test; Type: ROW SECURITY; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE bwi_de_002_dev.b3_tnr_test ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3747 (class 0 OID 21486)
-- Dependencies: 284
-- Name: b3_tnr_work; Type: ROW SECURITY; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER TABLE bwi_de_002_dev.b3_tnr_work ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3758 (class 3256 OID 17097)
-- Name: archiv_b3_ecke insert; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY insert ON bwi_de_002_dev.archiv_b3_ecke FOR INSERT WITH CHECK ((CURRENT_USER = (dathoheit)::text));


--
-- TOC entry 3757 (class 3256 OID 17096)
-- Name: archiv_b3_ecke read; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY read ON bwi_de_002_dev.archiv_b3_ecke USING ((CURRENT_USER = (datverwend)::text));


--
-- TOC entry 3759 (class 3256 OID 17089)
-- Name: b3_ecke read; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY read ON bwi_de_002_dev.b3_ecke USING ((POSITION((CURRENT_USER) IN ((datverwend)::text)) > 0));


--
-- TOC entry 3754 (class 3256 OID 17065)
-- Name: archiv_b3_tnr read_datverwend; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY read_datverwend ON bwi_de_002_dev.archiv_b3_tnr FOR SELECT USING ((CURRENT_USER = (datverwend)::text));


--
-- TOC entry 3760 (class 3256 OID 17050)
-- Name: b3_tnr read_datverwend; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY read_datverwend ON bwi_de_002_dev.b3_tnr FOR SELECT USING ((POSITION((CURRENT_USER) IN ((datverwend)::text)) > 0));


--
-- TOC entry 3766 (class 3256 OID 21724)
-- Name: b3_tnr_test read_datverwend; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY read_datverwend ON bwi_de_002_dev.b3_tnr_test FOR SELECT USING ((((POSITION((CURRENT_USER) IN ((datverwend)::text)) > 0) AND bwi_de_002_dev.check_permissions(tnr)) OR bwi_de_002_dev.pruefe_rechte_bil(tnr)));


--
-- TOC entry 3761 (class 3256 OID 21495)
-- Name: b3_tnr_work read_datverwend; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY read_datverwend ON bwi_de_002_dev.b3_tnr_work FOR SELECT USING ((POSITION((CURRENT_USER) IN ((datverwend)::text)) > 0));


--
-- TOC entry 3756 (class 3256 OID 17090)
-- Name: b3_ecke update; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY update ON bwi_de_002_dev.b3_ecke USING ((CURRENT_USER = (dathoheit)::text)) WITH CHECK ((CURRENT_USER = (dathoheit)::text));


--
-- TOC entry 3755 (class 3256 OID 17066)
-- Name: archiv_b3_tnr update_dathoheit; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY update_dathoheit ON bwi_de_002_dev.archiv_b3_tnr FOR INSERT WITH CHECK ((CURRENT_USER = (dathoheit)::text));


--
-- TOC entry 3753 (class 3256 OID 17052)
-- Name: b3_tnr update_dathoheit; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY update_dathoheit ON bwi_de_002_dev.b3_tnr FOR UPDATE USING ((CURRENT_USER = (dathoheit)::text)) WITH CHECK ((CURRENT_USER = (dathoheit)::text));


--
-- TOC entry 3765 (class 3256 OID 21639)
-- Name: b3_tnr_test update_dathoheit; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY update_dathoheit ON bwi_de_002_dev.b3_tnr_test FOR UPDATE USING ((POSITION((CURRENT_USER) IN ((datverwend)::text)) > 0)) WITH CHECK (bwi_de_002_dev.check_permissions(tnr));


--
-- TOC entry 3762 (class 3256 OID 21496)
-- Name: b3_tnr_work update_dathoheit; Type: POLICY; Schema: bwi_de_002_dev; Owner: postgres
--

CREATE POLICY update_dathoheit ON bwi_de_002_dev.b3_tnr_work FOR UPDATE USING ((CURRENT_USER = (dathoheit)::text)) WITH CHECK ((CURRENT_USER = (dathoheit)::text));


--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA api TO "BY";
GRANT USAGE ON SCHEMA api TO "NI";
GRANT USAGE ON SCHEMA api TO "SN";
GRANT USAGE ON SCHEMA api TO web_anon;
GRANT USAGE ON SCHEMA api TO "BB";
GRANT USAGE ON SCHEMA api TO "MV";
GRANT USAGE ON SCHEMA api TO "TH";
GRANT USAGE ON SCHEMA api TO zoe;


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA basic_auth; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA basic_auth TO laender;


--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA bwi_de_001_dev; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA bwi_de_001_dev TO web_anon;
GRANT USAGE ON SCHEMA bwi_de_001_dev TO laender;


--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA bwi_de_002_dev; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA bwi_de_002_dev TO laender;
GRANT USAGE ON SCHEMA bwi_de_002_dev TO web_anon;


--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 363
-- Name: FUNCTION generate_create_table_statement(p_table_name character varying); Type: ACL; Schema: api; Owner: postgres
--

REVOKE ALL ON FUNCTION api.generate_create_table_statement(p_table_name character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION api.generate_create_table_statement(p_table_name character varying) TO laender;


--
-- TOC entry 3820 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE aaa_test_baeume; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.aaa_test_baeume TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.aaa_test_baeume TO laender;


--
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE aaa_test_baeume_view; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE api.aaa_test_baeume_view TO laender;


--
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE b3_tnr_test; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.b3_tnr_test TO laender;


--
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 286 3830
-- Name: COLUMN b3_tnr_test.test; Type: ACL; Schema: api; Owner: postgres
--

GRANT UPDATE(test) ON TABLE api.b3_tnr_test TO laender;


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE bv_ecke; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.bv_ecke TO "NI";
GRANT SELECT ON TABLE api.bv_ecke TO "SN";
GRANT SELECT ON TABLE api.bv_ecke TO web_anon;
GRANT SELECT ON TABLE api.bv_ecke TO "BY";
GRANT SELECT ON TABLE api.bv_ecke TO "BB";
GRANT SELECT ON TABLE api.bv_ecke TO "MV";
GRANT SELECT ON TABLE api.bv_ecke TO "TH";


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE "getHeaders"; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api."getHeaders" TO web_anon;
GRANT SELECT ON TABLE api."getHeaders" TO laender;


--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE my_roles; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.my_roles TO laender;
GRANT SELECT ON TABLE api.my_roles TO web_anon;


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE my_schemata; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.my_schemata TO laender;
GRANT SELECT ON TABLE api.my_schemata TO web_anon;


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE testtabelle; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.testtabelle TO web_anon;


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 225 3891
-- Name: COLUMN testtabelle.telefon; Type: ACL; Schema: api; Owner: postgres
--

GRANT INSERT(telefon) ON TABLE api.testtabelle TO web_anon;


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE tokentest; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.tokentest TO web_anon;


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE x3_ba; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.x3_ba TO laender;


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE users; Type: ACL; Schema: basic_auth; Owner: postgres
--

GRANT SELECT ON TABLE basic_auth.users TO laender;


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE b3_ecke; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_001_dev.b3_ecke TO laender;


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE b3_tnr; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_001_dev.b3_tnr TO laender;


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE b3v_wzp; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_001_dev.b3v_wzp TO laender;


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE bv_gps; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_001_dev.bv_gps TO laender;


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE schreibtest; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bwi_de_001_dev.schreibtest TO laender;


--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 270
-- Name: SEQUENCE schreibtest_id_seq; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT USAGE ON SEQUENCE bwi_de_001_dev.schreibtest_id_seq TO laender;


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE version; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_001_dev.version TO laender;
GRANT SELECT ON TABLE bwi_de_001_dev.version TO web_anon;


--
-- TOC entry 3951 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE x3_ba; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_001_dev.x3_ba TO laender;


--
-- TOC entry 3952 (class 0 OID 0)
-- Dependencies: 269
-- Name: TABLE x3_bl; Type: ACL; Schema: bwi_de_001_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_001_dev.x3_bl TO laender;


--
-- TOC entry 3953 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE archiv_b3_ecke; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT ALL ON TABLE bwi_de_002_dev.archiv_b3_ecke TO laender;


--
-- TOC entry 3954 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE archiv_b3_tnr; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE bwi_de_002_dev.archiv_b3_tnr TO laender;


--
-- TOC entry 3956 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE b3_ecke; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3957 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.datverwend; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(datverwend) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3958 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.vbl; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(vbl) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3959 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.bl; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(bl) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3960 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.aufnbl; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(aufnbl) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3961 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_rechtse; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_rechtse) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3962 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_hoche; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_hoche) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3963 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_x_gk2; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_x_gk2) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3964 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_y_gk2; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_y_gk2) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3965 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_x_gk3; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_x_gk3) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3966 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_y_gk3; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_y_gk3) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3967 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_x_gk4; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_x_gk4) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3968 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_y_gk4; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_y_gk4) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3969 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_x_gk5; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_x_gk5) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3970 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_y_gk5; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_y_gk5) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3971 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_x_wgs84; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_x_wgs84) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3972 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_y_wgs84; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_y_wgs84) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3973 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_x_32n; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_x_32n) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3974 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_y_32n; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_y_32n) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3975 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_x_33n; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_x_33n) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3976 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.soll_y_33n; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_y_33n) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3977 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.wg; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(wg) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3978 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.wb; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(wb) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3979 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.hoenn; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(hoenn) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3980 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.ags; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(ags) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3981 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.atkis; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(atkis) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3982 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.dop; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(dop) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3983 (class 0 OID 0)
-- Dependencies: 276 3956
-- Name: COLUMN b3_ecke.dlm; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(dlm) ON TABLE bwi_de_002_dev.b3_ecke TO laender;


--
-- TOC entry 3985 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE b3_tnr; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3986 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.datverwend; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(datverwend) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3987 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.soll_re; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_re) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3988 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.soll_dre; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_dre) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3989 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.soll_ho; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_ho) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3990 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.soll_dho; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_dho) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3991 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.soll_rechtst; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_rechtst) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3992 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.soll_hocht; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(soll_hocht) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3993 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.topkar; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(topkar) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3994 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.aufnbl; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(aufnbl) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3995 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.standardbl; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(standardbl) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3996 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.laender; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(laender) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3997 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.netz; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(netz) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3998 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.netz64; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(netz64) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 3999 (class 0 OID 0)
-- Dependencies: 273 3985
-- Name: COLUMN b3_tnr.ktg; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(ktg) ON TABLE bwi_de_002_dev.b3_tnr TO laender;


--
-- TOC entry 4001 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE b3_tnr_test; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_002_dev.b3_tnr_test TO laender;


--
-- TOC entry 4002 (class 0 OID 0)
-- Dependencies: 285 4001
-- Name: COLUMN b3_tnr_test.test; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT UPDATE(test) ON TABLE bwi_de_002_dev.b3_tnr_test TO laender;


--
-- TOC entry 4006 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE b3_tnr_work; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_002_dev.b3_tnr_work TO laender;


--
-- TOC entry 4007 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE b3v_wzp; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT ALL ON TABLE bwi_de_002_dev.b3v_wzp TO laender;


--
-- TOC entry 4009 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE x_workflow_perm; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_002_dev.x_workflow_perm TO laender;


--
-- TOC entry 4010 (class 0 OID 0)
-- Dependencies: 290
-- Name: TABLE z3_col; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT ALL ON TABLE bwi_de_002_dev.z3_col TO laender;


--
-- TOC entry 4011 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE z3_tab; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT ALL ON TABLE bwi_de_002_dev.z3_tab TO laender;


--
-- TOC entry 4012 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE z3_tab_safe; Type: ACL; Schema: bwi_de_002_dev; Owner: postgres
--

GRANT SELECT ON TABLE bwi_de_002_dev.z3_tab_safe TO laender;


--
-- TOC entry 2350 (class 826 OID 17048)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: bwi_de_002_dev; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bwi_de_002_dev GRANT ALL ON TABLES  TO laender;


-- Completed on 2024-05-14 17:15:51 CEST

--
-- PostgreSQL database dump complete
--

