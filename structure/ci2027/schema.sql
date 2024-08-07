SET default_transaction_read_only = OFF;

-- SCHEMA DEFINITION
CREATE SCHEMA private_ci2027_001;
ALTER SCHEMA private_ci2027_001 OWNER TO postgres;

COMMENT ON SCHEMA private_ci2027_001 IS 'Kohlenstoffinventur 2027';

SET search_path TO private_ci2027_001;

CREATE TABLE lookup_TEMPLATE (
    --id SERIAL PRIMARY KEY, // To be set by lookup table individualy
    --abbreviation varchar(10) UNIQUE NOT NULL,  // To be set by lookup table individualy
    name_de VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    sort INTEGER NOT NULL
);