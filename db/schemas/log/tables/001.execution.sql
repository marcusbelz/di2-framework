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

-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_log.execution             IS 'Protokollierung je Prozessausfuehrung (Prozessebene).';

COMMENT ON COLUMN :schema_log.execution.process_id  IS 'FK -> config.process: ausgeführter Prozess.';
COMMENT ON COLUMN :schema_log.execution.start_on    IS 'Startzeitpunkt der Prozessausführung.';
COMMENT ON COLUMN :schema_log.execution.end_on      IS 'Endzeitpunkt der Prozessausführung (NULL, solange laufend).';
COMMENT ON COLUMN :schema_log.execution.delta_start IS 'Startzeitpunkt des Delta-/Inkrement-Zeitfensters.';
COMMENT ON COLUMN :schema_log.execution.delta_end   IS 'Endzeitpunkt des Delta-/Inkrement-Zeitfensters.';
COMMENT ON COLUMN :schema_log.execution.user_name   IS 'Benutzer der Ausführung.';
COMMENT ON COLUMN :schema_log.execution.machine     IS 'Host/Maschine, auf der die Ausführung lief.';
COMMENT ON COLUMN :schema_log.execution.instance    IS 'Instanz-/Umgebungskennung.';
COMMENT ON COLUMN :schema_log.execution.version     IS 'Version der ausführenden Anwendung.';
COMMENT ON COLUMN :schema_log.execution.state       IS 'Aktueller Status der Ausführung.';
COMMENT ON COLUMN :schema_log.execution.success     IS 'Erfolgreich abgeschlossen (true/false; NULL = laufend).';

\echo "## CREATE TABLE :schema_log.execution - DONE"
