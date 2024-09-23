SET search_path TO private_ci2027_001;
CREATE TABLE lookup_cluster_situation AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_cluster_situation ADD COLUMN abbreviation enum_cluster_situation UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_cluster_situation; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO lookup_cluster_situation (abbreviation, name_de, name_en, sort) VALUES
	('1', 'Waldtrakt der vorangegangenen Inventur', 'Waldtrakt der vorangegangenen Inventur', 1),
	('2', 'neu anzulegender Waldtrakt', 'erstmals anzulegender Waldtrakt', 2),
	('3', 'Wald/ Nichtwald-Entscheid ungewiss', 'Wald/ Nichtwald ungewiss', 3),
	('4', 'Nichtwaldtrakt, vollständig in bebautem Gebiet oder Gewässer gelegen', 'NWT in bebautem Gebiet', 4),
	('5', 'Nichtwaldtrakt in der offenen Landschaft', 'NWT in offener Landschaft', 5),
	('6', 'Waldtrakt außerhalb Landeswald (keine Erhebung bei Inventuren 2007/2008)', 'Waldtrakt außerhalb Landeswald', 6);


--
-- PostgreSQL database dump complete
--

