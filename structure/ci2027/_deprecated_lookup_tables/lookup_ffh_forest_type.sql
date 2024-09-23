SET search_path TO private_ci2027_001;
CREATE TABLE lookup_ffh_forest_type AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_ffh_forest_type ADD COLUMN abbreviation enum_ffh_forest_type UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_ffh_forest_type; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO nfi2022.lookup_ffh_forest_type (abbreviation, name_de, name_en, sort) VALUES
	('0', 'kein WLRT', 'no forest habitat-type', 0),
	('1', 'nicht vorklärbar (nur in Kombi mit Wie=3=Standortkartierung)', 'cannot be clarified', 1),
	('2180', 'bewaldete Bereiche der Atlantikküste', 'Wooded dunes of the Atlantic coast', 2180),
	('9110', 'Hainsimsen-Buchenwald (Luzulo-Fagetum) inkl. (Ilici-Fagion)', 'Luzulo-Fagetum beech forests', 9110),
	('9130', 'Waldmeister-Buchenwald (Asperulo-Fagetum)', 'Asperulo-Fagetum beech forests', 9130),
	('9140', 'subalpiner Buchenwald mit Ahorn und Bergampfer', 'subalpine beech woods with Acer and Rumex arifolius', 9140),
	('9150', 'Orchideen-Buchenwald (Cephalanthero-Fagion)', 'Calcareous beech forest (Cephalanthero-Fagion)', 9150),
	('9160', 'Sternmieren-Eichen-Hainbuchenwald (Stellario-Carpinetum)', 'Stellario-Carpinetum oak-hornbeam forests', 9160),
	('9161', 'Sternmieren-Eichen-Hainbuchenwald (Stellario-Carpinetum) auf Galio-Fagetum Standorten (9160)', 'Stellario-Carpinetum oak-hornbeam forests on Galio-Fagetum sites', 9158),
	('9162', 'Sternmieren-Eichen-Hainbuchenwald (Stellario-Carpinetum) auf anderen Standorten als Galio-Fagetum', 'Stellario-Carpinetum oak-hornbeam forests on Non-Galio-Fagetum sites', 9159),
	('9170', 'Labkraut-Eichen-Hainbuchenwald', 'Galio-Carpinetum oak-hornbeam forests', 9170),
	('9180', 'Hangmisch- und Schluchtwälder (Tilio-Acerion)', 'Tilio-Acerion forests of slopes, screes and ravines', 9180),
	('9190', 'alte bodensaure Eichenwälder mit Quercus robur auf Sandebenen', 'Old acidophilous oak woods with Quercus robur on sandy plains', 9190),
	('9191', 'alte bodensaure Eichenwälder mit Quercus robur auf Sandebenen und alten Waldstandorten (9190)', 'Old acidophilous oak woods with Quercus robur on sandy plains and old forest sites', 9188),
	('9192', 'alte bodensaure Eichenwälder mit Quercus robur auf Sandebenen und jungen Waldstandorten', 'Old acidophilous oak woods with Quercus robur on sandy plains and young forest sites', 9189),
	('9210', 'Moorwälder ', 'Bog woodland', 9210),
	('9211', 'Birken-Moorwald', 'Sphagnum birch woods', 9211),
	('9212', 'Waldkiefern-Moorwald', 'Scots pine bog woods', 9212),
	('9213', 'Bergkiefern-Moorwald', 'Mountain pine bog woods', 9213),
	('9214', 'Fichten-Moorwald', 'Sphagnum spruce woods', 9214),
	('9220', 'Erlen- und Eschenwälder und Weichholzauenwälder an Fließgewässern', 'Residual alluvial forests', 9220),
	('9230', 'Eichen-Ulmen-Eschen-Auenwälder am Ufer großer Flüsse', 'Ripian mixed oak-elm-ash forests of great rivers', 9230),
	('9240', 'Pannonische Wälder mit Quercus petraea und Carpinus betulus', 'Pannonian woods', 9240),
	('9410', 'Bodensaure Nadelwälder (Vaccinio-Piceetea)', 'Acidophilous forests (Vaccinio-Piceetea)', 9410),
	('9420', 'Alpiner Lärchen-Arvenwald', 'Alpine forests with larch and Pinus cembra', 9420),
	('9999', 'mehrere potentielle Waldlebensraumtypen', NULL, 9599);


--
-- PostgreSQL database dump complete
--

