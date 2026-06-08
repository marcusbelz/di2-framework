-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts a row in table [LOG].[Component] with
--    [state]   = 'processing'
--    [success] = 0
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       Execution ID of the current execution.
--    @p_componentId          AS int OUT
--       Returns the ID of the new row in [LOG].[Component].
--    @p_source               AS nvarchar(5)
--       Type of the calling source system (SSIS, T-SQL, ...).
--    @p_component            AS nvarchar(128)
--       Name of the calling SSIS-Package.
--    @p_versionBuild         AS int = NULL
--       VersionBuild number of the calling SSIS package. 
--       This parameter applies only to SSIS.
--    @p_entity               AS nvarchar(128) = NULL
--       Entity name the log entry refers to.
--    @p_step                 AS nvarchar(max)
--       Description of the task in the calling object that will be logged.
--    @p_description          AS nvarchar(max) = NULL 
--       Additional description of the task in the calling object that will be logged.
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
CREATE PROCEDURE [LOG].[spInsertComponent] 
    @p_executionId           AS int
   ,@p_componentId           AS int OUT
   ,@p_source                AS nvarchar(5)
   ,@p_component             AS nvarchar(128)
   ,@p_versionBuild          AS int           = NULL
   ,@p_entity                AS nvarchar(128) = NULL
   ,@p_step                  AS nvarchar(max)
   ,@p_description           AS nvarchar(max) = NULL
AS
BEGIN
   SET NOCOUNT ON;   

   DECLARE @component        AS nvarchar(128);
   DECLARE @table            AS table([ID] int);

   SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

   -- --------------------------------------------------------------------------------
   -- Check parameters
   -- --------------------------------------------------------------------------------
   IF (@p_executionId IS NULL)
      BEGIN
         EXEC [dbo].[spRaiseError] 'The parameter ''p_executionId'' is NULL.', @component;
         RETURN 0;
      END;
   IF ([dbo].[fnIsNullOrEmpty](@p_source, 1) <> 0 )
      BEGIN
         EXEC [dbo].[spRaiseError]  'The parameter ''p_source'' is either NULL or an empty string.', @component;
         RETURN 1;
      END;
   IF ([dbo].[fnIsNullOrEmpty](@p_component, 1) <> 0 )
      BEGIN
         EXEC [dbo].[spRaiseError]  'The parameter ''p_component'' is either NULL or an empty string.', @component;
         RETURN 1;
      END;
   IF ([dbo].[fnIsNullOrEmpty](@p_step, 1) <> 0)
      BEGIN
         EXEC [dbo].[spRaiseError]  'The parameter ''p_step'' is either NULL or an empty string.', @component;
         RETURN 1;
      END;

   -- --------------------------------------------------------------------------------
   -- Insert Component into [LOG].[Component]
   -- --------------------------------------------------------------------------------
   INSERT INTO [LOG].[Component]
   (
       [ExecutionID] 
      ,[Source] 
      ,[Component] 
      ,[VersionBuild] 
      ,[Entity] 
      ,[Step] 
      ,[Description] 
      ,[State] 
      ,[Success] 
   )
   OUTPUT Inserted.ID INTO @table
   VALUES
   (
       @p_executionId
      ,@p_source
      ,@p_component
      ,@p_versionBuild
      ,@p_entity
      ,@p_step
      ,@p_description
      ,'processing'
      ,0
   );

   SELECT @p_componentId = [ID] FROM @table;

   RETURN 0;
END
-- [LOG].[spInsertComponent] 

-- DECLARE @executionId  AS int;
-- DECLARE @componentId  AS int;
-- DECLARE @source       AS nvarchar(5);
-- DECLARE @component    AS nvarchar(128);
-- DECLARE @versionBuild AS int;
-- DECLARE @entity       AS nvarchar(128);
-- DECLARE @step         AS nvarchar(max);
-- DECLARE @description  AS nvarchar(max);

-- SET @executionId  = 1;
-- SET @source       = 'T-SQL';
-- SET @component    = 'test script';
-- SET @versionBuild = 123;
-- SET @entity       = '[LOG].[spInsertComponent]';
-- SET @step         = '[LOG].[spInsertComponent]';
-- SET @description  = 'none';

-- EXEC [LOG].[spInsertComponent] 
--     @p_executionId  = @executionId
--    ,@p_componentId  = @componentId OUTPUT
--    ,@p_source       = @source
--    ,@p_component    = @component  
--    ,@p_versionBuild = @versionBuild 
--    ,@p_entity       = @entity     
--    ,@p_step         = @step       
--    ,@p_description  = @description;

-- SELECT @componentId;
-- SELECT * FROM [LOG].[Component] WHERE [ID] = @componentId;
