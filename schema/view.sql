--- Create a view takes all trakt values as array and ecke values into a single JSON object.

CREATE OR REPLACE VIEW bwi_de_001_dev.user_permissions AS
SELECT * 
FROM information_schema.role_table_grants 
WHERE grantee = 'gerrit.balindt@thuenen.de';

GRANT ALL PRIVILEGES ON bwi_de_001_dev.user_permissions TO web_anon;

-- GET TRAKT
CREATE OR REPLACE VIEW bwi_root.b3_view AS
SELECT jsonb_agg(to_jsonb("bwi_root.b3_tnr") || jsonb_build_object(
        '_titel', 'Trakte',
        '_tableName', 'b3_tnr'
)) as "bwi_root$b3_tnr"
FROM (
    SELECT
    	bwi_root.b3_tnr.*,
        (
        	SELECT jsonb_agg(to_jsonb(nested_section) || jsonb_build_object(
                '_titel', 'Ecken',
                '_tableName', 'b3_ecke'
            ))
        	FROM (
	        	SELECT
		     		bwi_root.b3_ecke.*,
		     		(
		     			SELECT json_agg(nested_question)
		     			FROM (
		     				SELECT
		     				bwi_root.b3v_wzp.*
			     			FROM bwi_root.b3v_wzp
			     			where bwi_root.b3v_wzp.Enr = bwi_root.b3_ecke.Enr AND bwi_root.b3v_wzp.Tnr = bwi_root.b3_ecke.Tnr
		     			) AS nested_question
		     		) AS "bwi_root.b3v_wzp"
		        FROM bwi_root.b3_ecke
		        WHERE bwi_root.b3_ecke.Tnr = bwi_root.b3_tnr.Tnr
        	) AS nested_section
        ) AS "bwi_root.b3_ecke"
    FROM bwi_root.b3_tnr
) AS "bwi_root.b3_tnr";

GRANT ALL PRIVILEGES ON bwi_root.b3_view TO web_anon;

-- write trakt and ecke
CREATE OR REPLACE FUNCTION bwi_root.insert_or_update_b3(json_data json)
RETURNS text AS $$
DECLARE
    tnr_record bwi_root.b3_tnr%ROWTYPE;
    ecke_record bwi_root.b3_ecke%ROWTYPE;
    wzp_record bwi_root.b3v_wzp%ROWTYPE;
    trakt_data json;
    ecke_data json;
    wzp_data json;

    _fields TEXT = '';
    _record bwi_root.b3_tnr;
BEGIN
    -- Begin a block for exception handling
    BEGIN

        -- Get all column names from b3_tnr table
        SELECT string_agg(quote_ident(column_name), ', ') INTO _fields
        FROM information_schema.columns
        WHERE table_schema = 'bwi_root' AND table_name = 'b3_tnr';


        -- Loop through b3_tnr array in json_data
        FOR trakt_data IN SELECT * FROM json_array_elements(json_data->'bwi_root.b3_tnr')
        LOOP

            _record := json_populate_record(null::bwi_root.b3_tnr, (trakt_data)::json);

            -- Insert or update b3_tnr
            EXECUTE format('
                INSERT INTO bwi_root.b3_tnr SELECT * FROM json_populate_record(null::bwi_root.b3_tnr, ($1)::json)
                ON CONFLICT ((bwi_root.b3_tnr.intkey))
                DO UPDATE SET (%s) = %s;
            ', _fields, _record)
            USING trakt_data;

            

            /*-- Insert or update b3_tnr
            INSERT INTO bwi_root.b3_tnr SELECT * FROM json_populate_record(null::bwi_root.b3_tnr, (trakt_data)::json)
            ON CONFLICT (intkey)
            DO UPDATE SET
                datbis = EXCLUDED.datbis;*/



            -- Loop through b3_ecke array in tnr_record
            /*IF (trakt_data->'bwi_root.b3_ecke' IS NOT NULL) THEN
                FOR ecke_data IN SELECT * FROM json_array_elements(trakt_data->'bwi_root.b3_ecke')
                LOOP
                    
                    -- Insert or update b3_ecke
                    INSERT INTO bwi_root.b3_ecke
                    SELECT * FROM json_populate_record(NULL::bwi_root.b3_ecke, (ecke_data)::json)
                    ON CONFLICT (intkey)
                    DO UPDATE SET intkey = EXCLUDED.intkey;

                    -- Loop through b3v_wzp array in ecke_record
                    IF (ecke_data->'bwi_root.b3v_wzp' IS NOT NULL) THEN
                        FOR wzp_data IN SELECT * FROM json_array_elements(ecke_data->'bwi_root.b3v_wzp')
                        LOOP
                            
                            -- Insert or update b3v_wzp
                            INSERT INTO bwi_root.b3v_wzp
                            SELECT * FROM json_populate_record(NULL::bwi_root.b3v_wzp, (wzp_data)::json)
                            ON CONFLICT (intkey)
                            DO UPDATE SET intkey = EXCLUDED.intkey;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;*/
        END LOOP;
        RETURN 'Success';
    EXCEPTION WHEN OTHERS THEN
        -- Return the error message
        RETURN SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION bwi_root.insert_or_update_b3(nested_json JSON) TO web_anon;
