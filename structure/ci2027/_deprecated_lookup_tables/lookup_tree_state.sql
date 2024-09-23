SET search_path TO private_ci2027_001;
CREATE TABLE lookup_tree_state AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_tree_state ADD COLUMN abbreviation enum_tree_state UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_tree_state; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO nfi2022.lookup_tree_state (abbreviation, name_de, name_en, sort) VALUES
	('0', 'neuer Probebaum', 'new sample tree', 30),
	('1', 'wiederholt aufgenommener Probebaum', 'repeated collected saple tree', 31),
	('2', 'selektiv entnommener Probebaum', 'selected cut sample tree', 12),
	('3', 'bei Kahlschlag entnommen', 'cut by clear felling', 13),
	('4', 'nicht stehend, am Ort verblieben (ggf. Totholz)', 'not standing, stay on site', 24),
	('5', 'Probebaum der vorherigen Inventur, der nun länger als 12 Monate abgestorben ist', 'died (without fine branch structure)', 25),
	('6', 'Baum, außerhalb Bestand (vor 2008 und ab 2021 nur Aufnahme im Bestand)', 'old tree, out of stand', 35),
	('7', 'ungültiger Baum (Grenzstammkontrolle)', 'invalid tree from BWI1 (not ACS- tree)', 36),
	('8', 'ungültiger Probebaum, weil Horizontalentfernung größer als Grenzkreisradius', 'invalid tree from BWI2', 37),
	('9', 'nicht mehr auffindbarer Probebaum, auch nicht als Stock', 'not to be found', 18),
	('10', 'noch vorhanden, jedoch kein Probebaum mehr, kein Abgang', NULL, 40),
	('11', 'ausgeschiedener Baum außerhalb der Stichprobe', 'tree outside the sample dropped out', 41),
	('12', 'seit der  vorherigen Inventur entnommen', NULL, 12),
	('1111', 'permanent markierter Hilfsbaum zum Wiederfinden der Traktecke; kein Probebaum', NULL, 1111),
	('2002', 'schon 2002 (BWI2) ausgefallen', NULL, 2002),
	('2007', 'schon 2007 (RP-Inventur) ausgefallen', NULL, 2007),
	('2008', 'schon 2008 (THG1-, HE-, SN-, BB-Inventur) ausgefallen', NULL, 2008),
	('2012', 'schon 2012 (BWI3, NW2014, BB2013) ausgefallen', NULL, 2012),
	('2017', 'schon 2017 (CI17, HE, RP-, SN-Inventur) ausgefallen', NULL, 2017);


--
-- PostgreSQL database dump complete
--

