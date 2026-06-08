-- 01 — Datenbank + Owner-Rolle (gegen Maintenance-DB 'postgres' ausführen)
CREATE ROLE :database_owner WITH LOGIN PASSWORD :'database_owner_password';

CREATE DATABASE :database_name
    WITH
    OWNER = :database_owner
    ENCODING = 'UTF8';

REVOKE CONNECT ON DATABASE :database_name FROM PUBLIC;
GRANT  CONNECT ON DATABASE :database_name TO   :database_owner;
