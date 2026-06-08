-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 30.09.2019
-- Description: Counts findings in records and updates counter fields with number 
--              of ocurrances
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
CREATE PROCEDURE [T1].[spCountFindings]
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
   DECLARE @traceConfigId    AS int; 
   DECLARE @componentId      AS int;

   DECLARE @description      AS nvarchar(max);
   DECLARE @affectedrows     AS int;

   -- Configuation
   DECLARE @config_DateCreated_Period       AS int;
   DECLARE @config_DateModified_Period      AS int;
      
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
   SET @entity           = N'[T2].[Test]';

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
      SET @step        = N'Load data T1>T2';
      SET @description = N'';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, NULL, @entity, @step, @description;
      
      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = N'Get Configuration';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      SELECT @config_DateCreated_Period  = CAST([CONFIG].[fnFetchConfigValue]('CheckBotCode', 'DateCreated Period' ) AS int);
      SET @description = N'[CheckBotCode].[DateCreated Period] = ' + CAST(@config_DateCreated_Period AS nvarchar(max));
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceConfigId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      SELECT @config_DateModified_Period = CAST([CONFIG].[fnFetchConfigValue]('CheckBotCode', 'DateModified Period') AS int);
      SET @description = N'[CheckBotCode].[DateModified Period] = ' + CAST(@config_DateModified_Period AS nvarchar(max));
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceConfigId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Config', NULL, N'processing', 0;

      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Config', NULL;

      -- --------------------------------------------------------------------------------
      -- Count keywords by keyword, field and row
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = N'Count keywords';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Count', NULL, N'processing', 0;

      INSERT INTO [sec].[BotCodeKeywordCounter] WITH (TABLOCKX)
      (
          [ExecutionID]
         ,[ID]
         ,[Keyword]
         ,[Count]
      )
      SELECT --TOP 100
          @p_executionId
         ,[ID]
         ,[Keyword]
         ,[Salutation_Count] + [FirstName_Count] + [LastName_Count] + [Field1_Count] + [Field2_Count] + [Field3_Count] + [Field4_Count]
      FROM 
         [T1].[vTestCountByKeyword]
      WHERE 
         [Salutation_Count] + [FirstName_Count] + [LastName_Count] + [Field1_Count] + [Field2_Count] + [Field3_Count] + [Field4_Count] > 0;

      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Count', @@ROWCOUNT;
   
      -- --------------------------------------------------------------------------------
      -- Count keywords by field and row and update counter fields
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = N'Count findings by field';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Count', NULL, N'processing', 0;

      UPDATE T01
         SET 
             T01.[Salutation_Count] = T02.[Salutation_Count]
            ,T01.[FirstName_Count]  = T02.[FirstName_Count]
            ,T01.[LastName_Count]   = T02.[LastName_Count]
            ,T01.[Field1_Count]     = T02.[Field1_Count]
            ,T01.[Field2_Count]     = T02.[Field2_Count]
            ,T01.[Field3_Count]     = T02.[Field3_Count]
            ,T01.[Field4_Count]     = T02.[Field4_Count]
      FROM
         [T1].[Test] T01 WITH (TABLOCKX)
         INNER JOIN [T1].[vTestIndicator] T02
         ON
           T01.[ID] = T02.[ID];

      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, N'Update', @@ROWCOUNT;

      -- --------------------------------------------------------------------------------
      -- Count multiple occurances of data (e.g. IP-Address, DateCreated (in Period), 
      -- etc.)
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = N'Count multiple occurances';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Count', NULL, N'processing', 0;

      WITH
      CTE_MappedToContact AS
      (
         SELECT 
             [MappedToContact]
            ,COUNT(*) AS [Count]
         FROM 
            [T1].[Test]
         GROUP BY 
            [MappedToContact]
         HAVING 
            COUNT(*) > 1
      )
      ,CTE_IPv4Address AS
      (
         SELECT 
             [IPv4Address]
            ,COUNT(*) AS [Count]
         FROM 
            [T1].[Test]
         GROUP BY 
            [IPv4Address]
         HAVING 
            COUNT(*) > 1
      )
      ,CTE_DateCreated_base AS
      (
         SELECT 
             [DateCreated]
         FROM 
            [T1].[Test]
         GROUP BY
            [DateCreated]
      )
      ,CTE_DateCreated AS
      (
         SELECT 
             [DateCreated]
            ,[T1].[fnGetRequestsByPeriod_Created]([DateCreated], @config_DateCreated_Period) AS [Count]
         FROM 
            CTE_DateCreated_base
      )
      ,CTE_DateModified_base AS
      (
         SELECT 
             [DateModified]
         FROM 
            [T1].[Test] 
         GROUP BY
            [DateModified]
      )
      ,CTE_DateModified AS
      (
         SELECT 
             [DateModified]
            ,[T1].[fnGetRequestsByPeriod_Modified]([DateModified], @config_DateModified_Period) AS [Count]
         FROM 
            CTE_DateModified_base
      )
      UPDATE T01
         SET 
             T01.[MappedToContact_Count] = COALESCE(T02.[Count], 0) 
            ,T01.[IPv4Address_Count]     = COALESCE(T03.[Count], 0) 
            ,T01.[DateCreated_Count]     = COALESCE(T04.[Count], 0) 
            ,T01.[DateModified_Count]    = COALESCE(T05.[Count], 0) 
      
      FROM 
         [T1].[Test] T01 WITH (TABLOCKX)
         LEFT JOIN CTE_MappedToContact T02
         ON
           T01.[MappedToContact] = T02.[MappedToContact]
         LEFT JOIN CTE_IPv4Address T03
         ON
           T01.[IPv4Address] = T03.[IPv4Address]
         LEFT JOIN CTE_DateCreated T04
         ON
           T01.[DateCreated] = T04.[DateCreated]
         LEFT JOIN CTE_DateModified T05
         ON
           T01.[DateModified] = T05.[DateModified];

      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Count', @@ROWCOUNT;
   
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
-- [T1].[spCountFindings]

-- EXEC [T1].[spCountFindings] 33;