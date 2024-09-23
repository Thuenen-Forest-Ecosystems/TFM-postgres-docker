SET search_path TO private_ci2027_001;
CREATE TABLE lookup_gnss_quality AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_gnss_quality ADD COLUMN abbreviation enum_gnss_quality UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_gnss_quality; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO nfi2022.lookup_gnss_quality (abbreviation, name_de, name_en, sort) VALUES
	('1', 'GNSS (1) - Viertbeste Qualität', NULL, 4),
	('2', 'DGNSS (2) - Drittbeste Qualität', NULL, 3),
	('4', 'RTK fixed (4) - Beste Qualität', NULL, 1),
	('5', 'RTK floating (5) - Zweitbeste Qualität', NULL, 2),
	('9', 'GNSS (9) - Viertbeste Qualität', NULL, 5);


--
-- PostgreSQL database dump complete
--

