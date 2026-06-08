-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Creates an Email body for failed tasks/jobs.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       Execution ID of the current execution
--    @p_environment          AS nvarchar(128)
--       Name of the environment, where the failed job was executed
--       > e.g. Production, Integration
--    @p_jobName              AS nvarchar(128)
--       Name of the job that has failed
--    @p_useDescription       AS bit
--       Specifies whether to log the content of the column 
--       [LOG].[Error].[Description] instead of [LOG].[Error].[Step]
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
CREATE PROCEDURE [LOG].[spHTMLError]
(   
    @p_executionId           AS int
   ,@p_environment           AS nvarchar(128)
   ,@p_jobName               AS nvarchar(128)
   ,@p_useDescription        AS bit
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

   DECLARE @outputHTML       AS nvarchar(max);

   DECLARE @status           AS nvarchar(max);
   DECLARE @success          AS int;
   DECLARE @subject          AS nvarchar(max);
   DECLARE @startTime        AS nvarchar(25);
   DECLARE @endTime          AS nvarchar(25);
   DECLARE @duration         AS nvarchar(10);

   DECLARE @description      AS nvarchar(max);
   DECLARE @affectedrows     AS int;

   DECLARE @executionInfo1   AS nvarchar(max);
   DECLARE @executionInfo2   AS nvarchar(max);
   DECLARE @executionInfo3   AS nvarchar(max);
   DECLARE @executionInfo4   AS nvarchar(max);
   DECLARE @executionInfo5   AS nvarchar(max);
   DECLARE @executionInfo6   AS nvarchar(max);

   DECLARE @executionResult1 AS nvarchar(max);
   DECLARE @executionResult2 AS nvarchar(max);
   DECLARE @header           AS nvarchar(max);
   DECLARE @body             AS nvarchar(max);
   DECLARE @HTML_title       AS nvarchar(max);
   DECLARE @HTML_color       AS nvarchar(max);
   DECLARE @tableData_ErrorColumns AS nvarchar(max);
   DECLARE @tableData_Components   AS nvarchar(max);

   -- --------------------------------------------------------------------------------
   -- SET variables
   -- --------------------------------------------------------------------------------

   -- Logging
   SET @message          = NULL;
   SET @description      = NULL;
   SET @affectedrows     = 0;

   SET @component        = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source           = 'T-SQL';
   SET @componentId      = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity           = 'Job: ' + COALESCE(@p_jobName, '<unknown>');
   SET @HTML_title       = 'Status Mail - ' + COALESCE(@p_jobName, '<unknown>');
   SET @p_useDescription = COALESCE(@p_useDescription, 0);   

   -- --------------------------------------------------------------------------------
   -- Start TRY
   -- --------------------------------------------------------------------------------
   BEGIN TRY

      -- --------------------------------------------------------------------------------
      -- Check input parameters for integrity
      -- --------------------------------------------------------------------------------
      -- Check @p_executionId
      IF (@p_executionId IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_executionId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;
             
      -- Check @p_TableSchema 
      IF [dbo].[fnIsNullOrEmpty](@p_environment , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_Environment '' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;

      -- Check @p_TableName
      IF [dbo].[fnIsNullOrEmpty](@p_jobName , 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_JobName '' is NULL or empty.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;

      -- --------------------------------------------------------------------------------
      -- Start Component Logging
      -- --------------------------------------------------------------------------------
      SET @step        = 'Prepare Send Status Mail';
      SET @description = '';
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentId OUTPUT, @source, @component, @entity, @step, @description, 'processing', 0;
     

      -- --------------------------------------------------------------------------------
      -- Start Trace Logging
      -- --------------------------------------------------------------------------------
      SET @task        = NULL;
      SET @step        = 'Prepare Send Status Mail';
      SET @description = NULL; 
      EXEC [LOG].[spInsertTrace]  @p_executionId, @componentId, @traceId OUTPUT, @source, @component, @task, @entity, @step, @description, 'processing', 0;


      -- --------------------------------------------------------------------------------
      -- Ermittelt die Werte für den Header der Email (Execution)
      -- --------------------------------------------------------------------------------
      SELECT 
          @status    = [State]
         ,@success   = [Success]
         ,@startTime = CONVERT(nvarchar(25),[Start], 120  )
         ,@endTime   = CONVERT(nvarchar(25),[End]  , 120  )
         ,@duration  = CAST(DATEDIFF(SECOND,[Start], [End]) AS nvarchar(10))
      FROM 
         [LOG].[Execution]
      WHERE 
         [ID] = @p_executionId;

      -- --------------------------------------------------------------------------------
      -- Ermittelt die Texte, die den Status des Import-Prozesses 
      -- (Import ESXCEL-Dokumente) zusammenfassen
      -- --------------------------------------------------------------------------------
      IF @success = 1 
         BEGIN
            SET @executionResult1 = 'Der Prozess wurde erfolgreich ausgeführt.';
            SET @executionResult2 = 'Success';
         END
      ELSE IF @success = 0 AND @status = 'error'
         BEGIN
            SET @executionResult1 = 'Der Prozess wurde mit Fehlern beendet.';
            SET @executionResult2 = 'Error';
         END
      ELSE IF @success = 0 AND @status = 'error'
         BEGIN
            SET @executionResult1 = 'Der Prozess wurde mit Warnungen beendet.';
            SET @executionResult2 = 'Warning';
         END
      ELSE
         BEGIN
            SET @executionResult1 = 'Der Prozess wurde noch ausgeführt.';
            SET @executionResult2 = 'Processing';
         END;

      SET @subject = '[' + @p_environment + '] ' + @p_jobName + ' finished with status ''' + @executionResult2 + '''';

      -- --------------------------------------------------------------------------------
      -- Parameter für fehlerhafte Datensätze befüllen 
      -- inklusive 'Konvertierung' in HTML
      -- --------------------------------------------------------------------------------
      SET @tableData_ErrorColumns = '';      
      WITH 
      CTE_Base AS
      (
         SELECT 
             [ExecutionID]                         AS [ExecutionID]  
            ,COALESCE([ErrorType]      , '&nbsp;') AS [ErrorType]      
            ,COALESCE([SchemaName]     , '&nbsp;') AS [SchemaName]     
            ,COALESCE([TableName]      , '&nbsp;') AS [TableName]      
            ,COALESCE([ErrorColumnName], '&nbsp;') AS [ErrorColumnName]
            ,COALESCE([Step]           , '&nbsp;') AS [Step]
            ,COALESCE([Description]    , '&nbsp;') AS [Description]
            ,COALESCE([Source]         , '&nbsp;') AS [Source]
            ,COUNT(*)                              AS [Count]
         FROM 
            [LOG].[Error]
         WHERE                                                                               -- Die Bedingung [Source] = 'SSIS' ist erforderlich um 
               ([Component] IN ('IL.sp_DataCheck', 'CWL.sp_DataCheck') OR [Source] = 'SSIS') -- Fehler, die aus einem SSIS-Paket protokolliert wurden 
            AND [ExecutionID] = @p_executionId                                             -- berücksichtigen zu können
         GROUP BY 
             [ExecutionID]  
            ,COALESCE([ErrorType]      , '&nbsp;')
            ,COALESCE([SchemaName]     , '&nbsp;')
            ,COALESCE([TableName]      , '&nbsp;')
            ,COALESCE([ErrorColumnName], '&nbsp;')
            ,COALESCE([Step]           , '&nbsp;')
            ,COALESCE([Description]    , '&nbsp;')
            ,COALESCE([Source]         , '&nbsp;')
      ),
      CTE_Lines AS
      (
         SELECT 
             [SchemaName]
            ,[TableName] 
            ,CONCAT( '<tr>'                                                    + CHAR(13)
                    ,'   <td>' + CAST([ExecutionID] AS nvarchar(100))   + '</td>' + CHAR(13)
                    ,'   <td>' + [ErrorType]                            + '</td>' + CHAR(13)
                    ,'   <td>' + [SchemaName]                           + '</td>' + CHAR(13)
                    ,'   <td>' + [TableName]                            + '</td>' + CHAR(13)
                    ,'   <td>' + [ErrorColumnName]                      + '</td>' + CHAR(13)
                    ,CASE WHEN @p_useDescription = 1 OR [Source] = 'SSIS'
                        THEN '   <td>' + COALESCE([Description], '')    + '</td>' + CHAR(13)
                        ELSE '   <td>' + REPLACE(REPLACE(REPLACE([Step], 'Check Constraint: ', ''), 'Check Unique Columns: ', ''), 'Check Join: ', '') + '</td>' + CHAR(13)
                     END
                     -- --------------------------------------------------------------------------------
                     -- Handelt es sich um einen Fehler, der aus einem SSIS-Paket protokolliert wurde, 
                     -- ist de Spalte Step immer leer und die Spalte Source immer gefüllt. Der Parameter 
                     -- @p_useDescription ist dasher bei SSIS Fehlern nicht zu beürcksichtigen. Daher 
                     -- die Bedingung 'OR [Source] = 'SSIS''
                     -- --------------------------------------------------------------------------------
                     -- Handelt es sich um einen Fehler, der aus einer Prozedur heraus protokolliert 
                     -- wurde, sind beide Spalten immer befüllt
                     -- --------------------------------------------------------------------------------
                    ,CASE WHEN [Source] = 'SSIS'                   THEN '   <td>SSIS</td>'       + CHAR(13)
                          WHEN [Step] LIKE 'Check Constraint%'     THEN '   <td>Constraint</td>' + CHAR(13)
                          WHEN [Step] LIKE 'Check Unique Columns%' THEN '   <td>Uniqueness</td>' + CHAR(13)
                          WHEN [Step] LIKE 'Check Join%'           THEN '   <td>Join</td>'       + CHAR(13)
                          ELSE                                          '   <td>Unknown</td>'    + CHAR(13)
                     END
                    ,'   <td>' + CAST([Count] AS nvarchar(100)) + '</td>'
                    ,'</tr>'                                                   + CHAR(13)
                   ) AS [TableRow]
         FROM 
            CTE_Base
      )
      SELECT
         @tableData_ErrorColumns = @tableData_ErrorColumns + [TableRow]
      FROM
         CTE_Lines
      ORDER BY 
          [SchemaName]
         ,[TableName];

      -- --------------------------------------------------------------------------------
      -- Parameter für detaillierte Ausführungsschritte befüllen 
      -- inklusive 'Konvertierung' in HTML
      -- --------------------------------------------------------------------------------
      SET @tableData_Components = '';
      WITH CTE_Base AS 
      (
         SELECT 
             [ID]
            ,CONCAT( '<tr>'                                                    + CHAR(13)
                    ,'   <td>' + [Component]                         + '</td>' + CHAR(13)
                    ,'   <td>' + [Entity]                            + '</td>' + CHAR(13)
                    ,'   <td>' + [Step]                              + '</td>' + CHAR(13)
                    ,'   <td>' + [State]                             + '</td>' + CHAR(13)
                    ,'   <td>' + CAST([Success] AS nvarchar(max))    + '</td>' + CHAR(13)
                    ,'   <td>' + CAST([CreatedOn]  AS nvarchar(100)) + '</td>' + CHAR(13)
                    ,'   <td>' + CAST([ModifiedOn] AS nvarchar(100)) + '</td>' + CHAR(13)
                    ,'</tr>'                                                   + CHAR(13)
                   ) AS [TableRow]
         FROM 
            [LOG].[Component]
         WHERE 
                [Source]      = 'SSIS'
            AND [ExecutionID] = @p_executionId
      )
      SELECT
         @tableData_Components = @tableData_Components + [TableRow]
      FROM 
         CTE_Base
      ORDER BY 
         [ID];


      -- --------------------------------------------------------------------------------
      -- Generierung des HTML-Header-Elementes
      -- --------------------------------------------------------------------------------
      SET @header =           '<head>' + CHAR(13);
      SET @header = @header + '   <title>' + @HTML_title + '</title>' + CHAR(13);
      SET @header = @header + '   <style>' + CHAR(13);
      SET @header = @header + '   body {font-family: CorpoS, Arial;}' + CHAR(13);
      SET @header = @header + '   table {border: 1px solid black;font-size: 11px;border-collapse: collapse;}' + CHAR(13);
      SET @header = @header + '   td {border: 1px solid black;padding: 3px;}' + CHAR(13);
      SET @header = CASE UPPER(@p_environment) 
                       WHEN 'DEV'  THEN @header + 'th {border: 1px solid black;padding: 3px;background-color: #AEABF1;text-align: left;}' + CHAR(13) -- Helles Lila
                       WHEN 'INT'  THEN @header + 'th {border: 1px solid black;padding: 3px;background-color: #8984EA;text-align: left;}' + CHAR(13) -- Medium Lila
                       WHEN 'PROD' THEN @header + 'th {color: white; border: 1px solid black;padding: 3px;background-color: #251EAC;text-align: left;}' + CHAR(13) -- Dunkel Lila
                       ELSE             @header + 'th {border: 1px solid black;padding: 3px;background-color: #00ffff;text-align: left;}' + CHAR(13) -- Türkis
                    END;
      

            SET @header = @header + 'h2 {color: black;}' + CHAR(13); --Light Pink
            SET @header = @header + 'h3 {color: black;}' + CHAR(13);


      SET @header = @header + '   </style>' + CHAR(13);
      SET @header = @header + '</head>' + CHAR(13);

      -- --------------------------------------------------------------------------------
      -- Generierung der Ausführungsinformationen
      -- --------------------------------------------------------------------------------
      SET @executionInfo1 = '<hr>' + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '<h3>Prozess</h3>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '<table>'                                             + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '   <tr>'                                             + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '      <td>'                                          + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '         <table>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>Job ID</th>'                      + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>' + CAST(@p_executionId AS nvarchar(100)) + '</td>' + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>Job Name</th>'                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>' + @p_jobName + '</td>'          + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>Umgebung</th>'                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>' + @p_environment + '</td>'      + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>Status</th>'                      + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>' + @executionResult2 + '</td>'   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '         </table>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '      </td>'                                         + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '      <td>'                                          + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '         <table>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>&nbsp;</th>'                      + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>&nbsp;</td>'                      + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>Dauer [s]</th>'                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>' + @duration + '</td>'           + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>Start</th>'                       + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>' + @startTime + '</td>'          + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            <tr>'                                    + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <th>Ende</th>'                        + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '               <td>' + @endTime + '</td>'            + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '            </tr>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '         </table>'                                   + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '      </td>'                                         + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '   </tr>'                                            + CHAR(13);
      SET @executionInfo1 = @executionInfo1 + '</table>'                                            + CHAR(13);

      -- --------------------------------------------------------------------------------
      -- 
      -- --------------------------------------------------------------------------------
      SET @executionInfo2 = '<hr>'                                                                  + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '<h3>The process was successfull but following errors / warnings were detected:</h3>' + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '<table>'                                             + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '<tr>'                                                + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>ExecutionID</th>'                             + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>ErrorType</th>'                               + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>SchemaName</th>'                              + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>TableName</th>'                               + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>ErrorColumnName</th>'                         + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>Constraint</th>'                              + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>Type</th>'                                    + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '   <th>Count</th>'                                   + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + '</tr>'                                               + CHAR(13);
      SET @executionInfo2 = @executionInfo2 + @tableData_ErrorColumns;
      SET @executionInfo2 = @executionInfo2 + '</table>'                                            + CHAR(13);

      -- --------------------------------------------------------------------------------
      -- 
      -- --------------------------------------------------------------------------------
      SET @executionInfo3 = '<hr>'                                                                  + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '<h3>Detailled execution log:</h3>'                   + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '<table>'                                             + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '<tr>'                                                + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '   <th>Component</th>'                               + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '   <th>Entity</th>'                                  + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '   <th>Step</th>'                                    + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '   <th>State</th>'                                   + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '   <th>Success</th>'                                 + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '   <th>StartDate</th>'                               + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '   <th>EndDate</th>'                                 + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + '</tr>'                                               + CHAR(13);
      SET @executionInfo3 = @executionInfo3 + @tableData_Components
      SET @executionInfo3 = @executionInfo3 + '</table>'                                            + CHAR(13);
               
      -- --------------------------------------------------------------------------------
      -- Email Body zusammensetzen
      -- --------------------------------------------------------------------------------
      SET @body = @header;
      SET @body = @body + '<body>'                                                                  + CHAR(13);
      SET @body = @body + '<h2>' + @p_environment + ' - ' + @p_jobName + '</h2>'                    + CHAR(13);
      SET @body = @body + '<h3>' + @executionResult1 + '</h3>'                                      + CHAR(13);
      SET @body = @body + @executionInfo1;
      SET @body = @body + @executionInfo2;
      SET @body = @body + @executionInfo3;
      SET @body = @body + '</body>'                                                                 + CHAR(13);
   
      -- --------------------------------------------------------------------------------
      -- Trace Logging End
      -- --------------------------------------------------------------------------------
      SET @description = '';
      EXEC [LOG].[spUpdateTraceSuccess] @traceId, @description;

      -- --------------------------------------------------------------------------------
      -- Component Logging End
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateComponentSuccess1] @componentId;

      SELECT @body, @subject;

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
            EXEC [LOG].[spInsertError] @p_executionId, @componentId, @traceId, N'E', @source, @component, NULL, NULL, @step, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @error_number, @error_message, @error_line, @error_state;
         END;
      THROW;
      RETURN @error_number;
   END CATCH; 
END
-- [LOG].[spHTMLError]
