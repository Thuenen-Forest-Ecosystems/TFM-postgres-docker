-- SCHEMA DEFINITION
CREATE SCHEMA public_default;
ALTER SCHEMA public_default OWNER TO postgres;

GRANT USAGE ON SCHEMA public_default TO web_anon;

COMMENT ON SCHEMA public_default IS 'Kohlenstoffinventur 2027';

-- Cluster definition
CREATE TABLE IF NOT EXISTS public_default.cluster (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    cluster_name VARCHAR(255) NULL,
    cluster_name2 VARCHAR(255) NULL
);

COMMENT ON TABLE public_default.cluster IS 'Deine Trakte';
COMMENT ON COLUMN public_default.cluster.id IS 'Unique ID des Traktes';
COMMENT ON COLUMN public_default.cluster.created_at IS 'Erstellungsdatum';

COMMENT ON COLUMN public_default.cluster.cluster_name IS 'Name des Traktes';

ALTER TABLE public_default.cluster OWNER TO postgres;

GRANT SELECT ON public_default.cluster TO web_anon;
GRANT INSERT ON public_default.cluster TO web_anon;
GRANT UPDATE (cluster_name, cluser_name2) ON public_default.cluster TO web_anon;


-- DATA
INSERT INTO public_default.cluster (cluster_name) VALUES ('Thünen-Institut für Waldökologie');
INSERT INTO public_default.cluster (cluster_name) VALUES ('Grünecho');

-- Plot Definition
-- CREATE TABLE public_default.plot AS TABLE  private_ci2027_001.cluster WITH NO DATA;

CREATE TABLE IF NOT EXISTS public_default.plot (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    cluster_id SERIAL REFERENCES public_default.cluster(id),

    plot_name VARCHAR(255) NULL,
    geometry geometry(Point,4326)
);

GRANT ALL ON public_default.plot TO web_anon;

-- DATA
INSERT INTO public_default.plot (geometry, plot_name, cluster_id) VALUES (ST_MakePoint(13.810335, 52.825344), 'Thünen nr1', 1);
INSERT INTO public_default.plot (geometry, plot_name, cluster_id) VALUES (ST_MakePoint(13.810336, 52.825345), 'Thünen nr2', 1);
INSERT INTO public_default.plot (geometry, plot_name, cluster_id) VALUES (ST_MakePoint(13.810337, 52.825346), 'Thünen nr3', 1);
INSERT INTO public_default.plot (geometry, plot_name, cluster_id) VALUES (ST_MakePoint(13.810338, 52.825347), 'Thünen nr4', 1);
INSERT INTO public_default.plot (geometry, plot_name, cluster_id) VALUES (ST_MakePoint(13.972503, 47.402489), 'Grünecho', 2);



--WZP definition

CREATE TABLE IF NOT EXISTS public_default.wzp (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    plot_id SERIAL REFERENCES public_default.plot(id),

    wzp_name VARCHAR(255) NULL,
    geometry geometry(Point,4326)
);

-- DATA
INSERT INTO public_default.wzp (geometry, wzp_name, plot_id) VALUES (ST_MakePoint(13.810335, 52.825344), 'Thünen nr1', 1);
INSERT INTO public_default.wzp (geometry, wzp_name, plot_id) VALUES (ST_MakePoint(13.810336, 52.825345), 'Thünen nr2', 1);
INSERT INTO public_default.wzp (geometry, wzp_name, plot_id) VALUES (ST_MakePoint(13.810337, 52.825346), 'Thünen nr3', 1);
INSERT INTO public_default.wzp (geometry, wzp_name, plot_id) VALUES (ST_MakePoint(13.810338, 52.825347), 'Thünen nr4', 1);
INSERT INTO public_default.wzp (geometry, wzp_name, plot_id) VALUES (ST_MakePoint(13.810339, 52.825348), 'Thünen nr5', 1);
INSERT INTO public_default.wzp (geometry, wzp_name, plot_id) VALUES (ST_MakePoint(13.810340, 52.825349), 'Thünen nr6', 1);
INSERT INTO public_default.wzp (geometry, wzp_name, plot_id) VALUES (ST_MakePoint(13.972503, 47.402489), 'Grünecho', 2);

GRANT ALL ON public_default.wzp TO web_anon;