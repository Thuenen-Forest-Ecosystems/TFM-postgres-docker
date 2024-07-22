SET search_path TO private_ci2027_001, public;

-- Function to import Plot Location
CREATE OR REPLACE FUNCTION import_plot_location(plot_location json, plot_id int, parent_table enum_plot_location_parent_table)
RETURNS int AS
$$
DECLARE
    new_plot_location_id int;
BEGIN

    INSERT INTO plot_location (plot_id, parent_table, azimuth, distance, radius, geometry, circle_geometry, no_entities)
    VALUES (
        plot_id,
        parent_table,
        (plot_location->>'azimuth')::int,
        (plot_location->>'distance')::int,
        (plot_location->>'radius')::int,
        ST_GeomFromGeoJSON((plot_location->>'geometry')::text),
        ST_Buffer(
            ST_GeomFromGeoJSON((plot_location->>'geometry')::text),
            (plot_location->>'radius')::int, 'quad_segs=8'
        ),
        (plot_location->>'no_entities')::boolean
    )
    ON CONFLICT (id) DO UPDATE
    SET 
        plot_id = EXCLUDED.plot_id,
        parent_table = EXCLUDED.parent_table,
        azimuth = EXCLUDED.azimuth,
        distance = EXCLUDED.distance,
        radius = EXCLUDED.radius,
        geometry = EXCLUDED.geometry,
        no_entities = EXCLUDED.no_entities
    WHERE plot_location.id = EXCLUDED.id
    RETURNING id INTO new_plot_location_id;

    RETURN new_plot_location_id;
END;
$$ LANGUAGE plpgsql;