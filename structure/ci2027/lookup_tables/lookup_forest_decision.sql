SET search_path TO private_ci2027_001;
CREATE TABLE lookup_forest_decision AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_forest_decision ADD COLUMN abbreviation enum_forest_decision UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_forest_decision; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_forest_decision (abbreviation, name_de, name_en, sort) VALUES
	('0', 'Nichtwald       (Stand Referenztabellen 17.09.2020 14:09)', 'non forest', 10001),
	('1', 'produktiver Wald, Holzboden', 'productive forest, forest land', 2002),
	('2', 'unproduktiver Wald, Holzboden', 'non productive forest, forest land', 2002),
	('3', 'Wald, Blöße', 'forest, temporary unstocked area', 2001),
	('4', 'Wald, Nichtholzboden', 'forest, unstocked forest land', 4001),
	('5', 'Wald, bestockter Holzboden', '', 1001),
	('8', 'nicht relevant, weil außerhalb des Inventurgebietes', NULL, 8001),
	('9', 'nicht relevant, weil nicht zum Verdichtungsgebiet / Raster gehörig', NULL, 9001),
	('23', 'Wald, Blöße, nicht im terrestrischen Inventurnetz', 'forest,temporary unstocked area, not assessed', 11001),
	('24', 'Nichtholzboden, nicht im terrestrischen Inventurnetz', 'forest,unstocked forest land, not assessed', 11001),
	('25', 'bestockter Holzboden, nicht im terrestrischen Inventurnetz', 'forest, stocked area, not assessed', 11001);


--
-- PostgreSQL database dump complete
--

