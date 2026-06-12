\echo "## CREATE PROCEDURE :schema_log.sp_upd_execution_success"

DROP PROCEDURE IF EXISTS :schema_log.sp_upd_execution_success(bigint);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_id          bigint
--       Identifier des zu aktualisierenden Execution-Datensatzes
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE :schema_log.sp_upd_execution_success
(
    IN    p_id          bigint
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   -- --------------------------------------------------------------------------------
   -- Common
   -- --------------------------------------------------------------------------------
   l_component               varchar;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   -- schlank: kein lc_messages/PG_CONTEXT (keine Komponenten-Protokollierung; BUG-0337)
   l_component := 'log.sp_upd_execution_success';

   RAISE NOTICE '### procedure : %', l_component;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      -- legt state='success'/success=true fest; Validierung delegiert an sp_upd_execution.
      CALL log.sp_upd_execution(p_id, 'success', true);
   END;

END;
$procedure$;

ALTER PROCEDURE :schema_log.sp_upd_execution_success(bigint) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_log.sp_upd_execution_success - DONE"
