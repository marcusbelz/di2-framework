-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates [LOG].[Trace] with [State] = 'warning' and [Success] = '1' 
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_traceId              AS int
--       User::traceId
--    @p_description     AS nvarchar(max)
--       User::traceDescription
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
CREATE PROCEDURE [LOG].[spUpdateTraceWarning]
    @p_traceId               AS int           -- @p_traceId     int           > User::traceId
   ,@p_description           AS nvarchar(max) -- @p_description nvarchar(max) > User::traceDescription
   ,@p_action                AS nvarchar(100) = NULL -- @p_action nvarchar(100)      > User::traceAction
   ,@p_affectedRows          AS int                  -- @p_affectedRows int          > User::traceAffectedRows
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateTrace]
       @p_traceId            -- @p_traceId        int                  > User::traceId
      ,@p_description        -- @p_description    nvarchar(max)        > User::traceDescription
      ,@p_action             -- @p_action         nvarchar(100) = NULL > User::traceAction
      ,@p_affectedRows       -- @p_affectedRows   int                  > User::traceAffectedRows
      ,'warning'             -- @p_state          nvarchar(max) 
      ,1;                    -- @p_Success        bit
END;
-- [LOG].[spUpdateTraceWarning]

-- EXEC [LOG].[spUpdateTraceWarning] 1, 'description', 'action', 1;
