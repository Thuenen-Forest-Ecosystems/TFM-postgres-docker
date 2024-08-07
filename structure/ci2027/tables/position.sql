SET search_path TO private_ci2027_001, public;

CREATE TABLE position (

    id SERIAL PRIMARY KEY,
    plot_id INTEGER NOT NULL,
	plot_location_id INTEGER NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

    position_median GEOMETRY(Point, 4326) NOT NULL,
	position_mean GEOMETRY(Point, 4326) NOT NULL,

	--altitude_median float NULL, -- NEU
	--altitude_mean float NULL, -- Hoehe_MEAN
	
	hdop_mean float NULL, -- HDOP  MEAN OR MEDIAN ???
	pdop_mean float NULL, -- PDOP  MEAN OR MEDIAN ???

	satellites_count_mean float NULL, -- NumSat MEAN OR MEDIAN ???

	measurement_count smallint NULL, -- AnzahlMessungen
	
	rtcm_age float NULL, -- RTCMAlter

	start_measurement timestamp NULL, -- UTCStartzeit
	stop_measurement timestamp NULL, -- UTCStopzeit

	device_gps varchar(150) NULL, -- Geraet (smallint) || Ist hier ein freies Eingabefeld nicht sinnvoller ???

	quality enum_gnss_quality NULL -- GNSS_Qualitaet

);

COMMENT ON TABLE position IS 'Position der Probenfläche';
COMMENT ON COLUMN position.id IS 'Unique ID der Probenfläche';
COMMENT ON COLUMN position.plot_id IS 'ID der Probenfläche';
COMMENT ON COLUMN position.created_at IS 'Erstellungszeitpunkt';
COMMENT ON COLUMN position.hdop_mean IS 'HDOP Mean';
COMMENT ON COLUMN position.pdop_mean IS 'PDOP Mean';
COMMENT ON COLUMN position.satellites_count_mean IS 'Satellites Count Mean';
COMMENT ON COLUMN position.measurement_count IS 'Measurement Count';
COMMENT ON COLUMN position.rtcm_age IS 'RTCM Age';
COMMENT ON COLUMN position.start_measurement IS 'Start Measurement';
COMMENT ON COLUMN position.stop_measurement IS 'Stop Measurement';
COMMENT ON COLUMN position.device_gps IS 'Device GPS';
COMMENT ON COLUMN position.quality IS 'Quality of GNSS';

ALTER TABLE position ADD CONSTRAINT FK_Position_Plot FOREIGN KEY (plot_id)
	REFERENCES plot (id)
	ON DELETE CASCADE;

--ALTER TABLE position ADD CONSTRAINT CK_Position_Geometry CHECK (ST_IsValid(geometry));
--CREATE INDEX idx_position_geometry ON position USING GIST (geometry);

--- plot_location_id
ALTER TABLE position ADD CONSTRAINT FK_Position_PlotLocation FOREIGN KEY (plot_location_id)
	REFERENCES plot_location (id)
	ON DELETE CASCADE;

ALTER TABLE position ADD CONSTRAINT FK_Position_LookupGnssQuality FOREIGN KEY (quality)
	REFERENCES lookup_gnss_quality (abbreviation);
