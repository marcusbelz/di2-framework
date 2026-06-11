\echo "## CREATE TABLE :schema_config.db_version"

CREATE TABLE IF NOT EXISTS :schema_config.db_version
(
    id                bigserial    NOT NULL
   ,major             int          NOT NULL
   ,minor             int          NOT NULL
   ,build             int          NOT NULL
   ,release_version   varchar      NOT NULL GENERATED ALWAYS AS (major::text || '.' || minor::text || '.' || build::text) STORED
   ,git_commit        varchar(64)  NOT NULL
   ,git_tag           varchar(100)     NULL
   ,environment       varchar(10)  NOT NULL
   ,deployed_on       timestamptz  NOT NULL DEFAULT now()

   ,CONSTRAINT pk_db_version  PRIMARY KEY (id)

   ,CONSTRAINT chk_db_version_environment  CHECK (environment IN ('dev', 'int', 'test', 'prod'))
   ,CONSTRAINT chk_db_version_version      CHECK (major >= 0 AND minor >= 0 AND build >= 0)
);
ALTER TABLE :schema_config.db_version OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_config.db_version IS 'Deploy-Historie der Datenbank-Version: eine Zeile je Deploy (Version, Git-Stand, Umgebung).';
COMMENT ON COLUMN :schema_config.db_version.major IS 'Hauptversion (major) der Release-Version.';
COMMENT ON COLUMN :schema_config.db_version.minor IS 'Nebenversion (minor) der Release-Version.';
COMMENT ON COLUMN :schema_config.db_version.build IS 'Build-Nummer der Release-Version.';
COMMENT ON COLUMN :schema_config.db_version.release_version IS 'Lesbare Release-Version „major.minor.build" (generiert, stets konsistent zu major/minor/build).';
COMMENT ON COLUMN :schema_config.db_version.git_commit IS 'Commit-SHA des deployten Git-Stands.';
COMMENT ON COLUMN :schema_config.db_version.git_tag IS 'Git-Release-Tag des Stands (optional; NULL, wenn nicht getaggt).';
COMMENT ON COLUMN :schema_config.db_version.environment IS 'Zielumgebung des Deploys: dev/int/test/prod.';
COMMENT ON COLUMN :schema_config.db_version.deployed_on IS 'Zeitpunkt des Deploys.';

\echo "## CREATE TABLE :schema_config.db_version - DONE"
