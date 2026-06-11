\echo '-- --------------------------------------------------------------------------------'
\echo '-- PSQL variables (prod)'
\echo '-- --------------------------------------------------------------------------------'

-- --------------------------------------------------------------------------------
-- Database
-- --------------------------------------------------------------------------------
\set database_name            di2f_prod
\set database_owner           di2f_prod_owner
\echo '## database_name       = ' :database_name
\echo '## database_owner      = ' :database_owner

-- --------------------------------------------------------------------------------
-- Framework Schema Owner (besitzt alle vier Schemas)
-- --------------------------------------------------------------------------------
\set schema_owner             di2f_prod_fw
\echo '## schema_owner        = ' :schema_owner

-- --------------------------------------------------------------------------------
-- Schema Names (fix über alle Umgebungen)
-- --------------------------------------------------------------------------------
\set schema_config            config
\set schema_etl               etl
\set schema_helper            helper
\set schema_log               log
\echo '## schemas             = ' :schema_config ', ' :schema_etl ', ' :schema_helper ', ' :schema_log

-- --------------------------------------------------------------------------------
-- Role / User Definitions
-- --------------------------------------------------------------------------------
\set role_rw                  di2f_prod_rw
\set user_sa                  di2f_prod_sa
\echo '## role_rw             = ' :role_rw
\echo '## user_sa             = ' :user_sa

-- Passwörter werden via -v übergeben (DB_OWNER_PASSWORD etc.).
\echo ''
