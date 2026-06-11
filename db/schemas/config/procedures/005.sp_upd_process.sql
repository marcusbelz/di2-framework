\echo "## CREATE PROCEDURE :schema_config.sp_upd_process"

DROP PROCEDURE IF EXISTS :schema_config.sp_upd_process(bigint, varchar);

CREATE OR REPLACE PROCEDURE :schema_config.sp_upd_process
(
    IN    p_id          bigint
   ,IN    p_name        varchar
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   l_component               varchar;
   l_name                    varchar;
   l_current_name            varchar;
   l_error_message           text;
   l_error_code              text;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   -- schlank: kein lc_messages/PG_CONTEXT (keine Komponenten-Protokollierung; BUG-0337)
   l_component := 'config.sp_upd_process';

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

      IF p_name IS NULL OR length(trim(p_name)) = 0 THEN
         l_error_message := format($$%1$s: Prozessname darf nicht leer sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
      END IF;
   END;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      SELECT name
      INTO   l_current_name
      FROM   config.process
      WHERE  id = p_id;

      IF NOT FOUND THEN
         l_error_message := format($$%1$s: Prozess mit id=%2$s existiert nicht$$, l_component, p_id);
         l_error_code    := 'no_data_found';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
      END IF;

      l_name := trim(p_name);

      IF l_name = l_current_name THEN
         RETURN;   -- identischer Name -> No-op, kein Fehler
      END IF;

      UPDATE config.process
      SET    name = l_name
      WHERE  id = p_id;

   EXCEPTION WHEN unique_violation THEN
      l_error_message := format($$%1$s: Name '%2$s' wird bereits von einem anderen Prozess verwendet$$, l_component, l_name);
      l_error_code    := 'unique_violation';

      RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
   END;

END;
$procedure$;

ALTER PROCEDURE :schema_config.sp_upd_process(bigint, varchar) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_config.sp_upd_process - DONE"
