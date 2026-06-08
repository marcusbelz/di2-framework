-- 03 — Framework-Schema-Owner: besitzt alle vier Schemas, legt Objekte an.
CREATE USER :schema_owner WITH LOGIN PASSWORD :'schema_owner_password';

GRANT CONNECT ON DATABASE :database_name TO :schema_owner;

-- Owner-Rolle darf in die Schema-Owner-Rolle wechseln (für DDL-Migrationen).
GRANT :schema_owner TO :database_owner;

-- search_path über alle Framework-Schemas.
ALTER USER :schema_owner SET search_path TO
    :schema_config, :schema_etl, :schema_helper, :schema_log, public;
