\echo "## CREATE FUNCTION :schema_log.tf_set_modified()"

-- Generische BEFORE-UPDATE-Trigger-Funktion: setzt die Audit-Spalten bei jeder
-- Änderung. Wird von allen log-Tabellen mit modified_on/modified_by genutzt
-- (execution, component, trace, process). Kein DROP FUNCTION (Trigger-safe).
CREATE OR REPLACE FUNCTION :schema_log.tf_set_modified()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $triggerfunction$
BEGIN

   NEW.modified_on := now();
   NEW.modified_by := current_user;

   RETURN NEW;

END;
$triggerfunction$;

ALTER FUNCTION :schema_log.tf_set_modified() OWNER TO :schema_owner;

\echo "## CREATE FUNCTION :schema_log.tf_set_modified() - DONE"
