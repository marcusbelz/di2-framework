\echo "## CREATE TABLE :schema_log.execution"

CREATE TABLE IF NOT EXISTS :schema_log.execution
(
    id              bigserial      NOT NULL
   ,process_id      bigint         NOT NULL
   ,start_on        timestamptz    NOT NULL
   ,end_on          timestamptz        NULL
   ,delta_start     timestamptz        NULL
   ,delta_end       timestamptz        NULL
   ,user_name       varchar(128)       NULL
   ,machine         varchar(128)       NULL
   ,instance        varchar(50)        NULL
   ,version         varchar(50)        NULL
   ,state           varchar(128)       NULL
   ,success         boolean            NULL
   ,created_on      timestamptz    NOT NULL DEFAULT now()
   ,created_by      varchar(100)   NOT NULL DEFAULT current_user
   ,modified_on     timestamptz        NULL
   ,modified_by     varchar(100)       NULL

   ,CONSTRAINT pk_execution  PRIMARY KEY (id)
);
ALTER TABLE :schema_log.execution OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_log.execution DROP CONSTRAINT IF EXISTS fk_execution_process_id;
ALTER TABLE :schema_log.execution ADD  CONSTRAINT fk_execution_process_id FOREIGN KEY (process_id) REFERENCES :schema_config.process(id);

CREATE INDEX IF NOT EXISTS ix_execution_process_id ON :schema_log.execution (process_id);

COMMENT ON TABLE :schema_log.execution IS 'Protokollierung je Prozessausfuehrung (Prozessebene).';

\echo "## CREATE TABLE :schema_log.execution - DONE"
