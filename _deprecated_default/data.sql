SET search_path TO private_ci2027_001, public;

DO $$ 
DECLARE
    temp_cluster_id INT;
    temp_plot_id INT;
    temp_location_id INT;
    temp_cluster_id2 INT;
    temp_deadwood_location_id INT;
BEGIN

    -- Insert into cluster and return the generated id
    INSERT INTO cluster (name, description, state_administration, state_location, states, sampling_strata, cluster_identifier) 
        VALUES ('Test Tract', 'Test Description', 'BY', 'BY', '{"BY", "BE"}', '8', '5')
        RETURNING id INTO temp_cluster_id;
    INSERT INTO cluster (name, description, state_administration, state_location, states, sampling_strata, cluster_identifier) 
        VALUES ('Test Tract2', 'Test Description', 'BY', 'BY', '{"BY", "BE"}', '8', '5')
        RETURNING id INTO temp_cluster_id2;

    -- Insert into plot 
    INSERT INTO Plot (cluster_id, name, description, sampling_strata, state_administration, state_collect, geometry, marking_state, harvesting_method) 
        VALUES (temp_cluster_id, 'Test Plot', 'Test Description', '8', 'BY', 'BY', ST_GeomFromText('POINT(10 10)', 4326), '3', '1')
        RETURNING id INTO temp_plot_id;
    INSERT INTO Plot (cluster_id, name, description, sampling_strata, state_administration, state_collect, geometry, marking_state, harvesting_method) 
        VALUES (temp_cluster_id, 'Test Plot 2', 'Test Description 2', '8', 'BY', 'BY', ST_GeomFromText('POINT(20 20)', 4326), '3', '1')
        RETURNING id INTO temp_plot_id;


    -- Insert Plot Location
    INSERT INTO plot_location (plot_id, parent_table, azimuth, distance, radius, geometry, no_entities)
        VALUES (temp_plot_id, 'wzp_tree',100, 500, 100, ST_GeomFromText('POINT(20 20)', 4326), FALSE)
         RETURNING id INTO temp_location_id;

    -- Insert into wzp
    INSERT INTO wzp_tree (
        plot_id,
        plot_location_id,
        azimuth,
        distance, 
        tree_species, 
        bhd, 
        bhd_height,
        tree_number,
        tree_height, 
        stem_height, 
        tree_height_azimuth, 
        tree_height_distance, 
        tree_age, 
        stem_breakage, 
        stem_form, 
        pruning, 
        pruning_height, 
        stand_affiliation, 
        inventory_layer, 
        damage_dead, 
        damage_peel_new, 
        damage_peel_old, 
        damage_logging, 
        damage_fungus, 
        damage_resin, 
        damage_beetle
    ) VALUES (
        temp_plot_id, -- plot_id
        temp_location_id, -- location id
        100, -- azimuth
        200, -- distance
        10, -- tree_species (assuming smallint references a lookup table)
        700, -- bhd
        130, -- bhd_height (default value, can be omitted)
        1, -- tree_number
        150, -- tree_height
        140, -- stem_height
        100, -- tree_height_azimuth
        200, -- tree_height_distance
        50, -- tree_age
        '0', -- stem_breakage (replace '0' with actual enum value)
        '0', -- stem_form (replace '0' with actual enum value)
        '0', -- pruning (replace '0' with actual enum value)
        50, -- pruning_height
        false, -- stand_affiliation (default value, can be omitted)
        '0', -- inventory_layer (replace '0' with actual enum value)
        false, -- damage_dead (default value, can be omitted)
        false, -- damage_peel_new (default value, can be omitted)
        false, -- damage_peel_old (default value, can be omitted)
        false, -- damage_logging (default value, can be omitted)
        false, -- damage_fungus (default value, can be omitted)
        false, -- damage_resin (default value, can be omitted)
        false -- damage_beetle (default value, can be omitted)
    );
     -- Insert into wzp
    INSERT INTO wzp_tree (
        plot_id,
        plot_location_id,
        azimuth,
        distance, 
        tree_species, 
        bhd, 
        bhd_height,
        tree_number,
        tree_height, 
        stem_height, 
        tree_height_azimuth, 
        tree_height_distance, 
        tree_age, 
        stem_breakage, 
        stem_form, 
        pruning, 
        pruning_height, 
        stand_affiliation, 
        inventory_layer, 
        damage_dead, 
        damage_peel_new, 
        damage_peel_old, 
        damage_logging, 
        damage_fungus, 
        damage_resin, 
        damage_beetle
    ) VALUES (
        temp_plot_id, -- plot_id
        temp_location_id, -- location id
        100, -- azimuth
        200, -- distance
        10, -- tree_species (assuming smallint references a lookup table)
        500, -- bhd
        130, -- bhd_height (default value, can be omitted)
        1, -- tree_number
        67, -- tree_height
        140, -- stem_height
        100, -- tree_height_azimuth
        200, -- tree_height_distance
        50, -- tree_age
        '0', -- stem_breakage (replace '0' with actual enum value)
        '0', -- stem_form (replace '0' with actual enum value)
        '0', -- pruning (replace '0' with actual enum value)
        50, -- pruning_height
        false, -- stand_affiliation (default value, can be omitted)
        '0', -- inventory_layer (replace '0' with actual enum value)
        false, -- damage_dead (default value, can be omitted)
        false, -- damage_peel_new (default value, can be omitted)
        false, -- damage_peel_old (default value, can be omitted)
        false, -- damage_logging (default value, can be omitted)
        false, -- damage_fungus (default value, can be omitted)
        false, -- damage_resin (default value, can be omitted)
        false -- damage_beetle (default value, can be omitted)
    );

    -- Insert Plot Location
    INSERT INTO plot_location (plot_id, parent_table, azimuth, distance, radius, geometry, no_entities)
        VALUES (temp_plot_id, 'deadwood', 100, 500, 100, ST_GeomFromText('POINT(20 20)', 4326), FALSE)
         RETURNING id INTO temp_deadwood_location_id;

    INSERT INTO deadwood (plot_id, tree_species_group, dead_wood_type, decomposition, length_height, diameter_butt, diameter_top, count, bark_pocket) VALUES (temp_plot_id, '2', '2', '2', 10, 160, 100, 10, 10);

    INSERT INTO position (plot_id, position_median, position_mean, hdop_mean, pdop_mean, satellites_count_mean, measurement_count, rtcm_age, start_measurement, stop_measurement, device_gps, quality) VALUES
        (1, ST_SetSRID(ST_MakePoint(13.123456, 52.123456), 4326), ST_SetSRID(ST_MakePoint(13.123456, 52.123456), 4326), 1.0, 1.0, 1.0, 1, 1.0, '2020-01-01 00:00:00', '2020-01-01 00:00:00', 'Test', 'RTK');

END $$

