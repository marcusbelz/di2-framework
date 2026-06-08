-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts a row in table [LOG].[Error]. 
--
--              This procedure calls [LOG].[spInsertError] and encapsulates the 
--              following parameters:
--
--                @p_errorType     = 'E'
--                @p_errorLine     = NULL
--                @p_errorState    = NULL
--                @p_errorValue    = NULL
--                @p_errorField    = NULL
--                @p_errorFileName = NULL
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       Execution ID of the current execution
--    @p_componentId          AS int
--       Component ID the error message is related to.
--    @p_traceId              AS int
--       Trace ID the error message is related to.
--    @p_source               AS nvarchar(5)  
--       Specifies the source that is responsible for the error log entry
--        'SSIS'
--        'T-SQL' 
--    @p_component            AS nvarchar(128)
--       System::PackageName (SSIS specific)
--    @p_task                 AS nvarchar(128)
--       Task Name (SSIS specific)
--    @p_errorNumber          AS int
--       Error Code
--    @p_errorDescription     AS nvarchar(max)
--       Error Description
--    @p_entity               AS nvarchar(128)
--       Name of the table that is involved in this procedure call.
--    @p_step                 AS nvarchar(128)
--       Describe the step, that invokes this procedure call.
--    @p_schema               AS nvarchar(128) = NULL
--       Specifies the schema name of the table that contains the error.
--    @p_table                AS nvarchar(128) = NULL
--       Specifies the table name of the table that contains the error.
--    @p_ID1Field             AS nvarchar(128) = NULL
--       Primary key 1 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID1Value             AS nvarchar(max) = NULL
--       Primary key 1 value of the record the error is related to. 
--    @p_ID2Field             AS nvarchar(128) = NULL
--       Primary key 2 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID2Value             AS nvarchar(max) = NULL
--       Primary key 2 value of the record the error is related to. 
--    @p_ID3Field             AS nvarchar(128) = NULL
--       Primary key 3 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID3Value             AS nvarchar(max) = NULL
--       Primary key 3 value of the record the error is related to. 
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
CREATE PROCEDURE [LOG].[spInsertError3]
    @p_executionId           AS int
   ,@p_componentId           AS int
   ,@p_traceId               AS int
   ,@p_source                AS nvarchar(5)  
   ,@p_component             AS nvarchar(128)
   ,@p_task                  AS nvarchar(128)
   ,@p_errorNumber           AS int
   ,@p_errorDescription      AS nvarchar(max)
   ,@p_entity                AS nvarchar(128)
   ,@p_step                  AS nvarchar(128)
   ,@p_schema                AS nvarchar(128) = NULL
   ,@p_table                 AS nvarchar(128) = NULL
   ,@p_ID1Field              AS nvarchar(128) = NULL
   ,@p_ID1Value              AS nvarchar(max) = NULL
   ,@p_ID2Field              AS nvarchar(128) = NULL
   ,@p_ID2Value              AS nvarchar(max) = NULL
   ,@p_ID3Field              AS nvarchar(128) = NULL
   ,@p_ID3Value              AS nvarchar(max) = NULL

AS
BEGIN
   SET NOCOUNT ON;   

   EXECUTE [LOG].[spInsertError3]
       @p_executionId        -- @p_executionId      int           > User::executionId
      ,@p_componentId        -- @p_componentId      int           > User::componentId
      ,@p_traceId            -- @p_traceId          int           > User::traceId
      ,'E'                   -- @p_errorType        char(1)
      ,@p_source             -- @p_source           nvarchar(5)

      ,@p_component          -- @p_component        nvarchar(128) > System::PackageName
      ,@p_task               -- @p_task             nvarchar(128) > System::TaskName
      ,@p_entity             -- @p_entity           nvarchar(128) > User::traceEntity
      ,@p_step               -- @p_step             nvarchar(max) > User::traceStep
      
      ,@p_schema             -- @p_schema           nvarchar(128)
      ,@p_table              -- @p_table            nvarchar(128)
      
      ,@p_ID1Field           -- @p_ID1Field         nvarchar(128)  
      ,@p_ID1Value           -- @p_ID1Value         nvarchar(max)  
      ,@p_ID2Field           -- @p_ID2Field         nvarchar(128)
      ,@p_ID2Value           -- @p_ID2Value         nvarchar(max)
      ,@p_ID3Field           -- @p_ID3Field         nvarchar(128)
      ,@p_ID3Value           -- @p_ID3Value         nvarchar(max)
      
      ,NULL                  -- @p_errorValue       nvarchar(max)
      ,NULL                  -- @p_errorField       nvarchar(128)
      ,NULL                  -- @p_errorFileName    nvarchar(128)
      ,@p_errorDescription   -- @p_errorDescription nvarchar(max)  > System::ErrorDescription
      ,@p_errorNumber        -- @p_errorNumber      int            > System::ErrorCode
      ,NULL                  -- @p_errorLine        int
      ,NULL;                 -- @p_errorState       nvarchar(max)      
END;
-- [LOG].[spInsertError3]
