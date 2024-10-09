SET search_path TO private_ci2027_001, public;

-- Function to import sapling_2m
CREATE OR REPLACE FUNCTION set_sapling_2m(parent_id int, json_object json, plot_location_id int)
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

        INSERT INTO sapling_2m (
            id,
            plot_id,
            stand_affiliation,
            tree_species,
            browsing,
            tree_size_class,
            damage_peel,
            protection_individual,
            count
        )
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('sapling_2m_id_seq')),
            parent_id,
            (child_object->>'stand_affiliation')::int,
            (child_object->>'tree_species')::int,
            (child_object->>'browsing')::int,
            (child_object->>'tree_size_class')::int,
            (child_object->>'damage_peel')::int,
            (child_object->>'protection_individual')::int,
            (child_object->>'count')::int
        )
        ON CONFLICT (id) DO UPDATE
        SET
            plot_id = EXCLUDED.plot_id,
            stand_affiliation = COALESCE(EXCLUDED.stand_affiliation, sapling_2m.stand_affiliation),
            tree_species = COALESCE(EXCLUDED.tree_species, sapling_2m.tree_species),
            browsing = COALESCE(EXCLUDED.browsing, sapling_2m.browsing),
            tree_size_class = COALESCE(EXCLUDED.tree_size_class, sapling_2m.tree_size_class),
            damage_peel = COALESCE(EXCLUDED.damage_peel, sapling_2m.damage_peel),
            protection_individual = COALESCE(EXCLUDED.protection_individual, sapling_2m.protection_individual),
            count = COALESCE(EXCLUDED.count, sapling_2m.count)
            
        WHERE sapling_2m.id = EXCLUDED.id AND sapling_2m.plot_id = parent_id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := row_to_json(changed_values);

        modified := modified || modified_element;

    END LOOP;

    DELETE FROM sapling_2m WHERE id NOT IN (SELECT id FROM temp_child_ids) AND sapling_2m.plot_id = parent_id;

RETURN modified;

EXCEPTION WHEN others THEN
        RAISE EXCEPTION 'Error set_sapling_2m: %', SQLERRM; --SQLERRM;
        RETURN '{}'::json;

END;
$$ LANGUAGE plpgsql;