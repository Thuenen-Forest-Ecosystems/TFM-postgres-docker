-- FUNCTION: bwi_de_002_dev.pruefe_rechte_rolle_work(text, integer)

 DROP FUNCTION IF EXISTS bwi_de_002_dev.pruefe_rechte_rolle_work(text, integer);
DROP FUNCTION IF EXISTS bwi_de_002_dev.pruefe_rechte( integer);
DROP FUNCTION IF EXISTS bwi_de_002_dev.pruefe_rechte_bil( integer);


CREATE OR REPLACE FUNCTION bwi_de_002_dev.pruefe_rechte_rolle_work(
	rolle text,
	xtnr integer)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$

	DECLARE
	email_at text;
	wf integer;
    gruppe text;
	message character varying;
	  
	BEGIN
-- Workflow aus Work-Tab   
   wf:= (select b.workflow from
	bwi_de_002_dev.b3_tnr_work as b
    where b.tnr = xtnr);
   
-- Sonderbehandlung bei Rolle BIL
    if rolle ='BIL' THEN
	   RAISE NOTICE '%', 'Rolle= ' || rolle;
              	RETURN  (select((select count(b.tnr) from
				bwi_de_002_dev.b3_tnr_work as b
    			where b.tnr = xtnr and b.workflow IN (0,8,9)) =1));
	END IF;  
--email aus Work-Tab		
    email_at:= (select b.at from
	bwi_de_002_dev.b3_tnr_work as b
    where b.tnr = xtnr);
-- Gruppenrolle {AT,KT,LIL} aus users joined work-Tab
    gruppe:= (select  "group" from basic_auth.users as a
		where role=rolle and a.email=email_at );
	
	message := 'Rolle= ' || rolle || ' Email=' || email_at || ' Gruppe=' || gruppe || ' Workflow= ' || wf;
	
	if message is not NULL then 
		RAISE NOTICE '%', message;
		
	end if;

   
-- Auswahl der gültigen Workflows für die Gruppenrolle
	case gruppe
		  
		   when 'KT' then
				RETURN  (select((select count(b.tnr) from
				bwi_de_002_dev.b3_tnr_work as b
   				 where b.tnr = xtnr and b.at=email_at  and b.workflow IN (6)) =1));
 		   when 'AT' then
				RETURN  (select((select count(b.tnr) from
				bwi_de_002_dev.b3_tnr_work as b
   				 where b.tnr = xtnr and b.at=email_at and b.workflow IN (3)) =1));
           when 'LIL' then
				RETURN  (select((select count(b.tnr) from
				bwi_de_002_dev.b3_tnr_work as b
    			where b.tnr = xtnr and b.at=email_at and b.workflow IN (1,2,4,5,7)) =1));
		   else
	    	 	 RETURN  FALSE;
		   end case;
		RETURN  FALSE;
	END
	
-- probeaufruf
-- set role='postgres'		
-- set role= 'SN'		
-- select bwi_de_002_dev.pruefe_rechte_rolle_work('SN',9999999);
	
$BODY$;

ALTER FUNCTION bwi_de_002_dev.pruefe_rechte_rolle_work(text, integer)
    OWNER TO postgres;


-- POLICY: read_pruefe_rechte_rolle_work

-- DROP POLICY IF EXISTS read_pruefe_rechte_rolle_work ON bwi_de_002_dev.b3_tnr_test;

CREATE POLICY read_pruefe_rechte_rolle_work
    ON bwi_de_002_dev.b3_tnr_test
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (bwi_de_002_dev.pruefe_rechte_rolle_work((CURRENT_USER)::text, tnr));
	
	-- POLICY: update_pruefe_rechte_rolle_work

 DROP POLICY IF EXISTS read_datverwend ON bwi_de_002_dev.b3_tnr_test;
 DROP POLICY IF EXISTS update_dathoheit ON bwi_de_002_dev.b3_tnr_test;

CREATE POLICY update_pruefe_rechte_rolle_work
    ON bwi_de_002_dev.b3_tnr_test
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (bwi_de_002_dev.pruefe_rechte_rolle_work((CURRENT_USER)::text, tnr))
    WITH CHECK (bwi_de_002_dev.pruefe_rechte_rolle_work((CURRENT_USER)::text, tnr));
