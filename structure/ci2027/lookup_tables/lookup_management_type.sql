SET search_path TO private_ci2027_001;
CREATE TABLE lookup_management_type AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_management_type ADD COLUMN abbreviation enum_management_type UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_management_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_management_type (abbreviation, name_de, name_en, sort) VALUES
	('1', 'schlagweiser Hochwald', 'age class high forest', 11),
	('2', 'Plenterwald', 'plenter forest', 21),
	('3', 'Mittelwald', 'composite forest', 31),
	('4', 'Niederwald', 'coppice forest', 41),
	('5', 'Kurzumtriebsplantage', 'short rotation forest', 51),
	('6', 'Latschen- oder Grünerlenfeld', '???', 61);


--
-- PostgreSQL database dump complete
--

