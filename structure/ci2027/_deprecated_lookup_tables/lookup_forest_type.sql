SET search_path TO private_ci2027_001;
CREATE TABLE lookup_forest_type AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_forest_type ADD COLUMN abbreviation enum_forest_type UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_forest_type; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO nfi2022.lookup_forest_type (abbreviation, name_de, name_en, sort) VALUES
	('1', 'Hainsimsen-Buchenwald, z.T. mit Tanne', 'Luzulo-Fagetum', NULL),
	('2', 'Drahtschmielen-Buchenwald', 'Deschampsio-Fagetum', NULL),
	('3', 'Waldmeister-Buchenwald, z.T. mit Tanne', 'Galio odorati-Fagetum', NULL),
	('4', 'Waldgersten-Buchenwald, z.T. mit Tanne', 'Hordelymo-Fagetum', NULL),
	('5', 'Buchen-Traubeneichenwald', 'Fago-Quercetum', NULL),
	('6', 'Alpenheckenkirschen-Tannen-Buchenwald', 'Lonicero alpigenae-Fagetum', NULL),
	('7', 'Seggen-Buchenwald', 'Carici-Fagetum', NULL),
	('8', 'Fichten-Buchenwald', 'Fago-Piceetum', NULL),
	('9', 'Bergahorn-Buchenwald', 'Aceri-Fagetum', NULL),
	('10', 'Hainsimsen-Fichten-Tannenwald', 'Luzulo-Abietetum', NULL),
	('11', 'Labkraut-Fichten-Tannenwald', 'Galio rotundifolii-Abietetum', NULL),
	('12', 'Preiselbeer-Fichten-Tannenwald', 'Vaccinio-Abietetum', NULL),
	('13', 'Wintergrün-Fichten-Tannenwald', 'Pyrolo-Abietetum', NULL),
	('14', 'Birken-Stieleichenwald', 'Betulo-Quercetum roboris', NULL),
	('15', 'Birken-Traubeneichenwald', 'Luzulo-Quercetum', NULL),
	('16', 'Preiselbeer-Eichenwald und Weißmoos-Kiefernwald', 'Vaccino vitis idae-Quercetum und Leucobryo-Pinetum', NULL),
	('17', 'Sternmieren-Hainbuchen-Stieleichenwald', 'Stellario holosteae-Carpinetum', NULL),
	('18', 'Waldlabkraut-Hainbuchen-Traubeneichenwald', 'Galio sylvatici-Carpinetum', NULL),
	('19', 'Traubeneichen-Linden-Wälder', 'Querco-Tilietum', NULL),
	('20', 'Xerotherme Eichen-Mischwälder', 'Quercion pubescenti-petreae, Carpinion p.p.', NULL),
	('21', 'Schneeheide-Kiefernwälder', 'Erico-Pinetum', NULL),
	('22', 'Kiefern-Steppenwald', 'Pyrolo-Pinetum', NULL),
	('23', 'Ahorn-Eschenwald', 'Adoxo-Aceretum', NULL),
	('24', 'Edellaubbaum-Steinschutt- und Blockhangwälder', 'Lunario-Acerenion p.p., Tilienion platyphylli', NULL),
	('25', 'Grünerlengebüsch', 'Alnetum viridis', NULL),
	('26', 'Karpatenbirken-Ebereschen-Blockwald', 'Betula carpaticae-Sorbetum', NULL),
	('27', 'Block-Fichtenwald', 'Asplenio-Piceetum', NULL),
	('28', 'Peitschenmoos-Fichtenwald', 'Bazzanio-Piceetum', NULL),
	('29', 'Bergreitgras-Fichtenwald', 'Calamagrostio villosae-Piceetum', NULL),
	('30', 'Alpenlattich-Fichtenwald', 'Homogyno-Piceetum', NULL),
	('31', 'Alpenrosen-Latschengebüsche', 'Erico-Mugetum, Rhododendro-Vaccinienion p.p.', NULL),
	('32', 'Lärchen-Zirbenwald', 'Vaccinio-Pinetum cembrae', NULL),
	('33', 'Rauschbeeren-Moorwälder', 'Piceo-Vaccinienion', NULL),
	('34', 'Schwarzerlen-Bruch- und Sumpfwälder', 'Alnion glutinosae', NULL),
	('35', 'Traubenkirschen-Erlen-Eschenwälder', 'Pruno-Fraxinetum', NULL),
	('36', 'Bach-Eschenwälder', 'Carici remotae-Fraxinetum', NULL),
	('37', 'Hainmieren-Schwarzerlen-Auewald', 'Stellario-Alnetum', NULL),
	('38', 'Grauerlenauewald', 'Alnetum incanae', NULL),
	('39', 'Stieleichen-Ulmen-Hartholzauewald', 'Querco-Ulmetum', NULL),
	('40', 'Silberweiden-Weichholzauewald', 'Salicetum albae', NULL),
	('161', 'Preiselbeer-Eichenwald', 'Vaccinio vitis-idaeae-Quercetum', NULL),
	('162', 'Weißmoos-Kiefernwald', 'Leucobryo-Pinetum', NULL);


--
-- PostgreSQL database dump complete
--

