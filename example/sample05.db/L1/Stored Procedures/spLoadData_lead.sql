
-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 26.11.2019
-- Description: Load data from [T2].[Eloqua] to [L1].[lead]
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
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [L1].[spLoadData_lead]
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
   SET @entity           = N'[T2].[Eloqua]';

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
      SET @step        = N'Load data T2>L1';
      SET @description = N'';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, NULL, @entity, @step, @description;
      
      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = N'Insert data';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, N'Check', NULL, N'processing', 0;

      -- --------------------------------------------------------------------------------
      -- Delete data for current execution ID if available.
      -- --------------------------------------------------------------------------------
      DELETE FROM [L1].[lead] WHERE [ExecutionId] = @p_executionId;

      -- --------------------------------------------------------------------------------
      -- Insert data
      -- --------------------------------------------------------------------------------
      WITH
      CTE_ad_salutationcode AS
      (
         SELECT DISTINCT                                                                 --  Das Optionset ist mehrsprachig. Damit können Optionset Texte doppelt vorkommen.
             [attributename]                                                             --  Um eine eindeutige Zuordnung der Optionset Texte zu einem Optionset-Code zu 
            ,[attributevalue]                                                            --  gewährleisten, wird das SELECT mit einem DISTINCT ausgeführt.
            ,[value]                                                                     --  
            --,[langid]                                                                  --
         FROM                                                                            --
            [crm].[stringmap]                                                            --
         WHERE                                                                           --
                [objecttypecode] = 'Lead'                                                --
            AND [attributename] = 'ad_salutationcode'                                    -- 
      )
      INSERT INTO [L1].[lead]
      (
          [leadid]
         ,[ad_attachmenturl]
         ,[ad_companywidecommunication]
         ,[ad_eloquaidentifier]
         ,[ad_language]

         ,[ad_requestdate]
         ,[ad_pagesourceurl]
         ,[address1_city]
         ,[address1_country]
         ,[address1_line1]
         ,[address1_postalcode]

         ,[companyname]
         ,[description]
         ,[emailaddress1]
         ,[firstname]
         ,[lastname]
         ,[telephone1]

         ,[ad_countryid]
         ,[ad_countryidname]
 
         ,[ad_solutionid]
         ,[ad_solutionidname]

         ,[ad_salutationcode]
         ,[ad_salutationcodename]

         ,[leadsourcecode]
         ,[leadsourcecodename]

         ,[SysCreatedBy]
         ,[SysCreatedOn]
         ,[SysError]
         ,[SysWarning]
         ,[SysHashAttributes]
         ,[SysHashPrimaryKey]
         ,[ExecutionID]
         ,[SysSource]
      )
      SELECT 
          NEWID()                              AS [leaidid]                              -- 
         ,T01.[UploadUrl]                      AS [ad_attachmenturl]                     -- 
         ,T01.[DoubleOptInDate]                AS [ad_companywidecommunication]          -- 
         ,T01.[RecordId]                       AS [ad_eloquaidentifier]                  -- 
         ,T01.[Language]                       AS [ad_language]                          -- 

         ,T01.[RequestDateUTC]                 AS [ad_requestdate]                       -- 
         ,T01.[PageSource]                     AS [ad_pagesourceurl]                     -- 
         ,T01.[City]                           AS [address1_city]                        -- 
         ,T01.[Country]                        AS [address1_country]                     -- 
         ,T01.[Address]                        AS [address1_line1]                       -- 
         ,T01.[ZipOrPostalCode]                AS [address1_postalcode]                  -- 

         ,T01.[Company]                        AS [companyname]                          -- 
         ,CASE WHEN COALESCE(T01.[CallBackRequest], 1) = 1                                --
             THEN 'Callback: Yes'                                                        --
                  + CHAR(13) + 'Callback time window: '                                  --
                  +  CASE WHEN [clock_08_10] = 1 THEN + CHAR(13) + '08-10' ELSE '' END   --
                  +  CASE WHEN [clock_10_12] = 1 THEN + CHAR(13) + '10-12' ELSE '' END   --
                  +  CASE WHEN [clock_12_14] = 1 THEN + CHAR(13) + '12-14' ELSE '' END   --
                  +  CASE WHEN [clock_14_16] = 1 THEN + CHAR(13) + '14-16' ELSE '' END   --
                  +  CASE WHEN [clock_16_18] = 1 THEN + CHAR(13) + '16-18' ELSE '' END   --
             ELSE + CHAR(13) + 'Callback: No'                                            --
          END                                  AS [description]                          --
         ,T01.[EmailAddress]                   AS [emailaddress1]                        --
         ,T01.[FirstName]                      AS [firstname]                            --
         ,T01.[LastName]                       AS [lastname]                             --
         ,T01.[BusinessPhone]                  AS [telephone1]                           --
                                                                                         --
         ,T02.[territoryid]                    AS [ad_countryid]                         -- ID des Landes
         ,SUBSTRING(T01.[CRMSolutionID], 1, 2) AS [ad_countryidname]                     -- Die ID wird nicht über den Namen des Landes aufgelöst, sondern über den ISO Code

         ,T03.[productid]                      AS [ad_solutionid]                        -- ID des Produktes 
         ,T01.[CRMSolutionID]                  AS [ad_solutionidname]                    -- Das Produkt wird nicht über den Produkt-Namen sondern über die CRM Solution ID

         ,T04.[attributevalue]                 AS [ad_salutationcode]                    -- Optionset Code der Anrede
         ,T01.[Salutation]                     AS [ad_salutationcodename]                -- Optionset Text der Anrede

         ,8                                    AS [leadsourcecode]                       -- Default 8 = Webseite/Website
         ,'Website'                            AS [leadsourcecodename]                   -- Default Webseite/Website

         ,T01.[SysCreatedBy]                   AS [SysCreatedBy]                         -- System-User, der den Datensatz erstellt hat (i.d.R. der Proxy-User)
         ,T01.[SysCreatedOn]                   AS [SysCreatedOn]                         -- Datum und Ihrzeit des Einlesens der Eloqua-Daten (für alle Datensätze einer Ausführung gleich)
         ,NULL                                 AS [SysError]                             -- 
         ,NULL                                 AS [SysWarning]                           -- 
         ,NULL                                 AS [SysHashAttributes]                    -- Wird nicht verwendet
         ,NULL                                 AS [SysHashPrimaryKey]                    -- Wird nicht verwendet
         ,T01.[ExecutionID]                    AS [ExecutionID]                          -- 
         ,T01.[SysSource]                      AS [SysSource]                            -- Eloqua CompanyName (z.B. GrenkeAgSandbox)
      FROM 
         [T2].[Eloqua] T01
         LEFT JOIN [crm].[territory] T02
         ON
           SUBSTRING(T01.[CRMSolutionID], 1, 2) = T02.[ad_countrycodeiso]
         LEFT JOIN [crm].[product] T03
         ON
           T01.[CRMSolutionID] = T03.[productnumber]
         LEFT JOIN CTE_ad_salutationcode T04
         ON
           T01.[Salutation] = T04.[value]
      WHERE
         T01.[ExecutionID] = @p_executionId;

      -- --------------------------------------------------------------------------------
      -- End Trace Log
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateTraceSuccess1] @traceId, 'Insert', @@ROWCOUNT;     

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
-- [L1].[spLoadData_lead]

-- EXEC [L1].[spLoadData_lead] 25