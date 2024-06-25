CREATE VIEW public_default.cluster_with_plots_wzp AS
SELECT 
    c.*,
    json_agg(
        json_build_object(
            'plot', p.*,
            'wzp', (SELECT json_agg(w.*) FROM public_default.wzp w WHERE w.plot_id = p.id)
        )
    ) AS plots
FROM 
    public_default.cluster c
LEFT JOIN 
    public_default.plot p ON c.id = p.cluster_id
GROUP BY 
    c.id;

GRANT ALL ON public_default.cluster_with_plots_wzp TO web_anon;


-----

CREATE VIEW public_default.deep_cluster AS
SELECT
    json_agg(
        json_build_object(
            'cluster', c.*,
            'plots', (SELECT json_agg(
                        json_build_object(
                            'plot', p.*,
                            'wzps', (SELECT json_agg(
                                        json_build_object(
                                            'wzp', w.*
                                        )
                                    ) FROM public_default.wzp w WHERE w.plot_id = p.id)
                        )
                    ) FROM public_default.plot p WHERE p.cluster_id = c.id)
        )
    ) AS clusters
FROM public_default.cluster c;
GRANT ALL ON public_default.deep_cluster TO web_anon;

CREATE OR REPLACE FUNCTION public_default.set_deep_cluster(clusters json)
RETURNS json AS $$
DECLARE
    cluster json;
    plot json;
    wzp json;
BEGIN
    FOR cluster IN SELECT * FROM json_array_elements(clusters)
    LOOP
        -- Upsert cluster
        INSERT INTO public_default.cluster (id, cluster_name, cluster_name2) 
        VALUES ((cluster->'cluster'->>'id')::INT, cluster->'cluster'->>'cluster_name', cluster->'cluster'->>'cluster_name2') 
        ON CONFLICT (id) DO nothing; -- DO UPDATE SET created_at = EXCLUDED.created_at, cluster_name = EXCLUDED.cluster_name, cluster_name2 = EXCLUDED.cluster_name2;

        if found then PERFORM update_cluster((cluster->'cluster'->>'id')::INT, cluster->'cluster'); end if;

        -- Upsert plots
        FOR plot IN SELECT * FROM json_array_elements(cluster->'plots')
        LOOP
            INSERT INTO public_default.plot (id, created_at, cluster_id, plot_name, geometry) 
            VALUES ((plot->'plot'->>'id')::INT, (plot->'plot'->>'created_at')::TIMESTAMP, (plot->'plot'->>'cluster_id')::INT, plot->'plot'->>'plot_name', plot->'plot'->>'geometry') 
            ON CONFLICT (id) DO UPDATE SET created_at = EXCLUDED.created_at, cluster_id = EXCLUDED.cluster_id, plot_name = EXCLUDED.plot_name, geometry = EXCLUDED.geometry;

            -- Upsert wzp
            FOR wzp IN SELECT * FROM json_array_elements(plot->'wzp')
            LOOP
                INSERT INTO public_default.wzp (id, created_at, plot_id) 
                VALUES ((wzp->>'id')::INT, (wzp->>'created_at')::TIMESTAMP, (wzp->>'plot_id')::INT) 
                ON CONFLICT (id) DO UPDATE SET created_at = EXCLUDED.created_at, plot_id = EXCLUDED.plot_id;
            END LOOP;
        END LOOP;
    END LOOP;
    RETURN json_build_object('status', 'success');
END;
$$ LANGUAGE plpgsql;

GRANT ALL ON FUNCTION public_default.set_deep_cluster TO web_anon;


-----
CREATE OR REPLACE FUNCTION update_cluster(id integer, data json)
RETURNS void AS $$
DECLARE
    key TEXT;
    keys TEXT[];
    i INT;
BEGIN
    keys := ARRAY(SELECT json_object_keys(data));
    FOR i IN 1 .. array_length(keys, 1)
    LOOP
        key := keys[i];
        IF key = 'id' THEN
            CONTINUE;
        END IF;

        BEGIN
            EXECUTE format('UPDATE public_default.cluster SET %I = %L WHERE id = %L', key, data->>key, id);
            EXCEPTION WHEN insufficient_privilege THEN
                -- Do nothing
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public_default.upsert_cluster_plot_wzp(json_input json)
RETURNS json AS $$
DECLARE
    data_element json;
    plot_element json;
    wzp_element json;
    new_cluster_id INTEGER;
    new_plot_id INTEGER;
BEGIN

    FOR data_element IN SELECT * FROM json_array_elements(json_input)
    LOOP
        -- Extract data from JSON and insert/update into 'cluster' table
        INSERT INTO cluster (id, cluster_name, cluster_name2)
        VALUES (
            (data_element->>'id')::integer,
            data_element->>'cluster_name',
            data_element->>'cluster_name2'
        )
        ON CONFLICT (id) 
        DO nothing
        --DO UPDATE SET
        --    cluster_name = excluded.cluster_name,
        --    cluster_name2 = excluded.cluster_name2
        RETURNING id INTO new_cluster_id;
        

        --if not found then SELECT update_cluster((data_element->>'id')::integer, data_element); end if;

        -- Loop through 'plots' array
        IF data_element->'plots' IS NOT NULL THEN

            FOR plot_element IN SELECT * FROM json_array_elements(data_element->'plots')
            LOOP
                INSERT INTO plot (cluster_id, plot_name, geometry)
                VALUES (
                    (data_element->>'id')::integer,
                    plot_element->'plot'->>'plot_name',
                    ST_GeomFromText('POINT(' || (
                        SELECT string_agg(value::text, ' ')
                        FROM json_array_elements_text(plot_element->'plot'->'geometry'->'coordinates')
                    ) || ')', 4326)
                )
                ON CONFLICT (id) 
                DO UPDATE SET
                    plot_name = excluded.plot_name,
                    geometry = excluded.geometry
                RETURNING id INTO new_plot_id;

                -- Loop through 'wzp' array

               

                IF (plot_element->'wzp')::text != 'null' THEN

                    FOR wzp_element IN SELECT * FROM json_array_elements(plot_element->'wzp')
                    LOOP
                        -- Extract data from JSON and insert/update into 'wzp' table
                        INSERT INTO wzp (plot_id, wzp_name)
                        VALUES (
                            new_plot_id,
                            wzp_element->>'wzp_name'
                        )
                        ON CONFLICT (id) 
                        DO UPDATE SET
                            wzp_name = excluded.wzp_name;
                    END LOOP;

                    RETURN wzp_element;

                ELSE
                    -- DELETE FROM wzp WHERE plot_id = (plot_element->'plot'->>'id')::integer;
                    -- return plot_element->'wzp';

                END IF;
                
            END LOOP;
        END IF;
    END LOOP;

    RETURN json_build_object('status', 'success');
END;
$$ LANGUAGE plpgsql;

GRANT ALL ON FUNCTION public_default.upsert_cluster_plot_wzp TO web_anon;


-- NOT SET
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public_default TO web_anon;


