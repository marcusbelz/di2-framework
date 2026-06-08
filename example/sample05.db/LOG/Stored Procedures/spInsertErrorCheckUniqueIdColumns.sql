-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Checks the uniqueness of values in the columns
--              @p_schema.@p_table.@p_ID1Field & 
--              @p_schema.@p_table.@p_ID2Field &
--              @p_schema.@p_table.@p_ID3Field. Values that 
--              exist multiple times will be logged in the table [LOG].[Error] (one row 
--              per occurance).
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
--    @p_checkField           AS nvarchar(1000)
--       Comma separated list of field names that will be checked for uniqueness.
--    @p_maxOccurance         AS int
--       Maximum allowed occurances.
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
CREATE PROCEDURE [LOG].[spInsertErrorCheckUniqueIdColumns]
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
   ,@p_checkField            AS nvarchar(1000)
   ,@p_maxOccurance          AS int
   ,@p_message               AS nvarchar(max)
   ,@p_affectedRows          AS int OUT
   ,@p_whereClause           AS nvarchar(max) = NULL

WITH EXECUTE AS OWNER

AS
BEGIN
   SET NOCOUNT ON;

   -- --------------------------------------------------------------------------------
   -- Declare Variables
   -- --------------------------------------------------------------------------------
   -- Error Variables
   DECLARE @component                  AS nvarchar(128);
   DECLARE @message                    AS nvarchar(max);
   DECLARE @sql                        AS nvarchar(max);
   DECLARE @indexName                  AS nvarchar(50);  -- Index Name
   DECLARE @sql_Index1                 AS nvarchar(max); -- CREATE INDEX Statement
   DECLARE @sql_Index2                 AS nvarchar(max); -- DROP INDEX Statement
   DECLARE @sql_Concat                 AS nvarchar(max); -- CONCAT-Statement
   DECLARE @returnCode                 AS int;
   DECLARE @errorCode                  AS int;

   DECLARE @p_id1_isDateTime           AS bit;
   DECLARE @p_id2_isDateTime           AS bit;
   DECLARE @p_id3_isDateTime           AS bit;

   -- Curser Variables
   DECLARE @C_KeyField                 AS nvarchar(128);
   DECLARE @C_Count                    AS int;

   SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

   BEGIN TRY
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
      -- Check @p_check_field_name
      -- --------------------------------------------------------------------------------
      IF [dbo].[fnIsNullOrEmpty](@p_checkField, 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_checkField'' is NULL or empty.';
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


      SELECT @p_id1_isDateTime = [CONFIG].[fnColumnIsDateTime](@p_schema, @p_table, @p_ID1Field);
      SELECT @p_id2_isDateTime = [CONFIG].[fnColumnIsDateTime](@p_schema, @p_table, @p_ID2Field);
      SELECT @p_id3_isDateTime = [CONFIG].[fnColumnIsDateTime](@p_schema, @p_table, @p_ID3Field);

      -- --------------------------------------------------------------------------------
      -- Build CREATE/DROP INDEX SQL statement - Part I
      -- --------------------------------------------------------------------------------
      SET @indexName  = CAST (NEWID() AS nvarchar(50));
      SET @sql_Index1 = 'CREATE NONCLUSTERED INDEX [' + @indexName + '] ON [' + @p_schema + '].[' + @p_table + '](' + @p_checkField + ')';
      SET @sql_Index2 = 'IF EXISTS (SELECT name FROM sysindexes WHERE name = ''' + @indexName + ''') DROP INDEX [' + @indexName + '] ON [' + @p_schema + '].[' + @p_table + ']';

      -- --------------------------------------------------------------------------------
      -- Build SQL statement - Part II
      -- --------------------------------------------------------------------------------
      SET @sql = ''
      SET @sql = @sql + 'WITH '                                                                                    + CHAR(13);
      SET @sql = @sql + 'CTE AS '                                                                                  + CHAR(13);
      SET @sql = @sql + '( '                                                                                       + CHAR(13);
      SET @sql = @sql + '   SELECT  '                                                                              + CHAR(13);
      SET @sql = @sql + '       ' + @p_checkField                                                                  + CHAR(13);  
      SET @sql = @sql + '      ,COUNT(*) AS [COUNT] '                                                              + CHAR(13);
      SET @sql = @sql + '   FROM '                                                                                 + CHAR(13);
      SET @sql = @sql + '      [' + @p_schema + '].[' + @p_table + '] T01 '                                        + CHAR(13);
   
      IF [dbo].[fnIsNullOrEmpty](@p_whereClause, 1) = 0
      BEGIN
         SET @sql = @sql + '   WHERE '                                                                             + CHAR(13);
         SET @sql = @sql + '      ' + @p_whereClause + ' '                                                         + CHAR(13);
      END;

      SET @sql = @sql + '   GROUP BY '                                                                             + CHAR(13);
      SET @sql = @sql + '        ' + @p_checkField                                                                 + CHAR(13);

      SET @sql = @sql + '   HAVING '                                                                               + CHAR(13);
      SET @sql = @sql + '      COUNT(*) > ' + CAST(@p_maxOccurance AS nvarchar(100)) + ' '                         + CHAR(13);
      SET @sql = @sql + ') '                                                                                       + CHAR(13);
      SET @sql = @sql + 'INSERT INTO [LOG].[Error] WITH (TABLOCKX) '                                               + CHAR(13);
      SET @sql = @sql + '   ([ExecutionID], [ComponentID], [TraceID], [ErrorType], [Source], [Component], [TaskName], [Entity], [Step], [SchemaName], [TableName], [ID1Value], [ID1ColumnName], [ID2Value], [ID2ColumnName], [ID3Value], [ID3ColumnName], [ErrorValue], [ErrorColumnName], [FileName], [Description], [Number], [Line], [State], [CreatedOn], [CreatedBy]) ' + CHAR(13);
      SET @sql = @sql  + 'SELECT '                                                                                 + CHAR(13);
      SET @sql = @sql + '    ' + CAST(@p_executionId AS nvarchar(100))               +   ' AS [ExecutionID] '      + CHAR(13);
      SET @sql = @sql + '   ,' + CAST(@p_componentId AS nvarchar(100))               +   ' AS [ComponentID] '      + CHAR(13);
      SET @sql = @sql + '   ,' + CAST(@p_traceId AS nvarchar(100)  )                 +   ' AS [TraceID] '          + CHAR(13);
      SET @sql = @sql + '   ,''' + CAST(@p_errorType AS nvarchar(1))                 + ''' AS [ErrorType] '        + CHAR(13);
      SET @sql = @sql + '   ,' + '''T-SQL'''                                         +   ' AS [Source] '           + CHAR(13);
      SET @sql = @sql + '   ,''' + @p_component                                      + ''' AS [Component] '        + CHAR(13);
      SET @sql = @sql + '   ,''' + @p_task                                           + ''' AS [TaskName] '         + CHAR(13);
      SET @sql = @sql + '   ,''' + @p_entity                                         + ''' AS [Entity] '           + CHAR(13);
      SET @sql = @sql + '   ,''' + @p_step                                           + ''' AS [Step] '             + CHAR(13);
      SET @sql = @sql + '   ,''' + @p_schema                                         + ''' AS [SchemaName] '       + CHAR(13);
      SET @sql = @sql + '   ,''' + @p_table                                          + ''' AS [TableName] '        + CHAR(13);

      IF @p_id1_isDateTime = 1
         BEGIN
            SET @sql = @sql + '   , CONVERT(nvarchar(max), [T02].' + @p_ID1Field + ', 121) AS [ID1Value] '         + CHAR(13);
         END
      ELSE
         BEGIN
            SET @sql = @sql + '   , CAST([T02].' + @p_ID1Field + ' AS nvarchar(max))       AS [ID1Value] '         + CHAR(13);
         END;
      
      SET @sql = @sql + '   , ''' + @p_ID1Field + '''                                      AS [ID1ColumnName] '    + CHAR(13);

      IF [dbo].[fnIsNullOrEmpty](@p_ID2Field, 1) = 1
         BEGIN
            SET @sql = @sql + '   , NULL                                                AS [ID2Value] '            + CHAR(13);
            SET @sql = @sql + '   , NULL                                                AS [ID2ColumnName] '       + CHAR(13);
         END
      ELSE
         BEGIN
            IF @p_id2_isDateTime = 1
               BEGIN
                  SET @sql = @sql + '   , CONVERT(nvarchar(max), [T02].' + @p_ID2Field + ', 121) AS [ID2Value] '   + CHAR(13);
               END
            ELSE
               BEGIN
                  SET @sql = @sql + '   , CAST([T02].' + @p_ID2Field + ' AS nvarchar(max))       AS [ID2Value] '   + CHAR(13);
               END;
            
            SET @sql = @sql + '   , ''' + @p_ID2Field + '''                            AS [ID2ColumnName] '        + CHAR(13);
         END;
   
      IF [dbo].[fnIsNullOrEmpty](@p_ID3Field, 1) = 1
         BEGIN
            SET @sql = @sql + '   , NULL                                                AS [ID3Value] '            + CHAR(13);
            SET @sql = @sql + '   , NULL                                                AS [ID3ColumnName] '       + CHAR(13);
         END
      ELSE
         BEGIN
            IF @p_id3_isDateTime = 1
               BEGIN
                  SET @sql = @sql + '   , CONVERT(nvarchar(max), [T02].' + @p_ID3Field + ', 121) AS [ID3Value] '   + CHAR(13);
               END
            ELSE
               BEGIN
                  SET @sql = @sql + '   , CAST([T02].' + @p_ID3Field + ' AS nvarchar(max))       AS [ID3Value] '   + CHAR(13);
               END;
            SET @sql = @sql + '   , ''' + @p_ID3Field + '''                            AS [ID3ColumnName] '        + CHAR(13);
         END;
   
      -- --------------------------------------------------------------------------------
      -- Build SQL statement - Part III - Curser for Join
      -- --------------------------------------------------------------------------------
      SET @sql_Concat = '   ,CONCAT(';

      DECLARE cursor_loop1 CURSOR LOCAL FOR      
      SELECT * FROM [dbo].[fnSplit] (@p_checkField, ',');

      SET @C_Count = 1;      
      OPEN cursor_loop1;
      FETCH NEXT FROM cursor_loop1 INTO @C_KeyField;
      WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @C_Count > 1
               BEGIN
                   SET @sql_Concat = @sql_Concat + ', ';
               END;            
            SET @sql_Concat = @sql_Concat + '''['',' + 'COALESCE([T02].' + @C_KeyField + ', ''NULL''), ' + ''']''';
            SET @C_Count = @C_Count + 1;
                     
            FETCH NEXT FROM cursor_loop1 INTO @C_KeyField;
         END;
      CLOSE cursor_loop1;
      DEALLOCATE cursor_loop1;

      SET @sql_Concat = @sql_Concat + ')';
      SET @sql = @sql + @sql_Concat +  ' AS [ErrorValue] ' + CHAR(13);




      SET @sql = @sql + '   , ''' + @p_checkField + '''                           AS [ErrorColumnName] '           + CHAR(13);
      SET @sql = @sql + '   , NULL                                                      AS [FileName] '            + CHAR(13);
      SET @sql = @sql + '   ,''' + @p_message + ' ('' + CAST([T01].[COUNT] AS nvarchar(100)) + '' / ' + CAST(@p_maxOccurance AS nvarchar(100)) + ')'' AS [Description] ' + CHAR(13);
      SET @sql = @sql + '   , NULL                                                      AS [Number] '              + CHAR(13);
      SET @sql = @sql + '   , NULL                                                      AS [Line] '                + CHAR(13);
      SET @sql = @sql + '   , NULL                                                      AS [State] '               + CHAR(13);
      SET @sql = @sql + '   ,''' + CAST(GETUTCDATE() as nvarchar(100))            + ''' AS [CreatedOn] '           + CHAR(13);
      SET @sql = @sql + '   ,''' + SYSTEM_USER                                    + ''' AS [CreatedBy] '           + CHAR(13);
      SET @sql = @sql + 'FROM '                                                                                    + CHAR(13);
      SET @sql = @sql + '   CTE AS [T01] '                                                                         + CHAR(13);
      SET @sql = @sql + '   LEFT JOIN [' + @p_schema + '].[' + @p_table + '] AS [T02] '                            + CHAR(13);
      SET @sql = @sql + '   ON     ';

      -- --------------------------------------------------------------------------------
      -- Build SQL statement - Part III - Curser for Join
      -- --------------------------------------------------------------------------------
      DECLARE cursor_loop2 CURSOR LOCAL FOR      
      SELECT * FROM [dbo].[fnSplit] (@p_checkField, ',');

      SET @C_Count = 1;
      
      OPEN cursor_loop2;

      FETCH NEXT FROM cursor_loop2 INTO @C_KeyField;
      WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @C_Count > 1
               BEGIN
                   SET @sql = @sql + '   AND    ';
               END;
            
            SET @sql     = @sql + '[T01].' + @C_KeyField + ' = [T02].' + @C_KeyField + CHAR(13);
            SET @C_Count = @C_Count + 1;
         
            FETCH NEXT FROM cursor_loop2 INTO @C_KeyField;
         END;
      CLOSE cursor_loop2;
      DEALLOCATE cursor_loop2;

      -- --------------------------------------------------------------------------------
      -- Build SQL statement - Part III
      -- --------------------------------------------------------------------------------
 
      SET @sql = @sql + '; '   
   
      SET @sql = @sql + 'SET @affectedrecords_out = @@ROWCOUNT;'

      --SELECT @sql

      BEGIN TRY
         EXEC @returnCode = [dbo].[sp_executesql] @sql_Index1;
         EXEC @returnCode = [dbo].[sp_executesql] @sql, N'@affectedrecords_out int OUT', @p_affectedRows OUT;
         EXEC @returnCode = [dbo].[sp_executesql] @sql_Index2;
      END TRY
      BEGIN CATCH
         SET @message   = ERROR_MESSAGE();
         SET @errorCode = @@ERROR;
         EXEC [dbo].[sp_executesql] @sql_Index2;
         IF @errorCode > 0
            BEGIN
               EXEC [dbo].[spRaiseError] @message, @component;
               RETURN @errorCode;
            END;
      END CATCH



      RETURN 0;

   END TRY
   BEGIN CATCH
      -- Cursor 1 schließen
      IF (SELECT CURSOR_STATUS('local','cursor_loop1')) >= -1
      BEGIN
         IF (SELECT CURSOR_STATUS('local','cursor_loop1')) > -1
            BEGIN
               CLOSE cursor_loop1;
            END
         DEALLOCATE cursor_loop1;
      END;

      -- Cursor 2 schließen
      IF (SELECT CURSOR_STATUS('local','cursor_loop2')) >= -1
      BEGIN
         IF (SELECT CURSOR_STATUS('local','cursor_loop2')) > -1
            BEGIN
               CLOSE cursor_loop2;
            END
         DEALLOCATE cursor_loop2;
      END;
      THROW;
      RETURN ERROR_NUMBER();
   END CATCH; 

END
-- [LOG].[spInsertErrorCheckUniqueIdColumns]

-- --------------------------------------------------------------------------------
-- Test script
-- --------------------------------------------------------------------------------
--USE [framework_dev]
--GO

/*

DECLARE @p_executionId      int;
DECLARE @p_componentId      int;
DECLARE @p_traceId          int;
DECLARE @p_errorType        nchar(1);
DECLARE @p_component        nvarchar(128);
DECLARE @p_task             nvarchar(128);
DECLARE @p_entity           nvarchar(128);
DECLARE @p_step             nvarchar(max);
DECLARE @p_schema           nvarchar(128);
DECLARE @p_table            nvarchar(128);
DECLARE @p_ID1Field         nvarchar(128);
DECLARE @p_ID2Field         nvarchar(128);
DECLARE @p_ID3Field         nvarchar(128);
DECLARE @p_check_field_name nvarchar(1000);
DECLARE @p_maxOccurance     int;
DECLARE @p_message          nvarchar(max);
DECLARE @p_affectedRecords  int;
DECLARE @p_whereClause      nvarchar(max);

SET @p_executionId     = 647;
SET @p_componentId     = 14868;
SET @p_traceId         = 8289;
SET @p_errorType       = 'W';
SET @p_component       = '<@p_component>';
SET @p_task            = '<@p_task>';
SET @p_entity          = '<@p_entity>';
SET @p_step            = '<@p_step>';
SET @p_schema          = 'IL';
SET @p_table           = '<table>';
SET @p_ID1Field       = '<pk1>';
SET @p_ID2Field       = NULL;
SET @p_ID3Field       = NULL;
SET @p_check_field_name = '<field1>,<field2>,<field3>'
SET @p_maxOccurance    = 1;
SET @p_message         = 'Key is not unique';
SET @p_affectedRecords = NULL;
SET @p_whereClause     = NULL;

EXECUTE [LOG].[spInsertErrorCheckUniqueIdColumns]
    @p_executionId    
   ,@p_componentId    
   ,@p_traceId        
   ,@p_errorType      
   ,@p_component      
   ,@p_task           
   ,@p_entity         
   ,@p_step           
   ,@p_schema         
   ,@p_table          
   ,@p_ID1Field      
   ,@p_ID2Field      
   ,@p_ID3Field
   ,@p_check_field_name
   ,@p_maxOccurance   
   ,@p_message        
   ,@p_affectedRecords OUTPUT
   ,@p_whereClause;
GO

*/
-- --------------------------------------------------------------------------------