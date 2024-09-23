SET search_path TO private_ci2027_001;
CREATE TABLE lookup_states AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_states ADD COLUMN abbreviation enum_states UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_states; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO nfi2022.lookup_states (abbreviation, name_de, name_en, sort) VALUES
	('0', '(außerhalb Deutschlands)', '(outside germany area)', 1790),
	('1', 'Schleswig-Holstein', 'Schleswig-Holstein', 190),
	('2', 'Hansestadt Hamburg', 'Hansestadt Hamburg', 290),
	('3', 'Niedersachsen', 'Niedersachsen', 390),
	('4', 'Hansestadt Bremen', 'Hansestadt Bremen', 490),
	('5', 'Nordrhein-Westfalen', 'Nordrhein-Westfalen', 590),
	('6', 'Hessen', 'Hessen', 690),
	('7', 'Rheinland-Pfalz', 'Rheinland-Pfalz', 790),
	('8', 'Baden-Württemberg', 'Baden-Württemberg', 890),
	('9', 'Bayern', 'Bayern', 990),
	('10', 'Saarland', 'Saarland', 1090),
	('11', 'Berlin', 'Berlin', 1190),
	('12', 'Brandenburg', 'Brandenburg', 1290),
	('13', 'Mecklenburg-Vorpommern', 'Mecklenburg-Vorpommern', 1390),
	('14', 'Sachsen', 'Sachsen', 1490),
	('15', 'Sachsen-Anhalt', 'Sachsen-Anhalt', 1590),
	('16', 'Thüringen', 'Thüringen', 1690);


--
-- PostgreSQL database dump complete
--

