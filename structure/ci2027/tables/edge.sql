SET search_path TO private_ci2027_001, public;

CREATE TABLE IF NOT EXISTS edges (

    id SERIAL PRIMARY KEY,
	plot_id INTEGER NOT NULL,

	edge_number INTEGER NULL, -- NEU: Kanten-ID || ToDo: Welchen Mehrwert hat diese ID gegenüber der ID?

	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	edge_status enum_edge_status NOT NULL, --Rk
	edge_type enum_edge_type NOT NULL, --Rart
	terrain enum_terrain NULL, --Rterrain


	edges JSONB NOT NULL, -- NEU: GeoJSON
	geometry_edges Geometry(LineString, 4326) NULL -- NEU: Geometrie
);


COMMENT ON TABLE edges IS 'Tabelle für die Kanten';
COMMENT ON COLUMN edges.id IS 'Primärschlüssel';
COMMENT ON COLUMN edges.plot_id IS 'Fremdschlüssel auf Plot';
COMMENT ON COLUMN edges.created_at IS 'Erstellungszeitpunkt';
COMMENT ON COLUMN edges.edge_status IS 'Kennziffer des Wald-/Bestandesrandes';
COMMENT ON COLUMN edges.edge_type IS 'Art des Wald- /Bestandesrandes';
COMMENT ON COLUMN edges.terrain IS 'Vorgelagertes Terrain';
COMMENT ON COLUMN edges.geometry_edges IS 'Geometrie der Kante';

ALTER TABLE edges ADD CONSTRAINT FK_Edges_Plot FOREIGN KEY (plot_id) REFERENCES plot(id)
	ON DELETE CASCADE;

--ALTER TABLE edges ADD CONSTRAINT CK_Edges_Geometry CHECK (ST_IsValid(geometry_edges));

ALTER TABLE edges ADD CONSTRAINT FK_Edge_LookupEdgeStatus FOREIGN KEY (edge_status)
	REFERENCES lookup_edge_status (abbreviation);

ALTER TABLE edges ADD CONSTRAINT FK_Edge_LookupEdgeType FOREIGN KEY (edge_type)
	REFERENCES lookup_edge_type (abbreviation);

ALTER TABLE edges ADD CONSTRAINT FK_Edge_LookupTerrain FOREIGN KEY (terrain)
	REFERENCES lookup_terrain (abbreviation);


-- Create the function to update geometry_edges
CREATE OR REPLACE FUNCTION update_geometry_edges()
RETURNS TRIGGER AS $$
DECLARE
    start_point GEOMETRY(Point, 4326);
    end_point GEOMETRY(Point, 4326);
    azimuth DOUBLE PRECISION;
    distance DOUBLE PRECISION;
    coordinates GEOMETRY(LineString, 4326) := ST_MakeLine(ARRAY[]::GEOMETRY[]);
BEGIN
    -- Initialize the starting point from the center_location in the plot table
    SELECT center_location
    INTO start_point
    FROM plot
    WHERE id = NEW.plot_id;

    -- Ensure the starting point is valid
    IF start_point IS NULL THEN
        RAISE EXCEPTION 'Starting point is NULL';
    END IF;

	RAISE EXCEPTION 'Starting point is NULL';

    -- Loop through the array of azimuths and distances
    FOR i IN 0 .. jsonb_array_length(NEW.edges) - 1 LOOP
        azimuth := (NEW.edges->i->>'azimuth')::DOUBLE PRECISION * 180/200; -- Convert GON to degrees
        distance := (NEW.edges->i->>'distance')::DOUBLE PRECISION / 100.0; -- Convert cm to meters

        -- Calculate the end point using the azimuth and distance
        end_point := ST_Project(start_point, distance, radians(azimuth));

        -- Add the segment to the coordinates
        coordinates := ST_AddPoint(coordinates, end_point);

        -- Update the start point for the next segment
        start_point := end_point;
    END LOOP;

    -- Ensure the coordinates are valid
    IF ST_IsEmpty(coordinates) THEN
        RAISE EXCEPTION 'Generated coordinates are empty';
    END IF;

    -- Update the geometry_edges column in the edges table
    UPDATE edges
    SET geometry_edges = coordinates
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
-- Create the trigger to call the function on update
CREATE TRIGGER trigger_update_geometry_edges
AFTER INSERT OR UPDATE ON edges
FOR EACH ROW
EXECUTE FUNCTION update_geometry_edges();
*/