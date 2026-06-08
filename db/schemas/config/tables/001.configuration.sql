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
COMMENT ON TABLE :schema_config.configuration IS 'Konfigurationswerte der Anwendung (PK: section + code).';

\echo "## CREATE TABLE :schema_config.configuration - DONE"
