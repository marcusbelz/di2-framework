\echo "## CREATE PROCEDURE :schema_log.sp_ins_execution"

DROP PROCEDURE IF EXISTS :schema_log.sp_ins_execution(bigint, bigint, varchar, varchar);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_id            bigint
--       execution-id assigned to the newly inserted execution (INOUT, returned to caller)
--    p_process_id    bigint
--       FK -> config.process: auszuführender Prozess (Pflicht; muss existieren)
--    p_machine       varchar
--       Host/Maschine, auf der die Ausführung läuft
--    p_instance      varchar
--       Instanz-/Umgebungskennung (optional; historisch aus SSIS)
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE :schema_log.sp_ins_execution
(
    INOUT p_id            bigint
   ,IN    p_process_id    bigint
   ,IN    p_machine       varchar
   ,IN    p_instance      varchar
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
   l_start                   timestamptz;
   l_delta_start             timestamptz;
   l_version                 varchar;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   -- schlank: kein lc_messages/PG_CONTEXT (keine Komponenten-Protokollierung; BUG-0337)
   l_component := 'log.sp_ins_execution';

   RAISE NOTICE '### procedure : %', l_component;

   -- --------------------------------------------------------------------------------
   -- Check parameter
   -- --------------------------------------------------------------------------------
   BEGIN
      IF p_process_id IS NULL THEN

         l_error_message := format($$%1$s: p_process_id darf nicht NULL sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      IF NOT EXISTS (SELECT 1 FROM config.process WHERE id = p_process_id) THEN

         l_error_message := format($$%1$s: Prozess mit id=%2$s existiert nicht in config.process$$, l_component, p_process_id);
         l_error_code    := 'foreign_key_violation';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;
   END;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      -- start_on = delta_end des neuen Laufs (ein now() für beide Werte).
      l_start := now();

      -- Delta-Wasserzeichen: delta_end des aktuellsten erfolgreichen Laufs desselben
      -- Prozesses (state success/warning UND success = true) ergibt ein lückenloses
      -- Delta-Fenster; ein fehlgeschlagener Lauf rückt das Wasserzeichen nicht vor.
      -- Kein Vorlauf gefunden -> NULL (Erstlauf / Vollladung).
      SELECT
         delta_end
      INTO
         l_delta_start
      FROM
         log.execution
      WHERE
             process_id = p_process_id
         AND success    = true
         AND state      IN ('success', 'warning')
      ORDER BY
          start_on DESC
         ,id       DESC
      LIMIT 1;

      -- aktuelle Framework-Version aus der Deploy-Historie (major.minor.build).
      SELECT
         release_version
      INTO
         l_version
      FROM
         config.db_version
      ORDER BY
          deployed_on DESC
         ,id          DESC
      LIMIT 1;

      INSERT INTO log.execution
      (
          process_id
         ,start_on
         ,end_on
         ,delta_start
         ,delta_end
         ,user_name
         ,machine
         ,instance
         ,version
         ,state
         ,success
      )
      VALUES
      (
          p_process_id
         ,l_start
         ,NULL
         ,l_delta_start
         ,l_start
         ,current_user
         ,p_machine
         ,p_instance
         ,l_version
         ,'processing'
         ,false
      )
      RETURNING id INTO p_id;

   END;

END;
$procedure$;

ALTER PROCEDURE :schema_log.sp_ins_execution(bigint, bigint, varchar, varchar) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_log.sp_ins_execution - DONE"
