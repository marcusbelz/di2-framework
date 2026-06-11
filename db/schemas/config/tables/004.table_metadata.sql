\echo "## CREATE TABLE :schema_config.table_metadata"

CREATE TABLE IF NOT EXISTS :schema_config.table_metadata
(
    schema_id               integer         NOT NULL
   ,schema_name             varchar(128)    NOT NULL
   ,table_id                integer         NOT NULL
   ,table_name              varchar(128)    NOT NULL
   ,column_id               integer         NOT NULL
   ,column_name             varchar(128)    NOT NULL
   ,datatype                varchar(128)    NOT NULL
   ,length                  integer             NULL
   ,precision               integer             NULL
   ,scale                   integer             NULL
   ,is_nullable             boolean             NULL
   ,is_identity             boolean             NULL
   ,is_user_defined         boolean             NULL
   ,collation_name          varchar(128)        NULL
   ,index_primary_key       integer             NULL
   ,index_non_primary_key   integer             NULL
   ,null_handling           char(1)             NULL
   ,check_data              boolean         NOT NULL DEFAULT true
   ,decode_xml              boolean         NOT NULL DEFAULT false
   ,date_style              varchar(50)         NULL

   ,CONSTRAINT pk_table_metadata  PRIMARY KEY (schema_name, table_name, column_name)
);
ALTER TABLE :schema_config.table_metadata OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Unique constraints
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_config.table_metadata DROP CONSTRAINT IF EXISTS uq_table_metadata_ak1;
ALTER TABLE :schema_config.table_metadata ADD  CONSTRAINT uq_table_metadata_ak1 UNIQUE (schema_id, table_id, column_id);

COMMENT ON TABLE :schema_config.table_metadata IS 'Metadaten: eine Zeile je Spalte einer Quellsystem-Tabelle.';

\echo "## CREATE TABLE :schema_config.table_metadata - DONE"
