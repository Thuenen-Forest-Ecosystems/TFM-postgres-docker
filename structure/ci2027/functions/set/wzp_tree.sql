SET search_path TO private_ci2027_001, public;

-- Function to import WZP Trees
CREATE OR REPLACE FUNCTION set_wzp_tree(parent_id int, json_object json, plot_location_id int)
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
        
        INSERT INTO wzp_tree (id, plot_id, plot_location_id, azimuth, distance, tree_species, bhd, bhd_height, tree_number, tree_height, stem_height, tree_height_azimuth, tree_height_distance, tree_age, stem_breakage, stem_form, pruning, pruning_height, stand_affiliation, inventory_layer, damage_dead, damage_peel_new, damage_peel_old, damage_logging, damage_fungus, damage_resin, damage_beetle, damage_other, cave_tree, crown_clear, crown_dry)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('wzp_tree_id_seq')),
            parent_id,
            plot_location_id,
            (child_object->>'azimuth')::int,
            (child_object->>'distance')::int,
            (child_object->>'tree_species')::int,
            (child_object->>'bhd')::int,
            (child_object->>'bhd_height')::int,
            (child_object->>'tree_number')::int,
            (child_object->>'tree_height')::int,
            (child_object->>'stem_height')::int,
            (child_object->>'tree_height_azimuth')::int,
            (child_object->>'tree_height_distance')::int,
            (child_object->>'tree_age')::int,
            (child_object->>'stem_breakage')::enum_stem_breakage,
            (child_object->>'stem_form')::enum_stem_form,
            (child_object->>'pruning')::enum_pruning,
            (child_object->>'pruning_height')::int,
            (child_object->>'stand_affiliation')::boolean,
            (child_object->>'inventory_layer')::enum_stand_layer,
            (child_object->>'damage_dead')::boolean,
            (child_object->>'damage_peel_new')::boolean,
            (child_object->>'damage_peel_old')::boolean,
            (child_object->>'damage_logging')::boolean,
            (child_object->>'damage_fungus')::boolean,
            (child_object->>'damage_resin')::boolean,
            (child_object->>'damage_beetle')::boolean,
            (child_object->>'damage_other')::boolean,
            (child_object->>'cave_tree')::boolean,
            (child_object->>'crown_clear')::boolean,
            (child_object->>'crown_dry')::boolean
        )
        ON CONFLICT (id) DO UPDATE
        SET
            plot_id = EXCLUDED.plot_id,
            plot_location_id = EXCLUDED.plot_location_id,
            azimuth = EXCLUDED.azimuth,
            distance = EXCLUDED.distance,
            tree_species = EXCLUDED.tree_species,
            bhd = EXCLUDED.bhd,
            bhd_height = EXCLUDED.bhd_height,
            tree_number = EXCLUDED.tree_number,
            tree_height = EXCLUDED.tree_height,
            stem_height = EXCLUDED.stem_height,
            tree_height_azimuth = EXCLUDED.tree_height_azimuth,
            tree_height_distance = EXCLUDED.tree_height_distance,
            tree_age = EXCLUDED.tree_age,
            stem_breakage = EXCLUDED.stem_breakage,
            stem_form = EXCLUDED.stem_form,
            pruning = EXCLUDED.pruning,
            pruning_height = EXCLUDED.pruning_height,
            stand_affiliation = EXCLUDED.stand_affiliation,
            inventory_layer = EXCLUDED.inventory_layer,
            damage_dead = EXCLUDED.damage_dead,
            damage_peel_new = EXCLUDED.damage_peel_new,
            damage_peel_old = EXCLUDED.damage_peel_old,
            damage_logging = EXCLUDED.damage_logging,
            damage_fungus = EXCLUDED.damage_fungus,
            damage_resin = EXCLUDED.damage_resin,
            damage_beetle = EXCLUDED.damage_beetle,
            damage_other = EXCLUDED.damage_other,
            cave_tree = EXCLUDED.cave_tree,
            crown_clear = EXCLUDED.crown_clear,
            crown_dry = EXCLUDED.crown_dry
        WHERE wzp_tree.id = EXCLUDED.id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := json_build_object(
            'wzp_tree', changed_values
        );

        modified := modified || modified_element;

    END LOOP;

    DELETE FROM wzp_tree WHERE id NOT IN (SELECT id FROM temp_child_ids) AND wzp_tree.plot_id = parent_id;

RETURN modified;
END;
$$ LANGUAGE plpgsql;
