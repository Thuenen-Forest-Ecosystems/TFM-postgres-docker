SET search_path TO private_ci2027_001;

CREATE TABLE IF NOT EXISTS cluster (
    id SERIAL PRIMARY KEY,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
	modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	name varchar(255) NOT NULL, -- Unique human readable name
	description TEXT,

	topographic_map_number CK_TopographicMapNumber NULL,
	state_administration enum_state NOT NULL,
	state_location enum_state NULL,
	states enum_state[],
	sampling_strata enum_sampling_strata NOT NULL,
	cluster_identifier enum_cluster_identifier NULL
);



COMMENT ON TABLE private_ci2027_001.cluster IS 'Deine Trakte';
COMMENT ON COLUMN private_ci2027_001.cluster.id IS 'Unique ID des Traktes';
COMMENT ON COLUMN private_ci2027_001.cluster.created_at IS 'Erstellungsdatum';

COMMENT ON COLUMN private_ci2027_001.cluster.name IS 'Name des Traktes';
COMMENT ON COLUMN private_ci2027_001.cluster.description IS 'Beschreibung des Traktes';

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
