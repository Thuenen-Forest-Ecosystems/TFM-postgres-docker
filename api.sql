CREATE SCHEMA api AUTHORIZATION postgres;

-- Propergate schema names to the schema_names view
CREATE VIEW api.schema_names AS
SELECT schema_name
FROM information_schema.schemata;

