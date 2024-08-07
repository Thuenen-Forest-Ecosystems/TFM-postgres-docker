SET search_path TO private_ci2027_001, public;

CREATE OR REPLACE FUNCTION set_cluster(clusters json)
RETURNS json AS
$$
DECLARE
    i int = 0;
    new_cluster_id int;
    new_plot_id int;

    modified jsonb := '{"clusters": []}'::jsonb;
    new_cluster jsonb;
    new_plots jsonb;

    clusters_object json;
    cluster_object json;
    states_array enum_state[];

    plots_object json;
    plot_object json;

    changed_values RECORD;

    wzp_trees_object json;
BEGIN
    -- Loop through each feature in the GeoJSON
    FOR clusters_object IN SELECT * FROM json_array_elements(clusters)
    LOOP


        -- ADD CLUSTER
        cluster_object := clusters_object->'cluster';

        states_array := ARRAY(
            SELECT elem::enum_state
            FROM json_array_elements_text(cluster_object->'states') AS elem
        );
        
        INSERT INTO cluster (id, cluster_name, state_administration, state_location, states, sampling_strata, cluster_identifier, email)
        VALUES (
            COALESCE(NULLIF((cluster_object->>'id')::text, 'null')::int, nextval('cluster_id_seq')),
            (cluster_object->>'cluster_name')::int,
            (cluster_object->>'state_administration')::enum_state,
            (cluster_object->>'state_location')::enum_state,
            states_array,
            (cluster_object->>'sampling_strata')::enum_sampling_strata,
            (cluster_object->>'cluster_identifier')::enum_cluster_identifier,
            ARRAY[(cluster_object->>'email')::text] 
        )
        ON CONFLICT (id) DO UPDATE
        SET 
            cluster_name = EXCLUDED.cluster_name,
            state_administration = EXCLUDED.state_administration,
            state_location = EXCLUDED.state_location,
            states = COALESCE(EXCLUDED.states, cluster.states),
            sampling_strata = EXCLUDED.sampling_strata,
            cluster_identifier = COALESCE(EXCLUDED.cluster_identifier, cluster.cluster_identifier),
            email = EXCLUDED.email
        WHERE cluster.id = EXCLUDED.id
        RETURNING * INTO changed_values;

        new_cluster := json_build_object(
            'cluster', changed_values,
            'plot', '[]'::json
        );

        IF (clusters_object->'plot')::text != 'null' THEN
            SELECT(set_plot(changed_values.id, clusters_object->'plot')) INTO new_plots;
            new_cluster := jsonb_set(
                new_cluster,
                '{plot}',
                new_plots
            );
            
        END IF;

        modified := jsonb_set(
            modified,
            '{clusters}',
            (modified->'clusters')::jsonb || jsonb_build_array(new_cluster)
        );
        
    END LOOP;


    RETURN modified;
END;
$$ LANGUAGE plpgsql;