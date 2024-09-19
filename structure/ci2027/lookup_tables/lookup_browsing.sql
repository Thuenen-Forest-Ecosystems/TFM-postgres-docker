SET search_path TO private_ci2027_001;
CREATE TABLE lookup_browsing AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_browsing ADD COLUMN abbreviation enum_bitten UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_bitten; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_browsing (abbreviation, name_de, name_en, sort) VALUES
	('0', 'kein Verbiss', 'no', NULL),
	('1', 'einfacher (nur) Verbiss der Terminalknospe innerhalb der letzten 12 Monate', 'single', NULL),
	('2', 'mehrfacher Verbiss über längeren Zeitraum (einschließlich der letzten 12 Monate)', 'multi', NULL),
	('3', 'Verbiss im oberen Drittel an mindestens drei Seitentrieben bei intakter Terminalknospe', NULL, NULL),
	('4', 'Verbiss im oberen Drittel an mindestens drei Seitentrieben UND der Terminalknospe', NULL, NULL);


--
-- PostgreSQL database dump complete
--

