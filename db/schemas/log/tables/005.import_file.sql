\echo "## CREATE TABLE :schema_log.import_file"

CREATE TABLE IF NOT EXISTS :schema_log.import_file
(
    id                  bigserial       NOT NULL
   ,execution_id        bigint          NOT NULL
   ,file_name_source    varchar(1024)   NOT NULL
   ,file_name_working   varchar(1024)   NOT NULL
   ,file_name_archive   varchar(1024)       NULL
   ,created             timestamptz         NULL
   ,file_size           bigint              NULL
   ,import_date         timestamptz         NULL

   ,CONSTRAINT pk_import_file  PRIMARY KEY (id)
);
ALTER TABLE :schema_log.import_file OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_log.import_file DROP CONSTRAINT IF EXISTS fk_import_file_execution_id;
ALTER TABLE :schema_log.import_file ADD  CONSTRAINT fk_import_file_execution_id FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id);

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_log.import_file IS 'Informationen zu importierten Dateien.';
COMMENT ON COLUMN :schema_log.import_file.execution_id IS 'FK -> log.execution: zugehörige Prozessausführung.';
COMMENT ON COLUMN :schema_log.import_file.file_name_source IS 'Ursprünglicher Pfad/Name der Quelldatei.';
COMMENT ON COLUMN :schema_log.import_file.file_name_working IS 'Pfad/Name der Datei im Arbeitsverzeichnis.';
COMMENT ON COLUMN :schema_log.import_file.file_name_archive IS 'Pfad/Name der archivierten Datei (nach Verarbeitung).';
COMMENT ON COLUMN :schema_log.import_file.created IS 'Erstellzeitpunkt der Datei (Dateisystem).';
COMMENT ON COLUMN :schema_log.import_file.file_size IS 'Dateigröße in Bytes.';
COMMENT ON COLUMN :schema_log.import_file.import_date IS 'Zeitpunkt des Imports.';

\echo "## CREATE TABLE :schema_log.import_file - DONE"
