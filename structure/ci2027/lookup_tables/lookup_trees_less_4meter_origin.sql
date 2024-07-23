SET search_path TO private_ci2027_001;
CREATE TABLE lookup_trees_less_4meter_origin AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_trees_less_4meter_origin ADD COLUMN abbreviation enum_trees_less_4meter_origin UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_trees_less_4meter_origin; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_trees_less_4meter_origin (abbreviation, name_de, name_en, sort) VALUES
	('1', 'Naturverjüngung', 'natural regeneration', 10),
	('2', 'Saat', 'sowing', 20),
	('3', 'Pflanzung', 'planting', 30),
	('4', 'Stockausschlag', 'coppice shoot', 40),
	('5', 'nicht zuzuordnen', 'classification not possible', 50);


--
-- PostgreSQL database dump complete
--

