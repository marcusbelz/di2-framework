\echo "## CREATE PROCEDURE :schema_config.sp_ins_process"

DROP PROCEDURE IF EXISTS :schema_config.sp_ins_process(varchar, bigint);

CREATE OR REPLACE PROCEDURE :schema_config.sp_ins_process
(
    IN    p_name        varchar
   ,INOUT p_id          bigint
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   l_component               varchar;
   l_name                    varchar;
   l_error_message           text;
   l_error_code              text;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   -- schlank: kein lc_messages/PG_CONTEXT (keine Komponenten-Protokollierung; BUG-0337)
   l_component := 'config.sp_ins_process';

   RAISE NOTICE '### procedure : %', l_component;

   -- --------------------------------------------------------------------------------
   -- Check parameter
   -- --------------------------------------------------------------------------------
   BEGIN
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
      l_name := trim(p_name);

      INSERT INTO config.process (name)
      VALUES (l_name)
      RETURNING id INTO p_id;

   EXCEPTION WHEN unique_violation THEN
      l_error_message := format($$%1$s: Prozess mit Name '%2$s' existiert bereits$$, l_component, l_name);
      l_error_code    := 'unique_violation';

      RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
   END;

END;
$procedure$;

ALTER PROCEDURE :schema_config.sp_ins_process(varchar, bigint) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_config.sp_ins_process - DONE"
