SET search_path TO private_ci2027_001, public;

-- Function to import WZP Trees
CREATE OR REPLACE FUNCTION set_position(parent_id int, json_object json)
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

        INSERT INTO position (id, plot_id,
            position_median,
            position_mean,
            hdop_mean,
            pdop_mean,
            satellites_count_mean,
            measurement_count,
            rtcm_age,
            start_measurement,
            stop_measurement,
            device_gps,
            quality)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('position_id_seq')),
            parent_id,
            ST_GeomFromGeoJSON((child_object->>'position_median')::text),
            ST_GeomFromGeoJSON((child_object->>'position_mean')::text),
            (child_object->>'hdop_mean')::float,
            (child_object->>'pdop_mean')::float,
            (child_object->>'satellites_count_mean')::float,
            (child_object->>'measurement_count')::int,
            (child_object->>'rtcm_age')::int,
            (child_object->>'start_measurement')::timestamp,
            (child_object->>'stop_measurement')::timestamp,
            (child_object->>'device_gps')::text,
            (child_object->>'quality')::enum_gnss_quality
        )
        ON CONFLICT (id) DO UPDATE
        SET
            plot_id = EXCLUDED.plot_id,
            position_median = COALESCE(EXCLUDED.position_median, position.position_median),
            position_mean = COALESCE(EXCLUDED.position_mean, position.position_mean),
            hdop_mean = COALESCE(EXCLUDED.hdop_mean, position.hdop_mean),
            pdop_mean = COALESCE(EXCLUDED.pdop_mean, position.pdop_mean),
            satellites_count_mean = COALESCE(EXCLUDED.satellites_count_mean, position.satellites_count_mean),
            measurement_count = COALESCE(EXCLUDED.measurement_count, position.measurement_count),
            rtcm_age = COALESCE(EXCLUDED.rtcm_age, position.rtcm_age),
            start_measurement = COALESCE(EXCLUDED.start_measurement, position.start_measurement),
            stop_measurement = COALESCE(EXCLUDED.stop_measurement, position.stop_measurement),
            device_gps = COALESCE(EXCLUDED.device_gps, position.device_gps),
            quality = COALESCE(EXCLUDED.quality, position.quality)
            
        WHERE position.id = EXCLUDED.id AND position.plot_id = parent_id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := row_to_json(changed_values);

        modified := modified || modified_element;

    END LOOP;

    DELETE FROM position WHERE id NOT IN (SELECT id FROM temp_child_ids) AND position.plot_id = parent_id;

RETURN modified;
END;
$$ LANGUAGE plpgsql;