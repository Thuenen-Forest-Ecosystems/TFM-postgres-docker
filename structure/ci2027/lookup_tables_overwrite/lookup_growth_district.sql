-- Table: private_ci2027_001.lookup_growth_district

 --DROP TABLE IF EXISTS private_ci2027_001.lookup_growth_district;

CREATE TABLE IF NOT EXISTS private_ci2027_001.lookup_growth_district
(
    abbreviation integer NOT NULL,
    name_de character varying(150) COLLATE pg_catalog."default" NOT NULL,
    name_en character varying(150) COLLATE pg_catalog."default" NOT NULL,
	district_area integer not null,
    states private_ci2027_001.enum_state[],
    CONSTRAINT lookup_growth_district_pkey PRIMARY KEY (abbreviation)
	
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS private_ci2027_001.lookup_growth_district
    OWNER to postgres;



insert into private_ci2027_001.lookup_growth_district (abbreviation, name_de,name_en,district_area)
select icode,langd,langd as kurze,wg from private_ci2027_001.x3_wbkarte
where kurzd is null;

insert into private_ci2027_001.lookup_growth_district (abbreviation, name_de,name_en,district_area)
select icode,langd,langd as kurze,wg from private_ci2027_001.x3_wbkarte
where kurzd  is not null;





UPDATE private_ci2027_001.lookup_growth_district
SET states =subquery.statesn    
FROM (select a.icode,a.laendernr,get_enum_states(a.laendernr) as statesn ,b.states from private_ci2027_001.x3_wbkarte as a
inner join private_ci2027_001.lookup_growth_district as b
on a.icode =b.abbreviation) AS subquery
WHERE private_ci2027_001.lookup_growth_district.abbreviation=subquery.icode;


-- Constraint: fk_lookupgrowtharea

-- ALTER TABLE IF EXISTS private_ci2027_001.lookup_growth_district DROP CONSTRAINT IF EXISTS fk_tract_lookupstateadministration;

ALTER TABLE IF EXISTS private_ci2027_001.lookup_growth_district
    ADD CONSTRAINT fk_lookupgrowtharea FOREIGN KEY (district_area)
    REFERENCES private_ci2027_001.lookup_growth_area (abbreviation) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

DROP TABLE IF EXISTS private_ci2027_001.x3_wbkarte;