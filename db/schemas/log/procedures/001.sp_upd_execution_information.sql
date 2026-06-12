\echo "## CREATE PROCEDURE :schema_log.sp_upd_execution_information"

DROP PROCEDURE IF EXISTS :schema_log.sp_upd_execution_information(bigint, boolean);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_id          bigint
--       Identifier des zu aktualisierenden Execution-Datensatzes
--    p_success     boolean
--       Erfolgs-Flag; bei state='information' sind true und false zulässig
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE :schema_log.sp_upd_execution_information
(
    IN    p_id          bigint
   ,IN    p_success     boolean
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
   l_component := 'log.sp_upd_execution_information';

   RAISE NOTICE '### procedure : %', l_component;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      -- legt state='information' fest; success bleibt frei (true|false), Validierung
      -- delegiert an sp_upd_execution.
      CALL log.sp_upd_execution(p_id, 'information', p_success);
   END;

END;
$procedure$;

ALTER PROCEDURE :schema_log.sp_upd_execution_information(bigint, boolean) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_log.sp_upd_execution_information - DONE"
