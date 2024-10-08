SET search_path TO private_ci2027_001, public;

CREATE TABLE IF NOT EXISTS edges (

    id SERIAL PRIMARY KEY,
	plot_id INTEGER NOT NULL,

	edge_number INTEGER NOT NULL, -- NEU: Kanten-ID || ToDo: Welchen Mehrwert hat diese ID gegenüber der ID?

	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	edge_status enum_edge_status NOT NULL, --Rk
	edge_type enum_edge_type NOT NULL, --Rart
	terrain enum_terrain NOT NULL, --Rterrain

	geometry Geometry(LineString, 4326) -- NEU: Geometrie
);


COMMENT ON TABLE edges IS 'Tabelle für die Kanten';
COMMENT ON COLUMN edges.id IS 'Primärschlüssel';
COMMENT ON COLUMN edges.plot_id IS 'Fremdschlüssel auf Plot';
COMMENT ON COLUMN edges.created_at IS 'Erstellungszeitpunkt';
COMMENT ON COLUMN edges.edge_status IS 'Kennziffer des Wald-/Bestandesrandes';
COMMENT ON COLUMN edges.edge_type IS 'Art des Wald- /Bestandesrandes';
COMMENT ON COLUMN edges.terrain IS 'Vorgelagertes Terrain';
COMMENT ON COLUMN edges.geometry IS 'Geometrie der Kante';

ALTER TABLE edges ADD CONSTRAINT FK_Edges_Plot FOREIGN KEY (plot_id) REFERENCES plot(id)
	ON DELETE CASCADE;

ALTER TABLE edges ADD CONSTRAINT CK_Edges_Geometry CHECK (ST_IsValid(geometry));

ALTER TABLE edges ADD CONSTRAINT FK_Edge_LookupEdgeStatus FOREIGN KEY (edge_status)
	REFERENCES lookup_edge_status (abbreviation);

ALTER TABLE edges ADD CONSTRAINT FK_Edge_LookupEdgeType FOREIGN KEY (edge_type)
	REFERENCES lookup_edge_type (abbreviation);

ALTER TABLE edges ADD CONSTRAINT FK_Edge_LookupTerrain FOREIGN KEY (terrain)
	REFERENCES lookup_terrain (abbreviation);
