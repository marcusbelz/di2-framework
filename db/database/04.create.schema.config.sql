-- 04 — Schema config (Owner: Framework-Schema-Owner)
CREATE SCHEMA :schema_config AUTHORIZATION :schema_owner;

-- Vom DB-Owner angelegte Objekte sind automatisch für den Schema-Owner nutzbar.
ALTER DEFAULT PRIVILEGES FOR USER :database_owner IN SCHEMA :schema_config
    GRANT ALL ON TABLES TO :schema_owner;
