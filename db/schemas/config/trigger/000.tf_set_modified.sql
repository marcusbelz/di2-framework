\echo "## CREATE FUNCTION :schema_config.tf_set_modified()"

-- Generische BEFORE-UPDATE-Trigger-Funktion: setzt die Audit-Spalten bei jeder
-- Änderung. Wird von config-Tabellen mit modified_on/modified_by genutzt (process).
-- Eigene Kopie in config (nicht log.tf_set_modified() wiederverwenden): config wird
-- vor log deployt, log.tf_set_modified() existiert zu dem Zeitpunkt noch nicht.
-- Kein DROP FUNCTION (Trigger-safe).
CREATE OR REPLACE FUNCTION :schema_config.tf_set_modified()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $triggerfunction$
BEGIN

   NEW.modified_on := now();
   NEW.modified_by := current_user;

   RETURN NEW;

END;
$triggerfunction$;

ALTER FUNCTION :schema_config.tf_set_modified() OWNER TO :schema_owner;

\echo "## CREATE FUNCTION :schema_config.tf_set_modified() - DONE"
