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

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_config.table_metadata IS 'Metadaten: eine Zeile je Spalte einer Quellsystem-Tabelle.';
COMMENT ON COLUMN :schema_config.table_metadata.schema_id IS 'Numerische Schema-ID im Quellsystem.';
COMMENT ON COLUMN :schema_config.table_metadata.schema_name IS 'Schemaname (Teil des PK).';
COMMENT ON COLUMN :schema_config.table_metadata.table_id IS 'Numerische Tabellen-ID im Quellsystem.';
COMMENT ON COLUMN :schema_config.table_metadata.table_name IS 'Tabellenname (Teil des PK).';
COMMENT ON COLUMN :schema_config.table_metadata.column_id IS 'Spalten-ID / Ordinalposition im Quellsystem.';
COMMENT ON COLUMN :schema_config.table_metadata.column_name IS 'Spaltenname (Teil des PK).';
COMMENT ON COLUMN :schema_config.table_metadata.datatype IS 'Datentyp der Spalte im Quellsystem.';
COMMENT ON COLUMN :schema_config.table_metadata.length IS 'Länge des Datentyps (falls zutreffend).';
COMMENT ON COLUMN :schema_config.table_metadata.precision IS 'Genauigkeit (Gesamtstellen) bei numerischen Typen.';
COMMENT ON COLUMN :schema_config.table_metadata.scale IS 'Nachkommastellen bei numerischen Typen.';
COMMENT ON COLUMN :schema_config.table_metadata.is_nullable IS 'Spalte erlaubt NULL-Werte.';
COMMENT ON COLUMN :schema_config.table_metadata.is_identity IS 'Spalte ist eine Identity-/Autowert-Spalte.';
COMMENT ON COLUMN :schema_config.table_metadata.is_user_defined IS 'Spalte nutzt einen benutzerdefinierten Datentyp.';
COMMENT ON COLUMN :schema_config.table_metadata.collation_name IS 'Sortier-/Vergleichsregel (Collation) der Spalte.';
COMMENT ON COLUMN :schema_config.table_metadata.index_primary_key IS 'Position der Spalte im PK-Index (NULL = nicht enthalten).';
COMMENT ON COLUMN :schema_config.table_metadata.index_non_primary_key IS 'Position der Spalte in einem Nicht-PK-Index (NULL = nicht enthalten).';
COMMENT ON COLUMN :schema_config.table_metadata.null_handling IS 'Steuerung der NULL-Behandlung beim Laden (Code).';
COMMENT ON COLUMN :schema_config.table_metadata.check_data IS 'Spalte wird beim Laden geprüft.';
COMMENT ON COLUMN :schema_config.table_metadata.decode_xml IS 'XML-Inhalt der Spalte wird beim Laden dekodiert.';
COMMENT ON COLUMN :schema_config.table_metadata.date_style IS 'Datumsformat/-stil für die Konvertierung (falls Datumsspalte).';

\echo "## CREATE TABLE :schema_config.table_metadata - DONE"
