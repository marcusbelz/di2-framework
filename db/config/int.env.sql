\echo '-- --------------------------------------------------------------------------------'
\echo '-- PSQL variables (int)'
\echo '-- --------------------------------------------------------------------------------'

-- --------------------------------------------------------------------------------
-- Database
-- --------------------------------------------------------------------------------
\set database_name            di2_int
\set database_owner           di2_int_owner
\echo '## database_name       = ' :database_name
\echo '## database_owner      = ' :database_owner

-- --------------------------------------------------------------------------------
-- Framework Schema Owner (besitzt alle vier Schemas)
-- --------------------------------------------------------------------------------
\set schema_owner             di2_int_fw
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
\set role_rw                  di2_int_rw
\set user_sa                  di2_int_sa
\echo '## role_rw             = ' :role_rw
\echo '## user_sa             = ' :user_sa

-- Passwörter werden via -v übergeben (DB_OWNER_PASSWORD etc.).
\echo ''
