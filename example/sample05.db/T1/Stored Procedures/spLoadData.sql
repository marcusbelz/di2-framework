-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Load table from one schema to another and prepare the 
--              table for constraint data checks
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId           AS int
--       Execution ID of the current execution.
--    @p_sourceSchemaName      AS nvarchar(128)
--       Schema name of the source table.
--    @p_destinationSchemaName AS nvarchar(128) 
--       Schema name of the destination table.
--    @p_referenceSchemaName   AS nvarchar(128) 
--       Schema of the table, for which the column names to be included by this 
--       procedure are specified in table [CONFIG].[TableMetadata]
--    @p_tableName             AS nvarchar(128)
--       Name of the table in source and destination
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
CREATE PROCEDURE [T1].[spLoadData] 
(   
    @p_executionId           AS int
   ,@p_sourceSchemaName      AS nvarchar(128)
   ,@p_destinationSchemaName AS nvarchar(128)
   ,@p_referenceSchemaName   AS nvarchar(128)
   ,@p_tableName             AS nvarchar(128)
)
AS
BEGIN
   -- --------------------------------------------------------------------------------
   -- Declare all used variables
   -- --------------------------------------------------------------------------------

   -- Error Variables
   DECLARE @error_message           AS nvarchar(max);
   DECLARE @error_number            AS int;
   DECLARE @error_line              AS int;
   DECLARE @error_state             AS nvarchar(max);

   -- Logging Variables
   DECLARE @component               AS nvarchar(256);
   DECLARE @task                    AS nvarchar(128);
   DECLARE @schema                  AS nvarchar(128);
   DECLARE @table                   AS nvarchar(128);
   DECLARE @source                  AS nvarchar(5);
   DECLARE @step                    AS nvarchar(max);
   DECLARE @entity                  AS nvarchar(max);
   DECLARE @message                 AS nvarchar(max);
   DECLARE @traceid                 AS int; 
   DECLARE @componentid             AS int;
   DECLARE @description             AS nvarchar(max);
   DECLARE @affectedrows            AS int;

   -- Curser variables
   DECLARE @c_sourceSchemaName      AS nvarchar(10);
   DECLARE @c_destinationSchemaName AS nvarchar(10);
   DECLARE @c_tableName             AS nvarchar(128);
   DECLARE @c_columnName            AS nvarchar(128);
   DECLARE @c_columnName_Source     AS nvarchar(128);
   DECLARE @c_dataType              AS nvarchar(128);
   DECLARE @c_maxLength             AS int;
   DECLARE @c_precision             AS int;
   DECLARE @c_scale                 AS int;
   DECLARE @c_dateStyle             AS nvarchar(50);
   DECLARE @c_isNullable            AS bit;
   DECLARE @c_indexPrimaryKey       AS int;
   DECLARE @c_checkData             AS bit;
   DECLARE @c_decodeXML             AS bit;
   DECLARE @c_recordCount           AS int;

   -- SQL variables        
   DECLARE @SQLInsert               AS nvarchar(max);
   DECLARE @SQLSelect               AS nvarchar(max);
   DECLARE @SQL                     AS nvarchar(max);

   -- --------------------------------------------------------------------------------
   -- SET variables
   -- --------------------------------------------------------------------------------
   SET @SQLInsert    = N'';
   SET @SQLSelect    = N'';
   SET @SQL          = N'';   

   -- Logging
   SET @message        = NULL;
   SET @description    = NULL;
   SET @affectedrows   = 0;

   SET @component      = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source         = 'T-SQL';
   SET @componentid    = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity         = '[' + @p_destinationSchemaName + '].[' + @p_tableName + ']';
   
   SET @SQLInsert       = N'';
   SET @SQLSelect       = N'';

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
      IF [dbo].[fnIsNullOrEmpty](@p_sourceSchemaName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_sourceSchemaName'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_destinationSchemaName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_destinationSchemaName'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_referenceSchemaName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_referenceSchemaName'' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_tableName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_tableName '' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;

      -- --------------------------------------------------------------------------------
      -- Start Component Log
      -- --------------------------------------------------------------------------------
      SET @step        = 'Load data ' + @p_sourceSchemaName + '>' + @p_destinationSchemaName;
      SET @description = '';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentid OUTPUT, @source, @component, NULL, @entity, @step, @description;
      
      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = 'Load data ' + @p_sourceSchemaName + '>' + @p_destinationSchemaName;
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentid, @traceid OUTPUT, @source, @component, @task, @entity, @step, @description, 'Insert', NULL, 'processing', 0;

      -- --------------------------------------------------------------------------------
      -- Check whether metadata is available for the specified table
      -- --------------------------------------------------------------------------------
      SELECT 
         @c_recordCount = COUNT(*)
      FROM 
         [CONFIG].[TableMetadata]
      WHERE 
             [SchemaName] = @p_referenceSchemaName
         AND [TableName]  = @p_tableName;
      IF @c_recordCount = 0
         BEGIN
            SET @message = N'There is no metadata available for table ''[' + @p_referenceSchemaName + N'].[' + @p_tableName + ']''. Please check table [CONFIG].[TableMetadata].';
            EXEC [dbo].[spRaiseError] @message,  @component
            RETURN -1;
         END;

      -- --------------------------------------------------------------------------------
      -- Do something
      -- --------------------------------------------------------------------------------
      -- Curser loops over all columns for 
      --        [CONFIG].[TableMetadata].[SchemaName] = @p_referenceSchemaName
      --    AND [CONFIG].[TableMetadata].[TableName] = @p_tableName
      -- --------------------------------------------------------------------------------
      DECLARE cursor_columnloop CURSOR LOCAL FOR

      SELECT 
          @p_sourceSchemaName      AS [SourceSchemaName]
         ,@p_destinationSchemaName AS [DestinationSchemaName]
         ,[TableName]
         ,[ColumnName]
         ,[ColumnName] + N'_' + @p_sourceSchemaName
         ,[Datatype]
         ,[MaxLength]
         ,[Precision]
         ,[Scale]
         ,[IsNullable]
         ,[IndexPrimaryKey]
         ,[CheckData]
         ,[DecodeXML]
         ,[DateStyle]
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
          @c_sourceSchemaName
         ,@c_destinationSchemaName
         ,@c_tableName
         ,@c_columnName
         ,@c_columnName_Source
         ,@c_dataType
         ,@c_maxLength
         ,@c_precision
         ,@c_scale
         ,@c_isNullable
         ,@c_indexPrimaryKey
         ,@c_checkData
         ,@c_decodeXML
         ,@c_dateStyle;

      -- --------------------------------------------------------------------------------
      -- Create a dynamic SQL Statment for loading data from the source table to 
      -- destination table.
      -- --------------------------------------------------------------------------------
      WHILE @@FETCH_STATUS = 0
         BEGIN
            -- --------------------------------------------------------------------------------
            -- Check variables
            -- --------------------------------------------------------------------------------
            IF [dbo].[fnIsNullOrEmpty](@c_columnName , 1) = 1
               BEGIN
                  SET @message = N'The variable ''c_columnName'' is NULL or empty. Check table [CONFIG].[TableMetadata]';
                  EXEC [dbo].[spRaiseError] @message,  @component
                  RETURN -1;
               END;
            IF [dbo].[fnIsNullOrEmpty](@c_columnName_Source , 1) = 1
               BEGIN
                  SET @message = N'The variable ''c_columnName_Source'' is NULL or empty. Check table [CONFIG].[TableMetadata]';
                  EXEC [dbo].[spRaiseError] @message,  @component
                  RETURN -1;
               END;
            IF @c_dataType IN (N'date', N'datetime', N'datetime2')
               BEGIN
                  IF [dbo].[fnIsNullOrEmpty](@c_dateStyle , 1) = 1
                     BEGIN
                        SET @message = N'The variable ''c_dateStyle'' is NULL or empty. Check table [CONFIG].[TableMetadata] (columns [DateStyle] for column name ''' + @c_columnName + N''').';
                        EXEC [dbo].[spRaiseError] @message,  @component
                        RETURN -1;
                     END;
               END;
            IF @c_dataType IN (N'decimal', N'numeric')
               BEGIN
                  IF (@c_precision IS NULL) OR (@c_precision <= 0) OR (@c_scale IS NULL) OR (@c_scale < 0) OR (@c_precision <= @c_scale)
                     BEGIN
                        SET @message = N'The variables ''c_precision'' and/or ''c_scale'' are configured with inconsistent data. Check table [CONFIG].[TableMetadata] (columns [Precision]/[Scale] for column name ''' + @c_columnName + N''').';
                        EXEC [dbo].[spRaiseError] @message,  @component
                        RETURN -1;
                     END;
               END;
            IF @c_dataType LIKE N'%char'
               BEGIN
                  IF (@c_maxLength IS NULL) OR (@c_maxLength = 0) OR (@c_maxLength < -1) OR (@c_maxLength > 4000) 
                     BEGIN
                        SET @message = N'The variable ''c_maxLength'' are configured with inconsistent data. Check table [CONFIG].[TableMetadata] (columns [MaxLength] for column name ''' + @c_columnName + N''').';
                        EXEC [dbo].[spRaiseError] @message,  @component
                        RETURN -1;
                     END;
               END;


            -- --------------------------------------------------------------------------------
            -- Add a comma if required
            -- --------------------------------------------------------------------------------
            IF LEN(@SQLInsert) > 0
               BEGIN            
                  SET @SQLInsert = @SQLInsert + N', ';
                  SET @SQLSelect = @SQLSelect + N', ';
               END;

            -- --------------------------------------------------------------------------------
            -- Build column list for the INSERT statement
            -- --------------------------------------------------------------------------------
            -- Indicates, whether to load data additionally into a field with the same name 
            -- and an suffix _E1. This is required for checking purposes.
            -- --------------------------------------------------------------------------------
            IF @c_checkData = 1
               BEGIN
                  SET @SQLInsert = @SQLInsert + N'[' + @c_columnName_Source + N'], [' + @c_columnName + N']';
               END
            ELSE
               BEGIN
                  SET @SQLInsert = @SQLInsert + N'[' + @c_columnName + N']';
               END;

            IF @c_checkData = 1
               -- --------------------------------------------------------------------------------
               -- If @c_checkData = 1 then convert and load data into columns with the suffix _E1
               -- --------------------------------------------------------------------------------
               BEGIN
                  IF @c_dataType IN (N'tinyint', N'int', N'bigint', N'smallint')
                     BEGIN     
                        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName + N']  , TRY_CONVERT(' + @c_dataType + N', [' + @c_columnName + N'])';
                     END
                  ELSE IF @c_dataType = N'bit'
                     BEGIN
                        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , [dbo].[fnConvertBit]([' + @c_columnName + N'])';
                     END               
                  ELSE IF @c_dataType = N'date'
                     BEGIN
                        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , [dbo].[fnConvertDate]([' + @c_columnName + N'], ''' + @c_dateStyle + N''')';
                     END               
                  ELSE IF @c_dataType IN (N'datetime')
                     BEGIN
                        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , [dbo].[fnConvertDateTime]([' + @c_columnName + N'], ''' + @c_dateStyle + N''')';
                     END
                  ELSE IF @c_dataType IN (N'datetime2')
                     BEGIN
                        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , [dbo].[fnConvertDateTime2]([' + @c_columnName + N'], ''' + @c_dateStyle + N''')';
                     END
                  --ELSE IF @c_dataType = N'datetimeoffset'
                  --   BEGIN
                  --      SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , [dbo].[fnConvertDateTimeOffset]([' + @c_columnName + N'])';
                  --   END
                  ELSE IF @c_dataType IN (N'uniqueidentifier')
                     BEGIN
                        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , TRY_CONVERT(' + @c_dataType + N', [' + @c_columnName + N'])';
                     END
                  ELSE IF @c_dataType IN (N'decimal', N'numeric')
                     BEGIN
                        SET @SQLSelect = @SQLSelect + N'REPLACE([' + @c_columnName + N'], '','', ''.'') , TRY_CONVERT(' + @c_dataType + N'(' + CAST(@c_precision AS nvarchar(100)) + N',' + CAST(@c_scale AS nvarchar(max)) + N'), REPLACE([' + @c_columnName + N'], '','', ''.''))';
                     END
                  ELSE IF @c_dataType IN (N'float')
                     BEGIN
                        SET @SQLSelect = @SQLSelect + N'REPLACE([' + @c_columnName + N'], '','', ''.'') , TRY_CONVERT(' + @c_dataType + N', REPLACE([' + @c_columnName + N'], '','', ''.''))';
                     END
					   ELSE IF @c_decodeXML = 0
					      -- --------------------------------------------------------------------------------
					      -- This branch deals with character data types where no demasking of characters is 
					      -- required. Demasking applies to HTML/XML code.
					      -- --------------------------------------------------------------------------------
					      -- If @c_decodeXML = 0 then do not demask HTML/XML code.
					      -- --------------------------------------------------------------------------------
					      BEGIN
						      IF @c_dataType LIKE N'n%char'
							      BEGIN
								      IF @c_maxLength = -1
								         BEGIN
									         SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , CONVERT(' + @c_dataType + N'(max), [' + @c_columnName + N'])';
								         END
								      ELSE
									      BEGIN
									         SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , CONVERT(' + @c_dataType + N'(' + CAST(ISNULL((@c_maxLength), 4000) as nvarchar(10)) + N'), [' + @c_columnName + N'])';
									      END;                               
							       END
						      ELSE IF @c_dataType LIKE N'%char'
							      BEGIN
								      IF @c_maxLength = -1
								         BEGIN
									        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , CONVERT(' + @c_dataType + N'(max), [' + @c_columnName + N'])';
								         END
								      ELSE
								         BEGIN
									        SET @SQLSelect = @SQLSelect + N'[' + @c_columnName +  N'] , CONVERT(' + @c_dataType + N'(' + CAST(ISNULL((@c_maxLength), 4000) as nvarchar(10)) + N'), [' + @c_columnName + N'])';
								         END;                               
							      END;
						   END
					   ELSE IF @c_decodeXML = 1
					      -- --------------------------------------------------------------------------------
					      -- This branch deals with character data types where no demasking of characters is 
					      -- required. Demasking applies to HTML/XML code.
					      -- --------------------------------------------------------------------------------
					      -- If @c_decodeXML = 1 then demask HTML/XML code.
					      -- --------------------------------------------------------------------------------
					      BEGIN
						      IF @c_dataType LIKE N'n%char'
							      BEGIN
								      IF @c_maxLength = -1
								         BEGIN
									        SET @SQLSelect = @SQLSelect + N'[dbo].[fnDecodeXML]([' + @c_columnName +  N']) , [dbo].[fnDecodeXML](CONVERT(' + @c_dataType + N'(max), [' + @c_columnName + N']))';
								         END
								      ELSE
								         BEGIN
									        SET @SQLSelect = @SQLSelect + N'[dbo].[fnDecodeXML]([' + @c_columnName +  N']) , [dbo].[fnDecodeXML](CONVERT(' + @c_dataType + N'(' + CAST(ISNULL((@c_maxLength), 4000) as nvarchar(10)) + N'), [' + @c_columnName + N']))';
								         END;                               
							      END
						     ELSE IF @c_dataType LIKE N'%char'
							      BEGIN
								      IF @c_maxLength = -1
								         BEGIN
									        SET @SQLSelect = @SQLSelect + N'[dbo].[fnDecodeXML]([' + @c_columnName +  N']) , [dbo].[fnDecodeXML](CONVERT(' + @c_dataType + N'(max), [' + @c_columnName + N']))';
								         END
								      ELSE
								         BEGIN
									        SET @SQLSelect = @SQLSelect + N'[dbo].[fnDecodeXML]([' + @c_columnName +  N']) , [dbo].[fnDecodeXML](CONVERT(' + @c_dataType + N'(' + CAST(ISNULL((@c_maxLength), 4000) as nvarchar(10)) + N'), [' + @c_columnName + N']))';
								         END;                               
							      END;
					      END;
               END
            ELSE 
					-- --------------------------------------------------------------------------------
					-- Just select the original column if no data check is required
					-- --------------------------------------------------------------------------------
               BEGIN
                  SET @SQLSelect = @SQLSelect + N'[' + @c_columnName + N']';
               END;
            
            FETCH NEXT FROM cursor_columnloop
            INTO 
                @c_sourceSchemaName
               ,@c_destinationSchemaName
               ,@c_tableName
               ,@c_columnName
               ,@c_columnName_Source
               ,@c_dataType
               ,@c_maxLength
               ,@c_precision
               ,@c_scale
               ,@c_isNullable
               ,@c_indexPrimaryKey
               ,@c_checkData
               ,@c_decodeXML
               ,@c_dateStyle;
         END;

      CLOSE cursor_columnloop;
      DEALLOCATE cursor_columnloop;

      -- --------------------------------------------------------------------------------
      -- Build dynamic SQL-Statment
      -- --------------------------------------------------------------------------------
      SET @SQL = N'EXECUTE [dbo].[spTruncateTable] ''' + @p_destinationSchemaName + N''', ''' + @p_tableName + N''';';

      -- Insert Statement Clause
      SET @SQL = @SQL + N'INSERT INTO ['  + @p_destinationSchemaName + N'].[' +@p_tableName + N'] WITH (TABLOCKX) ';
      SET @SQL = @SQL + N'( ';
      SET @SQL = @SQL + @SQLInsert;
      SET @SQL = @SQL + N', [SysSource], [SysCreatedOn], [SysCreatedBy]';
      SET @SQL = @SQL + N')';

      -- Select Clause
      SET @SQL = @SQL + N'SELECT ';
      SET @SQL = @SQL + @SQLSelect 
      SET @SQL = @SQL + N', [SysSource], [SysCreatedOn], [SysCreatedBy] ';
      SET @SQL = @SQL + N' FROM [' + @p_sourceSchemaName + N'].[' +@p_tableName + N']; ';

      -- Set @affectedRows variable
      SET @SQL = @SQL + N'SET @affectedRows = @@ROWCOUNT;'

      PRINT @SQL;

      -- --------------------------------------------------------------------------------
      -- Excecute dynamic SQL-Statment
      -- --------------------------------------------------------------------------------         
      EXEC [dbo].[sp_executesql] @SQL, N'@affectedRows int OUT', @affectedrows OUT;
      --SELECT @affectedrows

      -- --------------------------------------------------------------------------------
      -- End Trace Log
      -- --------------------------------------------------------------------------------
      
      EXEC [LOG].[spUpdateTraceSuccess1] @traceid, N'Insert', @affectedrows;

      -- --------------------------------------------------------------------------------
      -- End Component Log
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateComponentSuccess1] @componentid;

   END TRY
   BEGIN CATCH
      SET @error_message = ERROR_MESSAGE();
      SET @error_number  = ERROR_NUMBER();
      SET @error_line    = ERROR_LINE();
      SET @error_state   = ERROR_STATE();

      -- --------------------------------------------------------------------------------
      -- Close and deallocate cursor
      -- --------------------------------------------------------------------------------
      IF (SELECT CURSOR_STATUS('local', 'cursor_columnloop')) >= -1
      BEGIN
         IF (SELECT CURSOR_STATUS('local', 'cursor_columnloop')) > -1
            BEGIN
               CLOSE cursor_columnloop;
            END
         DEALLOCATE cursor_columnloop;
      END;

      -- Write in Logging
      IF @p_executionId IS NOT NULL
         BEGIN
            EXEC [LOG].[spUpdateTraceError1] @traceid;
            EXEC [LOG].[spUpdateComponentError1] @componentid;
            EXEC [LOG].[spInsertError] @p_executionId, @componentid, @traceid, N'E', @source, @component, NULL, NULL, @step, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @error_number, @error_message, @error_line, @error_state;
         END;
      THROW;
      RETURN @error_number;
   END CATCH; 

END
-- EXEC [T1].[spLoadData] 1, N'E1', N'T1', N'T2', N'Test'

