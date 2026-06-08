-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Insert a row into the table [LOG].[Execu tion] with 
--                [state]   = 'processing'
--                [success] = 0
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int OUT
--       Returns the ID of the new row in [LOG].[Execution].
--    @p_process              AS nvarchar(max)   
--       Name of the execution process.
--    @p_machine              AS nvarchar(128)
--       Optional: Server Name (System::MachineName)
--    @p_instance             AS nvarchar(50)
--       Optional: Instance SSIS GUID (System::ExecutionInstanceGUID)
--    @p_versionBuild         AS int
--       Optional: SSIS Version Build Number of the starting package (Package::VersionBuild)
--    @p_deltaStart           AS datetime = NULL
--       Period of delta load (start)
--    @p_deltaEnd             AS datetime = NULL
--       Period of delta load (start)
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
CREATE PROCEDURE [LOG].[spInsertExecution] 
    @p_executionId           AS int OUT
   ,@p_process               AS nvarchar(max)
   ,@p_machine               AS nvarchar(128)
   ,@p_instance              AS nvarchar(50)
   ,@p_versionBuild          AS int
   ,@p_deltaStart            AS datetime = NULL
   ,@p_deltaEnd              AS datetime = NULL
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE @component        AS nvarchar(128);
   DECLARE @start            AS datetime;
   DECLARE @tempid           AS int;
   DECLARE @message          AS nvarchar(max);   
   DECLARE @table            AS table([ID] int);

   BEGIN TRY
      SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
      SET @start     = GETUTCDATE();

      -- --------------------------------------------------------------------------------
      -- Insert execution log into EXL_EXECUTIONLOG
      -- --------------------------------------------------------------------------------
      INSERT INTO [LOG].[Execution]
      (
          [Process]
         ,[Start]
         ,[End]
         ,[DeltaStart]
         ,[DeltaEnd]
         ,[User]
         ,[Machine]
         ,[Instance]
         ,[VersionBuild]
         ,[State]
         ,[Success]
      )
      OUTPUT Inserted.ID INTO @table
      VALUES
      (
          @p_process
         ,@start
         ,NULL
         ,@p_deltaStart
         ,@p_deltaEnd
         ,SYSTEM_USER
         ,@p_machine
         ,@p_instance
         ,@p_versionBuild
         ,'processing'
         ,0
      )
      SELECT @p_executionId = [ID] FROM @table;
 
      RETURN 0;
   END TRY
   BEGIN CATCH
      THROW;
   END CATCH; 
END
-- [LOG].[spInsertExecution] 
--DECLARE @executionId   AS int;
--EXEC [LOG].[spInsertExecution] @executionId OUTPUT, 'process name', 'Machine Name', 'Instance Name', 123, N'2018-01-01', N'2018-02-01';
--SELECT * FROM [LOG].[Execution]