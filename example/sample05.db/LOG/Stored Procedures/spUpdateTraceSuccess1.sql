-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates the fields [State] and [Success] in [LOG].[Trace] for 
--              the row with [ID] = @p_traceId.
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_traceId              AS int
--       User::traceId
--    @p_action               AS nvarchar(max) = NULL
--       User::traceAction
--    @p_affectedRows         AS nvarchar(max) = NULL
--       User::traceAffectedRows
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 : error
--    = 0 : success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [LOG].[spUpdateTraceSuccess1] 
    @p_traceId               AS int                  -- @p_traceId     int           > User::traceId
   ,@p_action                AS nvarchar(100) = NULL -- @p_action int                > User::traceAction
   ,@p_affectedRows          AS int                  -- @p_affectedRows int          > User::traceAffectedRows
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateTrace]
       @p_traceId            -- @p_traceId        int                  > User::traceId
      ,NULL                  -- @p_description    nvarchar(max)        > User::traceDescription
      ,@p_action             -- @p_action         nvarchar(100) = NULL > User::traceAction
      ,@p_affectedRows       -- @p_affectedRows   int                  > User::traceAffectedRows
      ,'success'             -- @p_state          nvarchar(max) 
      ,1;                    -- @p_success        bit
END
-- [LOG].[spUpdateTraceSuccess1] 

-- EXEC [LOG].[spUpdateTraceSuccess] 1, 'Insert', 11;