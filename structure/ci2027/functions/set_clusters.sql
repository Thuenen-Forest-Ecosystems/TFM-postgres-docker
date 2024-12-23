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

    trees_object json;
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
            FROM json_array_elements_text(cluster_object->'states_affected') AS elem
        );

        
        INSERT INTO cluster (
            cluster_name,
            state_responsible,
            states_affected,
            grid_density,
            cluster_status,
            cluster_situation,
            select_access_by,
            update_access_by
        )
        VALUES (
            (cluster_object->>'cluster_name')::int,
            (cluster_object->>'state_responsible')::enum_state,
            states_array,
            (cluster_object->>'grid_density')::enum_grid_density,
            (cluster_object->>'cluster_status')::enum_cluster_status,
            (cluster_object->>'cluster_situation')::enum_cluster_situation,
            ARRAY(SELECT json_array_elements_text(cluster_object->'select_access_by'))::text[],
            ARRAY(SELECT json_array_elements_text(cluster_object->'update_access_by'))::text[]
        )
        ON CONFLICT (cluster_name) DO UPDATE
        SET 
            state_responsible = COALESCE(EXCLUDED.state_responsible, cluster.state_responsible),
            states_affected = COALESCE(EXCLUDED.states_affected, cluster.states_affected),
            grid_density = COALESCE(EXCLUDED.grid_density, cluster.grid_density),
            cluster_status = COALESCE(EXCLUDED.cluster_status, cluster.cluster_status),
            select_access_by = COALESCE(EXCLUDED.select_access_by, cluster.select_access_by), -- select_access_by = cluster.select_access_by || '{"new item"}'
            update_access_by = COALESCE(EXCLUDED.update_access_by, cluster.update_access_by) -- select_access_by = cluster.select_access_by || '{"new item"}'
        WHERE cluster.cluster_name = EXCLUDED.cluster_name
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