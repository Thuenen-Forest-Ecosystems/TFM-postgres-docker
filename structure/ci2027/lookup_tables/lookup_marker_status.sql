SET search_path TO private_ci2027_001;
CREATE TABLE lookup_marker_status AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_marker_status ADD COLUMN abbreviation enum_marker_status UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_marker_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_marker_status (abbreviation, name_de, name_en, sort) VALUES
	('0', 'nicht gesucht, weil Nichtwald/Nichtholzboden', 'not searched/not found, non forest/non stocked area in forest', NULL),
	('1', 'alte Markierung wiedergefunden', 'old mark located', NULL),
	('2', 'alte Markierung nicht wiedergefunden, jedoch Ecke eindeutig  identifiziert, neue Marke gesetzt', 'old mark not located, but identified', NULL),
	('3', 'erstmals Markierung gesetzt', 'marked for the first time', NULL),
	('4', 'alte Markierung nicht gefunden; Neuaufnahme', 'old mark not found, new assesment', NULL);


--
-- PostgreSQL database dump complete
--

