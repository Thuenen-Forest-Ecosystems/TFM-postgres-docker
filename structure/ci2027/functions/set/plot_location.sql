SET search_path TO private_ci2027_001, public;

-- Function to import Plot Location
CREATE OR REPLACE FUNCTION set_plot_location(parent_id int, json_object json, parent_table_name enum_plot_location_parent_table)
RETURNS json AS
$$
DECLARE
    changed_values RECORD;
BEGIN

    

    -- return if json_object is null
    IF (json_object IS NULL OR (json_object)::text = 'null') THEN
        DELETE FROM plot_location WHERE plot_location.plot_id = parent_id AND plot_location.parent_table = parent_table_name;
        RETURN NULL;
    END IF;

    

    --IF (json_object->>'id' IS NULL OR (json_object->>'id')::text = 'null') THEN
        DELETE FROM plot_location WHERE plot_location.plot_id = parent_id AND plot_location.parent_table = parent_table_name;
    --END IF;

    --RAISE EXCEPTION '--->: %', json_object->>'id';

    INSERT INTO plot_location (id, plot_id, parent_table, azimuth, distance, 
        radius,
        geometry,
        --circle_geometry,
        no_entities
        )
    VALUES (
        COALESCE(NULLIF((json_object->>'id')::text, 'null')::int, nextval('plot_location_id_seq')),
        parent_id,
        parent_table_name,
        (json_object->>'azimuth')::int,
        (json_object->>'distance')::int,
        (json_object->>'radius')::int,
        ST_GeomFromGeoJSON((json_object->>'geometry')::text),
        --ST_Buffer(
        --    ST_GeomFromGeoJSON((json_object->>'geometry')::text),
        --    (json_object->>'radius')::int, 'quad_segs=8'
        --),
        (json_object->>'no_entities')::boolean
    )
    ON CONFLICT (id) DO UPDATE
    SET 
        plot_id = EXCLUDED.plot_id,
        azimuth = EXCLUDED.azimuth,
        distance = EXCLUDED.distance,
        radius = EXCLUDED.radius,
        --geometry = EXCLUDED.geometry,
        no_entities = EXCLUDED.no_entities
    WHERE plot_location.id = EXCLUDED.id AND plot_location.plot_id = parent_id AND plot_location.parent_table = parent_table_name
    RETURNING * INTO changed_values;

    

    RETURN row_to_json(changed_values);


EXCEPTION WHEN others THEN
        RAISE EXCEPTION 'Error set_plot_location: %', SQLERRM; --SQLERRM;
        RETURN '{}'::json;

END;
$$ LANGUAGE plpgsql;