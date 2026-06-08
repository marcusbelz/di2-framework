-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates the fields [State] and [Success] in [LOG].[Trace] for 
--              the row with [ID] = @p_traceId.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_traceId              AS int 
--       ID of the row in [LOG].[Trace], that is to be updated.
--   @p_description           AS nvarchar(max)
--       Additional description of the task in the calling object that will be logged
--    @p_action               AS nvarchar(max) = NULL
--       Specifiy any action that will be logged by this procedure call like Insert, Delete, Update, ...
--    @p_affectedRows         AS nvarchar(max) = NULL
--       Specifiy the number of rows/objects that were inserted, deleted, updated, ...
--    @p_state                AS nvarchar(100) 
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
CREATE PROCEDURE [LOG].[spUpdateTrace] 
    @p_traceId               AS int
   ,@p_description           AS nvarchar(max)
   ,@p_action                AS nvarchar(100) = NULL
   ,@p_affectedRows          AS int
   ,@p_state                 AS nvarchar(100)
   ,@p_success               AS bit
AS
BEGIN
   SET NOCOUNT ON;
   
   DECLARE @component        AS nvarchar(128);
   DECLARE @tempuid          AS int;
   DECLARE @message          AS nvarchar(max);
   
   BEGIN TRY
      SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

      -- --------------------------------------------------------------------------------
      -- Check @@p_traceId
      -- --------------------------------------------------------------------------------
      IF (@p_traceId IS NULL)
         BEGIN
            EXEC [dbo].[spRaiseError] 'The parameter ''p_traceid'' is NULL.', @component;
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
      IF (@p_success = 0 AND @p_state IN ('success')) OR (@p_success = 1 AND @p_state IN ('processing', 'error'))
         BEGIN
            SET @message = CONCAT('Invalid state ''', @p_state, ''' for p_success = ''', CAST(@p_success AS nvarchar(100)),'''.');
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;

      -- --------------------------------------------------------------------------------
      -- Check whether an trace log does exist in [LOG].[Trace] with 
      -- [ID] = @p_traceId
      -- --------------------------------------------------------------------------------
      SELECT 
          @tempuid = [ID]
      FROM 
         [LOG].[Trace] 
      WHERE 
         [ID] = @p_traceId;

      IF (@tempuid IS NULL)
         BEGIN
            SET @message = 'A record with [ID] = ''' + CAST(@p_traceId AS nvarchar(max)) + ''' could not be found.';
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;

      -- --------------------------------------------------------------------------------
      -- Update tarce log in [LOG].[Trace]
      -- --------------------------------------------------------------------------------
      UPDATE [LOG].[Trace]
         SET
             [Description]  = CASE WHEN (@p_description IS NULL OR DATALENGTH(@p_description) = 0) AND ([Description] IS NULL OR DATALENGTH([Description]) = 0) THEN NULL ELSE @p_description END
            ,[Action]       = @p_action
            ,[AffectedRows] = @p_affectedRows
            ,[State]        = @p_state
            ,[Success]      = @p_success
      WHERE 
         [ID] = @p_traceId;

      RETURN 0;         
   END TRY
   BEGIN CATCH
      THROW;
   END CATCH; 
END
-- [dbo].[spUpdateTrace] 

-- EXEC [LOG].[spUpdateTrace] 1, 'process successfully finished', 'Insert', 123, 'success', 1;