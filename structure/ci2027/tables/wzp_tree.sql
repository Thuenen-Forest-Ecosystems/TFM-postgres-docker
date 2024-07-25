SET search_path TO private_ci2027_001, public;


CREATE TABLE wzp_tree (
	
    id SERIAL PRIMARY KEY,
    plot_id INTEGER NOT NULL,
    plot_location_id INTEGER NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
	modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	interval_name enum_interval_name NOT NULL DEFAULT 'ci2027', -- Intervall

	tree_number smallint NOT NULL, -- Bnr
	tree_marked boolean NOT NULL DEFAULT false, -- Perm 
	tree_state enum_tree_state NULL, -- Pk

	azimuth CK_GON NOT NULL, -- Azi
	distance smallint NOT NULL, -- Hori

	tree_species smallint NULL, -- Ba

	bhd CK_BHD NOT NULL, -- M_Bhd
	bhd_height smallint NOT NULL DEFAULT 130, -- M_hBhd

	tree_height smallint NULL, -- M_Hoe
	stem_height smallint NULL, -- M_StHoe
	tree_height_azimuth smallint NULL, -- MPos_Azi
	tree_height_distance smallint NULL, -- MPos_Hori

	tree_age smallint NULL, -- Al_ba

	stem_breakage enum_stem_breakage NULL DEFAULT '0', -- Kh
	stem_form enum_stem_form NULL DEFAULT '0', --Kst

	pruning enum_pruning NULL, -- Ast
	pruning_height smallint NULL, -- Ast_Hoe (Astungungshöhe [dm])

	stand_affiliation BOOLEAN NULL DEFAULT false, -- Bz https://git-dmz.thuenen.de/datenerfassungci2027/ci2027_datenerfassung/ci2027-db-structure/-/issues/3#note_24310
	inventory_layer enum_stand_layer NULL, -- Bs //sablings_layer
	
	damage_dead boolean NULL DEFAULT false, -- Tot
	damage_peel_new boolean NULL DEFAULT false, -- jSchael
	damage_peel_old boolean NULL DEFAULT false, -- aeSchael
	damage_logging boolean NULL DEFAULT false, -- Ruecke
	damage_fungus boolean NULL DEFAULT false, -- Pilz
	damage_resin boolean NULL DEFAULT false, -- Harz
	damage_beetle boolean NULL DEFAULT false, -- Kaefer
	damage_other boolean NULL DEFAULT false, -- sStamm

	cave_tree boolean NULL DEFAULT false, -- Hoehle
	crown_clear boolean NULL DEFAULT false, -- Bizarr
	crown_dry boolean NULL DEFAULT false, -- Uralt

	damage_bark boolean NULL DEFAULT false, -- Horst
	biotope_marked boolean NULL DEFAULT false, -- MBiotop

	bark_condition smallint NULL -- NEU:  Rindenzustand für frisch abgestorbene WZP4-Bäume (ab 2021/2022 wird das ehemals landesspez. WZ1 bundesweit verwendet)

);

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_Plot FOREIGN KEY (plot_id)
	REFERENCES plot (id) MATCH SIMPLE
	ON DELETE CASCADE;

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_PlotLocation FOREIGN KEY (plot_location_id)
    REFERENCES plot_location (id) MATCH SIMPLE
    ON DELETE CASCADE;

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_TreeState FOREIGN KEY (tree_state)
	REFERENCES lookup_tree_state (abbreviation) MATCH SIMPLE;

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_TreeSpecies FOREIGN KEY (tree_species)
	REFERENCES lookup_tree_species (abbreviation) MATCH SIMPLE;

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_StemBreakage FOREIGN KEY (stem_breakage)
	REFERENCES lookup_stem_breakage (abbreviation) MATCH SIMPLE;

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_StemForm FOREIGN KEY (stem_form)
	REFERENCES lookup_stem_form (abbreviation) MATCH SIMPLE;

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_Prunging FOREIGN KEY (pruning)
	REFERENCES lookup_pruning (abbreviation) MATCH SIMPLE;

ALTER TABLE wzp_tree ADD CONSTRAINT FK_WzpTree_StandLayer FOREIGN KEY (inventory_layer)
	REFERENCES lookup_stand_layer (abbreviation) MATCH SIMPLE;


-- add Example Tree#
-- INSERT INTO wzp_tree (plot_id, tree_number, azimuth, distance, bhd, tree_height, stem_height, tree_age, stem_breakage, stem_form, pruning, pruning_height, stand_affiliation, inventory_layer, damage_dead, damage_peel_new, damage_peel_old, damage_logging, damage_fungus, damage_resin, damage_beetle, damage_other, cave_tree, crown_clear, crown_dry, damage_bark, biotope_marked, bark_condition)