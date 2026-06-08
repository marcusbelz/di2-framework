-- 99 — Datenbank, Rollen und Logins entfernen (gegen Maintenance-DB ausführen).

-- 1. Aktive Verbindungen trennen
\echo '1. Terminate active connections'
SELECT pg_terminate_backend(pid)
FROM   pg_stat_activity
WHERE  datname = :'database_name'
  AND  pid <> pg_backend_pid();

-- 2. Datenbank löschen
\echo '2. Drop database'
DROP DATABASE IF EXISTS :database_name;

-- 3. Service-Account
\echo '3. Drop service account'
DROP ROLE IF EXISTS :user_sa;

-- 4. RW-Gruppenrolle
\echo '4. Drop rw role'
DROP ROLE IF EXISTS :role_rw;

-- 5. Framework-Schema-Owner
\echo '5. Drop schema owner'
DROP ROLE IF EXISTS :schema_owner;

-- 6. Datenbank-Owner
\echo '6. Drop database owner'
DROP ROLE IF EXISTS :database_owner;
