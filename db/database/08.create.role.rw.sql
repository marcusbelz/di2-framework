-- 08 — RW-Gruppenrolle (NOLOGIN): DML über alle vier Framework-Schemas.
CREATE ROLE :role_rw WITH
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOINHERIT
    NOLOGIN
    NOREPLICATION
    NOBYPASSRLS
    CONNECTION LIMIT -1;

GRANT :role_rw TO postgres;
GRANT CONNECT ON DATABASE :database_name TO :role_rw;

-- --------------------------------------------------------------------------------
-- Bestehende Objekte: USAGE auf Schema, DML auf Tabellen, Sequenzen, Routinen.
-- (USAGE, nicht CREATE — Objekte legt nur der Schema-Owner an.)
-- --------------------------------------------------------------------------------
GRANT USAGE ON SCHEMA :schema_config, :schema_etl, :schema_helper, :schema_log TO :role_rw;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA :schema_config TO :role_rw;
GRANT USAGE                          ON ALL SEQUENCES IN SCHEMA :schema_config TO :role_rw;
GRANT EXECUTE                        ON ALL ROUTINES  IN SCHEMA :schema_config TO :role_rw;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA :schema_etl    TO :role_rw;
GRANT USAGE                          ON ALL SEQUENCES IN SCHEMA :schema_etl    TO :role_rw;
GRANT EXECUTE                        ON ALL ROUTINES  IN SCHEMA :schema_etl    TO :role_rw;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA :schema_helper TO :role_rw;
GRANT USAGE                          ON ALL SEQUENCES IN SCHEMA :schema_helper TO :role_rw;
GRANT EXECUTE                        ON ALL ROUTINES  IN SCHEMA :schema_helper TO :role_rw;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA :schema_log    TO :role_rw;
GRANT USAGE                          ON ALL SEQUENCES IN SCHEMA :schema_log    TO :role_rw;
GRANT EXECUTE                        ON ALL ROUTINES  IN SCHEMA :schema_log    TO :role_rw;

-- --------------------------------------------------------------------------------
-- Default Privileges: künftige Objekte des Schema-Owners automatisch erreichbar.
-- --------------------------------------------------------------------------------
ALTER DEFAULT PRIVILEGES FOR ROLE :schema_owner IN SCHEMA :schema_config, :schema_etl, :schema_helper, :schema_log
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :role_rw;

ALTER DEFAULT PRIVILEGES FOR ROLE :schema_owner IN SCHEMA :schema_config, :schema_etl, :schema_helper, :schema_log
    GRANT USAGE ON SEQUENCES TO :role_rw;

ALTER DEFAULT PRIVILEGES FOR ROLE :schema_owner IN SCHEMA :schema_config, :schema_etl, :schema_helper, :schema_log
    GRANT EXECUTE ON ROUTINES TO :role_rw;

-- Hinweis: Falls die Logging-Konvention später (analog SQL-Server-Vorlage)
-- `SET LOCAL lc_messages TO 'C'` in Prozeduren nutzt, braucht die Laufzeitrolle
-- zusätzlich: GRANT SET ON PARAMETER lc_messages TO :role_rw;  (PG15+)
