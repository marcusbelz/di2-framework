-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates the fields [End], [User], [State], [Success]  in 
--              the table [Execution] with [ID] = @p_executionId.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       ID of the row in [Execution] to be updated.
--    @p_end                  AS datetime
--       Optional: Specifies the end date and time of the execution.
--    @p_state                AS nvarchar(128)   
--       State of the current task (processing, success, error, warning)
--    @p_success              AS bit
--       Specifies the success state of the execution
--       0 = @p_state > processing, warning, error
--       1 = @p_state > success, warning
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
CREATE PROCEDURE [LOG].[spUpdateExecution] 
    @p_executionId           AS int
   ,@p_end                   AS datetime
   ,@p_state                 AS nvarchar(128)
   ,@p_success               AS bit
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE @component                  AS nvarchar(128);

   DECLARE @tempuid                    AS int;
   DECLARE @message                    AS nvarchar(max);
   
   BEGIN TRY
      SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

      -- --------------------------------------------------------------------------------
      -- Check parameters
      -- --------------------------------------------------------------------------------
      IF (@p_executionId IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_executionId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;
      IF ([dbo].[fnIsNullOrEmpty](@p_state, 1) <> 0 )
         BEGIN
            SET @message = 'The parameter ''p_state'' is NULL or an empty string.';
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;
      IF (@p_success IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_success'' is NULL.';
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;

      IF (@p_success = 0 AND @p_state IN ('success')) OR (@p_success = 1 AND @p_state IN ('processing', 'error'))
         BEGIN
            SET @message = CONCAT('Invalid state ''', @p_state, ''' for p_success = ''', CAST(@p_success AS nvarchar(100)),'''.');
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;
   
      -- --------------------------------------------------------------------------------
      -- Check whether an execution log does exist in [LOG].[Execution] with 
      -- EXL_ID = @p_executionId
      -- --------------------------------------------------------------------------------
      SELECT 
          @tempuid = [ID]
      FROM 
         [LOG].[Execution] 
      WHERE 
         [ID] = @p_executionId; 

      IF (@tempuid IS NULL)
         BEGIN
            SET @message = 'A record with [ID] = ''' + CAST(@p_executionId AS nvarchar(max)) + ''' could not be found.';
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;

      -- --------------------------------------------------------------------------------
      -- Update execution log in [LOG].[Execution]
      -- --------------------------------------------------------------------------------
      UPDATE [LOG].[Execution]
         SET 
             [End]     = CASE WHEN @p_end IS NULL THEN [End] ELSE @p_end END
            ,[User]    = SYSTEM_USER
            ,[State]   = @p_state
            ,[Success] = @p_success
      WHERE 
         [ID] = @p_executionId;

      RETURN 0;
   END TRY
   BEGIN CATCH
      THROW;
   END CATCH; 
END
-- [LOG].[spUpdateExecution] 

-- EXEC [LOG].[spUpdateExecution] 1, @end, 'success', 1;
