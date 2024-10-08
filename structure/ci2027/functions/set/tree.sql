SET search_path TO private_ci2027_001, public;

-- Function to import WZP Trees
CREATE OR REPLACE FUNCTION set_tree(parent_id int, json_object json)
RETURNS json AS
$$
DECLARE
    child_object json;

    modified jsonb := '[]'::jsonb;
    modified_element jsonb;

    changed_values RECORD;
    plot_location_geometry RECORD;

    new_geometry geometry;
BEGIN

    IF json_object IS NULL THEN
        RETURN modified;
    END IF;

    SELECT geometry INTO plot_location_geometry FROM plot_location WHERE plot_location.plot_id = parent_id AND  plot_location.parent_table = 'tree' LIMIT 1;
    
    CREATE TEMP TABLE IF NOT EXISTS temp_child_ids (id INT);
    TRUNCATE temp_child_ids;

    FOR child_object IN SELECT * FROM json_array_elements(json_object)
    LOOP
        IF plot_location_geometry IS NOT NULL THEN
            new_geometry := ST_Transform(
                ST_PROJECT( --https://postgis.net/docs/ST_Project.html
                    plot_location_geometry.geometry::geometry,
                    (child_object->>'distance')::int / 100, -- cm to m
                    radians((child_object->>'azimuth')::int)
                )::geometry,
                4326
            )::geometry;
        ELSE
            new_geometry := NULL;
        END IF;
        
        INSERT INTO tree (id, plot_id, azimuth, distance, geometry, tree_species, bhd, bhd_height, tree_id, tree_height, stem_height, tree_height_azimuth, tree_height_distance, tree_age, stem_breakage, stem_form, pruning, pruning_height, within_stand, stand_layer, damage_dead, damage_peel_new, damage_peel_old, damage_logging, damage_fungus, damage_resin, damage_beetle, damage_other, cave_tree, crown_dead_wood, tree_top_drought)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('tree_id_seq')),
            parent_id,
            (child_object->>'azimuth')::int,
            (child_object->>'distance')::int,
            new_geometry,

            (child_object->>'tree_species')::int,
            (child_object->>'bhd')::int,
            (child_object->>'bhd_height')::int,
            (child_object->>'tree_id')::int,
            (child_object->>'tree_height')::int,
            (child_object->>'stem_height')::int,
            (child_object->>'tree_height_azimuth')::int,
            (child_object->>'tree_height_distance')::int,
            (child_object->>'tree_age')::int,
            (child_object->>'stem_breakage')::enum_stem_breakage,
            (child_object->>'stem_form')::enum_stem_form,
            (child_object->>'pruning')::enum_pruning,
            (child_object->>'pruning_height')::int,
            (child_object->>'within_stand')::boolean,
            (child_object->>'stand_layer')::enum_stand_layer,
            (child_object->>'damage_dead')::boolean,
            (child_object->>'damage_peel_new')::boolean,
            (child_object->>'damage_peel_old')::boolean,
            (child_object->>'damage_logging')::boolean,
            (child_object->>'damage_fungus')::boolean,
            (child_object->>'damage_resin')::boolean,
            (child_object->>'damage_beetle')::boolean,
            (child_object->>'damage_other')::boolean,
            (child_object->>'cave_tree')::boolean,
            (child_object->>'crown_dead_wood')::boolean,
            (child_object->>'tree_top_drought')::boolean
        )
        ON CONFLICT (id) DO UPDATE
        SET
            plot_id = EXCLUDED.plot_id,
            azimuth = EXCLUDED.azimuth,
            distance = EXCLUDED.distance,
            geometry = EXCLUDED.geometry,

            tree_species = EXCLUDED.tree_species,
            bhd = EXCLUDED.bhd,
            bhd_height = EXCLUDED.bhd_height,
            tree_id = EXCLUDED.tree_id,
            tree_height = EXCLUDED.tree_height,
            stem_height = EXCLUDED.stem_height,
            tree_height_azimuth = EXCLUDED.tree_height_azimuth,
            tree_height_distance = EXCLUDED.tree_height_distance,
            tree_age = EXCLUDED.tree_age,
            stem_breakage = EXCLUDED.stem_breakage,
            stem_form = EXCLUDED.stem_form,
            pruning = EXCLUDED.pruning,
            pruning_height = EXCLUDED.pruning_height,
            within_stand = EXCLUDED.within_stand,
            stand_layer = EXCLUDED.stand_layer,
            damage_dead = EXCLUDED.damage_dead,
            damage_peel_new = EXCLUDED.damage_peel_new,
            damage_peel_old = EXCLUDED.damage_peel_old,
            damage_logging = EXCLUDED.damage_logging,
            damage_fungus = EXCLUDED.damage_fungus,
            damage_resin = EXCLUDED.damage_resin,
            damage_beetle = EXCLUDED.damage_beetle,
            damage_other = EXCLUDED.damage_other,
            cave_tree = EXCLUDED.cave_tree,
            crown_dead_wood = EXCLUDED.crown_dead_wood,
            tree_top_drought = EXCLUDED.tree_top_drought
        WHERE tree.id = EXCLUDED.id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := row_to_json(changed_values);

        modified := modified || modified_element;

    END LOOP;

    DELETE FROM tree WHERE id NOT IN (SELECT id FROM temp_child_ids) AND tree.plot_id = parent_id;

RETURN modified;

EXCEPTION WHEN others THEN
        RAISE EXCEPTION 'Error set_tree: %', SQLERRM; --SQLERRM;
        RETURN '{}'::json;

END;
$$ LANGUAGE plpgsql;
