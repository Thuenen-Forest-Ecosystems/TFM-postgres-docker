SET search_path TO private_ci2027_001;

CREATE TABLE lookup_state AS TABLE lookup_TEMPLATE WITH NO DATA;
ALTER TABLE lookup_state ADD COLUMN abbreviation enum_state UNIQUE NOT NULL;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.11 (Homebrew)


--
-- Data for Name: lookup_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO lookup_state (abbreviation, name_de, name_en) VALUES
  ('BW', 'Baden-Württemberg', 'Baden-Württemberg'),
  ('BY', 'Bayern', 'Bavaria'),
  ('BE', 'Berlin', 'Berlin'),
  ('BB', 'Brandenburg', 'Brandenburg'),
  ('HB', 'Bremen', 'Bremen'),
  ('HH', 'Hamburg', 'Hamburg'),
  ('HE', 'Hessen', 'Hesse'),
  ('MV', 'Mecklenburg-Vorpommern', 'Mecklenburg-Western Pomerania'),
  ('NI', 'Niedersachsen', 'Lower Saxony'),
  ('NW', 'Nordrhein-Westfalen', 'North Rhine-Westphalia'),
  ('RP', 'Rheinland-Pfalz', 'Rhineland-Palatinate'),
  ('SL', 'Saarland', 'Saarland'),
  ('SN', 'Sachsen', 'Saxony'),
  ('ST', 'Sachsen-Anhalt', 'Saxony-Anhalt'),
  ('SH', 'Schleswig-Holstein', 'Schleswig-Holstein'),
  ('TH', 'Thüringen', 'Thuringia');


--
-- PostgreSQL database dump complete
--

