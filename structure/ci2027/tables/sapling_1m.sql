SET search_path TO private_ci2027_001;

CREATE TABLE sapling_1m (

    id SERIAL PRIMARY KEY,
    plot_id INTEGER NOT NULL,
	plot_location_id INTEGER NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	stand_affiliation BOOLEAN NULL DEFAULT false, --Bz: https://git-dmz.thuenen.de/datenerfassungci2027/ci2027_datenerfassung/ci2027-db-structure/-/issues/4#note_24311	

	tree_species smallint NULL, --Ba
	bitten enum_bitten NOT NULL, --Biss
	protection_individual boolean NULL, --Schu
	quantity smallint NOT NULL --Anz

);


COMMENT ON TABLE sapling_1m IS 'Sub Plot Saplings';

COMMENT ON COLUMN sapling_1m.id IS 'Primary Key';
COMMENT ON COLUMN sapling_1m.plot_id IS 'Foreign Key to Plot.id';
COMMENT ON COLUMN sapling_1m.tree_species IS 'Baumart';
COMMENT ON COLUMN sapling_1m.bitten IS 'Einfacher oder mehrfacher Verbiss der Terminalknospe';
COMMENT ON COLUMN sapling_1m.protection_individual IS 'Einzelschutz der Bäume';
COMMENT ON COLUMN sapling_1m.quantity IS 'Anzahl gleichartiger Bäume';

ALTER TABLE sapling_1m ADD CONSTRAINT FK_Saplings1m_Plot FOREIGN KEY (plot_id) REFERENCES plot(id) MATCH SIMPLE
	ON DELETE CASCADE;

--- plot_location_id
ALTER TABLE sapling_1m ADD CONSTRAINT FK_Saplings1m_PlotLocation FOREIGN KEY (plot_location_id)
	REFERENCES plot_location (id)
	ON DELETE CASCADE;

ALTER TABLE sapling_1m ADD CONSTRAINT FK_Saplings1m_LookupTreeSpecies FOREIGN KEY (tree_species)
    REFERENCES lookup_tree_species (abbreviation);

ALTER TABLE sapling_1m ADD CONSTRAINT FK_Saplings1m_LookupBitten FOREIGN KEY (bitten)
    REFERENCES lookup_bitten (abbreviation);

