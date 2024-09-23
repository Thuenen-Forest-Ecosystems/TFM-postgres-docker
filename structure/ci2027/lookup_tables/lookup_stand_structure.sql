SET search_path TO private_ci2027_001;
CREATE TABLE lookup_stand_structure AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_stand_structure ADD COLUMN abbreviation enum_stand_structure UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_stand_structure; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_stand_structure (abbreviation, name_de, name_en, sort) VALUES
	('1', 'einschichtig', NULL, 10),
	('2', 'zweischichtig', NULL, 20),
	('3', 'zweischichtig (Überhälter/Nachhiebsrest)', NULL, 30),
	('4', 'zweischichtig (Vorausverjüngung)', NULL, 40),
	('5', 'zweischichtig (Unterbau)', NULL, 50),
	('6', 'mehrschichtig oder plenterartig', NULL, 60);


--
-- PostgreSQL database dump complete
--

