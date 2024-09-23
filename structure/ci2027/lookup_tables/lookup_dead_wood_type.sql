SET search_path TO private_ci2027_001;
CREATE TABLE lookup_dead_wood_type AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_dead_wood_type ADD COLUMN abbreviation enum_dead_wood_type UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_dead_wood_type; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_dead_wood_type (abbreviation, name_de, name_en, sort, "interval") VALUES
	('1', 'liegend', 'lying', 31, '{bwi2002,bwi2012}'),
	('2', 'stehend, ganzer Baum', 'standing, complete tree', 11, '{bwi2002,bwi2012}'),
	('3', 'stehend, Bruchstück (Höhe >= 130cm)', 'standing, fragment', 12, '{bwi2002,bwi2012}'),
	('4', 'Wurzelstock (Höhe < 130cm)', 'root stump', 21, '{bwi2002,bwi2012}'),
	('5', 'Abfuhrrest (aufgeschichtet)', 'removal rest', 41, '{bwi2002,bwi2012}'),
	('11', 'liegend, ganzer Baum mit Wurzelanlauf', NULL, 32, '{bwi2002,bwi2012}'),
	('12', 'liegend, Stammstück mit Wurzelanlauf', NULL, 33, '{bwi2002,bwi2012}'),
	('13', 'liegend, Teilstück ohne Wurzelanlauf', NULL, 34, '{bwi2002,bwi2012}');


--
-- PostgreSQL database dump complete
--

