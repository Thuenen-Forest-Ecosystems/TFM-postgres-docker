

CREATE SCHEMA dev_automated_001;

COMMENT ON SCHEMA dev_automated_001 IS 'Schema für die BWI-Datenbank';

ALTER SCHEMA dev_automated_001 OWNER TO postgres;

GRANT USAGE ON SCHEMA dev_automated_001 TO web_anon;
GRANT USAGE ON SCHEMA dev_automated_001 TO laender;

-- b3_tnr

CREATE TABLE dev_automated_001.b3_tnr (
  intkey TEXT,
  datvon TEXT,
  datbis TEXT,
  ledituser TEXT,
  ledittime TIMESTAMP,
  dathoheit TEXT,
  datverwend TEXT,
  Tnr INTEGER,
  Soll_RE SMALLINT,
  Soll_dRE SMALLINT,
  Soll_HO SMALLINT,
  Soll_dHO SMALLINT,
  Soll_RechtsT INTEGER,
  Soll_HochT INTEGER,
  TopKar SMALLINT,
  AufnBl SMALLINT,
  StandardBl SMALLINT,
  Laender TEXT,
  Netz SMALLINT,
  Netz64 SMALLINT,
  Ktg SMALLINT
);

COMMENT ON TABLE dev_automated_001.b3_tnr IS 'Trakte der Aufnahme';
COMMENT ON COLUMN dev_automated_001.b3_tnr.intkey IS 'ID des Traktes';

GRANT INSERT, UPDATE, SELECT ON TABLE dev_automated_001.b3_tnr TO laender;
GRANT SELECT ON TABLE dev_automated_001.b3_tnr TO web_anon;

ALTER TABLE dev_automated_001.b3_tnr ADD CONSTRAINT b3_tnr_key UNIQUE (intkey);
ALTER TABLE dev_automated_001.b3_tnr OWNER TO postgres;
ALTER TABLE dev_automated_001.b3_tnr ENABLE ROW LEVEL SECURITY;



-- b3_ecke

CREATE TABLE dev_automated_001.b3_ecke (
  intkey TEXT,
  datvon TEXT,
  datbis TEXT,
  ledituser TEXT,
  ledittime TIMESTAMP,
  dathoheit TEXT,
  datverwend TEXT,
  reftnr TEXT,
  refkey TEXT,
  Tnr INTEGER,
  Enr SMALLINT,
  Vbl SMALLINT,
  Bl SMALLINT,
  AufnBl SMALLINT,
  Soll_RechtsE INTEGER,
  Soll_HochE INTEGER,
  Soll_X_GK2 INTEGER,
  Soll_Y_GK2 INTEGER,
  Soll_X_GK3 INTEGER,
  Soll_Y_GK3 INTEGER,
  Soll_X_GK4 INTEGER,
  Soll_Y_GK4 INTEGER,
  Soll_X_GK5 INTEGER,
  Soll_Y_GK5 INTEGER,
  Soll_X_WGS84 DOUBLE PRECISION,
  Soll_Y_WGS84 DOUBLE PRECISION,
  Soll_X_32N DOUBLE PRECISION,
  Soll_Y_32N DOUBLE PRECISION,
  Soll_X_33N DOUBLE PRECISION,
  Soll_Y_33N DOUBLE PRECISION,
  Wg SMALLINT,
  Wb SMALLINT,
  HoeNN SMALLINT,
  AGS TEXT,
  ATKIS SMALLINT,
  DOP SMALLINT,
  DLM SMALLINT
);
ALTER TABLE dev_automated_001.b3_ecke
ADD CONSTRAINT b3_ecke_key UNIQUE (intkey);

GRANT INSERT, UPDATE, SELECT ON TABLE dev_automated_001.b3_ecke TO laender;
GRANT SELECT ON TABLE dev_automated_001.b3_ecke TO web_anon;

ALTER TABLE dev_automated_001.b3_ecke OWNER TO postgres;
ALTER TABLE dev_automated_001.b3_ecke ENABLE ROW LEVEL SECURITY;
-- wzp

CREATE TABLE dev_automated_001.b3v_wzp (
  intkey TEXT,
  datvon TEXT,
  datbis TEXT,
  ledituser TEXT,
  ledittime TIMESTAMP,
  dathoheit TEXT,
  datverwend TEXT,
  reftnr TEXT,
  refenr TEXT,
  refkey TEXT,
  Tnr INTEGER,
  Enr SMALLINT,
  Vbl SMALLINT,
  Bnr SMALLINT,
  Perm SMALLINT,
  Pk SMALLINT,
  Azi SMALLINT,
  Hori SMALLINT,
  Ba SMALLINT,
  M_Bhd SMALLINT,
  M_hBhd SMALLINT,
  M_Do SMALLINT,
  M_hDo SMALLINT,
  M_Hoe SMALLINT,
  M_StHoe SMALLINT,
  MPos_Azi SMALLINT,
  MPos_Hori SMALLINT,
  Al_ba SMALLINT,
  Kal SMALLINT,
  Kh SMALLINT,
  Kst SMALLINT,
  Bkl SMALLINT,
  Ast SMALLINT,
  Ast_Hoe SMALLINT,
  Ges_Hoe SMALLINT,
  Bz SMALLINT,
  Bs SMALLINT,
  Tot SMALLINT,
  jSchael SMALLINT,
  aeSchael SMALLINT,
  Ruecke SMALLINT,
  Pilz SMALLINT,
  Harz SMALLINT,
  Kaefer SMALLINT,
  sStamm SMALLINT,
  FaulKon SMALLINT,
  Hoehle SMALLINT,
  Bizarr SMALLINT,
  Uralt SMALLINT,
  Horst SMALLINT,
  MBiotop SMALLINT,
  WZ1 SMALLINT,
  WZ2 SMALLINT,
  WZ3 SMALLINT,
  Do_Geraet SMALLINT,
  K DOUBLE PRECISION
);
ALTER TABLE dev_automated_001.b3v_wzp
ADD CONSTRAINT b3v_wzp_key UNIQUE (intkey);

GRANT SELECT ON TABLE dev_automated_001.b3v_wzp TO web_anon;
GRANT INSERT, UPDATE, SELECT ON TABLE dev_automated_001.b3v_wzp TO laender;

ALTER TABLE dev_automated_001.b3v_wzp ENABLE ROW LEVEL SECURITY;
ALTER TABLE dev_automated_001.b3v_wzp OWNER TO postgres;