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

   ,CONSTRAINT pk_component  PRIMARY KEY (id)
);
ALTER TABLE :schema_log.component OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_log.component DROP CONSTRAINT IF EXISTS fk_component_execution_id;
ALTER TABLE :schema_log.component ADD  CONSTRAINT fk_component_execution_id FOREIGN KEY (execution_id) REFERENCES :schema_log.execution(id);

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_log.component              IS 'Protokollierung je Komponente (Prozedur/Python-Funktion) (Komponentenebene).';

COMMENT ON COLUMN :schema_log.component.execution_id IS 'FK -> log.execution: übergeordnete Prozessausführung.';
COMMENT ON COLUMN :schema_log.component.source       IS 'Herkunft/Typ der Komponente (z. B. plpgsql).';
COMMENT ON COLUMN :schema_log.component.component    IS 'Name der Komponente (Prozedur/Python-Funktion).';
COMMENT ON COLUMN :schema_log.component.version      IS 'Version der Komponente.';
COMMENT ON COLUMN :schema_log.component.entity       IS 'Fachliche Entität, die die Komponente bearbeitet.';
COMMENT ON COLUMN :schema_log.component.step         IS 'Verarbeitungsschritt innerhalb der Komponente.';
COMMENT ON COLUMN :schema_log.component.description  IS 'Beschreibung der Komponentenausführung.';
COMMENT ON COLUMN :schema_log.component.state        IS 'Aktueller Status der Komponente.';
COMMENT ON COLUMN :schema_log.component.success      IS 'Erfolgreich abgeschlossen (true/false; NULL = laufend).';

\echo "## CREATE TABLE :schema_log.component - DONE"
