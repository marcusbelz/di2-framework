-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts a row in table [LOG].[Trace] with the [State] = 'error' 
--              and [Success] = '0'.
--
--              This procedure calls [LOG].[spInsertTrace] and encapsulates the 
--              following parameters:
--
--                @p_action        = NULL
--                @p_affectedRows  = 0
--                @p_source        = 'SSIS'
--                @p_step          = 'end'
--                @p_state         = 'error'
--                @p_success       = 0
--
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       User::executionId
--    @p_componentId          AS int
--       User::componentId
--    @p_traceId              AS int OUT
--       User::traceId
--    @p_component            AS nvarchar(128)
--       System::PackageName
--    @p_task                 AS nvarchar(128) = NULL
--       System::TaskName
--    @p_entity               AS nvarchar(128) = NULL
--       User::traceEntity
--    @p_description          AS nvarchar(max) = NULL
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
CREATE PROCEDURE [LOG].[spInsertTraceError]
    @p_executionId           AS int           -- @p_executionId    int           > User::executionId
   ,@p_componentId           AS int           -- @p_componentId    int           > User::componentId
   ,@p_traceId               AS int OUT       -- @p_traceId        int           > User::traceId
   ,@p_component             AS nvarchar(128) -- @p_component      nvarchar(128) > System::PackageName
   ,@p_task                  AS nvarchar(128) -- @p_task           nvarchar(128) > System::TaskName
   ,@p_entity                AS nvarchar(128) -- @p_entity         nvarchar(128) > User::traceEntity
   ,@p_description           AS nvarchar(max) -- @p_description    nvarchar(max) > User::traceDescription
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spInsertTrace]
       @p_executionId    -- @p_executionId    int           > User::executionId
      ,@p_componentId    -- @p_componentId    int           > User::componentId
      ,@p_traceId OUT    -- @p_traceId        int           > User::traceId
      ,'SSIS'            -- @p_source         nvarchar(5)
      ,@p_component      -- @p_component      nvarchar(128) > System::PackageName
      ,@p_task           -- @p_task           nvarchar(128) > System::TaskName
      ,@p_entity         -- @p_entity         nvarchar(128) > User::traceEntity
      ,'end'             -- @p_step           nvarchar(max)
      ,@p_description    -- @p_description    nvarchar(max) > User::traceDescription
      ,NULL              -- @p_action         nvarchar(100)
      ,0                 -- @p_affectedRows   int
      ,'error'           -- @p_state          nvarchar(100) 
      ,0;                -- @p_success        bit
END;
-- [LOG].[spInsertTraceError]

-- EXEC [LOG].[spInsertTraceError] 1, 22, 54, 'T1_001_PackageName', 'SQL 0100 Do Somethingh', 'Contacts', 'Insert new Contacts'
