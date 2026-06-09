\echo "## CREATE TABLE :schema_log.process"

CREATE TABLE IF NOT EXISTS :schema_log.process
(
    id              bigserial      NOT NULL
   ,name            varchar(100)   NOT NULL
   ,created_on      timestamptz    NOT NULL DEFAULT now()
   ,created_by      varchar(100)   NOT NULL DEFAULT current_user
   ,modified_on     timestamptz        NULL
   ,modified_by     varchar(100)       NULL

   ,CONSTRAINT pk_process  PRIMARY KEY (id)
);
ALTER TABLE :schema_log.process OWNER TO :schema_owner;
COMMENT ON TABLE :schema_log.process IS 'Stammdaten: benannte Prozesse.';

\echo "## CREATE TABLE :schema_log.process - DONE"
