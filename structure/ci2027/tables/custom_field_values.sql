SET search_path TO private_ci2027_001, public;

CREATE TABLE custom_field_values (

    id SERIAL PRIMARY KEY,
    custom_field_id INTEGER NOT NULL, -- Foreign Key to parent table
    --parent_table enum_plot_location_parent_table NOT NULL, -- Parent Table Name

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

    name_de VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    sort INTEGER NOT NULL

);

ALTER TABLE custom_field_values ADD CONSTRAINT FK_CustomFieldValues_CustomField FOREIGN KEY (custom_field_id)
    REFERENCES custom_field (id)
    ON DELETE CASCADE;