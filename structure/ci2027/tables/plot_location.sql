SET search_path TO private_ci2027_001, public;


CREATE TABLE plot_location (
    id SERIAL PRIMARY KEY,
    plot_id INTEGER NOT NULL, -- Foreign Key to parent table
    parent_table enum_plot_location_parent_table NOT NULL, -- Parent Table Name

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

    azimuth CK_GON NOT NULL, -- Azimuth (Gon) NEU
    distance smallint NOT NULL  DEFAULT 500, -- Distance (cm) NEU
    radius smallint NOT NULL DEFAULT 100, -- Radius (cm) NEU

    --sub_plot_type enum_plot_type NOT NULL,
    geometry GEOMETRY(POINT, 4326) NOT NULL, -- Geometry (Polygon) NEU

    no_entities BOOLEAN DEFAULT FALSE -- Sub Plot is marked as "has no entities". 

);

ALTER TABLE plot_location ADD UNIQUE (plot_id, parent_table)

COMMENT ON TABLE plot_location IS 'Sub Plots';
COMMENT ON COLUMN plot_location.id IS 'Primary Key';
COMMENT ON COLUMN plot_location.azimuth IS 'Azimuth (Gon)';
COMMENT ON COLUMN plot_location.distance IS 'Distance (cm)';
COMMENT ON COLUMN plot_location.radius IS 'Radius (cm)';
COMMENT ON COLUMN plot_location.geometry IS 'Geometry (Polygon)';
COMMENT ON COLUMN plot_location.no_entities IS 'Sub Plot is marked as "has no entities".';