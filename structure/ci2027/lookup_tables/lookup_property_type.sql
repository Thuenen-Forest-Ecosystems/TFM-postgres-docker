SET search_path TO private_ci2027_001;
CREATE TABLE lookup_property_type AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_property_type ADD COLUMN abbreviation enum_property_type UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_property_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_property_type (abbreviation, name_de, name_en, sort) VALUES
	('1', 'Staatswald (Bund)', 'forest in federal property', 19),
	('2', 'Staatswald (Land)', 'forest in state property', 29),
	('3', 'Körperschaftswald', 'corporation forest', 39),
	('4', 'Privatwald', 'private forest', 49),
	('5', 'Treuhandwald', '???forest in management of the privatisation agency', 59),
	('21', 'Staatswald (anderes Land)', 'forest in state property (other federal state)', 21),
	('30', 'Körperschaftswald (Gemeindewald)', 'corporation forest (communal forest)', 30),
	('31', 'Körperschaftswald (Kirchenwald)', 'corporation forest (parish forest)', 31),
	('32', 'Körperschaftswald (Gemeinschaftwald)', 'corporation forest (community forest)', 32),
	('33', 'Körperschaftswald (Genossenschaftswald)', 'corporation forest (cooperative forest)', 33),
	('34', 'Körperschaftswald (Land)', 'corporation forest (land)', 34),
	('35', 'Körperschaftswald (Bund)', 'corporation forest (federal)', 35),
	('40', 'Privatwald (im engeren Sinn)', 'private forest (???)', 40),
	('41', 'Privatwald (Kirchenwald)', 'private forest (parish forest)', 41),
	('42', 'Privatwald (Gemeinschaftswald)', 'private forest (community forest)', 42),
	('43', 'Privatwald (Genossenschaftswald)', 'private forest (cooperative forest)', 43),
	('44', 'Privatwald (Land)', 'privat forest (cooperative forest)', 44),
	('45', 'Privatwald (Bund)', 'privat forest (federal)', 45);


--
-- PostgreSQL database dump complete
--

