SET search_path TO private_ci2027_001, public;

CREATE TABLE custom_field (

    id SERIAL PRIMARY KEY,
    plot_id INTEGER NOT NULL, -- Foreign Key to parent table
    --parent_table enum_plot_location_parent_table NOT NULL, -- Parent Table Name

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

    data_type enum:_regtype::REGTYPE NOT NULL,

    description_de VARCHAR(150) NOT NULL,
    description_en VARCHAR(150) NULL,
    
    default_value INTEGER NULL,

);

ALTER TABLE custom_field ADD CONSTRAINT FK_CustomField_Plot FOREIGN KEY (plot_id)
    REFERENCES plot (id)
    ON DELETE CASCADE;

ALTER TABLE custom_field ADD CONSTRAINT FK_CustomField_DefaultValue FOREIGN KEY (default_value)
    REFERENCES custom_field_values (id)
    ON DELETE SET NULL;

COMMENT ON TABLE custom_field IS 'Custom Fields';


enum_custom_field_type 