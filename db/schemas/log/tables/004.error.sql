\echo "## CREATE TABLE :schema_log.error"

CREATE TABLE IF NOT EXISTS :schema_log.error
(
    id                  bigserial      NOT NULL
   ,execution_id        bigint         NOT NULL
   ,component_id        bigint             NULL
   ,trace_id            bigint             NULL
   ,error_type          char(1)        NOT NULL
   ,source              varchar(5)     NOT NULL
   ,component           varchar(128)   NOT NULL
   ,task_name           varchar(128)       NULL
   ,entity              varchar(128)       NULL
   ,step                varchar            NULL
   ,schema_name         varchar(128)       NULL
   ,table_name          varchar(128)       NULL
   ,id1_value           varchar            NULL
   ,id1_column_name     varchar(128)       NULL
   ,id2_value           varchar            NULL
   ,id2_column_name     varchar(128)       NULL
   ,id3_value           varchar            NULL
   ,id3_column_name     varchar(128)       NULL
   ,error_value         varchar            NULL
   ,error_column_name   varchar(128)       NULL
   ,file_name           varchar(128)       NULL
   ,description         varchar            NULL
   ,error_number        integer            NULL
   ,error_line          integer            NULL
   ,error_state         varchar            NULL
   ,created_on          timestamptz    NOT NULL DEFAULT now()
   ,created_by          varchar(100)   NOT NULL DEFAULT current_user

   ,CONSTRAINT pk_error  PRIMARY KEY (id)
);
ALTER TABLE :schema_log.error OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_log.error DROP CONSTRAINT IF EXISTS fk_error_execution_id;
ALTER TABLE :schema_log.error ADD  CONSTRAINT fk_error_execution_id FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id);

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_log.error                   IS 'Protokollierung von Datenfehlern (Severity ueber error_type: E/W/I).';

COMMENT ON COLUMN :schema_log.error.execution_id      IS 'FK -> log.execution: Ausführung, in der der Fehler auftrat.';
COMMENT ON COLUMN :schema_log.error.component_id      IS 'Zugehörige Komponente (optional).';
COMMENT ON COLUMN :schema_log.error.trace_id          IS 'Zugehöriger Trace-Eintrag (optional).';
COMMENT ON COLUMN :schema_log.error.error_type        IS 'Schweregrad: E=Error, W=Warning, I=Info.';
COMMENT ON COLUMN :schema_log.error.source            IS 'Herkunft/Typ der fehlerverursachenden Komponente.';
COMMENT ON COLUMN :schema_log.error.component         IS 'Name der fehlerverursachenden Komponente.';
COMMENT ON COLUMN :schema_log.error.task_name         IS 'Task-/Arbeitsschritt-Name (optional).';
COMMENT ON COLUMN :schema_log.error.entity            IS 'Fachliche Entität, bei der der Fehler auftrat.';
COMMENT ON COLUMN :schema_log.error.step              IS 'Verarbeitungsschritt.';
COMMENT ON COLUMN :schema_log.error.schema_name       IS 'Schema der betroffenen Tabelle.';
COMMENT ON COLUMN :schema_log.error.table_name        IS 'Betroffene Tabelle.';
COMMENT ON COLUMN :schema_log.error.id1_value         IS 'Wert der 1. Identifizierungsspalte des fehlerhaften Datensatzes.';
COMMENT ON COLUMN :schema_log.error.id1_column_name   IS 'Name der 1. Identifizierungsspalte.';
COMMENT ON COLUMN :schema_log.error.id2_value         IS 'Wert der 2. Identifizierungsspalte (optional).';
COMMENT ON COLUMN :schema_log.error.id2_column_name   IS 'Name der 2. Identifizierungsspalte (optional).';
COMMENT ON COLUMN :schema_log.error.id3_value         IS 'Wert der 3. Identifizierungsspalte (optional).';
COMMENT ON COLUMN :schema_log.error.id3_column_name   IS 'Name der 3. Identifizierungsspalte (optional).';
COMMENT ON COLUMN :schema_log.error.error_value       IS 'Fehlerhafter Wert der geprüften Spalte.';
COMMENT ON COLUMN :schema_log.error.error_column_name IS 'Name der Spalte mit dem fehlerhaften Wert.';
COMMENT ON COLUMN :schema_log.error.file_name         IS 'Quelldatei, aus der der Datensatz stammt (optional).';
COMMENT ON COLUMN :schema_log.error.description       IS 'Beschreibung des Fehlers.';
COMMENT ON COLUMN :schema_log.error.error_number      IS 'Fehlernummer (technischer Code).';
COMMENT ON COLUMN :schema_log.error.error_line        IS 'Zeilennummer/Position des Fehlers.';
COMMENT ON COLUMN :schema_log.error.error_state       IS 'Technischer Fehler-Status/-Zustand.';

\echo "## CREATE TABLE :schema_log.error - DONE"
