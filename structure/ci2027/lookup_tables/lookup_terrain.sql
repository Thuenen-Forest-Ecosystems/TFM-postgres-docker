SET search_path TO private_ci2027_001;
CREATE TABLE lookup_terrain AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_terrain ADD COLUMN abbreviation enum_terrain UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_terrain; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_terrain (abbreviation, name_de, name_en, sort) VALUES
	('0', 'bestockter Holzboden', NULL, 5),
	('1', 'bebaute Flächen (Siedlungs-, Verkehrs-, Gewerbe-)', 'built-up areas (settlement areas, traffic areas, trade areas)', 10),
	('2', 'Acker', 'acre', 20),
	('3', 'Wiesen und Weiden', 'meadows and pastures', 30),
	('4', 'Waldsukzession', 'forest succession', 40),
	('5', 'Feuchtgebiet', 'wetland', 50),
	('6', 'Gewässer', 'waters', 60),
	('7', 'Hochmoor', 'highmoor', 70),
	('8', 'Felsflächen', 'rocks areas', 80),
	('9', 'Waldgrenze im Gebirge', 'forest limit in the mountains', 90),
	('10', 'sonstige extensiv oder nicht genutzte Landflächen', 'other extensive or under-utilised land areas', 100),
	('11', 'Nichtholzboden', NULL, 111),
	('12', 'Blöße', NULL, 112),
	('13', 'anderer Bestand, mit Aufnahme', NULL, 113),
	('14', 'anderer Bestand, ohne Aufnahme (nicht begehbar)', NULL, 114);


--
-- PostgreSQL database dump complete
--

