SET search_path TO private_ci2027_001, public;

CREATE OR REPLACE FUNCTION set_plot(parent_id int, json_object json)
RETURNS json AS
$$
DECLARE

    parent_object json;
    child_object json;

    modified jsonb := '[]'::jsonb;
    modified_element jsonb;

    child_wzp_tree jsonb;
    child_plot_location json;

    changed_values RECORD;

    locationId int;
BEGIN

    -- return if json_object is null
    IF json_object IS NULL THEN
        RETURN modified;
    END IF;

    -- ADD PLOT
    CREATE TEMP TABLE IF NOT EXISTS temp_child_ids (id INT);
    TRUNCATE temp_child_ids;
    
    FOR parent_object IN SELECT * FROM json_array_elements(json_object)
    LOOP


        child_object := parent_object->'plot';

        IF (child_object->>'cluster_id')::text != 'null' AND (child_object->>'cluster_id')::int != parent_id THEN
            CONTINUE;
        END IF;
        
        INSERT INTO plot (id, cluster_id, name, description, sampling_strata, state_administration, state_collect, marking_state, harvesting_method)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('plot_id_seq')),
            parent_id,
            child_object->>'name',
            child_object->>'description',
            (child_object->>'sampling_strata')::enum_sampling_strata,
            (child_object->>'state_administration')::enum_state,
            (child_object->>'state_collect')::enum_state,
            (child_object->>'marking_state')::enum_marking_state,
            (child_object->>'harvesting_method')::enum_harvesting_method
        )
        ON CONFLICT (id) DO UPDATE
        SET 
            cluster_id = parent_id,
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            sampling_strata = EXCLUDED.sampling_strata,
            state_administration = EXCLUDED.state_administration,
            state_collect = EXCLUDED.state_collect,
            marking_state = EXCLUDED.marking_state,
            harvesting_method = EXCLUDED.harvesting_method
        WHERE plot.id = EXCLUDED.id AND plot.cluster_id = parent_id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := json_build_object(
            'plot', changed_values,
            'wzp_tree', '{
                "wzp_tree": [],
                "plot_location": null
            }'::json,
            'deadwood', '{
                "deadwood": [],
                "plot_location": null
            }'::json,
            'position', '{
                "position": [],
                "plot_location": null
            }'::json
        );

        IF (parent_object->'wzp_tree')::text != 'null' THEN

            SELECT(set_plot_location(changed_values.id, parent_object->'wzp_tree'->'plot_location', 'wzp_tree')) INTO child_plot_location;

            locationId := COALESCE(NULLIF((child_plot_location->>'id')::text, 'null')::int, NULL);

            SELECT(set_wzp_tree(changed_values.id, parent_object->'wzp_tree'->'wzp_tree', locationId)) INTO child_wzp_tree;
            modified_element := jsonb_set(
                modified_element,
                '{wzp_tree, wzp_tree}',
                child_wzp_tree
            );
            IF child_plot_location IS NOT NULL THEN
                modified_element := jsonb_set(
                    modified_element,
                    '{wzp_tree, plot_location}',
                    child_plot_location::jsonb
                );
            END IF;

        END IF;

        IF (parent_object->'deadwood')::text != 'null' AND (parent_object->'deadwood'->'plot_location')::text != 'null' THEN

            SELECT( set_plot_location(changed_values.id, parent_object->'deadwood'->'plot_location', 'deadwood') ) INTO child_plot_location;

            locationId := COALESCE(NULLIF((child_plot_location->>'id')::text, 'null')::int, NULL);
            
            SELECT(set_deadwood(changed_values.id, parent_object->'deadwood'->'deadwood',locationId)) INTO child_wzp_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{deadwood, deadwood}',
                child_wzp_tree
            );

            IF child_plot_location IS NOT NULL THEN
                modified_element := jsonb_set(
                    modified_element,
                    '{deadwood, plot_location}',
                    child_plot_location::jsonb
                );
            END IF;
            
        END IF;

        IF (parent_object->'position')::text != 'null' AND (parent_object->'position'->'plot_location')::text != 'null' THEN

            SELECT( set_plot_location(changed_values.id, parent_object->'position'->'plot_location', 'position') ) INTO child_plot_location;

            locationId := COALESCE(NULLIF((child_plot_location->>'id')::text, 'null')::int, NULL);
            
            SELECT(set_position(changed_values.id, parent_object->'position'->'position',locationId)) INTO child_wzp_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{position, position}',
                child_wzp_tree
            );

            IF child_plot_location IS NOT NULL THEN
                modified_element := jsonb_set(
                    modified_element,
                    '{position, plot_location}',
                    child_plot_location::jsonb
                );
            END IF;
            
        END IF;

        modified := modified || modified_element;
    END LOOP;

    DELETE FROM plot WHERE id NOT IN (SELECT id FROM temp_child_ids) AND plot.cluster_id = parent_id;

    RETURN modified;

EXCEPTION WHEN others THEN
        RAISE EXCEPTION 'Error set_plot: %', SQLERRM; --SQLERRM;
        RETURN '{}'::json;


END;
$$ LANGUAGE plpgsql;