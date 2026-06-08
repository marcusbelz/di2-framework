-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates [LOG].[Trace] with [State] = 'error' and [Success] = '0'. 
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_traceId              AS int
--       User::traceId
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
CREATE PROCEDURE [LOG].[spUpdateTraceError1]
   @p_traceId            AS int                     -- @p_traceId        int           > User::traceId
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateTrace]
       @p_traceId            -- @p_traceId        int           > User::traceId
      ,NULL                  -- @p_description    nvarchar(max)
      ,NULL                  -- @p_action         nvarchar(100)
      ,0                     -- @p_affectedRows   int 
      ,'error'               -- @p_state          nvarchar(max) 
      ,0;                    -- @p_success        bit
END;
-- [LOG].[spUpdateTraceError1]

-- EXEC [LOG].[spUpdateTraceError1] 1;
