\echo "## CREATE TABLE :schema_log.component"

CREATE TABLE IF NOT EXISTS :schema_log.component
(
    id              bigserial      NOT NULL
   ,execution_id    bigint             NULL
   ,source          varchar(5)         NULL
   ,component       varchar(128)       NULL
   ,version         integer            NULL
   ,entity          varchar(128)       NULL
   ,step            varchar            NULL
   ,description     varchar            NULL
   ,state           varchar(100)       NULL
   ,success         boolean            NULL
   ,created_on      timestamptz        NULL DEFAULT now()
   ,created_by      varchar(100)       NULL DEFAULT current_user
   ,modified_on     timestamptz        NULL
   ,modified_by     varchar(100)       NULL

   ,CONSTRAINT pk_component               PRIMARY KEY (id)

   ,CONSTRAINT fk_component_execution_id  FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id)
);
ALTER TABLE :schema_log.component OWNER TO :schema_owner;
COMMENT ON TABLE :schema_log.component IS 'Protokollierung je Komponente (Prozedur/Python-Funktion) (Komponentenebene).';

\echo "## CREATE TABLE :schema_log.component - DONE"
