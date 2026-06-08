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

   ,CONSTRAINT pk_error               PRIMARY KEY (id)

   ,CONSTRAINT fk_error_execution_id  FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id)
);
ALTER TABLE :schema_log.error OWNER TO :schema_owner;
COMMENT ON TABLE :schema_log.error IS 'Protokollierung von Datenfehlern (Severity ueber error_type: E/W/I).';

\echo "## CREATE TABLE :schema_log.error - DONE"
