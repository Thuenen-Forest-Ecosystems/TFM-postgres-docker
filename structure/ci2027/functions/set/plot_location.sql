SET search_path TO private_ci2027_001, public;

-- Function to import Plot Location
CREATE OR REPLACE FUNCTION set_plot_location(parent_id int, json_object json, parent_geometry geometry)
RETURNS json AS
$$
DECLARE
    child_object json;

    modified jsonb := '[]'::jsonb;
    modified_element jsonb;

    changed_values RECORD;
BEGIN

    IF json_object IS NULL THEN
        RETURN modified;
    END IF;

    CREATE TEMP TABLE IF NOT EXISTS temp_child_ids (id INT);
    TRUNCATE temp_child_ids;

    FOR child_object IN SELECT * FROM json_array_elements(json_object)
    LOOP

        INSERT INTO plot_location (id,
            plot_id,
            parent_table,
            azimuth,
            distance, 
            radius,
            geometry,
            --geometry_buffer,
            --circle_geometry,
            no_entities
            )
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('plot_location_id_seq')),
            parent_id,
            (child_object->>'parent_table')::enum_plot_location_parent_table,
            (child_object->>'azimuth')::int,
            (child_object->>'distance')::int,
            (child_object->>'radius')::int,
            parent_geometry, --TODO: CREATE NEW POSITION
            --ST_Buffer(
            --    parent_geometry,
            --    (json_object->>'radius')::int, 'quad_segs=8'
            --),
            (child_object->>'no_entities')::boolean
        )
        ON CONFLICT (id) DO UPDATE
        SET 
            plot_id = EXCLUDED.plot_id,
            azimuth = EXCLUDED.azimuth,
            distance = EXCLUDED.distance,
            radius = EXCLUDED.radius,
            geometry = EXCLUDED.geometry,
            --geometry_buffer = EXCLUDED.geometry_buffer,
            no_entities = EXCLUDED.no_entities
        WHERE plot_location.id = EXCLUDED.id
        RETURNING * INTO changed_values;
        
        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);
        
        modified_element := row_to_json(changed_values);

        modified := modified || modified_element;
    
     END LOOP;

     DELETE FROM plot_location WHERE id NOT IN (SELECT id FROM temp_child_ids) AND plot_location.plot_id = parent_id;

RETURN modified;

EXCEPTION WHEN others THEN
        RAISE EXCEPTION 'Error set_plot_location: %', SQLERRM; --SQLERRM;
        RETURN '[]'::json;

END;
$$ LANGUAGE plpgsql;