\echo "## CREATE TABLE :schema_config.process"

CREATE TABLE IF NOT EXISTS :schema_config.process
(
    id              bigserial      NOT NULL
   ,name            varchar(100)   NOT NULL
   ,created_on      timestamptz    NOT NULL DEFAULT now()
   ,created_by      varchar(100)   NOT NULL DEFAULT current_user
   ,modified_on     timestamptz        NULL
   ,modified_by     varchar(100)       NULL

   ,CONSTRAINT pk_process  PRIMARY KEY (id)
);
ALTER TABLE :schema_config.process OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Unique constraints
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_config.process DROP CONSTRAINT IF EXISTS uq_process_name;
ALTER TABLE :schema_config.process ADD  CONSTRAINT uq_process_name UNIQUE (name);

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_config.process      IS 'Stammdaten: benannte Prozesse (Konfigurationsdaten).';

COMMENT ON COLUMN :schema_config.process.name IS 'Eindeutiger Prozessname (Natural Key, UNIQUE).';

\echo "## CREATE TABLE :schema_config.process - DONE"
