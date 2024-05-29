--- Create a view takes all trakt values as array and ecke values into a single JSON object.

CREATE OR REPLACE VIEW bwi_de_001_dev.user_permissions AS
SELECT * 
FROM information_schema.role_table_grants 
WHERE grantee = 'gerrit.balindt@thuenen.de';

GRANT ALL PRIVILEGES ON bwi_de_001_dev.user_permissions TO web_anon;

-- GET TRAKT
CREATE OR REPLACE VIEW dev_automated_001.b3_view AS
SELECT jsonb_agg(to_jsonb("dev_automated_001.b3_tnr") || jsonb_build_object(
        '_titel', 'Trakte',
        '_tableName', 'b3_tnr'
)) as "dev_automated_001$b3_tnr"
FROM (
    SELECT
    	dev_automated_001.b3_tnr.*,
        (
        	SELECT jsonb_agg(to_jsonb(nested_section) || jsonb_build_object(
                '_titel', 'Ecken',
                '_tableName', 'b3_ecke'
            ))
        	FROM (
	        	SELECT
		     		dev_automated_001.b3_ecke.*,
		     		(
		     			SELECT json_agg(nested_question)
		     			FROM (
		     				SELECT
		     				dev_automated_001.b3v_wzp.*
			     			FROM dev_automated_001.b3v_wzp
			     			where dev_automated_001.b3v_wzp.Enr = dev_automated_001.b3_ecke.Enr AND dev_automated_001.b3v_wzp.Tnr = dev_automated_001.b3_ecke.Tnr
		     			) AS nested_question
		     		) AS "dev_automated_001.b3v_wzp"
		        FROM dev_automated_001.b3_ecke
		        WHERE dev_automated_001.b3_ecke.Tnr = dev_automated_001.b3_tnr.Tnr
        	) AS nested_section
        ) AS "dev_automated_001.b3_ecke"
    FROM dev_automated_001.b3_tnr
) AS "dev_automated_001.b3_tnr";

GRANT ALL PRIVILEGES ON dev_automated_001.b3_view TO web_anon;

-- write trakt and ecke
CREATE OR REPLACE FUNCTION dev_automated_001.insert_or_update_b3(json_data json)
RETURNS text AS $$
DECLARE
    tnr_record dev_automated_001.b3_tnr%ROWTYPE;
    ecke_record dev_automated_001.b3_ecke%ROWTYPE;
    wzp_record dev_automated_001.b3v_wzp%ROWTYPE;
    trakt_data json;
    ecke_data json;
    wzp_data json;

    _fields TEXT = '';
    _record dev_automated_001.b3_tnr;
BEGIN
    -- Begin a block for exception handling
    BEGIN

        -- Get all column names from b3_tnr table
        SELECT string_agg(quote_ident(column_name), ', ') INTO _fields
        FROM information_schema.columns
        WHERE table_schema = 'dev_automated_001' AND table_name = 'b3_tnr';


        -- Loop through b3_tnr array in json_data
        FOR trakt_data IN SELECT * FROM json_array_elements(json_data->'dev_automated_001.b3_tnr')
        LOOP

            _record := json_populate_record(null::dev_automated_001.b3_tnr, (trakt_data)::json);

            -- Insert or update b3_tnr
            EXECUTE format('
                INSERT INTO dev_automated_001.b3_tnr SELECT * FROM json_populate_record(null::dev_automated_001.b3_tnr, ($1)::json)
                ON CONFLICT ((dev_automated_001.b3_tnr.intkey))
                DO UPDATE SET (%s) = %s;
            ', _fields, _record)
            USING trakt_data;

            

            /*-- Insert or update b3_tnr
            INSERT INTO dev_automated_001.b3_tnr SELECT * FROM json_populate_record(null::dev_automated_001.b3_tnr, (trakt_data)::json)
            ON CONFLICT (intkey)
            DO UPDATE SET
                datbis = EXCLUDED.datbis;*/



            -- Loop through b3_ecke array in tnr_record
            /*IF (trakt_data->'dev_automated_001.b3_ecke' IS NOT NULL) THEN
                FOR ecke_data IN SELECT * FROM json_array_elements(trakt_data->'dev_automated_001.b3_ecke')
                LOOP
                    
                    -- Insert or update b3_ecke
                    INSERT INTO dev_automated_001.b3_ecke
                    SELECT * FROM json_populate_record(NULL::dev_automated_001.b3_ecke, (ecke_data)::json)
                    ON CONFLICT (intkey)
                    DO UPDATE SET intkey = EXCLUDED.intkey;

                    -- Loop through b3v_wzp array in ecke_record
                    IF (ecke_data->'dev_automated_001.b3v_wzp' IS NOT NULL) THEN
                        FOR wzp_data IN SELECT * FROM json_array_elements(ecke_data->'dev_automated_001.b3v_wzp')
                        LOOP
                            
                            -- Insert or update b3v_wzp
                            INSERT INTO dev_automated_001.b3v_wzp
                            SELECT * FROM json_populate_record(NULL::dev_automated_001.b3v_wzp, (wzp_data)::json)
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

GRANT EXECUTE ON FUNCTION dev_automated_001.insert_or_update_b3(nested_json JSON) TO web_anon;
