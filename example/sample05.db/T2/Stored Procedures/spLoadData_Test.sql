-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 30.09.2018
-- Description: Load data from [T1].[Test] to [T2].[Test]
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       Execution ID of the current execution
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
CREATE PROCEDURE [T2].[spLoadData_Test]
(   
    @p_executionId           AS int
)
AS
BEGIN
   SET NOCOUNT ON;   

   -- Error Variables
   DECLARE @error_message    AS nvarchar(max);
   DECLARE @error_number     AS int;
   DECLARE @error_line       AS int;
   DECLARE @error_state      AS nvarchar(max);

   -- Logging Variables
   DECLARE @component        AS nvarchar(128);
   DECLARE @task             AS nvarchar(128);
   DECLARE @schema           AS nvarchar(128);
   DECLARE @table            AS nvarchar(128);

   DECLARE @source           AS nvarchar(5);
   DECLARE @step             AS nvarchar(max);
   DECLARE @entity           AS nvarchar(max);
   DECLARE @message          AS nvarchar(max);

   DECLARE @traceId          AS int; 
   DECLARE @componentId      AS int;

   DECLARE @description      AS nvarchar(max);
   DECLARE @affectedrows     AS int;

   -- --------------------------------------------------------------------------------
   -- SET variables
   -- --------------------------------------------------------------------------------

   -- Logging
   SET @message          = NULL;
   SET @description      = NULL;
   SET @affectedrows     = 0;

   SET @component        = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source           = N'T-SQL';
   SET @componentId      = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity           = N'[T2].[Test]';

   -- --------------------------------------------------------------------------------
   -- Start TRY
   -- --------------------------------------------------------------------------------
   BEGIN TRY

      -- --------------------------------------------------------------------------------
      -- Check input parameters for integrity
      -- --------------------------------------------------------------------------------
      IF (@p_executionId IS NULL)
         BEGIN
            SET @message = N'The parameter ''p_executionId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;

      -- --------------------------------------------------------------------------------
      -- Start Component Log
      -- --------------------------------------------------------------------------------
      SET @step        = N'Load data T1>T2';
      SET @description = N'';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, NULL, @entity, @step, @description;
      
      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = N'Insert data';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Check', NULL, N'processing', 0;

      -- --------------------------------------------------------------------------------
      -- Insert data
      -- --------------------------------------------------------------------------------
      DELETE FROM [T2].[Test] WHERE [ExecutionID] = @p_executionId;

      INSERT INTO [T2].[Test]
      (
          [ID]
         ,[Status]
         ,[DateCreated]
         ,[DateModified]
         ,[MappedToContact]
         ,[NotificationEmailAddress1]
         ,[NotificationEmailAddress2]
         ,[Salutation]
         ,[FirstName]
         ,[LastName]
         ,[Field1]
         ,[Field2]
         ,[Field3]
         ,[Field4]
         ,[IPv4Address]
         ,[ExecutionID]
         ,[SysCreatedOn]
         ,[SysCreatedBy]
         ,[SysSource]
      )
     SELECT
          T01.[ID]                        AS [ID]
         ,T01.[Status]                    AS [Status]
         ,T01.[DateCreated]               AS [DateCreated]
         ,T01.[DateModified]              AS [DateModified]
         ,T01.[MappedToContact]           AS [MappedToContact]
         ,T01.[NotificationEmailAddress1] AS [NotificationEmailAddress1]
         ,T01.[NotificationEmailAddress2] AS [NotificationEmailAddress2]
         ,T01.[Salutation]                AS [Salutation]
         ,T01.[FirstName]                 AS [FirstName]
         ,T01.[LastName]                  AS [LastName]
         ,T01.[Field1]                    AS [Field1]
         ,T01.[Field2]                    AS [Field2]
         ,T01.[Field3]                    AS [Field3]
         ,T01.[Field4]                    AS [Field4]
         ,T01.[IPv4Address]               AS [IPv4Address]
         ,@p_executionId                  AS [ExecutionID]
         ,T01.[SysCreatedOn]              AS [SysCreatedOn]
         ,T01.[SysCreatedBy]              AS [SysCreatedBy]
         ,T01.[SysSource]                 AS [SysSource]
     FROM  
        [T1].[Test] T01
     WHERE 
        T01.[SysError] IS NULL; 

      -- --------------------------------------------------------------------------------
      -- End Trace Log
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Insert', @@ROWCOUNT;

      -- --------------------------------------------------------------------------------
      -- End Component Log 
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateComponentSuccess1] @componentId;

      -- --------------------------------------------------------------------------------
      -- Catch Errors
      -- --------------------------------------------------------------------------------
   END TRY
   BEGIN CATCH
      SET @error_message = ERROR_MESSAGE();
      SET @error_number  = ERROR_NUMBER();
      SET @error_line    = ERROR_LINE();
      SET @error_state   = ERROR_STATE();

      -- Write in Logging
      IF @p_executionId IS NOT NULL
         BEGIN
            EXEC [LOG].[spUpdateTraceError1] @traceId;
            EXEC [LOG].[spUpdateComponentError1] @componentId;
            EXEC [LOG].[spInsertError] @p_executionId, @componentid, @traceId, N'E', @source, @component, NULL, NULL, @step, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @error_number, @error_message, @error_line, @error_state;
         END;
      THROW;
      RETURN @error_number;
   END CATCH; 
END
-- [T2].[spLoadData_Test]

-- EXEC [T2].[spLoadData_Test] 33