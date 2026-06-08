-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Checks the maximum Length of texts in a column. The maximum length 
--              will be taken from a nother column in the same table. Texts that 
--              are too long will be logged in the table ERR_ERROR.
-- --------------------------------------------------------------------------------
-- Parameters
--    @p_executionId          AS int
--       Execution ID of the current execution
--    @p_componentId          AS int
--       Component ID the error message is related to.
--    @p_traceId              AS int
--       Trace ID the error message is related to.
--    @p_errorType            AS nchar(1)
--       Specifies the trace type of the entry 
--         I = Information
--         W = Warning
--         E = Error
--    @p_component            AS nvarchar(128)
--       System::PackageName (SSIS specific)
--    @p_task                 AS nvarchar(128)
--       Task Name (SSIS specific)
--    @p_entity               AS nvarchar(128)
--       Name of the table that is involved in this procedure call.
--    @p_step                 AS nvarchar(max)
--       Describe the step, that invokes this procedure call.
--    @p_schema               AS nvarchar(128)
--       Specifies the schema name of the table that contains the error.
--    @p_table                AS nvarchar(128)
--       Specifies the table name of the table that contains the error.
--    @p_ID1Field             AS nvarchar(128)
--       Primary key 1 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID2Field             AS nvarchar(128) = NULL
--       Primary key 2 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_ID3Field             AS nvarchar(128) = NULL
--       Primary key 3 field name of the record the error is related to. The primary key field must 
--       exist in the table that is specified in p_table.
--    @p_checkField           AS nvarchar(128)
--       Field name of the field that contains the error.
--    @p_lengthField          AS nvarchar(128)
--       Field name that contains the maximum length of texts in column |p_checkField
--    @p_message              AS nvarchar(max)
--       Message that will be logged with each error.
--    @p_affectedRows         AS int OUT
--       Returns the number of log entries.
--    @p_whereClause          AS nvarchar(max) = NULL
--       Optional WHERE clause
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 error
--      0 = success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [LOG].[spInsertErrorCheckNVarCharLength2]
    @p_executionId           AS int
   ,@p_componentId           AS int
   ,@p_traceId               AS int
   ,@p_errorType             AS nchar(1)
   ,@p_component             AS nvarchar(128)
   ,@p_task                  AS nvarchar(128)
   ,@p_entity                AS nvarchar(128)
   ,@p_step                  AS nvarchar(max)
   ,@p_schema                AS nvarchar(128)
   ,@p_table                 AS nvarchar(128)
   ,@p_ID1Field              AS nvarchar(128)
   ,@p_ID2Field              AS nvarchar(128) = NULL
   ,@p_ID3Field              AS nvarchar(128) = NULL
   ,@p_checkField            AS nvarchar(128)
   ,@p_lengthField           AS nvarchar(128)
   ,@p_message               AS nvarchar(max)
   ,@p_affectedRows          AS int OUT
   ,@p_whereClause           AS nvarchar(max) = NULL
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE @component        AS nvarchar(128);
   DECLARE @message          AS nvarchar(max);
   DECLARE @sql              AS nvarchar(max);
   DECLARE @returnCode       AS int;
   DECLARE @errorCode        AS int;

   SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

   -- --------------------------------------------------------------------------------
   -- Check Parameters
   -- --------------------------------------------------------------------------------
   BEGIN
      -- --------------------------------------------------------------------------------
      -- Check @p_executionId
      -- --------------------------------------------------------------------------------
      IF (@p_executionId IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_executionId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_componentId
      -- --------------------------------------------------------------------------------
      IF (@p_componentId IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_componentId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_traceId
      -- --------------------------------------------------------------------------------
      IF (@p_traceId IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_traceid'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_errorType
      -- --------------------------------------------------------------------------------
      IF (@p_errorType IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_errortype'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_component
      -- --------------------------------------------------------------------------------
      IF (@p_component IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_component'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_entity
      -- --------------------------------------------------------------------------------
      IF (@p_entity IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_entity'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_step
      -- --------------------------------------------------------------------------------
      IF (@p_step IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_step'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_schema
      -- --------------------------------------------------------------------------------
      IF [dbo].[fnIsNullOrEmpty](@p_schema, 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_schema'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_table
      -- --------------------------------------------------------------------------------
      IF [dbo].[fnIsNullOrEmpty](@p_table, 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_table'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_ID1Field
      -- --------------------------------------------------------------------------------
      IF [dbo].[fnIsNullOrEmpty](@p_ID1Field, 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_id1_field'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      -- --------------------------------------------------------------------------------
      -- Check @p_checkField 
      -- --------------------------------------------------------------------------------
      IF [dbo].[fnIsNullOrEmpty](@p_checkField , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_check_field'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
   END;

   -- --------------------------------------------------------------------------------
   -- Handle other NULLs
   -- --------------------------------------------------------------------------------
   SET @p_task     = COALESCE(@p_task    , '');
   SET @p_message  = COALESCE(@p_message , '');

   -- --------------------------------------------------------------------------------
   -- Trim values
   -- --------------------------------------------------------------------------------
   SET @p_schema   = LTRIM(RTRIM(@p_schema));
   SET @p_table    = LTRIM(RTRIM(@p_table ));

   -- --------------------------------------------------------------------------------
   -- Build SQL statement
   -- --------------------------------------------------------------------------------
   SET @sql = ''
   SET @sql = @sql + 'INSERT INTO [LOG].[Error] '                                                               + CHAR(13);
   SET @sql = @sql + '   ([ExecutionID], [ComponentID], [TraceID], [ErrorType], [Source], [Component], [TaskName], [Entity], [Step], [SchemaName], [TableName], [ID1Value], [ID1ColumnName], [ID2Value], [ID2ColumnName], [ID3Value], [ID3ColumnName], [ErrorValue], [ErrorColumnName], [FileName], [Description], [Number], [Line], [State], [CreatedOn], [CreatedBy]) ' + CHAR(13);
   SET @sql = @sql + 'SELECT '                                                                                  + CHAR(13);
   SET @sql = @sql + '    ' + CAST(@p_executionId AS nvarchar(100))          +   ' AS [ExecutionID] '           + CHAR(13);
   SET @sql = @sql + '   ,' + CAST(@p_componentId AS nvarchar(100))          +   ' AS [ComponentID] '           + CHAR(13);
   SET @sql = @sql + '   ,' + CAST(@p_traceId AS nvarchar(100)  )            +   ' AS [TraceID] '               + CHAR(13);
   SET @sql = @sql + '   ,''' + CAST(@p_errorType AS nvarchar(1))            + ''' AS [ErrorType] '             + CHAR(13);
   SET @sql = @sql + '   ,' + '''T-SQL'''                                    +   ' AS [Source] '                + CHAR(13);
   SET @sql = @sql + '   ,''' + @p_component                                 + ''' AS [Component] '             + CHAR(13);
   SET @sql = @sql + '   ,''' + @p_task                                      + ''' AS [TaskName] '              + CHAR(13);

   SET @sql = @sql + '   ,''' + @p_entity                                    + ''' AS [Entity] '                + CHAR(13);
   SET @sql = @sql + '   ,''' + @p_step                                      + ''' AS [Step] '                  + CHAR(13);
   SET @sql = @sql + '   ,''' + @p_schema                                    + ''' AS [SchemaName] '            + CHAR(13);
   SET @sql = @sql + '   ,''' + @p_table                                     + ''' AS [TableName] '             + CHAR(13);
   
   IF [dbo].[fnIsNullOrEmpty](@p_ID1Field, 1) = 1
      BEGIN
         SET @sql = @sql + '   , NULL                                              AS [ID1Value] '              + CHAR(13);
         SET @sql = @sql + '   , NULL                                              AS [ID1ColumnName] '         + CHAR(13);
      END
   ELSE
      BEGIN
         SET @sql = @sql + '   , CAST([T01].' + @p_ID1Field + ' AS nvarchar(128)) AS [ID1Value] '               + CHAR(13);
         SET @sql = @sql + '   , ''' + @p_ID1Field + '''                          AS [ID1ColumnName] '          + CHAR(13);
      END;
   
   IF [dbo].[fnIsNullOrEmpty](@p_ID2Field, 1) = 1
      BEGIN
         SET @sql = @sql + '   , NULL                                              AS [ID2Value] '              + CHAR(13);
         SET @sql = @sql + '   , NULL                                              AS [ID2ColumnName] '         + CHAR(13);
      END
   ELSE
      BEGIN
         SET @sql = @sql + '   , CAST([T01].' + @p_ID2Field + ' AS nvarchar(128)) AS [ID2Value] '               + CHAR(13);
         SET @sql = @sql + '   , ''' + @p_ID2Field + '''                          AS [ID2ColumnName] '          + CHAR(13);
      END;
   
   IF [dbo].[fnIsNullOrEmpty](@p_ID3Field, 1) = 1
      BEGIN
         SET @sql = @sql + '   , NULL                                              AS [ID3Value] '              + CHAR(13);
         SET @sql = @sql + '   , NULL                                              AS [ID3ColumnName] '         + CHAR(13);
      END
   ELSE
      BEGIN
         SET @sql = @sql + '   , CAST([T01].' + @p_ID3Field + ' AS nvarchar(128)) AS [ID3Value] '               + CHAR(13);
         SET @sql = @sql + '   , ''' + @p_ID3Field + '''                          AS [ID3ColumnName] '          + CHAR(13);
      END;
   SET @sql = @sql + '   ,' + '[T01].[' + @p_checkField    + ']                    AS [ErrorValue] '            + CHAR(13);
   SET @sql = @sql + '   ,''' + @p_checkField                                + ''' AS [ErrorColumnName] '       + CHAR(13);
   SET @sql = @sql + '   , NULL                                                    AS [FileName] '              + CHAR(13);
   SET @sql = @sql + '   ,''' + @p_message + ' ('' + CAST((DATALENGTH([T01].[' + @p_checkField  + ']) / 2) AS nvarchar(100)) + '' / '' + CAST([T01].[' + @p_lengthField  + '] AS nvarchar(100)) + '')'' AS [Description] ' + CHAR(13);
   SET @sql = @sql + '   , NULL                                                    AS [Number] '                + CHAR(13);
   SET @sql = @sql + '   , NULL                                                    AS [Line] '                  + CHAR(13);
   SET @sql = @sql + '   , NULL                                                    AS [State] '                 + CHAR(13);
   SET @sql = @sql + '   ,''' + CAST(GETUTCDATE() as nvarchar(100))          + ''' AS [CreatedOn] '             + CHAR(13);
   SET @sql = @sql + '   ,''' + SYSTEM_USER                                  + ''' AS [CreatedBy] '             + CHAR(13);
   SET @sql = @sql + 'FROM '                                                                                    + CHAR(13);
   SET @sql = @sql + '   [' + @p_schema + '].[' + @p_table + '] T01 '                                           + CHAR(13);
   SET @sql = @sql + 'WHERE '                                                                                   + CHAR(13);
   SET @sql = @sql + '       DATALENGTH([T01].[' + @p_checkField  + ']) / 2 > [T01].[' + @p_lengthField  + '] ' + CHAR(13);

   IF [dbo].[fnIsNullOrEmpty](@p_whereClause, 1) = 0
      BEGIN
         SET @sql = @sql + '   AND ' + @p_whereClause + ' '                                                     + CHAR(13);
      END;
   SET @sql = @sql + ';'                                                                                        + CHAR(13);

   --PRINT @sql;

   SET @sql = @sql + 'SET @affectedrecords_out = @@ROWCOUNT;'

   EXEC @returnCode = [dbo].[sp_executesql] @sql, N'@affectedrecords_out int OUT', @p_affectedRows OUT;

   SET @message   = ERROR_MESSAGE();
   SET @errorCode = @@ERROR;
   IF @errorCode > 0
      BEGIN
         EXEC [dbo].[spRaiseError] @message, @component;
         RETURN @errorCode;
      END;

   RETURN 0;
END
-- [LOG].[spInsertErrorCheckNVarCharLength2]

-- --------------------------------------------------------------------------------
-- Test script
-- --------------------------------------------------------------------------------
--USE [logging]
--GO

--DECLARE @RC                AS int;
--DECLARE @p_executionId     AS int;
--DECLARE @p_componentId     AS int;
--DECLARE @p_traceId         AS int;
--DECLARE @p_errorType       AS nchar(1);
--DECLARE @p_component       AS nvarchar(128);
--DECLARE @p_task            AS nvarchar(128);
--DECLARE @p_entity          AS nvarchar(128);
--DECLARE @p_step            AS nvarchar(max);
--DECLARE @p_schema          AS nvarchar(128);
--DECLARE @p_table           AS nvarchar(128);
--DECLARE @p_ID1Field        AS nvarchar(128);
--DECLARE @p_ID2Field        AS nvarchar(128);
--DECLARE @p_ID3Field        AS nvarchar(128);
--DECLARE @p_checkField      AS nvarchar(128);
--DECLARE @p_lengthField     AS nvarchar(128);
--DECLARE @p_message         AS nvarchar(max);
--DECLARE @p_affectedRows    AS int OUT;
--DECLARE @p_whereClause     AS nvarchar(max);

--SET @p_executionId = 1;
--SET @p_componentId = 1;
--SET @p_traceId     = 1;
--SET @p_errorType   = 'I';
--SET @p_component   = '<@p_component>';
--SET @p_task        = '<@p_task>';
--SET @p_entity      = '<@p_entity>';
--SET @p_step        = '<@p_step>';
--SET @p_schema      = 'dbo';
--SET @p_table       = 'TEST';
--SET @p_ID1Field    = 'ID';
--SET @p_ID2Field    = NULL;
--SET @p_ID3Field    = NULL;
--SET @p_checkField  = 'T_TEXT';
--SET @p_lengthField = 'T_LENGTH';
--SET @p_message     = 'Text is too long'
--SET @p_whereClause = 'ID > 5000';

--EXECUTE @RC = [LOG].[spInsertErrorCheckNVarCharLength2]
--    @p_executionId
--   ,@p_componentId
--   ,@p_traceId
--   ,@p_errorType
--   ,@p_component
--   ,@p_task
--   ,@p_entity
--   ,@p_step
--   ,@p_schema
--   ,@p_table
--   ,@p_ID1Field
--   ,@p_ID2Field
--   ,@p_ID3Field
--   ,@p_checkField
--   ,@p_lengthField
--   ,@p_message
--   ,@p_affectedRows OUTPUT
--   ,@p_whereClause
--GO