SET search_path TO private_ci2027_001;
CREATE TABLE lookup_state AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_state ADD COLUMN abbreviation enum_state UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_state; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_state (abbreviation, name_de, name_en, sort) VALUES
	('--', '(außerhalb Deutschlands)', '(outside germany area)', 1790),
	('SH', 'Schleswig-Holstein', 'Schleswig-Holstein', 190),
	('HH', 'Hansestadt Hamburg', 'Hansestadt Hamburg', 290),
	('NI', 'Niedersachsen', 'Niedersachsen', 390),
	('HB', 'Hansestadt Bremen', 'Hansestadt Bremen', 490),
	('NW', 'Nordrhein-Westfalen', 'Nordrhein-Westfalen', 590),
	('HE', 'Hessen', 'Hessen', 690),
	('RP', 'Rheinland-Pfalz', 'Rheinland-Pfalz', 790),
	('BW', 'Baden-Württemberg', 'Baden-Württemberg', 890),
	('BY', 'Bayern', 'Bayern', 990),
	('SL', 'Saarland', 'Saarland', 1090),
	('BE', 'Berlin', 'Berlin', 1190),
	('BB', 'Brandenburg', 'Brandenburg', 1290),
	('MV', 'Mecklenburg-Vorpommern', 'Mecklenburg-Vorpommern', 1390),
	('SN', 'Sachsen', 'Sachsen', 1490),
	('ST', 'Sachsen-Anhalt', 'Sachsen-Anhalt', 1590),
	('TH', 'Thüringen', 'Thüringen', 1690);


--
-- PostgreSQL database dump complete
--

