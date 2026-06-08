-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Wrapper for doing two checks: unknown/missing
--              This wrapper can be used in many ways: eg. after looking up a value 
--              or trying to convert a text to a date or integer value.
-- --------------------------------------------------------------------------------
-- Parameters
--    @p_executionId          AS int
--       Execution ID
--    @p_componentId          AS int
--       Component ID the error message is related to.
--       Note: 
--          Tthis procedures logs the component id that was passed to this procedure 
--          and not the componentid of this procedure call (@componentId). This is, 
--          to enable a clean error count in the calling procedure/object.
--    @p_traceId              AS int
--       Trace ID the error message is related to.
--    @p_entity               AS nvarchar(128)
--       Trace ID the error message is related to.
--    @p_step                 AS nvarchar(max)
--       Describe the step, that invokes this procedure call.
--    @p_affectedRows         AS int OUT
--       Returns the number of log entries.
--    @p_constraint           AS nvarchar(max) = NULL
--       WHERE clause that will be checked. 
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
CREATE PROCEDURE [LOG].[spInsertErrorCheckLookup]
    @p_executionId           AS int
   ,@p_componentId           AS int
   ,@p_traceId               AS int
   ,@p_entity                AS nvarchar(128)
   ,@p_step                  AS nvarchar(max)
   ,@p_affectedRows          AS int OUT
   ,@p_constraint            AS nvarchar(max) = NULL
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

   DECLARE @id1_field        AS nvarchar(128);
   DECLARE @id2_field        AS nvarchar(128);
   DECLARE @id3_field        AS nvarchar(128);
   DECLARE @check_src        AS nvarchar(128);
   DECLARE @check_dst        AS nvarchar(128);
   DECLARE @constraint       AS nvarchar(256);
   DECLARE @errortype        AS char(1);

   SET @p_affectedRows = 0;

   SET @id1_field      = NULL;
   SET @id2_field      = NULL;
   SET @id3_field      = NULL;
   SET @message        = NULL;
   SET @description    = NULL;
   SET @affectedrows   = 0;

   SET @component   = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source      = 'T-SQL';
   SET @componentId      = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity      = '<target table>';

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
               EXEC [dbo].[spRaiseError] @message,  @component;
               RETURN -1;
            END;
         -- --------------------------------------------------------------------------------
         -- Check @p_componentId
         -- --------------------------------------------------------------------------------
         IF (@p_componentId IS NULL)
            BEGIN
               SET @message = 'The parameter ''p_componentId'' is NULL.';
               EXEC [dbo].[spRaiseError] @message,  @component;
               RETURN -1;
            END;
         -- --------------------------------------------------------------------------------
         -- Check @p_executionId
         -- --------------------------------------------------------------------------------
         IF [dbo].[fnIsNullOrEmpty](@p_entity, 1) = 1
            BEGIN
               SET @message = 'The parameter ''p_entity'' is NULL or empty.';
               EXEC [dbo].[spRaiseError] @message,  @component;
               RETURN -1;
            END
         ELSE
            BEGIN
               SET @entity = LTRIM(RTRIM(@p_entity));
            END;
      END;

      -- --------------------------------------------------------------------------------
      -- start
      -- --------------------------------------------------------------------------------
      SET @step        = 'Check Lookup Values...';
      SET @entity      = @p_entity;
      SET @description = NULL;
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, @entity, @step, @description, 'processing', 0;

      -- --------------------------------------------------------------------------------
      -- Check lookup missing
      -- --------------------------------------------------------------------------------
      BEGIN
         SET @check_src     = 'I_SRC';
         SET @check_dst     = 'I_DST';
         SET @step          = 'Check missing: ' + @check_src; 
         SET @constraint    = @check_src + ' IS NULL';
         IF [dbo].[fnIsNullOrEmpty](@p_constraint, 1) = 0
            BEGIN
               SET @constraint = @constraint + ' AND (' + @p_constraint + ')';
            END;
         SET @schema        = 'dbo';
         SET @table         = 'TEST';
         SET @errortype     = 'I'; -- Check, whether you can read the type from a CONFIG-Table
         SET @message       = 'Missing lookup.'
         SET @task          = NULL;
         SET @id1_field     = 'ID';
         SET @id2_field     = NULL;
         SET @id3_field     = NULL;
         IF @errortype IS NOT NULL
            BEGIN
               EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, 'processing', 0;
               EXEC [LOG].[spInsertErrorCheckConstraint] @p_executionId, @p_componentId, @p_traceId, @errortype, @component, @task, @entity, @step, @schema, @table, @id1_field, @id2_field, @id3_field, @check_src, @message, @affectedrows OUTPUT, @constraint;
               SET @description = 'Number of rows: ' + CAST(@affectedrows as nvarchar(max));
               EXEC [LOG].[spUpdateTrace] @traceId, 'success', @description, 1;
               SET  @p_affectedRows =  @p_affectedRows + @affectedrows;
            END;
      END;
   
      -- --------------------------------------------------------------------------------
      -- Check lookup unknown
      -- --------------------------------------------------------------------------------
      BEGIN
         SET @check_src     = 'I_SRC';
         SET @check_dst     = 'I_DST';
         SET @step          = 'Check unknown: ' + @check_src + '/' + @check_dst; 
         SET @constraint    = @check_src + ' IS NOT NULL AND ' + @check_dst + ' IS NULL';
         IF [dbo].[fnIsNullOrEmpty](@p_constraint, 1) = 0
            BEGIN
               SET @constraint = @constraint + ' AND (' + @p_constraint + ')';
            END;
         SET @schema        = 'dbo';
         SET @table         = 'TEST';
         SET @errortype     = 'E'; -- Check, whether you can read the type from a CONFIG-Table
         SET @message       = 'Unknown lookup.'
         SET @task          = NULL;
         SET @id1_field     = 'ID';
         SET @id2_field     = NULL;
         SET @id3_field     = NULL;
         IF @errortype IS NOT NULL
            BEGIN
               EXEC [LOG].[spInsertTrace]  @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, 'processing', 0;
               EXEC [LOG].[spInsertErrorCheckConstraint] @p_executionId, @p_componentId, @p_traceId, @errortype, @component, @task, @entity, @step, @schema, @table, @id1_field, @id2_field, @id3_field, @check_src, @message, @affectedrows OUTPUT, @constraint;
               SET @description = 'Number of rows: ' + CAST(@affectedrows as nvarchar(max));
               EXEC [LOG].[spUpdateTrace] @traceId, 'success', @description, 1;
               SET  @p_affectedRows =  @p_affectedRows + @affectedrows;
            END;
      END;

      -- --------------------------------------------------------------------------------
      -- end
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateComponentSuccess1] @componentId;

      RETURN 0;
   END TRY
   BEGIN CATCH
      SET @error_message = ERROR_MESSAGE();
      SET @error_number  = ERROR_NUMBER();
      SET @error_line    = ERROR_LINE();
      SET @error_state   = ERROR_STATE();

      IF @p_executionId IS NOT NULL
         BEGIN
            EXEC [LOG].[spUpdateTraceError1] @traceId;
            EXEC [LOG].[spUpdateComponentError1] @componentId;
            EXEC [LOG].[spInsertError]  @p_executionId, 'E', @source, @component, NULL, @traceId, NULL, @step, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @error_number, @error_message, @error_line, @error_state;
         END;
      THROW;
      RETURN @error_number;
   END CATCH; 
END;
-- [LOG].[spInsertErrorCheckLookup]
