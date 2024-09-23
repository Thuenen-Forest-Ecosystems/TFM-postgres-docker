SET search_path TO private_ci2027_001;
CREATE TABLE lookup_land_use AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_land_use ADD COLUMN abbreviation enum_land_use UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_land_use; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_land_use (abbreviation, name_de, name_en, sort) VALUES
	('3', 'Feuchtflächen', 'moisture areas', 30),
	('4', 'Wasserflächen', 'surface waters', 40),
	('11', 'Industrie-, Gewerbe-, Verkehrsflächen', 'industrial areas, traffic areas', 11),
	('12', 'keiner anderen Kategorie zugehörige bebaute oder versiegelte Flächen (z.B. Wohngebiete)', 'residential areas, other areas covered with buildings and other sealed surfaces', 12),
	('13', 'Abbauflächen, Deponien, Halden, offene Flächen ohne oder mit geringer Vegetation', 'excavation areas, landfills, dumps', 13),
	('14', 'Städtische Grünflächen, sonstige nicht versiegelte Flächen, Sport- u. Freizeitanlagen', 'urban green areas, sports facilities, recreational facilities and other non seales surfaces', 14),
	('21', 'Ackerland', 'agricultural land', 21),
	('22', 'Dauerkulturen (Rebflächen, Obstbestände, Hopfen, nicht zum Wald gehörige Baumschulen)', 'continuous crops (viticulture, orchards, hop fields, tree nurseries outside forests)', 22),
	('23', 'Dauergrünland (Weiden, Wiesen, natürliches Grünland, Heiden, Wald-Strauch-Übergangstadien)', 'permanent grassland (pastures and meadows, natural green areas, heathland, succession areas )', 23),
	('90', 'Traktecke war schon früher eindeutig Nichtwald (Falschansprache Waldentscheid bei Vorgängerinventur)', NULL, 90),
	('92', 'Traktecke war schon früher eindeutig Nichtholzboden (fehlende/falsche Ansprache Vorgängerinventur)', NULL, 92),
	('93', 'Traktecke war schon früher eindeutig Holzboden (fehlende/falsche Ansprache Vorgängerinventur)', NULL, 93),
	('99', 'Traktecke war schon früher eindeutig Wald (fehlende Ansprache Vorgängerinventur)', NULL, 99);


--
-- PostgreSQL database dump complete
--

