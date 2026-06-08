-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts a row in table [LOG].[Trace]
-- --------------------------------------------------------------------------------
-- Parameters
--    @p_executionId          AS int
--       Execution ID of the current execution
--    @p_componentId          AS int
--       Each procedure call gets a unique id that allows identifying all messages 
--       that will be written by the procedure call
--    @p_traceId              AS int OUT
--       Returns the ID of the new row in [LOG].[Trace]
--    @p_source               AS nvarchar(5)
--       Type of the calling source system (SSIS, T-SQL, ...)
--    @p_component            AS nvarchar(128)
--       Name of the calling SSIS-Package
--    @p_task                 AS nvarchar(128) = NULL
--       SSIS-Task name the log entry refers to.
--    @p_entity               AS nvarchar(128) = NULL
--       Entity name the log entry refers to.
--    @p_step                 AS nvarchar(max)
--       Description of the task in the calling object that will be logged
--    @p_description          AS nvarchar(max) = NULL
--       Additional description of the task in the calling object that will be logged
--    @p_action               AS nvarchar(max) = NULL
--       Specifiy any action that will be logged by this procedure call like Insert, Delete, Update, ...
--    @p_affectedRows         AS nvarchar(max) = NULL
--       Specifiy the number of rows/objects that were inserted, deleted, updated, ...
--    @p_state                AS nvarchar(100)
--       State of the current task (processing, success, error, warning)
--    @p_success              AS bit
--       Specifies whether the calling procedure succeded
--       0 = processing, warning, error
--       1 = success
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
CREATE PROCEDURE [LOG].[spInsertTrace] 
    @p_executionId           AS int
   ,@p_componentId           AS int
   ,@p_traceId               AS int OUT
   ,@p_source                AS nvarchar(5)
   ,@p_component             AS nvarchar(128)
   ,@p_task                  AS nvarchar(128) = NULL
   ,@p_entity                AS nvarchar(128) = NULL
   ,@p_step                  AS nvarchar(max)
   ,@p_description           AS nvarchar(max) = NULL
   ,@p_action                AS nvarchar(100) = NULL
   ,@p_affectedRows          AS int 
   ,@p_state                 AS nvarchar(100)
   ,@p_success               AS bit
AS
BEGIN
   SET NOCOUNT ON;   

   DECLARE @component        AS nvarchar(128);
   DECLARE @table            AS table([ID] int);
   DECLARE @message          AS nvarchar(max);

   BEGIN TRY
      SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

      -- --------------------------------------------------------------------------------
      -- Check parameters
      -- --------------------------------------------------------------------------------
      IF (@p_executionId IS NULL)
         BEGIN
            EXEC [dbo].[spRaiseError] 'The parameter ''p_executionId'' is NULL.', @component;
            RETURN 0;
         END;
      IF (@p_componentId IS NULL)
         BEGIN
            EXEC [dbo].[spRaiseError] 'The parameter ''p_componentId'' is NULL.', @component;
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
      IF ([dbo].[fnIsNullOrEmpty](@p_state, 1) <> 0)
         BEGIN
            EXEC [dbo].[spRaiseError]  'The parameter ''p_state'' is either NULL or an empty string', @component;         
            RETURN 1;
         END;
      IF ([dbo].[fnIsNullOrEmpty](@p_success, 1) <> 0)
         BEGIN
            EXEC [dbo].[spRaiseError]  'The parameter ''p_success'' is either NULL or an empty string', @component;         
            RETURN 1;
         END;
      IF (@p_success = 0 AND @p_state IN ('success')) OR (@p_success = 1 AND @p_state IN ('processing', 'error'))
         BEGIN
            SET @message = CONCAT('Invalid state ''', @p_state, ''' for p_success = ''', CAST(@p_success AS nvarchar(100)),'''.');
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;

      -- --------------------------------------------------------------------------------
      -- Insert trace into [LOG].[Trace]
      -- --------------------------------------------------------------------------------
      INSERT INTO [LOG].[Trace]
      (
          [ExecutionID] 
         ,[ComponentID] 
         ,[Source] 
         ,[Component] 
         ,[Task] 
         ,[Entity] 
         ,[Step] 
         ,[Description] 
         ,[Action] 
         ,[AffectedRows] 
         ,[State] 
         ,[Success] 
      )
      OUTPUT Inserted.ID INTO @table
      VALUES
      (
          @p_executionId
         ,@p_componentId
         ,@p_source
         ,@p_component
         ,@p_task
         ,@p_entity
         ,@p_step
         ,CASE WHEN @p_description IS NULL OR DATALENGTH(@p_description) = 0  THEN NULL ELSE @p_description END
         ,@p_action
         ,@p_affectedRows
         ,@p_state
         ,@p_success
      );

      SELECT @p_traceId = [ID] FROM @table;

      RETURN 0;
   END TRY
   BEGIN CATCH
      THROW;
   END CATCH; 
END
-- [LOG].[spInsertTrace] 

-- DECLARE @executionId  AS int;
-- DECLARE @componentId  AS int;
-- DECLARE @traceId      AS int;
-- DECLARE @source       AS nvarchar(5);
-- DECLARE @component    AS nvarchar(128);
-- DECLARE @entity       AS nvarchar(128);
-- DECLARE @step         AS nvarchar(max);
-- DECLARE @description  AS nvarchar(max);
-- DECLARE @action       AS nvarchar(100) = NULL
-- DECLARE @affectedRows AS int 
-- DECLARE @state        AS nvarchar(100);
-- DECLARE @success      AS bit;
--
-- SET @executionId  = 1;
-- SET @componentId  = 1;
-- SET @source       = 'T-SQL';
-- SET @component    = 'test script';
-- SET @entity       = '[LOG].[spInsertTrace]';
-- SET @step         = '[LOG].[spInsertTrace]';
-- SET @description  = 'none';
-- SET @action       = 'Insert';
-- SET @affectedRows = 55;
-- SET @state        = 'processing';
-- SET @success      = 0;
-- 
-- EXEC [LOG].[spInsertTrace] 
--     @p_executionId  = @executionId
--    ,@p_componentId  = @componentId
--    ,@p_traceId      = @traceId OUTPUT
--    ,@p_source       = @source
--    ,@p_component    = @component  
--    ,@p_entity       = @entity     
--    ,@p_step         = @step       
--    ,@p_description  = @description
--    ,@p_action       = @action
--    ,@p_affectedRows = @affectedRows
--    ,@p_state        = @state      
--    ,@p_success      = @success;
-- 
-- SELECT @traceId;
-- SELECT * FROM [LOG].[Trace] WHERE [ID] = @traceId;
