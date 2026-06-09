-- --------------------------------------------------------------------------------
-- clean.schema.sql — droppt alle Objekte eines Schemas (Schema selbst bleibt).
-- --------------------------------------------------------------------------------
-- Aufruf über db/scripts/clean.sh; erwartet die psql-Variable :schema_target
-- (der konkrete Schemaname, z. B. 'log'). Reihenfolge ist abhängigkeitssicher:
-- erst Views/Matviews, dann Tabellen (CASCADE löst FK/Trigger), dann Routinen,
-- zuletzt Sequenzen. Alle DROPs sind IF EXISTS -> idempotent.
-- --------------------------------------------------------------------------------

\echo '## CLEAN schema objects in ' :schema_target

-- Views
SELECT 'DROP VIEW IF EXISTS ' || quote_ident(:'schema_target') || '.' || quote_ident(viewname) || ' CASCADE;'
FROM   pg_views
WHERE  schemaname = :'schema_target';
\gexec

-- Materialized Views
SELECT 'DROP MATERIALIZED VIEW IF EXISTS ' || quote_ident(:'schema_target') || '.' || quote_ident(matviewname) || ' CASCADE;'
FROM   pg_matviews
WHERE  schemaname = :'schema_target';
\gexec

-- Tabellen (CASCADE entfernt zugehörige Trigger, FKs, Default-Constraints)
SELECT 'DROP TABLE IF EXISTS ' || quote_ident(:'schema_target') || '.' || quote_ident(tablename) || ' CASCADE;'
FROM   pg_tables
WHERE  schemaname = :'schema_target';
\gexec

-- Funktionen (inkl. Trigger-Funktionen)
SELECT 'DROP FUNCTION IF EXISTS ' || quote_ident(:'schema_target') || '.' || quote_ident(T01.proname) || '(' || pg_get_function_identity_arguments(T01.oid) || ') CASCADE;'
FROM   pg_proc T01
       INNER JOIN pg_namespace T02
       ON
         T02.oid = T01.pronamespace
WHERE      T02.nspname = :'schema_target'
   AND     T01.prokind = 'f';
\gexec

-- Prozeduren
SELECT 'DROP PROCEDURE IF EXISTS ' || quote_ident(:'schema_target') || '.' || quote_ident(T01.proname) || '(' || pg_get_function_identity_arguments(T01.oid) || ') CASCADE;'
FROM   pg_proc T01
       INNER JOIN pg_namespace T02
       ON
         T02.oid = T01.pronamespace
WHERE      T02.nspname = :'schema_target'
   AND     T01.prokind = 'p';
\gexec

-- Sequenzen (verbliebene, nicht via Tabelle entfernte)
SELECT 'DROP SEQUENCE IF EXISTS ' || quote_ident(:'schema_target') || '.' || quote_ident(sequence_name) || ' CASCADE;'
FROM   information_schema.sequences
WHERE  sequence_schema = :'schema_target';
\gexec

\echo '## CLEAN schema objects in ' :schema_target ' - DONE'
