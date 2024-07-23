SET search_path TO private_ci2027_001, public;

-- Function to import WZP Trees
CREATE OR REPLACE FUNCTION import_wzp_tree(plot_id_parent int, wzp_tree json)
RETURNS int[] AS
$$
DECLARE
    modified_ids int[];
    new_wzp_tree_id int;
    wzp_trees_objects json;
    wzp_trees_object json;
    new_plot_location_id int;
BEGIN


    IF (wzp_tree->'wzp_tree')::text = 'null' THEN
        RETURN modified_ids;
        RAISE EXCEPTION 'wzp_tree: %', wzp_tree;
        RAISE EXCEPTION 'WZP Tree is required / DELETE';
    END IF;
    IF (wzp_tree->'plot_location')::text != 'null' THEN
        SELECT import_plot_location(wzp_tree->'plot_location', plot_id_parent, 'wzp_tree') INTO new_plot_location_id;
    ELSE
        RAISE EXCEPTION 'Plot Location is required / DELETE';
    END IF;


    CREATE TEMP TABLE IF NOT EXISTS temp_wzp_tree_ids (id INT);
    TRUNCATE temp_wzp_tree_ids;

    FOR wzp_trees_object IN SELECT * FROM json_array_elements(wzp_tree->'wzp_tree')
    LOOP

        --wzp_trees_object := wzp_trees_objects->'wzp_tree';

        INSERT INTO temp_wzp_tree_ids (id) VALUES ((wzp_trees_object->>'id')::int);

        
        
        INSERT INTO wzp_tree (id, plot_id, plot_location_id, azimuth, distance, tree_species, bhd, bhd_height, tree_number, tree_height, stem_height, tree_height_azimuth, tree_height_distance, tree_age, stem_breakage, stem_form, pruning, pruning_height, stand_affiliation, inventory_layer, damage_dead, damage_peel_new, damage_peel_old, damage_logging, damage_fungus, damage_resin, damage_beetle, damage_other, cave_tree, crown_clear, crown_dry)
        VALUES (
            (wzp_trees_object->>'id')::int,
            plot_id_parent,
            new_plot_location_id,
            (wzp_trees_object->>'azimuth')::int,
            (wzp_trees_object->>'distance')::int,
            (wzp_trees_object->>'tree_species')::int,
            (wzp_trees_object->>'bhd')::int,
            (wzp_trees_object->>'bhd_height')::int,
            (wzp_trees_object->>'tree_number')::int,
            (wzp_trees_object->>'tree_height')::int,
            (wzp_trees_object->>'stem_height')::int,
            (wzp_trees_object->>'tree_height_azimuth')::int,
            (wzp_trees_object->>'tree_height_distance')::int,
            (wzp_trees_object->>'tree_age')::int,
            (wzp_trees_object->>'stem_breakage')::enum_stem_breakage,
            (wzp_trees_object->>'stem_form')::enum_stem_form,
            (wzp_trees_object->>'pruning')::enum_pruning,
            (wzp_trees_object->>'pruning_height')::int,
            (wzp_trees_object->>'stand_affiliation')::boolean,
            (wzp_trees_object->>'inventory_layer')::enum_stand_layer,
            (wzp_trees_object->>'damage_dead')::boolean,
            (wzp_trees_object->>'damage_peel_new')::boolean,
            (wzp_trees_object->>'damage_peel_old')::boolean,
            (wzp_trees_object->>'damage_logging')::boolean,
            (wzp_trees_object->>'damage_fungus')::boolean,
            (wzp_trees_object->>'damage_resin')::boolean,
            (wzp_trees_object->>'damage_beetle')::boolean,
            (wzp_trees_object->>'damage_other')::boolean,
            (wzp_trees_object->>'cave_tree')::boolean,
            (wzp_trees_object->>'crown_clear')::boolean,
            (wzp_trees_object->>'crown_dry')::boolean
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
        RETURNING id INTO new_wzp_tree_id;

    END LOOP;

    DELETE FROM wzp_tree WHERE id NOT IN (SELECT id FROM temp_wzp_tree_ids) AND wzp_tree.plot_id = plot_id_parent;

RETURN modified_ids;
END;
$$ LANGUAGE plpgsql;
