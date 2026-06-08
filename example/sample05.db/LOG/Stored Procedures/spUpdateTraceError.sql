-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates [LOG].[Trace] with [State] = 'error' and [Success] = '0'. 
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_traceId              AS int
--       User::traceId
--    @p_description     AS nvarchar(max)
--       User::traceDescription
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
CREATE PROCEDURE [LOG].[spUpdateTraceError]
    @p_traceId               AS int           -- @p_traceId     int           > User::traceId
   ,@p_description           AS nvarchar(max) -- @p_description int           > User::traceDescription
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateTrace]
       @p_traceId            -- @p_traceId        int           > User::traceId
      ,@p_description        -- @p_description    nvarchar(max) > User::traceDescription
      ,NULL                  -- @p_action         nvarchar(100)
      ,0                     -- @p_affectedRows   int 
      ,'error'               -- @p_state          nvarchar(max) 
      ,0;                    -- @p_success        bit
END;
-- [LOG].[spUpdateTraceError]

-- EXEC [LOG].[spUpdateTraceError] 1, 'description';
