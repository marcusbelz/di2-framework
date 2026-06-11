\echo "## CREATE TABLE :schema_log.export_file"

CREATE TABLE IF NOT EXISTS :schema_log.export_file
(
    id                  bigserial       NOT NULL
   ,execution_id        bigint          NOT NULL
   ,file_name_export    varchar(1024)   NOT NULL
   ,exported_rows       integer         NOT NULL
   ,error_rows          integer         NOT NULL
   ,created             timestamptz         NULL
   ,file_size           integer             NULL
   ,export_date         timestamptz         NULL

   ,CONSTRAINT pk_export_file  PRIMARY KEY (id)
);
ALTER TABLE :schema_log.export_file OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_log.export_file DROP CONSTRAINT IF EXISTS fk_export_file_execution_id;
ALTER TABLE :schema_log.export_file ADD  CONSTRAINT fk_export_file_execution_id FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id);

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_log.export_file                  IS 'Informationen zu exportierten Dateien.';

COMMENT ON COLUMN :schema_log.export_file.execution_id     IS 'FK -> log.execution: zugehörige Prozessausführung.';
COMMENT ON COLUMN :schema_log.export_file.file_name_export IS 'Pfad/Name der Exportdatei.';
COMMENT ON COLUMN :schema_log.export_file.exported_rows    IS 'Anzahl exportierter Zeilen.';
COMMENT ON COLUMN :schema_log.export_file.error_rows       IS 'Anzahl fehlerhafter/abgewiesener Zeilen.';
COMMENT ON COLUMN :schema_log.export_file.created          IS 'Erstellzeitpunkt der Datei (Dateisystem).';
COMMENT ON COLUMN :schema_log.export_file.file_size        IS 'Dateigröße in Bytes.';
COMMENT ON COLUMN :schema_log.export_file.export_date      IS 'Zeitpunkt des Exports.';

\echo "## CREATE TABLE :schema_log.export_file - DONE"
