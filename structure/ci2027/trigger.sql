SET search_path TO private_ci2027_001;

CREATE OR REPLACE FUNCTION update_table()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_by = CURRENT_USER::REGROLE;
    NEW.modified_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_modified_at_before_update
BEFORE UPDATE ON cluster
FOR EACH ROW
EXECUTE FUNCTION update_table();

CREATE TRIGGER trigger_plot_modified
BEFORE UPDATE ON plot
FOR EACH ROW
EXECUTE FUNCTION update_table();

CREATE TRIGGER trigger_plot_location_modified
BEFORE UPDATE ON plot_location
FOR EACH ROW
EXECUTE FUNCTION update_table();

CREATE TRIGGER trigger_wzp_tree_modified
BEFORE UPDATE ON wzp_tree
FOR EACH ROW
EXECUTE FUNCTION update_table();