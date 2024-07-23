SET search_path TO private_ci2027_001;
CREATE TABLE lookup_layer_type AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_layer_type ADD COLUMN abbreviation enum_layer_type UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_layer_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_layer_type (abbreviation, name_de, name_en, sort) VALUES
	('1', 'einschichtig', NULL, 10),
	('2', 'zweischichtig', NULL, 20),
	('3', 'zweischichtig (Überhälter/Nachhiebsrest)', NULL, 30),
	('4', 'zweischichtig (Vorausverjüngung)', NULL, 40),
	('5', 'zweischichtig (Unterbau)', NULL, 50),
	('6', 'mehrschichtig oder plenterartig', NULL, 60);


--
-- PostgreSQL database dump complete
--

