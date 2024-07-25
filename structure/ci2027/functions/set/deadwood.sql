SET search_path TO private_ci2027_001, public;

-- Function to import WZP Trees
CREATE OR REPLACE FUNCTION set_deadwood(parent_id int, json_object json, plot_location_id int)
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

        INSERT INTO deadwood (id, plot_id, plot_location_id, azimuth, distance, tree_species, bhd, bhd_height, tree_number, tree_height, stem_height, tree_height_azimuth, tree_height_distance, tree_age, stem_breakage, stem_form, pruning, pruning_height, stand_affiliation, inventory_layer, damage_dead, damage_peel_new, damage_peel_old, damage_logging, damage_fungus, damage_resin, damage_beetle, damage_other, cave_tree, crown_clear, crown_dry)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('deadwood_id_seq')),
            parent_id,
            plot_location_id,
            (deadwood_object->>'azimuth')::int,
            (deadwood_object->>'distance')::int,
            (deadwood_object->>'tree_species')::int,
            (deadwood_object->>'bhd')::int,
            (deadwood_object->>'bhd_height')::int,
            (deadwood_object->>'tree_number')::int,
            (deadwood_object->>'tree_height')::int,
            (deadwood_object->>'stem_height')::int,
            (deadwood_object->>'tree_height_azimuth')::int,
            (deadwood_object->>'tree_height_distance')::int,
            (deadwood_object->>'tree_age')::int,
            (deadwood_object->>'stem_breakage')::enum_stem_breakage,
            (deadwood_object->>'stem_form')::enum_stem_form,
            (deadwood_object->>'pruning')::enum_pruning,
            (deadwood_object->>'pruning_height')::int,
            (deadwood_object->>'stand_affiliation')::boolean,
            (deadwood_object->>'inventory_layer')::enum_stand_layer,
            (deadwood_object->>'damage_dead')::boolean,
            (deadwood_object->>'damage_peel_new')::boolean,
            (deadwood_object->>'damage_peel_old')::boolean,
            (deadwood_object->>'damage_logging')::boolean,
            (deadwood_object->>'damage_fungus')::boolean,
            (deadwood_object->>'damage_resin')::boolean,
            (deadwood_object->>'damage_beetle')::boolean,
            (deadwood_object->>'damage_other')::boolean,
            (deadwood_object->>'cave_tree')::boolean,
            (deadwood_object->>'crown_clear')::boolean,
            (deadwood_object->>'crown_dry')::boolean
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
        WHERE deadwood.id = EXCLUDED.id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := json_build_object(
            'deadwood', changed_values
        );

        modified := modified || modified_element;

    END LOOP;

    DELETE FROM deadwood WHERE id NOT IN (SELECT id FROM temp_deadwood_ids) AND deadwood.plot_id = parent_id;

RETURN modified;
END;
$$ LANGUAGE plpgsql;