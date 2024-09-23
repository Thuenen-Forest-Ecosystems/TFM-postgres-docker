SET search_path TO private_ci2027_001;
CREATE TABLE lookup_marker_profile AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_marker_profile ADD COLUMN abbreviation enum_marker_profile UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_marker_profile; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_marker_profile (abbreviation, name_de, name_en, sort) VALUES
	('10', 'Rundeisen (Standard bei BWI1)', NULL, 10),
	('11', 'Ringmagnet (NW, BWI1, gebietsweise)', NULL, 11),
	('13', 'Rundeisen + Atlasdraht an Bäumen', NULL, 13),
	('20', 'T-Profil (Standard bei BWI2)', NULL, 20),
	('21', 'Rundeisen + T-Profileisen (NW, BWI2, eine Ecke/Trakt)', NULL, 21),
	('22', 'Unterflurmarken (SN,BWI2)', NULL, 22),
	('23', 'T-Profil + Atlasdraht an Bäumen (RP,BB,ST)', NULL, 23),
	('24', 'Metallrohr (27mm;4,5mm Stärke) + Atlasdraht an Bäumen (BW, BWI2)', NULL, 24),
	('25', 'T-Profil + Unterflurmarken', NULL, 25),
	('26', 'Eisenstab + Unterflurmarke (MV,SN,BWI2)', NULL, 26),
	('28', 'Ringmagnet (HE, LI2008, gebietsweise)', NULL, 28),
	('29', 'Winkeleisen (geplanter Standard bei THG2008, praktisch nicht gesetzt)', 'Winkeleisen mit ca. 3cm Kantenlänge (Standar bei THG2008)', 29),
	('30', 'Winkeleisen (Standard BWI3, Landesinventur BB)', NULL, 30),
	('33', 'Winkeleisen + Atlasdraht', NULL, 33),
	('34', 'Rundeisen (graue Kappe, LWI2 NW, 2013/2014)', NULL, 34),
	('38', 'Ringmagnete plus Edelstahl', NULL, 28),
	('41', 'quadratische Eisen (25x25x300) (ST BWI2022)', NULL, 41),
	('99', 'sonstige permanente Markierung (bitte in NOTIZ konkretisieren)', NULL, 99);


--
-- PostgreSQL database dump complete
--

