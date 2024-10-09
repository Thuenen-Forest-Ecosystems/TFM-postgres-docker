SET search_path TO private_ci2027_001, public;

-- Function to import edges
CREATE OR REPLACE FUNCTION set_edges(parent_id int, json_object json, plot_location_id int)
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
        INSERT INTO edges (id, plot_id, edge_status, edge_type, terrain)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('edges_id_seq')),
            parent_id,
            (child_object->>'edge_status')::enum_edge_status,
            (child_object->>'edge_type')::enum_edge_type,
            (child_object->>'terrain')::enum_terrain
            
        )
        ON CONFLICT (id) DO UPDATE
        SET
            plot_id = EXCLUDED.plot_id,
            edge_status = COALESCE(EXCLUDED.edge_status, edges.edge_status),
            edge_type = COALESCE(EXCLUDED.edge_type, edges.edge_type),
            terrain = COALESCE(EXCLUDED.terrain, edges.terrain)
            
        WHERE edges.id = EXCLUDED.id AND edges.plot_id = parent_id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := row_to_json(changed_values);

        modified := modified || modified_element;

    END LOOP;

    DELETE FROM edges WHERE id NOT IN (SELECT id FROM temp_child_ids) AND edges.plot_id = parent_id;

RETURN modified;

EXCEPTION WHEN others THEN
    RAISE EXCEPTION 'Error set_edges: %', SQLERRM; --SQLERRM;
    RETURN '{}'::json;

END;
$$ LANGUAGE plpgsql;


-- Example Insert data
