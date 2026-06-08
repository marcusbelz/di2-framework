-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 30.09.2019
-- Description: Writes the configuration to the trace log
--              
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       Execution ID of the current execution
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 : error
--    = 0 : success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20190916 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [T1].[spCheckData_WriteConfiguration]
(   
    @p_executionId           AS int
)
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

   -- Configuation
   DECLARE @ThresholdIndicator2             AS integer;
   DECLARE @ThresholdPer10Seconds           AS integer;
   DECLARE @ThresholdIndicator1             AS integer;
   DECLARE @ThresholdRequestsByIPAddress    AS integer;
   DECLARE @ThresholdRequestsByEmailAddress AS integer;
   DECLARE @traceConfigId                   AS int; 

   -- --------------------------------------------------------------------------------
   -- SET variables
   -- --------------------------------------------------------------------------------

   -- Logging
   SET @message          = NULL;
   SET @description      = NULL;
   SET @affectedrows     = 0;

   SET @component        = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source           = N'T-SQL';
   SET @componentId      = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity           = N'[T1].[Test]';

   -- --------------------------------------------------------------------------------
   -- Start TRY
   -- --------------------------------------------------------------------------------
   BEGIN TRY

      -- --------------------------------------------------------------------------------
      -- Check input parameters for integrity
      -- --------------------------------------------------------------------------------
      IF (@p_executionId IS NULL)
         BEGIN
            SET @message = N'The parameter ''p_executionId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;

      -- --------------------------------------------------------------------------------
      -- Start Component Log
      -- --------------------------------------------------------------------------------
      SET @step        = N'Get Configuration';
      SET @description = N'';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, NULL, @entity, @step, @description;
      
      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = N'Get Configuration';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      SELECT @ThresholdIndicator1             = [Value] FROM [CONFIG].[Configuration] WHERE [Group] = 'BotCodeCheck' AND [Code] = 'ThresholdIndicator1';
      SET @description = N'[BotCodeCheck].[ThresholdIndicator1] = ' + CAST(@ThresholdIndicator1 AS nvarchar(max));
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceConfigId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      SELECT @ThresholdIndicator2             = [Value] FROM [CONFIG].[Configuration] WHERE [Group] = 'BotCodeCheck' AND [Code] = 'ThresholdIndicator2';
      SET @description = N'[BotCodeCheck].[ThresholdIndicator2] = ' + CAST(@ThresholdIndicator2 AS nvarchar(max));
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceConfigId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      SELECT @ThresholdPer10Seconds           = [Value] FROM [CONFIG].[Configuration] WHERE [Group] = 'BotCodeCheck' AND [Code] = 'ThresholdPer10Seconds';
      SET @description = N'[BotCodeCheck].[ThresholdPer10Seconds] = ' + CAST(@ThresholdPer10Seconds AS nvarchar(max));
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceConfigId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      SELECT @ThresholdRequestsByIPAddress    = [Value] FROM [CONFIG].[Configuration] WHERE [Group] = 'BotCodeCheck' AND [Code] = 'ThresholdRequestsByIPAddress';
      SET @description = N'[BotCodeCheck].[ThresholdRequestsByEmailAddress] = ' + CAST(@ThresholdRequestsByEmailAddress AS nvarchar(max));
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceConfigId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      SELECT @ThresholdRequestsByEmailAddress = [Value] FROM [CONFIG].[Configuration] WHERE [Group] = 'BotCodeCheck' AND [Code] = 'ThresholdRequestsByEmailAddress';
      SET @description = N'[BotCodeCheck].[ThresholdRequestsByIPAddress] = ' + CAST(@ThresholdRequestsByIPAddress AS nvarchar(max));
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceConfigId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Config', NULL;

      -- --------------------------------------------------------------------------------
      -- End Component Log 
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateComponentSuccess1] @componentId;

      -- --------------------------------------------------------------------------------
      -- Catch Errors
      -- --------------------------------------------------------------------------------
   END TRY
   BEGIN CATCH
      SET @error_message = ERROR_MESSAGE();
      SET @error_number  = ERROR_NUMBER();
      SET @error_line    = ERROR_LINE();
      SET @error_state   = ERROR_STATE();

      -- Write in Logging
      IF @p_executionId IS NOT NULL
         BEGIN
            EXEC [LOG].[spUpdateTraceError1] @traceId;
            EXEC [LOG].[spUpdateComponentError1] @componentId;
            EXEC [LOG].[spInsertError] @p_executionId, @componentid, @traceId, N'E', @source, @component, NULL, NULL, @step, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @error_number, @error_message, @error_line, @error_state;
         END;
      THROW;
      RETURN @error_number;
   END CATCH; 
END
-- [T1].[spCheckData_WriteConfiguration]

-- EXEC [T1].[spCheckData_WriteConfiguration] 33;