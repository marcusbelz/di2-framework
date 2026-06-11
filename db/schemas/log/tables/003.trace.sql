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

COMMENT ON TABLE :schema_log.trace IS 'Detaillierte Protokollierung je Einzelaktion im Prozess (unterste Ebene).';

\echo "## CREATE TABLE :schema_log.trace - DONE"
