SET search_path TO private_ci2027_001;

-- DOMAIN

CREATE DOMAIN CK_BHD as integer check(value >= 70 AND value <= 10000);
CREATE DOMAIN CK_GON AS smallint CHECK (value >= 0 AND value <= 400);
CREATE DOMAIN CK_SLOPE_DEGREE AS smallint CHECK (value >= 0 AND value <= 45);
CREATE DOMAIN CK_STAND_AGE AS smallint CHECK (value > 0 AND value < 300);
CREATE DOMAIN CK_TopographicMapNumber as integer check(value between 999 and 10000);
CREATE DOMAIN CK_FORESTRY_DEPARTMENT as smallint check(value between 999 and 99999);

CREATE DOMAIN CK_BIOTOPE as smallint check(value between 0 and 9999);