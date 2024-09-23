SET search_path TO private_ci2027_001;
CREATE TABLE lookup_tree_species AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_tree_species ADD COLUMN abbreviation SMALLINT UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.13 (Homebrew)


--
-- Data for Name: lookup_tree_species; Type: TABLE DATA; Schema: nfi2022; Owner: postgres
--

INSERT INTO nfi2022.lookup_tree_species (abbreviation, name_de, name_en, sort) VALUES
	(10, 'Gemeine Fichte', 'Picea abies (European spruce)', 3201),
	(11, 'Omorikafichte', 'Picea omorika (Omorica spruce)', 3202),
	(12, 'Sitkafichte', 'Picea sitchensis (Sitka spruce)', 3203),
	(13, 'Schwarzfichte', 'Picea mariana (Black spruce)', 3204),
	(14, 'Engelmannsfichte', 'Picea engelmannii (Engelmann spruce)', 3205),
	(15, 'Blaufichte, Stechfichte', 'Picea pungens (Colorado spruce)', 3206),
	(16, 'Weißfichte', 'Picea glauca (Canadian spruce)', 3207),
	(19, 'Sonstige Fichten', 'Picea spec.  (Other spruces)', 3208),
	(20, 'Gemeine Kiefer', 'Pinus sylvestris (Common pine)', 3261),
	(21, 'Bergkiefer', 'Pinus mugo (Dwarf mountain pine)', 3262),
	(22, 'Schwarzkiefer', 'Pinus nigra (European black pine)', 3263),
	(23, 'Rumelische Kiefer', 'Pinus peuce (Balkan pine)', 3264),
	(24, 'Zirbelkiefer', 'Pinus cembra (Cembra pine)', 3265),
	(25, 'Weymouthskiefer', 'Pinus strobus (Weymouth pine)', 3266),
	(26, 'Murraykiefer', 'Pinus contorta (Lodgepole pine)', 3267),
	(27, 'Gelbkiefer', 'Pinus ponderosa (Western yellow pine)', 3268),
	(29, 'Sonstige Kiefern', 'Pinus spec.  (Other pines)', 3269),
	(30, 'Weißtanne', 'Abies alba (European silver fir)', 3221),
	(31, 'Amerikanische Edeltanne', 'Abies procera (Noble fir)', 3222),
	(32, 'Coloradotanne', 'Abies concolor (Colorado white fir)', 3223),
	(33, 'Küstentanne', 'Abies grandis (Grand fir)', 3224),
	(34, 'Nikkotanne', 'Abies homolepis (Nikko fir)', 3225),
	(35, 'Nordmannstanne', 'Abies nordmanniana (Caucasian fir)', 3226),
	(36, 'Veitchtanne', 'Abies veitchii (Veitch´s silver fir)', 3227),
	(39, 'Sonstige Tannen', 'Abies spec. (Other firs)', 3228),
	(40, 'Douglasie', 'Pseudotsuga menziesii (Douglas fir)', 3241),
	(50, 'Europäische Lärche', 'Larix decidua (European larch)', 3281),
	(51, 'Japanische Lärche (+Hybrid)', 'Larix kaempferi (Japanese larch)', 3282),
	(90, 'sonstige Nadelbäume', 'Other conifers', 3209),
	(91, 'Lebensbaum', 'Thuja spec. (Arbor vitae)', 3210),
	(92, 'Hemlockstanne', 'Tsuga spec. (Canada hemlock)', 3211),
	(93, 'Mammutbaum', 'Metasequoia spec. (Sequoia)', 3212),
	(94, 'Eibe', 'Taxus baccata (Common yew)', 3213),
	(95, 'Lawsonszypresse', 'Chamaecyparis lawsoniana (Lawson cypress)', 3214),
	(99, 'Übrige Nadelbäume', 'Other conifers', 3215),
	(100, 'Rotbuche', 'Fagus sylvatica (Common beech)', 3111),
	(110, 'Stieleiche', 'Quercus robur (Common oak)', 3101),
	(111, 'Traubeneiche', 'Quercus petraea (Chestnut oak)', 3102),
	(112, 'Roteiche', 'Quercus rubra (Red oak)', 3103),
	(113, 'Zerreiche', 'Quercus cerris (Turkey oak)', 3104),
	(114, 'Sumpfeiche', 'Quercus palustris (Swamp oak)', 3105),
	(120, 'Gemeine Esche', 'Fraxinus excelsior (Common ash)', 3121),
	(121, 'Weißesche', 'Fraxinus americana (White ash)', 3122),
	(130, 'Hainbuche (Weißbuche)', 'Carpinus betulus (Hornbeam)', 3123),
	(140, 'Bergahorn', 'Acer pseudoplatanus (Sycamore maple)', 3124),
	(141, 'Spitzahorn', 'Acer platanoides (Plane maple)', 3125),
	(142, 'Feldahorn', 'Acer campestre (Field maple)', 3126),
	(143, 'Eschenblättriger Ahorn', 'Acer negundo (Ash-leaced maple)', 3127),
	(144, 'Silberahorn', 'Acer saccharinum (Silver maple)', 3128),
	(150, 'Linde (heimische Arten)', 'Tilia spec. (Lime tree, native species)', 3129),
	(160, 'Robinie', 'Robinia pseudoacacia (Common robinia)', 3130),
	(170, 'Ulme (Rüster), heimische Arten', 'Ulmus spec. (Elm, native species)', 3131),
	(180, 'Rosskastanie', 'Aesculus hippocastanum (Horse chestnut)', 3132),
	(181, 'Edelkastanie', 'Castanea sativa (European chestnut)', 3133),
	(190, 'Sonstige Lb. mit hoher Lebensdauer', 'Other deciduous trees with high life expectancy', 3134),
	(191, 'Speierling', 'Sorbus domestica (Service tree)', 3135),
	(192, 'Weißer Maulbeerbaum', 'Morus alba (White mulberry)', 3136),
	(193, 'Echte Mehlbeere', 'Sorbus aria (Whitebeam tree)', 3137),
	(194, 'Nußbaum-Arten (Wal-, Schwarz-, Butternuß)', 'Juglans spec. (Nut tree species)', 3138),
	(195, 'Stechpalme', 'Ilex aquifolium (Holly)', 3139),
	(196, 'Ahornblättrige Platane', 'Platanus x hispanica (Plane tree)', 3140),
	(199, 'Übrige Lb. mit hoher Lebensdauer', 'Other deciduous trees with high life expectancy', 3141),
	(200, 'Gemeine Birke', 'Betula pendula (European white birch)', 3151),
	(201, 'Moorbirke (+Karpatenbirke)', 'Betula pubescens (Pubescent birch)', 3152),
	(210, 'Erle', 'Alnus spec. (Alder)', 3153),
	(211, 'Schwarzerle', 'Alnus glutinosa (Black alder)', 3154),
	(212, 'Weißerle, Grauerle', 'Alnus incana (Grey alder)', 3155),
	(213, 'Grünerle', 'Alnus viridis (Green alder)', 3156),
	(220, 'Aspe, Zitterpappel', 'Populus tremula (Trembling poplar)', 3157),
	(221, 'Europäische Schwarzpappel (+Hybriden)', 'Populus nigra (European black poplar)', 3158),
	(222, 'Graupappel (+Hybriden)', 'Populus x canescens (Grey poplar)', 3159),
	(223, 'Silberpappel, Weißpappel', 'Populus alba (White poplar)', 3160),
	(224, 'Balsampappel (+Hybriden)', 'Populus trichocarpa x maximoviczii (Balsam poplar)', 3161),
	(230, 'Vogelbeere', 'Sorbus aucuparia (Rowan berry)', 3162),
	(240, 'Weide', 'Salix spec. (Willow)', 3163),
	(250, 'Gewöhnliche Traubenkirsche', 'Prunus padus (European bird cherry)', 3164),
	(251, 'Vogelkirsche', 'Prunus avium (Mazard cherry)', 3165),
	(252, 'Spätblühende Traubenkirsche', 'Prunus serotina (American black cherry)', 3166),
	(290, 'Sonstige Lb. mit niedriger Lebensdauer', 'Other deciduous trees with low life expectancy', 3167),
	(291, 'Gemeiner Faulbaum, Pulverholz', 'Rhamnus frangula (Glossy buckthorn)', 3168),
	(292, 'Holzapfel, Wildapfel', 'Malus sylvestris (Wild apple)', 3169),
	(293, 'Holzbirne, Wildbirne', 'Pyrus communis (Wild pear)', 3170),
	(294, 'Baumhasel', 'Corylus colurna (Tree hazel)', 3171),
	(295, 'Elsbeere', 'Sorbus torminalis (Wild service tree)', 3172),
	(296, 'Gemeiner Götterbaum', 'Ailantus altissima (Tree of heaven)', 3173),
	(299, 'Übrige Lb. mit niedriger Lebensdauer', 'Other deciduous trees with low life expectancy', 3174),
	(901, 'Ahorn', 'Acer spec. (Maple)', NULL),
	(902, 'Bergahorn', 'Acer pseudoplatanus (Sycamore maple)', NULL),
	(903, 'Birke', 'Betula pendula (European white birch)', NULL),
	(904, 'Buntlaubbaum ?! = sLb', 'Other deciduous with high life expectancy', NULL),
	(905, 'Balsampappel', 'Populus trichocarpa x maximoviczii (Balsam poplar)', NULL),
	(906, 'Buche', 'Fagus sylvatica (Common beech)', 3106),
	(907, 'Douglasie', 'Pseudotsuga menziesii (Douglas fir)', NULL),
	(908, 'Eiche', 'Quercus spec. (Oak)', 3001),
	(909, 'Elsbeere', 'Sorbus torminalis (Wild service tree)', NULL),
	(910, 'Europäische Lärche', 'Larix decidua (European larch)', NULL),
	(911, 'Erle', 'Alnus spec. (Alder)', NULL),
	(912, 'Esche', 'Fraxinus exelsior (Common ash)', NULL),
	(913, 'Feldahorn', 'Acer campestre (Field maple)', NULL),
	(914, 'Fichte', 'Picea abies (European spruce)', NULL),
	(915, 'Hainbuche (Weißbuche)', 'Carpinus betulus (Hornbeam)', NULL),
	(916, 'Japanische Lärche', 'Larix kaempferi (Japanese larch)', NULL),
	(917, 'Kastanie (Roßkastanie)', 'Aesculus hippocastanum (Horse chestnut)', NULL),
	(918, 'Kiefer', 'Pinus sylvestris (Scotch pine/Common pine)', NULL),
	(919, 'Kirsche', 'Sorbus spec. (Cherry)', NULL),
	(920, 'Küstentanne', 'Abies grandis (Grand fir)', NULL),
	(921, 'Lärche', 'Larix spec. (Larch)', NULL),
	(922, 'Linde', 'Tilia spec. (Lime tree)', NULL),
	(923, 'Pappel', 'Popupus spec. (Poplar)', NULL),
	(924, 'Roteiche', 'Quercus rubra (Red oak)', 3003),
	(925, 'Robinie', 'Robinia pseudoacacia (Common robinia)', NULL),
	(926, 'Spitzahorn', 'Acer platanoides (Plane maple)', NULL),
	(927, 'Sitkafichte', 'Picea sitchensis (Sitka spruce)', NULL),
	(928, 'Schwarzkiefer', 'Pinus nigra (European black pine)', NULL),
	(929, 'sonstige Laubbäume', 'Other deciduous trees', NULL),
	(930, 'sonstige Nadelbäume', 'Other coniferous trees', NULL),
	(931, 'Tanne', 'Abies alba (European silver fir)', NULL),
	(932, 'Thuja', 'Thuja spec. (Arbor vitae)', NULL),
	(933, 'Tsuga', 'Tsuga spec. (Canada hemlock)', NULL),
	(934, 'Ulme (Rüster)', 'Ulmus spec. (Elm)', NULL),
	(935, 'Vogelbeere', 'Sorbus aucuparia (Rowan berry)', NULL),
	(936, 'Weide', 'Salix spec. (Willow)', NULL),
	(937, 'Weymouthkiefer', 'Pinus strobus (Weymouth pine)', NULL),
	(950, 'Blöße', 'temporary unstocked area', NULL),
	(951, 'Lücke', 'gap', NULL);


--
-- PostgreSQL database dump complete
--

