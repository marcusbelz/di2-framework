-- 05 — Schema etl (Owner: Framework-Schema-Owner)
CREATE SCHEMA :schema_etl AUTHORIZATION :schema_owner;

ALTER DEFAULT PRIVILEGES FOR USER :database_owner IN SCHEMA :schema_etl
    GRANT ALL ON TABLES TO :schema_owner;
