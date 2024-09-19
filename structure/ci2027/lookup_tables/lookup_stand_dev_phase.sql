SET search_path TO private_ci2027_001;
CREATE TABLE lookup_stand_dev_phase AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_stand_dev_phase ADD COLUMN abbreviation enum_stand_dev_phase UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_stand_dev_phase; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_stand_dev_phase (abbreviation, name_de, name_en, sort) VALUES
	('1', 'Blöße bis Stangenholz (BHD<20 cm); Pionierphase', NULL, 10),
	('2', 'geringes Baumholz (BHD 20 bis  <35  cm)', NULL, 20),
	('3', 'mittleres Baumholz (BHD 35 bis <50 cm)', NULL, 30),
	('4', 'starkes Baumholz (BHD 50 bis <70 cm)', NULL, 40),
	('5', 'Altholz (BHD >= 70 cm)', NULL, 50);


--
-- PostgreSQL database dump complete
--

