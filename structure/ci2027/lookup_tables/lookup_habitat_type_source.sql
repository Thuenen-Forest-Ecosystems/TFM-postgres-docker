SET search_path TO private_ci2027_001;
CREATE TABLE lookup_habitat_type_source AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_habitat_type_source ADD COLUMN abbreviation enum_habitat_type_source UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_habitat_type_source; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_habitat_type_source (abbreviation, name_de, name_en, sort) VALUES
	('1', 'Herleitung aus Lebensraumtyp-Kartierung', NULL, 1),
	('2', 'Herleitung aus Biotopkartierung', NULL, 2),
	('3', 'Herleitung aus Standortkartierung bzw. -parametern', NULL, 3),
	('4', 'Herleitung aus geologischen Karten', NULL, 4),
	('5', 'Herleitung aus anderen Kartenwerken', NULL, 5),
	('6', 'Lt. NatWG (Vorkl) ist nur 1 Waldlebensraumtyp möglich bzw. kein Waldlebensraumtyp', NULL, 6),
	('7', 'Übernahme aus der Vorgängerinventur', NULL, 7),
	('8', 'Truppentscheid', NULL, 8),
	('9', 'Gesonderte Expertenbegehung', NULL, 9),
	('10', 'Übernahme aus Vorklärung', NULL, 10),
	('11', 'Ergebnis laut Algorithmus lt. Version 1', NULL, 11),
	('12', 'Ergebnis laut Algorithmus lt. Version 2', NULL, 12),
	('13', 'Ergebnis laut Algorithmus lt. Version 3', NULL, 13),
	('14', 'Ergebnis laut Algorithmus ... ', NULL, 14),
	('90', 'Abbruch WLT-Algorithmus: Fehlende oder unzulässig: NatWg (Feld)', NULL, 90),
	('91', 'Abbruch WLT-Algorithmus: Fehlende oder unzulässig: Bl, Wg, Wb, NatHoe/Hz', NULL, 91),
	('92', 'Abbruch WLT-Algorithmus: Fehlende oder unzulässig Definition in Maske WLT (Tabelle b3v_def_vegwlt)', NULL, 92),
	('93', 'Abbruch WLT-Algorithmus: Fehlende Hauptbestockung oder Entwicklungsphase', NULL, 93),
	('94', 'Abbruch WLT-Algorithmus: Fehlende Hilfsgröße:  Küste (WLT=2180)', NULL, 94),
	('95', 'Abbruch WLT-Algorithmus: Fehlende Hilfsgrößen: Torfdicke, Torfmoose, Moorart  (WLT=921* / 91D*)', NULL, 95),
	('96', 'Abbruch WLT-Algorithmus: Fehlende Hilfsgröße: DiffArt (WLT=9160/9170)', NULL, 96),
	('97', 'Abbruch WLT-Algorithmus: Fehlende Hilfsgröße: Carpinion, Biogeogr. Region (WLT=9160/9170/9190)', NULL, 97),
	('98', 'Abbruch WLT-Algorithmus: Fehlende Hilfsgröße: Gestein/Sand/Veg.zeiger (WLT=9190)', NULL, 98),
	('99', 'Abbruch WLT-Algorithmus: Keine eindeutige Entscheidung zum WLT (mehrere WLT möglich)', NULL, 99);


--
-- PostgreSQL database dump complete
--

