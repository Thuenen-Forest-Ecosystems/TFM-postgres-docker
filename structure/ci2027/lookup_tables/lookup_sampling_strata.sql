SET search_path TO private_ci2027_001;

CREATE TABLE lookup_sampling_strata AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_sampling_strata ADD COLUMN abbreviation enum_sampling_strata UNIQUE NOT NULL;

INSERT INTO lookup_sampling_strata (abbreviation, name_de, name_en) VALUES
  ('0', 'unsystematisch, Schulungs- oder Demonstration-Trakt', 'unsystematic, training or demonstration cluster'),
  ('1', '1 km x 1 km - Raster', '1 km x 1 km - Grid'),
  ('4', '2 km x 2 km - Raster', '2 km x 2 km - Grid'),
  ('8', '2,83 km x 2,83 km - Raster', '2.83 km x 2.83 km - Grid'),
  ('16', '4 km x 4 km - Raster', '4 km x 4 km- Grid'),
  ('64', '8 km x 8 km - Raster', '8 km x 8 km - Grid'),
  ('128', '11,31 km x 11,31 km - Raster', '11.31 km x 11.31 km - Grid'),
  ('256', '16 km x 16 km - Raster', '16 km x 16 km - Grid'),
  ('512', '22,63 km x 22,63 km - Raster', '22.63 km x 22.63 km - Grid');