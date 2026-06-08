-- 07 — Schema log (Owner: Framework-Schema-Owner)
CREATE SCHEMA :schema_log AUTHORIZATION :schema_owner;

ALTER DEFAULT PRIVILEGES FOR USER :database_owner IN SCHEMA :schema_log
    GRANT ALL ON TABLES TO :schema_owner;
