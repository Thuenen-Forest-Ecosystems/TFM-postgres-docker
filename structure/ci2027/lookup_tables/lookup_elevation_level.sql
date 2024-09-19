SET search_path TO private_ci2027_001;
CREATE TABLE lookup_elevation_level AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_elevation_level ADD COLUMN abbreviation enum_elevation_level UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_elevation_level; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_elevation_level (abbreviation, name_de, name_en, sort) VALUES
	('1', 'planar', 'planar', NULL),
	('2', 'kollin', 'colline', NULL),
	('3', 'submontan', 'submontane', NULL),
	('4', 'montan', 'montane', NULL),
	('5', 'hochmontan/subalpin', 'high-montane/sub-alpine', NULL);


--
-- PostgreSQL database dump complete
--

