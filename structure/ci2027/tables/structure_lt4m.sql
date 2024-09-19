CREATE TABLE structure_lt4m (

    id SERIAL PRIMARY KEY,
    plot_id INTEGER NOT NULL,
	plot_location_id INTEGER NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	tree_species enum_tree_species NULL, --Ba
	coverage enum_coverage NOT NULL, --Anteil
	regeneration_type enum_reg_type NULL --Vart
);


COMMENT ON TABLE structure_lt4m IS 'Probekreis mit 10 m Radius für die Erfassung der Jungbestockung - Bäume bis 4 m Höhe';

COMMENT ON COLUMN structure_lt4m.id IS 'Primary Key';
COMMENT ON COLUMN structure_lt4m.plot_id IS 'Foreign Key to Plot.id';
COMMENT ON COLUMN structure_lt4m.tree_species IS 'Baumart';
COMMENT ON COLUMN structure_lt4m.coverage IS 'Anteil der Baumart in Zehntel (Deckungsgrad entspricht 10 Zehntel = 100 %)';
COMMENT ON COLUMN structure_lt4m.regeneration_type IS 'Verjüngungsart der Baumart';

ALTER TABLE structure_lt4m ADD CONSTRAINT FK_StructureLt4m_Plot FOREIGN KEY (plot_id) REFERENCES plot(id) MATCH SIMPLE
	ON DELETE CASCADE;

--- plot_location_id
ALTER TABLE structure_lt4m ADD CONSTRAINT FK_StructureLt4m_PlotLocation FOREIGN KEY (plot_location_id)
	REFERENCES plot_location (id)
	ON DELETE CASCADE;

ALTER TABLE structure_lt4m ADD CONSTRAINT FK_StructureLt4m_LookupTreeSpecies FOREIGN KEY (tree_species)
    REFERENCES lookup_tree_species (abbreviation);

ALTER TABLE structure_lt4m ADD CONSTRAINT FK_StructureLt4m_LookupCoverage FOREIGN KEY (coverage)
    REFERENCES lookup_coverage (abbreviation);

ALTER TABLE structure_lt4m ADD CONSTRAINT FK_StructureLt4m_LookupRegType FOREIGN KEY (regeneration_type)
    REFERENCES lookup_regeneration_type (abbreviation);
