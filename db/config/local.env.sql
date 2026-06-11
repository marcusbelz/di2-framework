\echo '-- --------------------------------------------------------------------------------'
\echo '-- PSQL variables (local)'
\echo '-- --------------------------------------------------------------------------------'

-- --------------------------------------------------------------------------------
-- Database
-- --------------------------------------------------------------------------------
\set database_name            di2f
\set database_owner           di2f_owner
\echo '## database_name       = ' :database_name
\echo '## database_owner      = ' :database_owner

-- --------------------------------------------------------------------------------
-- Framework Schema Owner (besitzt alle vier Schemas)
-- --------------------------------------------------------------------------------
\set schema_owner             di2f_fw
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
\set role_rw                  di2f_rw
\set user_sa                  di2f_sa
\echo '## role_rw             = ' :role_rw
\echo '## user_sa             = ' :user_sa

-- --------------------------------------------------------------------------------
-- Passwords (nur local — hardcodierte Dev-Werte; auf Hetzner via -v)
-- --------------------------------------------------------------------------------
\set database_owner_password  pw
\set schema_owner_password    pw
\set user_sa_password         pw

\echo ''
