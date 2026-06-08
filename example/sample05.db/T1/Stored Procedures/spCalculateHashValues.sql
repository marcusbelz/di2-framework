-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Calculates Hash Values for the primary key fields and the 
--              attributes fields.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId           AS int
--       ID of the current execution ([LOG].[Execution])
--    @p_schemaName    AS nvarchar(128)
--       Schema of the table, that contains the columns for which the hash values 
--       will be calculated.
--    @p_tableName             AS nvarchar(128)
--       Table name of the table, that contains the columns for which the hash 
--       values will be calculated.
--    @p_referenceSchemaName   AS nvarchar(128) 
--       Schema of the table, for which the column names to be included by this 
--       procedure are specified in table [CONFIG].[TableMetadata]
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
CREATE PROCEDURE [T1].[spCalculateHashValues] 
(   
    @p_executionId           AS int
   ,@p_schemaName            AS nvarchar(128)
   ,@p_tableName             AS nvarchar(128)
   ,@p_referenceSchemaName   AS nvarchar(128)
)
AS
BEGIN
   -- --------------------------------------------------------------------------------
   -- Declare all used variables
   -- --------------------------------------------------------------------------------

   -- Error Variables
   DECLARE @error_message nvarchar(max);
   DECLARE @error_number  int;
   DECLARE @error_line    int;
   DECLARE @error_state   nvarchar(max);

   -- Logging Variables
   DECLARE @component     nvarchar(256);
   DECLARE @task          nvarchar(128);
   DECLARE @schema        nvarchar(128);
   DECLARE @table         nvarchar(128);

   DECLARE @source        nvarchar(5);
   DECLARE @step          nvarchar(max);
   DECLARE @entity        nvarchar(max);
   DECLARE @message       nvarchar(max);

   DECLARE @traceId       int; 
   DECLARE @componentId   int;

   DECLARE @description   nvarchar(max);
   DECLARE @affectedrows  int;

   -- Curser variables
   DECLARE @c_schemaName            AS nvarchar(10);
   DECLARE @c_tableName             AS nvarchar(128);
   DECLARE @c_columnName            AS nvarchar(128);
   DECLARE @c_dataType              AS nvarchar(128);
   DECLARE @c_maxLength             AS int;
   DECLARE @c_precision             AS int;
   DECLARE @c_scale                 AS int;
   DECLARE @c_mandatory             AS bit;
   DECLARE @c_indexPrimaryKey       AS int;
   
   -- SQL variables        
   DECLARE @sqlInsert               AS nvarchar(max);
   DECLARE @sqlSelect               AS nvarchar(max);
   DECLARE @sql                     AS nvarchar(max);
   DECLARE @sqlHashField            AS nvarchar(max);
   DECLARE @sqlHashFields1          AS nvarchar(max);
   DECLARE @sqlHashFields2          AS nvarchar(max);
   DECLARE @sqlHashFields1Count     AS int;
   DECLARE @sqlHashFields2Count     AS int;

   -- --------------------------------------------------------------------------------
   -- SET variables
   -- --------------------------------------------------------------------------------

   -- SQL
   SET @sqlInsert           = N'';
   SET @sqlSelect           = N'';
   SET @sql                 = N'';   
   SET @sqlHashFields1      = N'';   
   SET @sqlHashFields2      = N'';   
   SET @sqlHashFields1Count = 0;   
   SET @sqlHashFields2Count = 0;   

   -- Logging
   SET @message        = NULL;
   SET @description    = NULL;
   SET @affectedrows   = 0;

   SET @component   = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source      = 'T-SQL';
   SET @componentId = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity         = '[' + @p_schemaName + '].[' + @p_tableName + ']';

   BEGIN TRY
      -- --------------------------------------------------------------------------------
      -- Check input parameters for integrity
      -- --------------------------------------------------------------------------------
      IF (@p_executionId IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_executionId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_schemaName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_schemaName'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_tableName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_tableName'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_referenceSchemaName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_referenceSchemaName'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;

      -- --------------------------------------------------------------------------------
      -- Start Component Log
      -- --------------------------------------------------------------------------------
      SET @step        = 'Calculate hash values';
      SET @description = '';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, NULL, @entity, @step, @description;
      
      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = 'Calculate hash values';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, 'Calculate', NULL, 'processing', 0;

      -- --------------------------------------------------------------------------------
      -- Do something
      -- --------------------------------------------------------------------------------
      -- Curser loops over all constraints in [CONFIG].[TableMetadata] for 
      --    [TableName] = @p_tableName
      -- --------------------------------------------------------------------------------
      DECLARE cursor_columnloop CURSOR LOCAL FOR

      SELECT 
          [SchemaName]
         ,[TableName]
         ,[ColumnName]
         ,[Datatype]
         ,[MaxLength]
         ,[Precision]
         ,[Scale]
         ,[IsNullable]
         ,[IndexPrimaryKey]
      FROM 
         [CONFIG].[TableMetadata]
      WHERE 
             [SchemaName] = @p_referenceSchemaName
         AND [TableName]  = @p_tableName
      ORDER BY
          [IndexPrimaryKey] ASC
         ,[ColumnName]      ASC;

      OPEN cursor_columnloop;

      FETCH NEXT FROM cursor_columnloop
      INTO 
          @c_schemaName
         ,@c_tableName
         ,@c_columnName
         ,@c_dataType
         ,@c_maxLength
         ,@c_precision
         ,@c_scale
         ,@c_mandatory
         ,@c_indexPrimaryKey;

      WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @c_indexPrimaryKey > 0
               BEGIN
                  IF LEN(@sqlHashFields1) > 0
                     BEGIN            
                        SET @sqlHashFields1 = @sqlHashFields1 + ', ''#'', ';
                     END;
                  SET @sqlHashFields1Count = @sqlHashFields1Count + 1;
                  SET @sqlHashFields1      = @sqlHashFields1 + N'COALESCE(CAST([' + @c_columnName +'] AS nvarchar(max))' + N', ''#'') ';
               END
            ELSE
               BEGIN
                  IF LEN(@sqlHashFields2) > 0
                     BEGIN            
                        SET @sqlHashFields2 = @sqlHashFields2 + ', ''#'', ';
                     END;
                  SET @sqlHashFields2      = @sqlHashFields2 + N'COALESCE(CAST([' + @c_columnName + '] AS nvarchar(max))' + N', ''#'')';
                  SET @sqlHashFields2Count = @sqlHashFields2Count + 1;
               END;

            FETCH NEXT FROM cursor_columnloop
            INTO 
                @c_schemaName
               ,@c_tableName
               ,@c_columnName
               ,@c_dataType
               ,@c_maxLength
               ,@c_precision
               ,@c_scale
               ,@c_mandatory
               ,@c_indexPrimaryKey;
         END;

      CLOSE cursor_columnloop;
      DEALLOCATE cursor_columnloop;

      -- --------------------------------------------------------------------------------
      -- Build SQL UPDATE statement
      -- --------------------------------------------------------------------------------
      SET @sql =        N'UPDATE ' + @p_schemaName + N'.' +@p_tableName + N' '                                  + CHAR(13);
      SET @sql = @sql + N'   SET '                                                                              + CHAR(13);

      IF LEN(@sqlHashFields1) > 0
         BEGIN
            IF @sqlHashFields1Count = 1
               BEGIN
                  -- --------------------------------------------------------------------------------
                  -- There is only one primary key column
                  -- --------------------------------------------------------------------------------
                  SET @sql = @sql + N'[SysHashPrimaryKey] = HASHBYTES(''SHA1'', ' + @sqlHashFields1 + N')'         + CHAR(13);
               END
            ELSE
               BEGIN
                  -- --------------------------------------------------------------------------------
                  -- There are multiple primary key columns
                  -- --------------------------------------------------------------------------------
                  SET @sql = @sql + N'[SysHashPrimaryKey] = HASHBYTES(''SHA1'', CONCAT(' + @sqlHashFields1 + N'))' + CHAR(13);
               END;            
         END;

      IF LEN(@sqlHashFields1) > 0 AND LEN(@sqlHashFields2) > 0
         BEGIN
            SET @sql = @sql + N', ';
         END;


      IF LEN(@sqlHashFields2) > 0
         BEGIN
            IF @sqlHashFields2Count = 1
               BEGIN
                  -- --------------------------------------------------------------------------------
                  -- There is only one attribute column
                  -- --------------------------------------------------------------------------------
                  SET @sql = @sql + N'[SysHashAttributes] = HASHBYTES(''SHA1'', ' + @sqlHashFields2 + N')'         + CHAR(13);
               END
            ELSE
               BEGIN
                  -- --------------------------------------------------------------------------------
                  -- There are multiple attribute columns
                  -- --------------------------------------------------------------------------------
                  SET @sql = @sql + N'[SysHashAttributes] = HASHBYTES(''SHA1'', CONCAT(' + @sqlHashFields2 + N'))' + CHAR(13);
               END;            
         END;

      SET @sql = @sql + N'WHERE ' ;
      SET @sql = @sql + N'      [SysError] IS NULL'                                                             + CHAR(13);
      SET @sql = @sql + N'   OR [SysError] = 0;'                                                                + CHAR(13);
      SET @sql = @sql + N'SET @affectedrows = @@ROWCOUNT;'

      -- PRINT @sql;

      -- --------------------------------------------------------------------------------
      -- Excecute dynamic SQL-Statment
      -- --------------------------------------------------------------------------------         
      EXEC [dbo].[sp_executesql] @sql, N'@affectedrows int OUT', @affectedrows OUT;

      -- --------------------------------------------------------------------------------
      -- End Trace Log
      -- --------------------------------------------------------------------------------
      SET @description = '';
      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Update', @affectedrows;
   
      -- --------------------------------------------------------------------------------
      -- End Component Log 
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateComponentSuccess1] @componentId;

   END TRY
   BEGIN CATCH
      SET @error_message = ERROR_MESSAGE();
      SET @error_number  = ERROR_NUMBER();
      SET @error_line    = ERROR_LINE();
      SET @error_state   = ERROR_STATE();

      -- --------------------------------------------------------------------------------
      -- Close and deallocate cursor
      -- --------------------------------------------------------------------------------
      IF (SELECT CURSOR_STATUS('local','cursor_columnloop')) >= -1
      BEGIN
         IF (SELECT CURSOR_STATUS('local','cursor_columnloop')) > -1
            BEGIN
               CLOSE cursor_columnloop;
            END
         DEALLOCATE cursor_columnloop;
      END;

      IF @p_executionId IS NOT NULL
         BEGIN
            EXEC [LOG].[spUpdateTraceError1] @traceid;
            EXEC [LOG].[spUpdateComponentError1] @componentid;
            EXEC [LOG].[spInsertError] @p_executionId, @componentid, @traceid, N'E', @source, @component, NULL, NULL, @step, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @error_number, @error_message, @error_line, @error_state;
         END;
      THROW;
      RETURN @error_number;
   END CATCH; 
END;
-- EXEC [T1].[spCalculateHashValues] 1, 'T1', 'Test'