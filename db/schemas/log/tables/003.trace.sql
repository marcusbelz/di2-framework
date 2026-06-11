\echo "## CREATE TABLE :schema_log.trace"

CREATE TABLE IF NOT EXISTS :schema_log.trace
(
    id              bigserial      NOT NULL
   ,execution_id    bigint         NOT NULL
   ,component_id    bigint         NOT NULL
   ,source          varchar(5)     NOT NULL
   ,component       varchar(128)   NOT NULL
   ,task            varchar(128)       NULL
   ,entity          varchar(128)       NULL
   ,step            varchar        NOT NULL
   ,description     varchar            NULL
   ,action          varchar(100)       NULL
   ,affected_rows   integer            NULL
   ,state           varchar(100)   NOT NULL
   ,success         boolean        NOT NULL
   ,created_on      timestamptz    NOT NULL DEFAULT now()
   ,created_by      varchar(100)   NOT NULL DEFAULT current_user
   ,modified_on     timestamptz        NULL
   ,modified_by     varchar(100)       NULL

   ,CONSTRAINT pk_trace  PRIMARY KEY (id)
);
ALTER TABLE :schema_log.trace OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_log.trace DROP CONSTRAINT IF EXISTS fk_trace_component_id;
ALTER TABLE :schema_log.trace ADD  CONSTRAINT fk_trace_component_id FOREIGN KEY (component_id) REFERENCES :schema_log.component(id);
ALTER TABLE :schema_log.trace DROP CONSTRAINT IF EXISTS fk_trace_execution_id;
ALTER TABLE :schema_log.trace ADD  CONSTRAINT fk_trace_execution_id FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id);

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_log.trace IS 'Detaillierte Protokollierung je Einzelaktion im Prozess (unterste Ebene).';
COMMENT ON COLUMN :schema_log.trace.execution_id IS 'FK -> log.execution: zugehörige Prozessausführung.';
COMMENT ON COLUMN :schema_log.trace.component_id IS 'FK -> log.component: zugehörige Komponente.';
COMMENT ON COLUMN :schema_log.trace.source IS 'Herkunft/Typ der protokollierten Aktion.';
COMMENT ON COLUMN :schema_log.trace.component IS 'Name der ausführenden Komponente.';
COMMENT ON COLUMN :schema_log.trace.task IS 'Task-/Arbeitsschritt-Name (optional).';
COMMENT ON COLUMN :schema_log.trace.entity IS 'Fachliche Entität der Aktion.';
COMMENT ON COLUMN :schema_log.trace.step IS 'Verarbeitungsschritt.';
COMMENT ON COLUMN :schema_log.trace.description IS 'Beschreibung der Einzelaktion.';
COMMENT ON COLUMN :schema_log.trace.action IS 'Art der Aktion (z. B. INSERT/UPDATE/DELETE).';
COMMENT ON COLUMN :schema_log.trace.affected_rows IS 'Anzahl der von der Aktion betroffenen Zeilen.';
COMMENT ON COLUMN :schema_log.trace.state IS 'Status der Aktion.';
COMMENT ON COLUMN :schema_log.trace.success IS 'Aktion erfolgreich (true/false).';

\echo "## CREATE TABLE :schema_log.trace - DONE"
