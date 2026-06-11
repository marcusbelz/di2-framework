\echo "## CREATE TABLE :schema_config.check_constraint"

CREATE TABLE IF NOT EXISTS :schema_config.check_constraint
(
    id                  bigserial       NOT NULL
   ,procedure_name      varchar(128)    NOT NULL
   ,error_type          char(1)         NOT NULL
   ,task                varchar(128)        NULL
   ,entity              varchar         NOT NULL
   ,step                varchar         NOT NULL
   ,schema_name         varchar(10)     NOT NULL
   ,table_name          varchar(128)    NOT NULL
   ,id1_field_name      varchar(128)    NOT NULL
   ,id2_field_name      varchar(128)        NULL
   ,id3_field_name      varchar(128)        NULL
   ,check_field_name    varchar(1000)   NOT NULL
   ,where_clause        varchar         NOT NULL
   ,max_occurance       integer            NULL
   ,message             varchar         NOT NULL
   ,description         varchar             NULL
   ,is_active           boolean         NOT NULL
   ,is_manual           boolean             NULL

   ,CONSTRAINT pk_check_constraint  PRIMARY KEY (id)
);
ALTER TABLE :schema_config.check_constraint OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_config.check_constraint                  IS 'Pruefregeln (Check Constraints), die beim Laden der Daten geprueft werden.';

COMMENT ON COLUMN :schema_config.check_constraint.procedure_name   IS 'Name der Prüfprozedur, die diese Regel ausführt.';
COMMENT ON COLUMN :schema_config.check_constraint.error_type       IS 'Schweregrad bei Verstoß: E=Error, W=Warning, I=Info.';
COMMENT ON COLUMN :schema_config.check_constraint.task             IS 'Task-/Arbeitsschritt-Name (optional).';
COMMENT ON COLUMN :schema_config.check_constraint.entity           IS 'Fachliche Entität, auf die sich die Prüfung bezieht.';
COMMENT ON COLUMN :schema_config.check_constraint.step             IS 'Verarbeitungsschritt im Ladeprozess.';
COMMENT ON COLUMN :schema_config.check_constraint.schema_name      IS 'Schema der zu prüfenden Tabelle.';
COMMENT ON COLUMN :schema_config.check_constraint.table_name       IS 'Zu prüfende Tabelle.';
COMMENT ON COLUMN :schema_config.check_constraint.id1_field_name   IS 'Name der 1. Identifizierungsspalte (für die Fehlerzuordnung).';
COMMENT ON COLUMN :schema_config.check_constraint.id2_field_name   IS 'Name der 2. Identifizierungsspalte (optional).';
COMMENT ON COLUMN :schema_config.check_constraint.id3_field_name   IS 'Name der 3. Identifizierungsspalte (optional).';
COMMENT ON COLUMN :schema_config.check_constraint.check_field_name IS 'Zu prüfende Spalte(n).';
COMMENT ON COLUMN :schema_config.check_constraint.where_clause     IS 'WHERE-Bedingung zur Eingrenzung der geprüften Zeilen.';
COMMENT ON COLUMN :schema_config.check_constraint.max_occurance    IS 'Maximal erlaubte Trefferzahl, bevor ein Fehler gemeldet wird.';
COMMENT ON COLUMN :schema_config.check_constraint.message          IS 'Fehlermeldung bei Verstoß gegen die Regel.';
COMMENT ON COLUMN :schema_config.check_constraint.description      IS 'Optionale Beschreibung der Prüfregel.';
COMMENT ON COLUMN :schema_config.check_constraint.is_active        IS 'Regel aktiv (true) oder deaktiviert (false).';
COMMENT ON COLUMN :schema_config.check_constraint.is_manual        IS 'Regel manuell gepflegt (true) statt generiert.';

\echo "## CREATE TABLE :schema_config.check_constraint - DONE"
