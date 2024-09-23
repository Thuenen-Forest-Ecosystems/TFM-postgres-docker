SET search_path TO private_ci2027_001;
CREATE TABLE lookup_terrain_form AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_terrain_form ADD COLUMN abbreviation enum_terrain_form UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_terrain_form; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_terrain_form (abbreviation, name_de, name_en, sort) VALUES
	('0', 'Ebene', 'plain', 0),
	('1', 'hügelig, wellig', 'hilly, wavy', 10),
	('2', 'Tallage', 'valley site', 20),
	('3', 'Hanglage', 'sloping site', 30),
	('4', 'Hoch-, Kamm oder Plateaulage', 'high altidudes site, ridge site, high plateau site', 40),
	('21', 'Tallage ohne Kaltluftstau', 'valley site without frost pool', 21),
	('22', 'Tallage mit Kaltluftstau', 'valley site with frost pool', 22),
	('31', 'untere Hanglage', 'lower sloping site', 31),
	('32', 'mittlere Hanglage', 'middle sloping site', 32),
	('33', 'obere Hanglage', 'upper sloping site', 33);


--
-- PostgreSQL database dump complete
--

