SET search_path TO private_ci2027_001, public;
--https://stackoverflow.com/questions/6850500/postgis-installation-type-geometry-does-not-exist


CREATE TABLE IF NOT EXISTS plot (
    id SERIAL PRIMARY KEY,
    cluster_id SERIAL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
	modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	name varchar(255) NOT NULL, -- Unique human readable name
	description TEXT, -- Description of the plot

    
	sampling_strata enum_sampling_strata NOT NULL,
	state_administration enum_state NOT NULL,
	state_collect enum_state NOT NULL,

	geometry Geometry(Point, 4326), -- geom NEU, PostGis wird gebraucht


	growth_district integer  NULL, -- wb

	forest_decision enum_forest_decision NULL, -- wa
	accessibility smallint NULL, -- begehbar TODO
	
	-- ags varchar(8)  NULL, -- ags Wird das noch gebraucht?  (Amtlicher Gemeindeschlüssel (8-stellig, Pos 1+2=Bl, 3=RegBez, 4-5=Kreis, 6-7=Gemeinde), aus Karte 1:250.000 (31.12.2008)) Alternative: reverse lookup ??
	-- kreis smallint NULL, -- kreis Ist das für Trupps eine relevante Information? (Land-/Stadtkreis) Alternative: reverse lookup ??
	-- gemeinde int NULL, -- gemeinde Ist das für Trupps eine relevante Information? (Gemeinde) Alternative: reverse lookup ??


	---- MAY BE REPLACED BY SEPERATE GEO-TABLES created from shape files
    -- biogeogrregion smallint NULL, -- biogeogrregion Ist das für Trupps eine relevante/änderbare Information? (atlantisch, kontinental, alpin)
	-- ffh smallint NULL, -- ffh Ist das für Trupps eine relevante/änderbare Information und aktuell? (z.B. DE2735301 | Alte Elde zwischen Wanzlitz und Krohn)
	-- vogelsg smallint NULL, -- vogelsg (vgl. ffh)
	-- nationalp smallint NULL, -- nationalp (vgl. ffh)
    -- naturp smallint NULL, -- naturp (vgl. ffh)
	-- biosphaere smallint NULL, -- biosphaere (vgl. ffh)
	-- natursg smallint NULL, -- natursg (vgl. ffh)

	forestry_department CK_FORESTRY_DEPARTMENT NULL, -- fa
	height_layer_class enum_height_layer_class NULL, -- nathoe
	property_type enum_property_type NULL, -- eg
	property_size_class enum_property_size_class NULL, -- eggrkl

	forest_type enum_forest_type NULL, -- natwgv
	habitat_type enum_habitat_type NULL, -- wlt_v
	habitat_type_source enum_habitat_type_source NULL, --wlt_wiev

	use_restriction enum_use_restriction NULL, -- ne
	
	land_use enum_land_use NULL, -- lanu

	-- ez1 smallint NULL, -- ez1 --Wird in Rücksprache mit TS anders erfasst (TODO)
    -- ez2 smallint NULL, -- ez2
	-- ez3 smallint NULL, -- ez3
	-- ez4 smallint NULL, -- ez4

	-- exploration_instruction smallint NULL, -- st_methode ?? finde ich nicht in z3_col
	-- st_quelle smallint NULL, -- st_quelle Länderspezifisch: finde ich nur in x3_bl
	-- st_b smallint NULL, --st_b Länderspezifisch: finde ich nur in x3_bl
	-- st_ks_hs smallint NULL, --st_ks_hs Länderspezifisch: finde ich nur in x3_bl
	-- st_ks_fs smallint NULL, --st_ks_fs Länderspezifisch: finde ich nur in x3_bl
	-- st_n smallint NULL, -- st_n Länderspezifisch: finde ich nur in x3_bl
	-- st_nz smallint NULL, --st_nz Länderspezifisch: finde ich nur in x3_bl
	-- st_wh_fg smallint NULL, --st_wh_fg Länderspezifisch: finde ich nur in x3_bl
	-- st_wh_fz smallint NULL, --st_wh_fz Länderspezifisch: finde ich nur in x3_bl
	-- st_wh_e smallint NULL, --st_wh_e Länderspezifisch: finde ich nur in x3_bl
	-- st_var varchar(18)  NULL, -- st_var Länderspezifisch: finde ich nur in x3_bl

	coast BOOLEAN NOT NULL DEFAULT FALSE, --kueste
	sandy BOOLEAN NOT NULL DEFAULT FALSE, -- gestein
	conservation_area BOOLEAN NOT NULL DEFAULT FALSE, -- lsg
	histwald BOOLEAN NOT NULL DEFAULT FALSE, -- histwald


	use_restriction_reasons enum_use_restriction_reason[] NOT NULL DEFAULT '{}', -- NEU: Nutzungseinschränkungen als Array TODO: Lookup Table

    -- wfkt1 smallint NOT NULL, -- wfkt1  --Wird in Rücksprache mit TS anders erfasst (TODO)
	-- wfkt2 smallint NULL, -- wfkt2
	-- wfkt3 smallint NULL, -- wfkt3
	-- wfkt4 smallint NULL, -- wfkt4
	-- wfkt5 smallint NULL, -- wfkt5
	-- wfkt6 smallint NULL, -- wfkt6
	-- wfkt7 smallint NULL, -- wfkt7
	-- wfkt8 smallint NULL, -- wfkt8
	-- wfkt9 smallint NULL, -- wfkt9

	landmark_azimuth CK_GON NULL, -- mark_azi
	landmark_distance smallint NULL, -- mark_hori
	landmark_note varchar(12)  NULL, -- mark_beschreibung

	marking_state enum_marking_state NOT NULL, -- perm: Das Feld bietet kein Mehrwert, da perm_profile die gleiche Information enthält
	marking_azimuth CK_GON NULL, -- perm_azi: 
	marking_distance smallint NULL, -- perm_hori
	marking_profile enum_marking_profile NULL, -- perm_profil

	terrain_form enum_terrain_form NULL, -- gform
	terrain_slope CK_SLOPE_DEGREE NULL, -- gneig [Grad]
	terrain_exposure CK_GON NULL, -- gexp [Gon]

	management_type enum_management_type NULL, -- be
	harvesting_method enum_harvesting_method NOT NULL, -- ernte (x3_ernte)
	biotope CK_BIOTOPE NULL, -- biotop (x3_biotop)
	layer_type enum_layer_type NULL, -- ab
	stand_age CK_STAND_AGE NULL, -- al_best
	stand_phase enum_stand_phase NULL, -- phase

	sablings_layer enum_stand_layer NULL, -- b0_bs
	sablings_fence BOOLEAN NULL DEFAULT FALSE, -- b0_zaun

	trees_less_4meter_mirrored enum_trees_less_4meter_mirrored NULL, -- schigt4_sp (gespiegelt)
	trees_less_4meter_count_factor enum_trees_less_4meter_count_factor NULL, -- schigt4_zf
	trees_less_4meter_coverage smallint NULL, -- schile4_bedg
	trees_less_4meter_layer enum_trees_less_4meter_layer NULL -- schile4_schi

	-- ez5 smallint NULL, -- ez5
	-- ez6 smallint NULL, -- ez6
	-- ez7 smallint NULL, -- ez7
	-- ez8 smallint NULL, -- ez8
	-- ez9 smallint NULL -- ez9
);

ALTER TABLE plot ADD CONSTRAINT FK_Plot_Cluster FOREIGN KEY (cluster_id)
	REFERENCES cluster (id) MATCH SIMPLE
	ON DELETE CASCADE;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_SamplingStrata FOREIGN KEY (sampling_strata)
	REFERENCES lookup_sampling_strata (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupGrowthDistrict FOREIGN KEY (growth_district)
        REFERENCES lookup_growth_district (abbreviation) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupForestDecision FOREIGN KEY (forest_decision)
		REFERENCES lookup_forest_decision (abbreviation) MATCH SIMPLE
		ON UPDATE NO ACTION
		ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupForestryDepartment FOREIGN KEY (forestry_department) 
		REFERENCES lookup_forestry_department (abbreviation) MATCH SIMPLE
		ON UPDATE NO ACTION
		ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupHeightLayerClass FOREIGN KEY (height_layer_class) 
	REFERENCES lookup_height_layer_class (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupPropertyType FOREIGN KEY (property_type)
	REFERENCES lookup_property_type (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupPropertySizeClass FOREIGN KEY (property_size_class)
	REFERENCES lookup_property_size_class (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupForestType FOREIGN KEY (forest_type)
	REFERENCES lookup_forest_type (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupHabitatType FOREIGN KEY (habitat_type)
	REFERENCES lookup_habitat_type (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupHabitatTypeSource FOREIGN KEY (habitat_type_source)
	REFERENCES lookup_habitat_type_source (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupUseRestriction FOREIGN KEY (use_restriction)
	REFERENCES lookup_use_restriction (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupLandUse FOREIGN KEY (land_use)
	REFERENCES lookup_land_use (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

--ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupUseRestrictionReasons FOREIGN KEY (use_restriction_reasons)
--	REFERENCES lookup_use_restriction_reason (abbreviation) MATCH SIMPLE
--	ON UPDATE NO ACTION
--	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupMarkingState FOREIGN KEY (marking_state)
	REFERENCES lookup_marking_state (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupMarkingProfile FOREIGN KEY (marking_profile)
	REFERENCES lookup_marking_profile (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupTerrainForm FOREIGN KEY (terrain_form)
	REFERENCES lookup_terrain_form (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupManagementType FOREIGN KEY (management_type)
	REFERENCES lookup_management_type (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupHarvestingMethod FOREIGN KEY (harvesting_method)
	REFERENCES lookup_harvesting_method (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

--ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupBiotope FOREIGN KEY (biotope)
--	REFERENCES lookup_biotope (abbreviation) MATCH SIMPLE
--	ON UPDATE NO ACTION
--	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupLayerType FOREIGN KEY (layer_type)
	REFERENCES lookup_layer_type (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupStandPhase FOREIGN KEY (stand_phase)
	REFERENCES lookup_stand_phase (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupStandLayer FOREIGN KEY (sablings_layer)
	REFERENCES lookup_stand_layer (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupTreesLess4meterMirrored FOREIGN KEY (trees_less_4meter_mirrored)
	REFERENCES lookup_trees_less_4meter_mirrored (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupTreesLess4meterCountFactor FOREIGN KEY (trees_less_4meter_count_factor)
	REFERENCES lookup_trees_less_4meter_count_factor (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;

ALTER TABLE plot ADD CONSTRAINT FK_Plot_LookupTreesLess4meterLayer FOREIGN KEY (trees_less_4meter_layer)
	REFERENCES lookup_trees_less_4meter_layer (abbreviation) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;


--CONSTRAINT FK_Plot_Lookupgrid FOREIGN KEY (grid)
--        REFERENCES lookup_grid (abbreviation) MATCH SIMPLE
--        ON UPDATE NO ACTION
--        ON DELETE NO ACTION,
--CONSTRAINT FK_Plot_LookupStateAdministration FOREIGN KEY (state_administration)
--        REFERENCES lookup_states (abbreviation) MATCH SIMPLE
--        ON UPDATE NO ACTION
--        ON DELETE NO ACTION,	
--CONSTRAINT FK_Plot_LookupStateCollect FOREIGN KEY (state_collect)
--        REFERENCES lookup_states (abbreviation) MATCH SIMPLE
--        ON UPDATE NO ACTION
--        ON DELETE NO ACTION,
