-- --------------------------------------------------------------------------------
-- Author         : Marcus Belz
-- Create date    : 21.02.2017
-- Description    : Perform data/constraint checks on table
-- Acknowledgement: Initially created by Andy Saile
-- --------------------------------------------------------------------------------
-- Parameters
--    @p_executionId          AS int 
--       ID of the current execution ([LOG].[Execution])
--    @p_schemaName           AS nvarchar(128)
--       Schema name of the table, where to check the data
--       > typically T1
--    @p_tableName            AS nvarchar(128)
--       Table name of the table, where to check the data
--    @p_referenceSchemaName  AS nvarchar(128)
--       Schema name of the table, that specifiies the target datatypes 
--       > typically T2
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
CREATE procedure [T1].[spCheckData] 
(   
    @p_executionId           AS int
   ,@p_schemaName            AS nvarchar(128)
   ,@p_tableName             AS nvarchar(128)
   ,@p_referenceSchemaName   AS nvarchar(128)
)

WITH EXECUTE AS OWNER

AS
BEGIN

   -- --------------------------------------------------------------------------------
   -- Declare all used variables
   -- --------------------------------------------------------------------------------

   -- Error Variables
   DECLARE @error_message    AS nvarchar(max);
   DECLARE @error_number     AS int;
   DECLARE @error_line       AS int;
   DECLARE @error_state      AS nvarchar(max);

   -- Logging Variables
   DECLARE @component        AS nvarchar(256);
   DECLARE @task             AS nvarchar(128);
   DECLARE @schema           AS nvarchar(128);
   DECLARE @table            AS nvarchar(128);
   DECLARE @source           AS nvarchar(5);
   DECLARE @step             AS nvarchar(max);
   DECLARE @entity           AS nvarchar(max);
   DECLARE @message          AS nvarchar(max);
   DECLARE @traceId_loop     AS int;
   DECLARE @traceId          AS int; 
   DECLARE @componentId      AS int;
   DECLARE @description      AS nvarchar(max);
   DECLARE @affectedrows     AS int;
                                
   -- Curser variables          
   DECLARE @c_procedure      AS nvarchar(128);
   DECLARE @c_schema         AS nvarchar(128);
   DECLARE @c_table          AS nvarchar(128);
   DECLARE @c_check_Field    AS nvarchar(1000);
   DECLARE @c_step           AS nvarchar(max);
   DECLARE @c_constraint     AS nvarchar(256);
   DECLARE @c_entity         AS nvarchar(max);
   DECLARE @c_errorType      AS char(1);
   DECLARE @c_message        AS nvarchar(max);
   DECLARE @c_task           AS nvarchar(128);
   DECLARE @c_id1_Field      AS nvarchar(128);
   DECLARE @c_id2_Field      AS nvarchar(128);
   DECLARE @c_id3_Field      AS nvarchar(128);
   DECLARE @c_description    AS nvarchar(max);
   DECLARE @c_activeFlag     AS bit;
   DECLARE @c_manualFlag     AS bit;
   DECLARE @c_maxOccurance   AS int;
                                
   -- Check variables           
   DECLARE @id1_field           AS nvarchar(128);
   DECLARE @id2_field           AS nvarchar(128);
   DECLARE @id3_field           AS nvarchar(128);
   DECLARE @check_src           AS nvarchar(1000);
   DECLARE @check_src_UniqueID  AS nvarchar(1000);
   DECLARE @constraint          AS nvarchar(256);
   DECLARE @errortype           AS char(1);
   DECLARE @length              AS int;

   DECLARE @maxOccurance        AS int;
   DECLARE @whereClause         AS nvarchar(max);

   DECLARE @numberOfE           AS int;
   DECLARE @numberOfW           AS int;
   DECLARE @numberOfI           AS int;

   -- --------------------------------------------------------------------------------
   -- SET variables
   -- --------------------------------------------------------------------------------
   -- Logging
   SET @message        = NULL;
   SET @description    = NULL;
   SET @affectedrows   = 0;

   SET @component      = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source         = 'T-SQL';
   SET @componentId    = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity         = '[' + @p_schemaName + '].[' + @p_tableName + ']';

   -- Check variables
   SET @maxOccurance   = 1;
   SET @whereClause    = NULL;

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
            SET @message = 'The parameter ''p_tableSchema '' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_tableName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_tableName '' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;
         
      -- --------------------------------------------------------------------------------
      -- Start Component Log
      -- --------------------------------------------------------------------------------
      SET @step        = 'Check constraints';
      SET @description = '';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, NULL, @entity, @step, @description;
      
      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = 'Check constraints';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, 'Check', NULL, 'processing', 0;

      -- --------------------------------------------------------------------------------
      -- Start Procedure Logic
      -- --------------------------------------------------------------------------------
      SET @schema = NULL;
      -- --------------------------------------------------------------------------------
      -- Do something
      -- --------------------------------------------------------------------------------
      -- Curser loops over all constraints in [CONFIG].[CheckConfiguration] for 
     --    [TableName] = @p_tableName
      -- --------------------------------------------------------------------------------
      DECLARE cursor_constraintloop CURSOR LOCAL FOR

      SELECT 
          [ProcedureName]
         ,[SchemaName]
         ,[TableName]
         ,[Check_FieldName]
         ,[Step]
         ,[Constraint]
         ,[Entity]
         ,[ErrorType]
         ,[Message]
         ,[Task]
         ,[Id1_FieldName]
         ,[Id2_FieldName]
         ,[Id3_FieldName]  
         ,[MaxOccurance]  
         ,[Description]
         ,[ActiveFlag]
         ,[ManualFlag]
      FROM 
         [CONFIG].[CheckConstraint]
      WHERE 
             [SchemaName] = @p_schemaName
         AND [TableName]  = @p_tableName
         AND [ActiveFlag] = 1;

      OPEN cursor_constraintloop;

      FETCH NEXT FROM cursor_constraintloop
      INTO 
          @c_procedure
         ,@c_schema
         ,@c_table
         ,@c_check_Field
         ,@c_step
         ,@c_constraint
         ,@c_entity
         ,@c_errorType
         ,@c_message
         ,@c_task
         ,@c_id1_Field
         ,@c_id2_Field
         ,@c_id3_Field
         ,@c_maxOccurance
         ,@c_description
         ,@c_activeFlag
         ,@c_manualFlag;

      WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @schema             = @c_schema;
            SET @table              = @c_table;
            SET @check_src_UniqueID = @c_check_Field;
            SET @constraint         = @c_constraint;
            SET @entity             = @c_entity;
            SET @errortype          = @c_errorType;
            SET @message            = @c_message;
            SET @task               = @c_task;
            SET @id1_field          = @c_id1_Field;
            SET @id2_field          = @c_id2_Field;
            SET @id3_field          = @c_id3_Field;
            SET @description        = @c_description;
            SET @check_src          = @c_check_Field + '_E1';
            SET @maxOccurance       = CASE WHEN @c_maxOccurance IS NULL THEN 1 ELSE @c_maxOccurance END;

            IF LOWER(@c_procedure) = LOWER(N'spInsertErrorCheckConstraint')
               BEGIN
                  SELECT                                                                                      -- Replace @@@ in @constraint for datatype LIKE '%char'
                     @constraint = CASE WHEN [Datatype] LIKE '%char'                                          -- 
                                      THEN REPLACE(@constraint, '@@@', CAST([MaxLength] * 2 AS nvarchar(10))) -- [MaxLength] * 2 because check is for DATALENGTH() not LEN()
                                      ELSE @constraint                                                        --
                                   END                                                                        --
                  FROM                                                                                        --
                     [CONFIG].[TableMetadata]                                                                 --
                  WHERE                                                                                       --
                         [SchemaName] = @p_referenceSchemaName                                                --
                     AND [TableName]  = @p_tableName                                                          --
                     AND [ColumnName] = @c_check_Field;                                                       --

                  SET @step      = @c_step + ': ' + REPLACE(@constraint, '''', '''''');                       -- 

                  -- Execute constraint check
                  IF @errortype IS NOT NULL
                     BEGIN
                        EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId_loop OUTPUT, @source, @component, @task, @entity, @step, @description, 'Check', NULL, 'processing', 0;
                        EXEC [LOG].[spInsertErrorCheckConstraint] @p_executionId, @componentId, @traceId, @errortype, @component, @task, @entity, @step, @schema, @table, @id1_field, @id2_field, @id3_field, @check_src, @message, @affectedrows OUTPUT, @constraint;
                        EXEC [LOG].[spUpdateTraceSuccess] @traceId_loop, NULL, 'Check', @affectedrows;
                     END;
               END         
            ELSE IF LOWER(@c_procedure) = LOWER(N'spInsertErrorCheckUniqueIdColumns')
               BEGIN
                  SET @step = @c_step + ': [Max ' + CAST(@maxOccurance AS nvarchar(max))  +'] ' + @c_check_Field;

                  -- Execute unique id columns check   
                  IF @errortype IS NOT NULL
                     BEGIN
                        EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId_loop OUTPUT, @source, @component, @task, @entity, @step, @description, 'Check', NULL, 'processing', 0;
                        EXEC [LOG].[spInsertErrorCheckUniqueIdColumns] @p_executionId, @componentId, @traceId, @errortype, @component, @task, @entity, @step, @schema, @table, @id1_field, @id2_field, @id3_field, @check_src_UniqueID, @maxOccurance, @message, @affectedrows OUTPUT, @whereClause;
                        EXEC [LOG].[spUpdateTraceSuccess] @traceId_loop, NULL, 'Check', @affectedrows;
                     END;
               END;

            -- Fetch next row of cursor
            FETCH NEXT FROM cursor_constraintloop
            INTO 
                @c_procedure
               ,@c_schema
               ,@c_table
               ,@c_check_Field
               ,@c_step
               ,@c_constraint
               ,@c_entity
               ,@c_errorType
               ,@c_message
               ,@c_task
               ,@c_id1_Field
               ,@c_id2_Field
               ,@c_id3_Field
               ,@c_maxOccurance
               ,@c_description
               ,@c_activeFlag
               ,@c_manualFlag;
         END;

      CLOSE cursor_constraintloop;
      DEALLOCATE cursor_constraintloop;

      -- --------------------------------------------------------------------------------
      -- Update columns [SysError] & [SysWarning] in SourceTable
      -- --------------------------------------------------------------------------------
      IF @schema IS NOT NULL
         BEGIN      
            SET @step = 'Count rows with errors and warnings';
            EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId_loop OUTPUT, @source, @component, @task, @entity, @step, @description, NULL, NULL, 'processing', 0;
            EXEC [T1].[spUpdateDatasetError] @p_executionId, @schema, @table, @id1_field, @id2_field, @id3_field, @numberOfE OUT, @numberOfW OUT, @numberOfI OUT;
            SET @description = 'E=' + CAST(@numberOfE AS nvarchar(max)) + '; W=' + CAST(@numberOfW AS nvarchar(max));
            EXEC [LOG].[spUpdateTrace] @traceId_loop, @description, NULL, NULL, 'success', 1;      
         END;
   
      -- --------------------------------------------------------------------------------
      -- End Trace Log
      -- --------------------------------------------------------------------------------
      SET @description = '';
      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Check', NULL;
   
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
      IF (SELECT CURSOR_STATUS('local','cursor_constraintloop')) >= -1
         BEGIN
            IF (SELECT CURSOR_STATUS('local','cursor_constraintloop')) > -1
               BEGIN
                  CLOSE cursor_constraintloop;
               END
            DEALLOCATE cursor_constraintloop;
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
-- [T1].[spCheckData] 

-- EXEC [T1].[spCheckData]  1, N'T1', N'Test'