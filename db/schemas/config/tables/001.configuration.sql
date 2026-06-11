\echo "## CREATE TABLE :schema_config.configuration"

CREATE TABLE IF NOT EXISTS :schema_config.configuration
(
    section         varchar(32)    NOT NULL
   ,code            varchar(32)    NOT NULL
   ,value           varchar        NOT NULL
   ,description     varchar            NULL

   ,CONSTRAINT pk_configuration  PRIMARY KEY (section, code)
);
ALTER TABLE :schema_config.configuration OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_config.configuration IS 'Konfigurationswerte der Anwendung (PK: section + code).';
COMMENT ON COLUMN :schema_config.configuration.section IS 'Konfigurationsbereich (Teil des PK).';
COMMENT ON COLUMN :schema_config.configuration.code IS 'Schlüssel innerhalb der Section (Teil des PK).';
COMMENT ON COLUMN :schema_config.configuration.value IS 'Konfigurationswert.';
COMMENT ON COLUMN :schema_config.configuration.description IS 'Optionale Beschreibung des Eintrags.';

\echo "## CREATE TABLE :schema_config.configuration - DONE"
