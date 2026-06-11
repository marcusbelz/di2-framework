\echo "## CREATE TABLE :schema_config.db_version"

CREATE TABLE IF NOT EXISTS :schema_config.db_version
(
    release_version     varchar(50)    NOT NULL
   ,internal_version    varchar(50)        NULL

   ,CONSTRAINT pk_db_version  PRIMARY KEY (release_version)
);
ALTER TABLE :schema_config.db_version OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_config.db_version IS 'Datenbank-Version.';
COMMENT ON COLUMN :schema_config.db_version.release_version IS 'Veröffentlichte DB-Version (PK).';
COMMENT ON COLUMN :schema_config.db_version.internal_version IS 'Interne Versionskennung (optional).';

\echo "## CREATE TABLE :schema_config.db_version - DONE"
