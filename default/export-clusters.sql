SET search_path TO private_ci2027_001, public;

GRANT usage ON SCHEMA private_ci2027_001 TO web_anon;

CREATE OR REPLACE FUNCTION export_geojson(cluster_ids int[])
RETURNS json AS
$$
DECLARE
BEGIN

    RETURN (
        SELECT json_agg(
            json_build_object(
                'cluster', cluster.*,
                'plots', (SELECT json_agg(
                        json_build_object(
                            'plot', plot.*,
                            'wzp_tree', (SELECT json_agg(
                                    json_build_object(
                                        'wzp_tree', wzp_tree.*,
                                        'plot_location', (
                                            SELECT json_agg(
                                                json_build_object(
                                                    'plot_location', plot_location.*
                                                )
                                            )
                                            FROM plot_location WHERE plot_location.id = wzp_tree.plot_location_id
                                        )
                                    )
                                )
                                FROM wzp_tree WHERE wzp_tree.plot_id = plot.id
                            ),
                            'deadwood', (SELECT json_agg(
                                    json_build_object(
                                        'deadwood', deadwood.*,
                                        'plot_location', (
                                            SELECT json_agg(
                                                json_build_object(
                                                    'plot_location', plot_location.*
                                                )
                                            )
                                            FROM plot_location WHERE plot_location.id = deadwood.plot_location_id
                                        )
                                    )
                                )
                                FROM deadwood WHERE deadwood.plot_id = plot.id
                            )
                        )
                    )
                    FROM plot WHERE plot.cluster_id = cluster.id
                )
            )
        )
        FROM cluster 
        WHERE cluster.id = ANY(cluster_ids)
    );
END;
$$ LANGUAGE plpgsql;

ALTER FUNCTION export_geojson(int[]) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION export_geojson(int[]) TO web_anon;

GRANT SELECT ON TABLE cluster TO web_anon;
GRANT SELECT ON TABLE plot TO web_anon;
GRANT SELECT ON TABLE wzp_tree TO web_anon;
GRANT SELECT ON TABLE plot_location TO web_anon;