-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts a row in table [LOG].[Trace] with the [State] = 'success' 
--              and [Success] = '1'.
--
--              This procedure calls [LOG].[spInsertTrace] and encapsulates the 
--              following parameters:
--
--                @p_source        = 'SSIS'
--                @p_step          = 'end'
--                @p_state         = 'success'
--                @p_success       = 1
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
--    @p_action               AS nvarchar(max) = NULL
--       Specifiy any action that will be logged by this procedure call like Insert, Delete, Update, ...
--    @p_affectedRows         AS nvarchar(max) = NULL
--       Specifiy the number of rows/objects that were inserted, deleted, updated, ...
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
CREATE PROCEDURE [LOG].[spInsertTraceSuccess]
    @p_executionId           AS int                  -- @p_executionId    int           > User::executionId
   ,@p_componentId           AS int                  -- @p_componentId    int           > User::componentId
   ,@p_traceId               AS int OUT              -- @p_traceId        int           > User::traceId
   ,@p_component             AS nvarchar(128)        -- @p_component      nvarchar(128) > System::PackageName
   ,@p_task                  AS nvarchar(128)        -- @p_task           nvarchar(128) > System::TaskName
   ,@p_entity                AS nvarchar(128)        -- @p_entity         nvarchar(128) > User::traceEntity
   ,@p_description           AS nvarchar(max)        -- @p_description    nvarchar(max) > User::traceDescription
   ,@p_action                AS nvarchar(100) = NULL -- @p_description    nvarchar(max) > User::traceAction
   ,@p_affectedRows          AS int                  -- @p_description    nvarchar(max) > User::traceAffectedRows
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
      ,@p_action         -- @p_action         nvarchar(100) > User::traceAction
      ,@p_affectedRows   -- @p_affectedRows   int           > User::traceAffectedRows
      ,'success'         -- @p_state          nvarchar(100) 
      ,1;                -- @p_success        bit
END;
-- [LOG].[spInsertTraceSuccess]

-- EXEC [LOG].[spInsertTraceError] 1, 22, 54, 'T1_001_PackageName', 'SQL 0100 Do Somethingh', 'Contacts', 'Insert new Contacts', 'Insert', 55;
