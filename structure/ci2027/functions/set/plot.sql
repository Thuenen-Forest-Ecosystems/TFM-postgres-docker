SET search_path TO private_ci2027_001, public;

CREATE OR REPLACE FUNCTION set_plot(parent_id int, json_object json)
RETURNS json AS
$$
DECLARE

    child_object json;

    modified jsonb := '[]'::jsonb;
    modified_element jsonb;

    child_wzp_tree jsonb;
    child_plot_location json;

    changed_values RECORD;
    changed_id INTEGER;

    locationId int := 0;

    id_array INTEGER[];
    row_count INTEGER;
BEGIN

    -- return if json_object is null
    IF json_object IS NULL THEN
        RETURN modified;
    END IF;

    -- ADD PLOT
    --id_array := '[]'::INTEGER[];
    
    FOR child_object IN SELECT * FROM json_array_elements(json_object)
    LOOP

        

        IF (child_object->>'cluster_id')::text != 'null' AND (child_object->>'cluster_id')::int != parent_id THEN
            CONTINUE;
        END IF;

        
        
        INSERT INTO plot (id, cluster_id, plot_name, sampling_strata, state_administration, state_collect, marking_state, harvesting_method)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('plot_id_seq')),
            parent_id,
            (child_object->>'plot_name')::int,
            (child_object->>'sampling_strata')::enum_sampling_strata,
            (child_object->>'state_administration')::enum_state,
            (child_object->>'state_collect')::enum_state,
            (child_object->>'marking_state')::enum_marking_state,
            (child_object->>'harvesting_method')::enum_harvesting_method
        )
        ON CONFLICT (id) DO UPDATE
        SET 
            cluster_id = parent_id,
            plot_name = EXCLUDED.plot_name,
            sampling_strata = EXCLUDED.sampling_strata,
            state_administration = EXCLUDED.state_administration,
            state_collect = EXCLUDED.state_collect,
            marking_state = EXCLUDED.marking_state,
            harvesting_method = EXCLUDED.harvesting_method
        WHERE plot.id = EXCLUDED.id AND plot.cluster_id = parent_id
        RETURNING * INTO changed_values;

        -- push new id to id_array
        id_array := id_array || changed_values.id;

        changed_id := changed_values.id;

        modified_element := json_build_object(
            'plot', changed_values,
            'wzp_tree', '[]'::json,
            'deadwood', '[]'::json,
            'position', '[]'::json
        );

        IF (child_object->'wzp_tree')::text != 'null' THEN

            -- REPLACE WITH REFERENCE POSITION
            --SELECT(set_plot_location(changed_values.id, child_object->'wzp_tree'->'plot_location', 'wzp_tree')) INTO child_plot_location;
            --locationId := COALESCE(NULLIF((child_plot_location->>'id')::text, 'null')::int, NULL);

            SELECT(set_wzp_tree(changed_values.id, child_object->'wzp_tree', NULL)) INTO child_wzp_tree;
            modified_element := jsonb_set(
                modified_element,
                '{wzp_tree}',
                child_wzp_tree
            );
            --IF child_plot_location IS NOT NULL THEN
            --    modified_element := jsonb_set(
            --        modified_element,
            --        '{wzp_tree}',
            --        child_plot_location::jsonb
            --    );
            --END IF;

        END IF;

        IF (child_object->'deadwood')::text != 'null' THEN
            
            SELECT(set_deadwood(changed_values.id, child_object->'deadwood', NULL)) INTO child_wzp_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{deadwood}',
                child_wzp_tree
            );

            
        END IF;

        IF (child_object->'position')::text != 'null' THEN

            SELECT(set_position(changed_values.id, child_object->'position')) INTO child_wzp_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{position}',
                child_wzp_tree
            );

            
            
        END IF;

        IF (child_object->'edges')::text != 'null' THEN

            SELECT(set_edges(changed_values.id, child_object->'edges',NULL)) INTO child_wzp_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{edges}',
                child_wzp_tree
            );

        END IF;

        modified := modified || modified_element;
    END LOOP;

        
    
    -- DELETE PLOTS not in id_array
    DELETE FROM plot WHERE cluster_id = parent_id AND id NOT IN (SELECT unnest(id_array));
    
    RETURN modified;

EXCEPTION WHEN others THEN
        RAISE EXCEPTION 'Error set_plot: %', SQLERRM; --SQLERRM;
        RETURN '{}'::json;


END;
$$ LANGUAGE plpgsql;