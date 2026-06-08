-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts a row in table [LOG].[Error].
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       Execution ID of the current execution
--    @p_componentId          AS int
--       Component ID the error message is related to.
--    @p_traceId              AS int
--       Trace ID the error message is related to.
--    @p_errorType            AS char(1)
--       Specifies the error type of the entry 
--         I = Information
--         W = Warning
--         E = Error
--    @p_source               AS nvarchar(5)
--       Specifies the source that is responsible for the error log entry
--        'SSIS'
--        'T-SQL' 
--    @p_component            AS nvarchar(128)
--       Specifies either the SQL Procedure Name or an an SSIS Package Name
--    @p_task                 AS nvarchar(128)  = NULL
--       Task Name (SSIS specific)
--    @p_entity               AS nvarchar(128)
--       Name of the table that is involved in this procedure call.
--    @p_step                 AS nvarchar(max)
--       Describe the step, that invokes this procedure call.
--    @p_schema               AS nvarchar(128)  = NULL
--       Specifies the schema name of the table that contains the error.
--    @p_table                AS nvarchar(128)  = NULL
--       Specifies the table name of the table that contains the error.
--    @p_ID1Field             AS nvarchar(128)
--       Primary key 1 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID1Value             AS nvarchar(max)
--       Primary key 1 value of the record the error is related to. 
--    @p_ID2Field             AS nvarchar(128)  = NULL 
--       Primary key 2 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID2Value             AS nvarchar(max)  = NULL 
--       Primary key 2 value of the record the error is related to. 
--    @p_ID3Field             AS nvarchar(128)  = NULL 
--       Primary key 3 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID3Value             AS nvarchar(max)  = NULL 
--       Primary key 3 value of the record the error is related to. 
--    @p_errorValue           AS nvarchar(max)  = NULL 
--       Error value
--    @p_errorField           AS nvarchar(128)  = NULL
--       Field name of the field that contains the erroneous value
--    @p_errorFileName        AS nvarchar(128)  = NULL
--       File name of the file the error is related to
--    @p_errorNumber          AS int            = NULL
--       SQL Error number.
--    @p_errorDescription     AS nvarchar(max)  = NULL
--       SQL Error description.
--    @p_errorLine            AS int            = NULL
--       SQL Error line.
--    @p_errorState           AS nvarchar(max)  = NULL
--       SQL Error state.
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 : error
--    = 0 : success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [LOG].[spInsertError] 
    @p_executionId           AS int
   ,@p_componentId           AS int
   ,@p_traceId               AS int
   ,@p_errorType             AS char(1)
   ,@p_source                AS nvarchar(5)
   ,@p_component             AS nvarchar(128)
   ,@p_task                  AS nvarchar(128)  = NULL
   ,@p_entity                AS nvarchar(128)
   ,@p_step                  AS nvarchar(max)
   ,@p_schema                AS nvarchar(128)  = NULL
   ,@p_table                 AS nvarchar(128)  = NULL
   ,@p_ID1Field              AS nvarchar(128)
   ,@p_ID1Value              AS nvarchar(max)
   ,@p_ID2Field              AS nvarchar(128)  = NULL 
   ,@p_ID2Value              AS nvarchar(max)  = NULL 
   ,@p_ID3Field              AS nvarchar(128)  = NULL 
   ,@p_ID3Value              AS nvarchar(max)  = NULL 
   ,@p_errorValue            AS nvarchar(max)  = NULL 
   ,@p_errorField            AS nvarchar(128)  = NULL
   ,@p_errorFileName         AS nvarchar(128)  = NULL
   ,@p_errorNumber           AS int            = NULL
   ,@p_errorDescription      AS nvarchar(max)  = NULL
   ,@p_errorLine             AS int            = NULL
   ,@p_errorState            AS nvarchar(max)  = NULL
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE @component        AS nvarchar(128);
   
   SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

   -- --------------------------------------------------------------------------------
   -- Check parameters
   -- --------------------------------------------------------------------------------
   IF (@p_component IS NULL)
      BEGIN
         EXEC [dbo].[spRaiseError] 'The parameter ''p_component'' is NULL.', @component;
         RETURN 1;
      END;
   IF (@p_executionId IS NULL )
      BEGIN
         EXEC [dbo].[spRaiseError] 'The parameter ''p_executionId'' is NULL.', @p_component;
         RETURN 1;
      END;
   IF ([dbo].[fnIsNullOrEmpty](@p_errorType, 1) <> 0 )
      BEGIN
         EXEC [dbo].[spRaiseError] 'The parameter ''p_errortype'' is either NULL or an empty string.', @p_component;
         RETURN 1;
      END;
   IF (@p_errorType IS NULL)
      BEGIN
         EXEC [dbo].[spRaiseError] 'The parameter ''p_errortype'' is NULL.', @p_component;
         RETURN 1;
      END;
   IF ([dbo].[fnIsNullOrEmpty](@p_source, 1) <> 0)
      BEGIN
         EXEC [dbo].[spRaiseError] 'The parameter ''p_source'' is NULL.', @p_component;
         RETURN 1;
      END
   ELSE IF LEN(RTRIM(LTRIM(@p_source))) > 5
      BEGIN
         EXEC [dbo].[spRaiseError] 'The parameter ''p_source'' is too long (max. 5 characters).', @p_component;
         RETURN 1;
      END;

   SET @p_errorType = UPPER(@p_errorType); 
   SET @p_source    = RTRIM(LTRIM(@p_source)); 
   SET @p_component = LOWER(RTRIM(LTRIM(@p_component))); 
   SET @p_table     = CASE WHEN @p_table IS NULL THEN '<System>' ELSE @p_table END;

   INSERT INTO [LOG].[Error]
   (
       [ExecutionID]
      ,[ComponentID]
      ,[TraceID]
      ,[ErrorType]
      ,[Source]
      ,[Component]
      ,[TaskName]
      ,[Entity]
      ,[Step]
      ,[SchemaName]
      ,[TableName]
      ,[ID1Value]
      ,[ID1ColumnName]
      ,[ID2Value]
      ,[ID2ColumnName]
      ,[ID3Value]
      ,[ID3ColumnName]
      ,[ErrorValue]
      ,[ErrorColumnName]
      ,[FileName]
      ,[Description]
      ,[Number]
      ,[Line]
      ,[State]
      ,[CreatedBy]
      ,[CreatedOn]
   )
   VALUES
   (
       @p_executionId
      ,@p_componentId
      ,@p_traceId
      ,@p_errorType
      ,@p_source      
      ,@p_component
      ,@p_task
      ,@p_entity
      ,@p_step
      ,@p_schema
      ,@p_table       
      ,@p_ID1Value
      ,@p_ID1Field
      ,@p_ID2Value
      ,@p_ID2Field
      ,@p_ID3Value
      ,@p_ID3Field
      ,@p_errorValue
      ,@p_errorField
      ,@p_errorFileName
      ,@p_errorDescription 
      ,@p_errorNumber 
      ,@p_errorLine 
      ,@p_errorState 
      ,SYSTEM_USER
      ,GETUTCDATE()
   );

   RETURN 0;
END
-- [LOG].[spInsertError]
