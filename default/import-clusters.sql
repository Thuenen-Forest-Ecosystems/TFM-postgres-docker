SET search_path TO private_ci2027_001, public;

GRANT usage ON SCHEMA private_ci2027_001 TO web_anon;

CREATE OR REPLACE FUNCTION import_geojson(clusters json)
RETURNS json AS
$$
DECLARE
    i int = 0;
    new_cluster_id int;
    new_plot_id int;

    modified_cluster_ids int[];
    clusters_object json;
    cluster_object json;
    states_array enum_state[];

    plots_object json;
    plot_object json;

    wzp_trees_object json;
BEGIN
    -- Loop through each feature in the GeoJSON
    FOR clusters_object IN SELECT * FROM json_array_elements(clusters)
    LOOP

        cluster_object := clusters_object->'cluster';

        states_array := ARRAY(
            SELECT elem::enum_state
            FROM json_array_elements_text(cluster_object->'states') AS elem
        );
        
        INSERT INTO cluster (id, name, description, state_administration, state_location, states, sampling_strata, cluster_identifier)
        VALUES (
            (cluster_object->>'id')::int, -- Assuming 'id' is an integer
            cluster_object->>'name',
            cluster_object->>'description',
            (cluster_object->>'state_administration')::enum_state,
            (cluster_object->>'state_location')::enum_state,
            states_array,
            (cluster_object->>'sampling_strata')::enum_sampling_strata,
            (cluster_object->>'cluster_identifier')::enum_cluster_identifier
        )
        ON CONFLICT (id) DO UPDATE
        SET 
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            state_administration = EXCLUDED.state_administration,
            state_location = EXCLUDED.state_location,
            states = EXCLUDED.states,
            sampling_strata = EXCLUDED.sampling_strata,
            cluster_identifier = EXCLUDED.cluster_identifier
        WHERE cluster.id = EXCLUDED.id
        RETURNING id INTO new_cluster_id;


        -- START: Insert plot - DATA
        -- Step 1: Collect IDs
        CREATE TEMP TABLE IF NOT EXISTS temp_plot_ids (id INT);
        TRUNCATE temp_plot_ids;

        FOR plots_object IN SELECT * FROM json_array_elements(clusters_object->'plots')
        LOOP

            plot_object := plots_object->'plot';
            

            INSERT INTO temp_plot_ids (id)
                VALUES ((plot_object->>'id')::int);
            
            

            INSERT INTO plot (id, cluster_id, name, description, sampling_strata, state_administration, state_collect, marking_state, harvesting_method)
            VALUES (
                (plot_object->>'id')::int, -- Assuming 'id' is an integer
                new_cluster_id,
                plot_object->>'name',
                plot_object->>'description',
                (cluster_object->>'sampling_strata')::enum_sampling_strata,
                (cluster_object->>'state_administration')::enum_state,
                ('BY')::enum_state,
                (plot_object->>'marking_state')::enum_marking_state,
                (plot_object->>'harvesting_method')::enum_harvesting_method
            )
            ON CONFLICT (id) DO UPDATE
            SET 
                cluster_id = EXCLUDED.cluster_id,
                name = EXCLUDED.name,
                description = EXCLUDED.description,
                sampling_strata = EXCLUDED.sampling_strata,
                state_administration = EXCLUDED.state_administration,
                state_collect = EXCLUDED.state_collect,
                marking_state = EXCLUDED.marking_state,
                harvesting_method = EXCLUDED.harvesting_method
            WHERE plot.id = EXCLUDED.id
            RETURNING id INTO new_plot_id;

            -- add wzp_tree

            -- if not null
            
            IF (plots_object->'wzp_tree')::text != 'null' THEN
                PERFORM import_wzp_tree(new_plot_id, plots_object->'wzp_tree');
            END IF;
            
        END LOOP;

        -- Delete Plots Not in JSON Array
        DELETE FROM plot
        WHERE id NOT IN (SELECT id FROM temp_plot_ids)
        AND cluster_id = new_cluster_id;

    END LOOP;

    RETURN modified_cluster_ids;
END;
$$ LANGUAGE plpgsql;

-- Function to import Plot Location
CREATE OR REPLACE FUNCTION import_plot_location(plot_location json)
RETURNS int AS
$$
DECLARE
    new_plot_location_id int;
BEGIN

    INSERT INTO plot_location (id, azimuth, distance, radius, geometry, no_entities)
    VALUES (
        (plot_location->>'id')::int,
        (plot_location->>'azimuth')::int,
        (plot_location->>'distance')::int,
        (plot_location->>'radius')::int,
        ST_GeomFromGeoJSON((plot_location->>'geometry')::text),
        (plot_location->>'no_entities')::boolean
    )
    ON CONFLICT (id) DO UPDATE
    SET 
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

-- Function to import WZP Trees
CREATE OR REPLACE FUNCTION import_wzp_tree(plot_id_parent int, wzp_tree json)
RETURNS json AS
$$
DECLARE
    modified_wzp_tree_ids int[];
    new_wzp_tree_id int;
    wzp_trees_objects json;
    wzp_trees_object json;
    new_plot_location_id int;
BEGIN


    CREATE TEMP TABLE IF NOT EXISTS temp_wzp_tree_ids (id INT);
    TRUNCATE temp_wzp_tree_ids;

    FOR wzp_trees_objects IN SELECT * FROM json_array_elements(wzp_tree)
    LOOP

        wzp_trees_object := wzp_trees_objects->'wzp_tree';

        INSERT INTO temp_wzp_tree_ids (id) VALUES ((wzp_trees_object->>'id')::int);

        IF (wzp_trees_objects->'plot_location')::text != 'null' THEN
            SELECT import_plot_location(wzp_trees_objects->'plot_location') INTO new_plot_location_id;
            
        ELSE
            RAISE EXCEPTION 'Plot Location is required / DELETE';
        END IF;
        


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

RETURN modified_wzp_tree_ids;
END;
$$ LANGUAGE plpgsql;



ALTER FUNCTION import_geojson(json) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION import_geojson(json) TO web_anon;

GRANT SELECT, UPDATE, INSERT ON TABLE cluster TO web_anon;
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE plot TO web_anon;
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE wzp_tree TO web_anon;
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE plot_location TO web_anon;
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE deadwood TO web_anon;



--
--GRANT SELECT ON TABLE plot_location (id, updated_at, azimuth, distance, radius, geometry, no_entities) TO web_anon;
--REVOKE UPDATE(updated_at) ON table_name FROM target_user;
ALTER TABLE plot_location ENABLE ROW LEVEL SECURITY;

--CREATE POLICY allow_update_except_radius ON plot_location FOR UPDATE TO web_anon USING (true);

-- RLS Policy to restrict 'web_anon' from updating 'radius' within 'plot_location'
--CREATE OR REPLACE FUNCTION fn_check_column_permissions()
--RETURNS TRIGGER AS $$
--BEGIN
--  -- Check if the 'radius' field is being modified
--  IF TG_OP = 'UPDATE' AND OLD.radius IS DISTINCT FROM NEW.radius THEN
--    NEW.radius := OLD.radius;
--  END IF;
--  RETURN NEW;
--END;
--$$ LANGUAGE plpgsql;
--
--CREATE TRIGGER trg_check_column_permissions
--BEFORE UPDATE ON plot_location
--FOR EACH ROW
--WHEN (CURRENT_USER = 'web_anon')
--FOR EACH ROW EXECUTE FUNCTION fn_check_column_permissions();


-- postgres set rls dynamically
-- postgres set rls dynamically with optional column-specific trigger creation for update restrictions
CREATE OR REPLACE FUNCTION apply_rls_policy_and_trigger(
    table_name TEXT,
    policy_name TEXT,
    role_name TEXT,
    using_expr TEXT,
    with_check_expr TEXT DEFAULT NULL,
    restricted_column TEXT DEFAULT NULL -- New parameter for column-specific update restriction
) RETURNS void AS $$
BEGIN
    -- Drop the policy if it already exists
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', policy_name, table_name);
    
    -- Create the new policy with or without a WITH CHECK expression
    IF with_check_expr IS NOT NULL THEN
        EXECUTE format(
            'CREATE POLICY %I ON %I FOR ALL TO %I USING (%s) WITH CHECK (%s)',
            policy_name, table_name, role_name, using_expr, with_check_expr
        );
    ELSE
        EXECUTE format(
            'CREATE POLICY %I ON %I FOR ALL TO %I USING (%s)',
            policy_name, table_name, role_name, using_expr
        );
    END IF;

    -- Corrected part of the apply_rls_policy_and_trigger function
    IF restricted_column IS NOT NULL THEN
        -- Define the trigger function SQL using format to inject identifiers and literals properly
        EXECUTE format(
            $f$
            CREATE OR REPLACE FUNCTION %I()
            RETURNS TRIGGER AS $body$
            BEGIN
                IF OLD.%I IS DISTINCT FROM NEW.%I THEN
                    -- set the NEW value to the OLD value
                    NEW.%I := OLD.%I;

                    --RAISE EXCEPTION 'Updating the %I column is not allowed for.';
                END IF;
                RETURN NEW;
            END;
            $body$ LANGUAGE plpgsql;
            $f$,
            'fn_prevent_' || restricted_column || '_update', -- Function name
            restricted_column, -- OLD.%I
            restricted_column, -- NEW.%I
            restricted_column, -- OLD.%I SET
            restricted_column, -- NEW.%I SET
            restricted_column, -- Exception message column name
            role_name -- Exception message role name
        );

        -- Define the trigger using format to inject identifiers properly
        EXECUTE format(
            $f$
            CREATE TRIGGER %I
            BEFORE UPDATE ON %I
            FOR EACH ROW
            WHEN (CURRENT_USER = %L)
            EXECUTE FUNCTION %I();
            $f$,
            'trg_prevent_' || restricted_column || '_update', -- Trigger name
            table_name, -- Table name
            role_name, -- CURRENT_USER comparison
            'fn_prevent_' || restricted_column || '_update' -- Function name
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Apply the RLS policy to restrict 'web_anon' from updating 'radius' within 'plot_location'

CREATE OR REPLACE FUNCTION apply_rls_policy_and_trigger()
RETURNS void AS
$$
DECLARE
BEGIN
    
    
    --GRANT web_anon TO current_user;

    PERFORM apply_rls_policy_and_trigger(
        'plot_location',
        'allow_update_except_radius',
        'web_anon',
        'true',
        NULL,
        'radius'
    );
END;
$$ LANGUAGE plpgsql;

ALTER TABLE plot_location OWNER TO web_anon;
ALTER SCHEMA private_ci2027_001 OWNER TO web_anon;


CREATE OR REPLACE FUNCTION check_update_permission(table_name TEXT, column_name TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    trigger_name TEXT;
    role_allowed TEXT;
    is_allowed BOOLEAN := FALSE;
BEGIN
    -- Construct the trigger name based on the column name
    trigger_name := 'trg_prevent_' || column_name || '_update';

    -- Attempt to find a trigger by name that matches the pattern and is associated with the given table
    SELECT INTO role_allowed rolname
    FROM pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    JOIN pg_proc p ON t.tgfoid = p.oid
    JOIN pg_roles r ON r.rolname = current_user
    WHERE c.relname = table_name
    AND t.tgname = trigger_name
    AND p.proname = 'fn_prevent_' || column_name || '_update';

    -- Check if the CURRENT_USER matches the role allowed to update
    -- This part is simplified; actual implementation might need to parse the function definition
    -- or rely on naming conventions or external metadata to determine the allowed role
    IF role_allowed IS NOT NULL THEN
        is_allowed := TRUE;
    END IF;

    RETURN is_allowed;
END;
$$ LANGUAGE plpgsql;