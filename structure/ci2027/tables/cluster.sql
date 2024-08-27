SET search_path TO private_ci2027_001;

CREATE TABLE IF NOT EXISTS cluster (

    --id SERIAL PRIMARY KEY NOT NULL,
	id INTEGER PRIMARY KEY NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
	modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	--cluster_name INTEGER NOT NULL UNIQUE PRIMARY KEY, -- Unique human readable name
	--email TEXT[] NOT NULL DEFAULT array[]::text[], -- Email of the user who created the cluster
	select_access_by TEXT[] NOT NULL DEFAULT array[]::TEXT[], -- Roles that can access the cluster
	update_access_by TEXT[] NOT NULL DEFAULT array[]::TEXT[], -- Roles that can update the cluster

	supervisor_id INTEGER NULL, -- Supervisor of the cluster

	topographic_map_number CK_TopographicMapNumber NULL,
	state_administration enum_state NOT NULL,
	state_location enum_state NULL,
	states enum_state[],
	sampling_strata enum_sampling_strata NOT NULL,
	cluster_identifier enum_cluster_identifier NULL
);

ALTER TABLE cluster ADD CONSTRAINT fk_Cluster_user_id FOREIGN KEY (supervisor_id) REFERENCES basic_auth.users(id);


CREATE OR REPLACE FUNCTION check_select_access_by_emails(select_access_by text[]) RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT bool_and(email_exists)
        FROM (
            SELECT u.email IS NOT NULL AS email_exists
            FROM unnest(select_access_by) AS e(email)
            LEFT JOIN basic_auth.users u ON e.email = u.email
        ) AS subquery
    );
END;
$$ LANGUAGE plpgsql;
ALTER TABLE cluster
ADD CONSTRAINT check_select_access_by_emails_constraint
CHECK (check_select_access_by_emails(select_access_by));
ALTER TABLE cluster
ADD CONSTRAINT check_update_access_by_emails_constraint
CHECK (check_select_access_by_emails(update_access_by));


COMMENT ON TABLE private_ci2027_001.cluster IS 'Eindeutige Bezeichung des Traktes';
COMMENT ON COLUMN private_ci2027_001.cluster.id IS 'Unique ID des Traktes';
COMMENT ON COLUMN private_ci2027_001.cluster.created_at IS 'Erstellungsdatum';

--COMMENT ON COLUMN private_ci2027_001.cluster.cluster_name IS 'Eindeutige Bezeichung des Traktes';

COMMENT ON COLUMN private_ci2027_001.cluster.topographic_map_number IS 'Nummer der topgraphischen Karte 1:25.000';
COMMENT ON COLUMN private_ci2027_001.cluster.state_administration IS 'Aufnahme-Bundesland für Feldaufnahmen und ggf. Vorklärungsmerkmale';
COMMENT ON COLUMN private_ci2027_001.cluster.state_location IS 'Standard-Land für Ecken und Wege, meist wie Aufnahmeland "AufnBl", Ausnahmen bei Grenztrakten';
COMMENT ON COLUMN private_ci2027_001.cluster.states IS 'zugehörige Ländernummer(n), auch mehrere';
COMMENT ON COLUMN private_ci2027_001.cluster.sampling_strata IS 'Zugehörigkeit zum Rasternetz';
COMMENT ON COLUMN private_ci2027_001.cluster.cluster_identifier IS 'Traktkennung / Traktkennzeichen lt. Vorklärung durch vTI';


ALTER TABLE private_ci2027_001.cluster OWNER TO postgres;


--ALTER TABLE cluster
--	ADD CONSTRAINT FK_Tract_LookupStates
--	FOREIGN KEY (states[])
--	REFERENCES lookup_state (abbreviation);
--
ALTER TABLE cluster
	ADD CONSTRAINT FK_Tract_LookupStateAdministration
	FOREIGN KEY (state_administration)
	REFERENCES lookup_state (abbreviation);

ALTER TABLE cluster
	ADD CONSTRAINT FK_Tract_LookupStateLocation
	FOREIGN KEY (state_location)
	REFERENCES lookup_state (abbreviation);



--ALTER TABLE cluster
--	ADD CONSTRAINT FK_Tract_LookupSamplingStrata
--	FOREIGN KEY (sampling_strata)
--	REFERENCES lookup_sampling_strata (abbreviation);
--
--ALTER TABLE cluster
--	ADD CONSTRAINT FK_Tract_LookupTractIdentifier
--	FOREIGN KEY (cluster_identifier)
--	REFERENCES lookup_cluster_identifier (abbreviation);




-- MOVE TO SOMEWHERE ELSE ???

-- Enable Row-Level Security
ALTER TABLE cluster ENABLE ROW LEVEL SECURITY;



CREATE POLICY cluster_select ON cluster
FOR SELECT
USING (current_setting('request.jwt.claims', true)::json->>'email' = ANY(select_access_by) OR current_user = 'country_admin');

CREATE POLICY cluster_delete ON cluster
	FOR DELETE
	USING (current_user = 'country_admin');
COMMENT ON POLICY cluster_delete ON cluster IS 'Only country_admin can insert new clusters';

CREATE POLICY cluster_insert ON cluster
	FOR INSERT
	WITH CHECK (current_setting('request.jwt.claims', true)::json->>'email' = ANY(update_access_by) OR current_user = 'country_admin');
COMMENT ON POLICY cluster_insert ON cluster IS 'Only country_admin can insert new clusters';

CREATE POLICY cluster_update ON cluster
	FOR UPDATE
	USING (current_setting('request.jwt.claims', true)::json->>'email' = ANY(update_access_by) OR current_user = 'country_admin')
	WITH CHECK (true);
COMMENT ON POLICY cluster_update ON cluster IS 'Only country_admin can update clusters';

-----------------------------------------------------------------------------------------------------------------------

-- Step 1: Add a lock column to the table
ALTER TABLE cluster ADD COLUMN is_locked BOOLEAN DEFAULT FALSE;

-- Step 2: Create a trigger function to prevent updates if the row is locked
CREATE OR REPLACE FUNCTION prevent_update_if_locked() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.is_locked THEN
        RAISE EXCEPTION 'Row is locked and cannot be updated';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create a trigger to enforce the lock
CREATE TRIGGER prevent_update_if_locked_trigger
BEFORE UPDATE ON cluster
FOR EACH ROW
EXECUTE FUNCTION prevent_update_if_locked();

-- Function to lock a row
CREATE OR REPLACE FUNCTION lock_row(cluster_id int) RETURNS void AS $$
BEGIN
    UPDATE cluster SET is_locked = TRUE WHERE id = cluster_id;
END;
$$ LANGUAGE plpgsql;

-- Function to unlock a row (if needed)
CREATE OR REPLACE FUNCTION unlock_row(cluster_id int) RETURNS void AS $$
BEGIN
    UPDATE cluster SET is_locked = FALSE WHERE id = cluster_id;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions to the necessary role
GRANT EXECUTE ON FUNCTION lock_row(int) TO web_anon;
GRANT EXECUTE ON FUNCTION unlock_row(int) TO web_anon;