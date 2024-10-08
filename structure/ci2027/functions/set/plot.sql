SET search_path TO private_ci2027_001, public;

CREATE OR REPLACE FUNCTION set_plot(parent_id int, json_object json)
RETURNS json AS
$$
DECLARE

    child_object json;

    modified jsonb := '[]'::jsonb;
    modified_element jsonb;

    child_tree jsonb;
    child_plot_location jsonb;

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

        INSERT INTO plot (
            id,
            cluster_id,
            plot_name,
            sampling_stratum,
            state,
            state_responsible,
            marker_status,
            harvesting_method,
            geometry,
            growth_district,
            forest_status,
            accessibility,
            forest_office,
            elevation_level,
            property_type,
            property_size_class
        )
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('plot_id_seq')),
            parent_id,
            (child_object->>'plot_name')::int,
            (child_object->>'sampling_stratum')::int,
            (child_object->>'state')::enum_state,
            (child_object->>'state_responsible')::enum_state,
            (child_object->>'marker_status')::enum_marker_status,
            (child_object->>'harvesting_method')::enum_harvesting_method,
            
            ST_GeomFromGeoJSON((child_object->>'geometry')::text),

            (child_object->>'growth_district')::int,
            (child_object->>'forest_status')::enum_forest_status,
            (child_object->>'accessibility')::int,
            (child_object->>'forest_office')::int,
            (child_object->>'elevation_level')::enum_elevation_level,
            (child_object->>'property_type')::enum_property_type,
            (child_object->>'property_size_class')::enum_property_size_class
        )
        ON CONFLICT (id) DO UPDATE
        SET 
            --cluster_id = parent_id,
            plot_name = COALESCE(EXCLUDED.plot_name, plot.plot_name),
            sampling_stratum = COALESCE(EXCLUDED.sampling_stratum, plot.sampling_stratum),
            state = COALESCE(EXCLUDED.state, plot.state),
            state_responsible = COALESCE(EXCLUDED.state_responsible, plot.state_responsible),
            marker_status = COALESCE(EXCLUDED.marker_status, plot.marker_status),
            harvesting_method = COALESCE(EXCLUDED.harvesting_method, plot.harvesting_method),
            geometry = COALESCE(ST_GeomFromGeoJSON((child_object->>'geometry')::text), plot.geometry),
            growth_district = COALESCE(EXCLUDED.growth_district, plot.growth_district),
            forest_status = COALESCE(EXCLUDED.forest_status, plot.forest_status),
            accessibility = COALESCE(EXCLUDED.accessibility, plot.accessibility),
            forest_office = COALESCE(EXCLUDED.forest_office, plot.forest_office),
            elevation_level = COALESCE(EXCLUDED.elevation_level, plot.elevation_level),
            property_type = COALESCE(EXCLUDED.property_type, plot.property_type),
            property_size_class = COALESCE(EXCLUDED.property_size_class, plot.property_size_class)

        WHERE plot.id = EXCLUDED.id AND plot.cluster_id = parent_id
        RETURNING * INTO changed_values;

        -- push new id to id_array
        id_array := id_array || changed_values.id;

        changed_id := changed_values.id;

        -- Convert the record to JSONB
        modified_element := to_jsonb(changed_values);

        --modified_element := json_build_object(
        --    --'plot', changed_values,
        --    'tree', '[]'::json,
        --    'deadwood', '[]'::json,
        --    'position', '[]'::json,
        --    'plot_location', '[]'::json
        --);

        SELECT(set_plot_location(changed_values.id, child_object->'plot_location', changed_values.geometry)) INTO child_plot_location;
            --locationId := COALESCE(NULLIF((child_plot_location->>'id')::text, 'null')::int, NULL);
            modified_element := jsonb_set(
                modified_element,
                '{plot_location}',
                child_plot_location
            );

        --IF (child_object->'plot_location')::text != 'null' THEN
        --END IF;

        

        IF (child_object->'tree')::text != 'null' THEN
            SELECT(set_tree(changed_values.id, child_object->'tree')) INTO child_tree;
            modified_element := jsonb_set(
                modified_element,
                '{tree}',
                child_tree
            );
        ELSE
            modified_element := jsonb_set(
                modified_element,
                '{tree}',
                '[]'::json
            );
        END IF;

        IF (child_object->'deadwood')::text != 'null' THEN
            
            SELECT(set_deadwood(changed_values.id, child_object->'deadwood', NULL)) INTO child_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{deadwood}',
                child_tree
            );
        ELSE
            modified_element := jsonb_set(
                modified_element,
                '{deadwood}',
                '[]'::json
            );
        END IF;

        IF (child_object->'position')::text != 'null' THEN

            SELECT(set_position(changed_values.id, child_object->'position')) INTO child_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{position}',
                child_tree
            );
        ELSE
            modified_element := jsonb_set(
                modified_element,
                '{position}',
                '[]'::json
            );
        END IF;

        IF (child_object->'edges')::text != 'null' THEN

            SELECT(set_edges(changed_values.id, child_object->'edges',NULL)) INTO child_tree;
            
            modified_element := jsonb_set(
                modified_element,
                '{edges}',
                child_tree
            );

        ELSE
            modified_element := jsonb_set(
                modified_element,
                '{edges}',
                '[]'::json
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