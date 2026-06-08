-- 09 — Service-Account (LOGIN, INHERIT): die Anwendung verbindet sich hiermit.
CREATE USER :user_sa WITH LOGIN INHERIT PASSWORD :'user_sa_password';

GRANT CONNECT ON DATABASE :database_name TO :user_sa;

ALTER USER :user_sa SET search_path TO
    :schema_config, :schema_etl, :schema_helper, :schema_log, public;
