SET search_path TO private_ci2027_001;
CREATE TABLE lookup_trees_less_4meter_mirrored AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_trees_less_4meter_mirrored ADD COLUMN abbreviation enum_trees_less_4meter_mirrored UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_trees_less_4meter_mirrored; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_trees_less_4meter_mirrored (abbreviation, name_de, name_en, sort) VALUES
	('0', 'nicht gespiegelt', NULL, NULL),
	('1', 'echte Spiegelung mit Relaskop', NULL, NULL),
	('2', 'Walk-Trough-Methode', NULL, NULL);


--
-- PostgreSQL database dump complete
--

