SET search_path TO private_ci2027_001;
CREATE TABLE lookup_stand_layer AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_stand_layer ADD COLUMN abbreviation enum_stand_layer UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_stand_layer; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_stand_layer (abbreviation, name_de, name_en, sort) VALUES
	('0', 'keine Zuordnung möglich (Plenterwald)', 'classification not possible (plenter forest)', 1001),
	('1', 'Hauptbestand', 'principal stand', 1002),
	('2', 'Unterstand', 'under storey', 2001),
	('3', 'Oberstand', 'upper storey', 2002),
	('4', 'Verjüngung unter Schirm', 'regeneration under shelterwood', 2003),
	('9', 'liegender Baum / sehr schräg stehend', NULL, 2004);


--
-- PostgreSQL database dump complete
--

