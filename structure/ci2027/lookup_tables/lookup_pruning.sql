SET search_path TO private_ci2027_001;
CREATE TABLE lookup_pruning AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_pruning ADD COLUMN abbreviation enum_pruning UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_pruning; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_pruning (abbreviation, name_de, name_en, sort) VALUES
	('0', 'keine Astung', 'no pruning', 10),
	('1', 'Astung bis 2,5 m (Astungshöhe 2 m)', 'hight of pruning up to 2,5 m', 11),
	('2', 'Astung von 2,5 bis 5 m (Astungshöhe 4 m)', 'hight of pruning from 2,5 m to 5 m', 12),
	('3', 'Astung von 5 bis 7,5 m (Astungshöhe 6,5 m)', 'hight of pruning from 5 m to 7,5 m', 14),
	('4', 'Astung von 5,5 bis 10 m (Astungshöhe 8,75 m)', 'hight of pruning from 7,5 m to 10 m', 15),
	('5', 'Astung von 10 m bis 15m (Astungshöhe 12,5 m)', 'hight of pruning above 10 m', 16),
	('6', 'Astung höher als 15 m', 'hight of pruning above 10 m', 16),
	('9', 'Astung höher als 5 m', 'hight of pruning above 5 m', 19);


--
-- PostgreSQL database dump complete
--

