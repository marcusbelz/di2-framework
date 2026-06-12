\echo "## CREATE PROCEDURE :schema_log.sp_upd_execution"

DROP PROCEDURE IF EXISTS :schema_log.sp_upd_execution(bigint, varchar, boolean);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_id          bigint
--       Identifier des zu aktualisierenden Execution-Datensatzes
--    p_state       varchar
--       neuer Status (processing/error/warning/information/success)
--    p_success     boolean
--       Erfolgs-Flag; muss zur Kombinatorik des state passen
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE :schema_log.sp_upd_execution
(
    IN    p_id          bigint
   ,IN    p_state       varchar
   ,IN    p_success     boolean
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   -- --------------------------------------------------------------------------------
   -- Common
   -- --------------------------------------------------------------------------------
   l_component               varchar;

   -- --------------------------------------------------------------------------------
   -- Error Handling
   -- --------------------------------------------------------------------------------
   l_error_message           text;
   l_error_code              text;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   l_state                   varchar;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   -- schlank: kein lc_messages/PG_CONTEXT (keine Komponenten-Protokollierung; BUG-0337)
   l_component := 'log.sp_upd_execution';

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

      IF p_state IS NULL OR length(trim(p_state)) = 0 THEN

         l_error_message := format($$%1$s: p_state darf nicht leer sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      IF p_success IS NULL THEN

         l_error_message := format($$%1$s: p_success darf nicht NULL sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      l_state := lower(trim(p_state));

      IF l_state NOT IN ('processing', 'error', 'warning', 'information', 'success') THEN

         l_error_message := format($$%1$s: ungültiger state '%2$s' (erlaubt: processing, error, warning, information, success)$$, l_component, l_state);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      -- Kombinatorik state/success: success=true nur bei success/warning/information,
      -- success=false nicht bei state='success'. (processing/error => immer false.)
      IF (p_success = true  AND l_state IN ('processing', 'error'))
      OR (p_success = false AND l_state = 'success') THEN

         l_error_message := format($$%1$s: ungültige Kombination state='%2$s' / success=%3$s$$, l_component, l_state, p_success);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;
   END;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      -- ändert ausschließlich state/success/end_on; process_id, start_on, delta_*,
      -- user_name, machine, instance, version bleiben unangetastet.
      -- modified_on/modified_by setzt der Trigger tr_u_execution (tf_set_modified).
      UPDATE log.execution
         SET
             state   = l_state
            ,success = p_success
            ,end_on  = now()
      WHERE
         id = p_id;

      IF NOT FOUND THEN

         l_error_message := format($$%1$s: Execution mit id=%2$s existiert nicht$$, l_component, p_id);
         l_error_code    := 'no_data_found';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;
   END;

END;
$procedure$;

ALTER PROCEDURE :schema_log.sp_upd_execution(bigint, varchar, boolean) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_log.sp_upd_execution - DONE"
