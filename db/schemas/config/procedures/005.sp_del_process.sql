\echo "## CREATE PROCEDURE :schema_config.sp_del_process"

DROP PROCEDURE IF EXISTS :schema_config.sp_del_process(bigint);

CREATE OR REPLACE PROCEDURE :schema_config.sp_del_process
(
    IN    p_id          bigint
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   l_component               varchar;
   l_ref_count               bigint;
   l_error_message           text;
   l_error_code              text;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   -- schlank: kein lc_messages/PG_CONTEXT (keine Komponenten-Protokollierung; BUG-0337)
   l_component := 'config.sp_del_process';

   RAISE NOTICE '### procedure : %', l_component;

   -- --------------------------------------------------------------------------------
   -- Check parameter
   -- --------------------------------------------------------------------------------
   BEGIN
      IF p_id IS NULL THEN
         l_error_message := format($$%1$s: p_id darf nicht NULL sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
      END IF;
   END;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM config.process WHERE id = p_id) THEN
         l_error_message := format($$%1$s: Prozess mit id=%2$s existiert nicht$$, l_component, p_id);
         l_error_code    := 'no_data_found';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
      END IF;

      SELECT count(*)
      INTO   l_ref_count
      FROM   log.execution
      WHERE  process_id = p_id;

      IF l_ref_count > 0 THEN
         l_error_message := format($$%1$s: Prozess id=%2$s wird von %3$s Execution(s) referenziert und kann nicht geloescht werden$$, l_component, p_id, l_ref_count);
         l_error_code    := 'foreign_key_violation';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
      END IF;

      -- DELETE separat gekapselt: faengt nur eine zwischen Zaehlung und DELETE neu
      -- hinzugekommene Referenz ab (Race). Ohne diese Kapselung wuerde der
      -- FK-Handler die obige zaehlbasierte Meldung ueberschreiben.
      BEGIN
         DELETE FROM config.process
         WHERE  id = p_id;
      EXCEPTION WHEN foreign_key_violation THEN
         l_error_message := format($$%1$s: Prozess id=%2$s wird referenziert und kann nicht geloescht werden$$, l_component, p_id);
         l_error_code    := 'foreign_key_violation';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
      END;
   END;

END;
$procedure$;

ALTER PROCEDURE :schema_config.sp_del_process(bigint) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_config.sp_del_process - DONE"
