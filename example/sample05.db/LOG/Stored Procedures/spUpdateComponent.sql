-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates the fields [State] and [Success] in [LOG].[Component] for 
--              the row with [ID] = @p_componentId.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_componentId          AS int
--       ID of the row in [LOG].[Component], that is to be updated.
--    @p_description          AS nvarchar(max)
--       Additional description of the task in the calling object that will be logged
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
CREATE PROCEDURE [LOG].[spUpdateComponent] 
    @p_componentId           AS int
   ,@p_description           AS nvarchar(max)
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
      -- Check parameters
      -- --------------------------------------------------------------------------------
      IF (@p_componentId IS NULL)
         BEGIN
            EXEC [dbo].[spRaiseError] 'The parameter ''p_componentId'' is NULL.', @component;
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
      IF (@p_success = 0 AND @p_state IN ('success')) OR (@p_success = 1 AND @p_state IN ('processing', 'error'))
         BEGIN
            SET @message = CONCAT('Invalid state ''', @p_state, ''' for p_success = ''', CAST(@p_success AS nvarchar(100)),'''.');
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;

      -- --------------------------------------------------------------------------------
      -- Check whether an Component log does exist in [LOG].[Component] with 
      -- [ID] = @p_componentId
      -- --------------------------------------------------------------------------------
      SELECT 
          @tempuid = [ID]
      FROM 
         [LOG].[Component] 
      WHERE 
         [ID] = @p_componentId;

      IF (@tempuid IS NULL)
         BEGIN
            SET @message = 'A record with [ID] = ''' + CAST(@p_componentId AS nvarchar(max)) + ''' could not be found.';
            EXEC [dbo].[spRaiseError] @message, @component;
            RETURN 1;
         END;

      -- --------------------------------------------------------------------------------
      -- Update tarce log in [LOG].[Component]
      -- --------------------------------------------------------------------------------
      UPDATE [LOG].[Component]
         SET
             [State]       = @p_state
            ,[Description] = CASE WHEN @p_description IS NULL THEN [Description] ELSE @p_description END
            ,[Success]     = @p_success
      WHERE 
         [ID] = @p_componentId;

      RETURN 0;
   END TRY
   BEGIN CATCH
      THROW;
   END CATCH; 
END
-- [LOG].[spUpdateComponent] 

-- EXEC [LOG].[spUpdateComponent] 1, 'process successfully finished', 'success', 1;