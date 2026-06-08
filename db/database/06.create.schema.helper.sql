-- 06 — Schema helper (Owner: Framework-Schema-Owner)
CREATE SCHEMA :schema_helper AUTHORIZATION :schema_owner;

ALTER DEFAULT PRIVILEGES FOR USER :database_owner IN SCHEMA :schema_helper
    GRANT ALL ON TABLES TO :schema_owner;
