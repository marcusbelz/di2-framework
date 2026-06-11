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

-- Foreign keys
ALTER TABLE :schema_log.export_file DROP CONSTRAINT IF EXISTS fk_export_file_execution_id;
ALTER TABLE :schema_log.export_file ADD  CONSTRAINT fk_export_file_execution_id FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id);

COMMENT ON TABLE :schema_log.export_file IS 'Informationen zu exportierten Dateien.';

\echo "## CREATE TABLE :schema_log.export_file - DONE"
