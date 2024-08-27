SET search_path TO private_ci2027_001, public;

CREATE OR REPLACE FUNCTION set_cluster(json_object json)
RETURNS json AS
$$
DECLARE
    i int = 0;
    new_cluster_id int;
    new_plot_id int;

    modified jsonb := '{"clusters": []}'::jsonb;
    modified_element jsonb := '[]'::jsonb;

    new_cluster jsonb;
    new_plots jsonb;

    clusters_object json;
    cluster_object json;
    states_array enum_state[];

    plots_object json;
    plot_object json;

    changed_values RECORD;

    wzp_trees_object json;
    username text;
BEGIN

    username := current_setting('request.jwt.claims', true)::json->>'email';

    -- Loop through each feature in the GeoJSON
    FOR cluster_object IN SELECT * FROM json_array_elements(json_object)
    LOOP


        -- ADD CLUSTER
        --cluster_object := clusters_object->'cluster';

        -- REPLACE EMAIL BY USER ID

        states_array := ARRAY(
            SELECT elem::enum_state
            FROM json_array_elements_text(cluster_object->'states') AS elem
        );

        
        INSERT INTO cluster (
            id,
            state_administration,
            state_location,
            states,
            sampling_strata,
            cluster_identifier,
            select_access_by,
            update_access_by
        )
        VALUES (
            (cluster_object->>'id')::int,
            (cluster_object->>'state_administration')::enum_state,
            (cluster_object->>'state_location')::enum_state,
            states_array,
            (cluster_object->>'sampling_strata')::enum_sampling_strata,
            (cluster_object->>'cluster_identifier')::enum_cluster_identifier,
            ARRAY(SELECT json_array_elements_text(cluster_object->'select_access_by'))::text[],
            ARRAY(SELECT json_array_elements_text(cluster_object->'update_access_by'))::text[]
        )
        ON CONFLICT (id) DO UPDATE
        SET 
            state_administration = 'BB', --COALESCE(EXCLUDED.state_administration, cluster.state_administration)
            state_location = COALESCE(EXCLUDED.state_location, cluster.state_location),
            states = COALESCE(EXCLUDED.states, cluster.states),
            sampling_strata = COALESCE(EXCLUDED.sampling_strata, cluster.sampling_strata),
            cluster_identifier = COALESCE(EXCLUDED.cluster_identifier, cluster.cluster_identifier),
            select_access_by = COALESCE(EXCLUDED.select_access_by, cluster.select_access_by), -- select_access_by = cluster.select_access_by || '{"new item"}'
            update_access_by = COALESCE(EXCLUDED.update_access_by, cluster.update_access_by) -- select_access_by = cluster.select_access_by || '{"new item"}'
        WHERE cluster.id = EXCLUDED.id
        RETURNING * INTO changed_values;

        new_cluster := row_to_json(changed_values);

       
        IF (cluster_object->'plot')::text != 'null' THEN

            SELECT(set_plot(changed_values.id, cluster_object->'plot')) INTO new_plots;
            new_cluster := jsonb_set(
                new_cluster,
                '{plot}',
                COALESCE(new_plots, 'null'::jsonb)
            );
            
            
        END IF;

        -- ADD new_cluster TO modified_element
        modified_element := new_cluster || jsonb_build_array(new_cluster);

        --modified := jsonb_set(
        --    modified,
        --    '{clusters}',
        --    (modified->'clusters')::jsonb || jsonb_build_array(new_cluster)
        --);
        
    END LOOP;

    

    RETURN modified_element;

EXCEPTION WHEN others THEN
        RAISE EXCEPTION 'Error set_cluster: %', SQLERRM; --SQLERRM;

END;
$$ LANGUAGE plpgsql;