
-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates the fields [SysError] and [SysWarning] in schema T1 tables.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_componentId          AS int 
--       ID of the row in [LOG].[Component], that is to be updated.
--    @p_state                AS nvarchar(100) 
--       State of the current task (processing, success, error, warning)
--    @p_Description          AS nvarchar(max) 
--       Additional description of the task in the calling object that will be logged
--    @p_Success              AS bit
--       Specifies whether the calling procedure succeded
--       1 = processing, warning, error
--       0 = success
--    @p_Error                AS int
--       Returns number of rows with errors 
--        > don't mix it up with the number of errors
--    @p_Warning              AS int
--       Returns number of rows with warnings
--        > don't mix it up with the number of warnings
--    @p_Infomation           AS int
--       Returns number of rows with warnings
--        > don't mix it up with the number of warnings
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
CREATE PROCEDURE [T1].[spUpdateDatasetError] 
(
    @p_executionId           AS int 
   ,@p_schemaName            AS nvarchar(128)
   ,@p_tableName             AS nvarchar(128)
   ,@p_ID1Field              AS nvarchar(128)
   ,@p_ID2Field              AS nvarchar(128) = NULL
   ,@p_ID3Field              AS nvarchar(128) = NULL
   ,@p_Error                 AS int OUT
   ,@p_Warning               AS int OUT
   ,@p_Information           AS int OUT
)
AS
BEGIN
   SET NOCOUNT ON;
	
   -- --------------------------------------------------------------------------------
   -- Declare Variables
   -- --------------------------------------------------------------------------------

   -- Error Variables
   DECLARE @component            AS nvarchar(128);
   DECLARE @message              AS nvarchar(max);
   DECLARE @returnCode           AS int;
   DECLARE @errorCode            AS int;
   DECLARE @p_affectedRecords    AS int;

   -- SQL Variables
   DECLARE @sql                  AS nvarchar(max);
   DECLARE @parameterDefinition  AS nvarchar(500);  
   SET @component = OBJECT_SCHEMA_NAME(@@PROCID) + N'.' + OBJECT_NAME(@@PROCID);

   -- --------------------------------------------------------------------------------
   -- Check input parameters for integrity
   -- --------------------------------------------------------------------------------
   IF (@p_executionId IS NULL)
      BEGIN
         SET @message = N'The parameter ''p_executionId'' is NULL.';
         EXEC [dbo].[spRaiseError] @message,  @component
         RETURN -1;
      END;
   IF [dbo].[fnIsNullOrEmpty](@p_schemaName, 1) = 1
      BEGIN
         SET @message = N'The parameter ''p_schemaName'' is NULL or empty.';
         EXEC [dbo].[spRaiseError] @message,  @component
         RETURN -1;
      END;
   IF [dbo].[fnIsNullOrEmpty](@p_tableName, 1) = 1
      BEGIN
         SET @message = N'The parameter ''p_tableName'' is NULL or empty.';
         EXEC [dbo].[spRaiseError] @message,  @component
         RETURN -1;
      END;
   IF [dbo].[fnIsNullOrEmpty](@p_ID1Field, 1) = 1
      BEGIN
         SET @message = N'The parameter ''p_ID1Field'' is NULL or empty.';
         EXEC [dbo].[spRaiseError] @message,  @component
         RETURN -1;
      END;

   -- --------------------------------------------------------------------------------
   -- Build SQL statement
   -- --------------------------------------------------------------------------------
   SET @sql = N'';
   SET @sql = N'WITH'                                                                                                + CHAR(13);
   SET @sql = @sql + N'CTE_Count AS'                                                                                 + CHAR(13);
   SET @sql = @sql + N'('                                                                                            + CHAR(13);
   SET @sql = @sql + N'SELECT'                                                                                       + CHAR(13);
   SET @sql = @sql + N'       SUM (CASE WHEN [ErrorType] = ''E'' THEN 1 ELSE 0 END) AS [SysError]'                   + CHAR(13);
   SET @sql = @sql + N'      ,SUM (CASE WHEN [ErrorType] = ''W'' THEN 1 ELSE 0 END) AS [SysWarning]'                 + CHAR(13);
   SET @sql = @sql + N'      ,SUM (CASE WHEN [ErrorType] = ''I'' THEN 1 ELSE 0 END) AS [SysInformation]'             + CHAR(13);
   SET @sql = @sql + N'      ,[ID1Value]'                                                                            + CHAR(13);

   IF [dbo].[fnIsNullOrEmpty](@p_ID2Field, 1) = 0
      BEGIN
         SET @sql = @sql + N'      ,[ID2Value]'                                                                      + CHAR(13);
      END

   IF [dbo].[fnIsNullOrEmpty](@p_ID3Field, 1) = 0
      BEGIN
         SET @sql = @sql + N'      ,[ID3Value]'                                                                      + CHAR(13);
      END

   SET @sql = @sql + N'   FROM'                                                                                      + CHAR(13);
   SET @sql = @sql + N'      [LOG].[Error]'                                                                          + CHAR(13);
   SET @sql = @sql + N'   WHERE'                                                                                     + CHAR(13);
   SET @sql = @sql + N'          [ExecutionID] = ' + CAST (@p_executionId AS nvarchar(100))                          + CHAR(13);
   SET @sql = @sql + N'      AND [SchemaName]  = ''' + @p_schemaName + N''''                                         + CHAR(13);
   SET @sql = @sql + N'      AND [TableName]   = ''' + @p_tableName + N''''                                          + CHAR(13);
   SET @sql = @sql + N'   GROUP BY'                                                                                  + CHAR(13);
   SET @sql = @sql + N'       [ID1Value]'                                                                            + CHAR(13);

   IF [dbo].[fnIsNullOrEmpty](@p_ID2Field, 1) = 0
      BEGIN
         SET @sql = @sql + N'      ,[ID2Value]'                                                                      + CHAR(13);
      END

   IF [dbo].[fnIsNullOrEmpty](@p_ID3Field, 1) = 0
      BEGIN
         SET @sql = @sql + N'      ,[ID3Value]'                                                                      + CHAR(13);
      END

   SET @sql = @sql + N')'                                                                                            + CHAR(13);
   SET @sql = @sql + N'UPDATE T01'                                                                                   + CHAR(13);
   SET @sql = @sql + N'   SET'                                                                                       + CHAR(13);
   SET @sql = @sql + N'       T01.[SysError]   = CASE WHEN T02.[SysError]   = 0 THEN NULL ELSE T02.[SysError]   END' + CHAR(13);
   SET @sql = @sql + N'      ,T01.[SysWarning] = CASE WHEN T02.[SysWarning] = 0 THEN NULL ELSE T02.[SysWarning] END' + CHAR(13);
   SET @sql = @sql + N'FROM'                                                                                         + CHAR(13);
   SET @sql = @sql + N'   [' + @p_schemaName + N'].[' + @p_tableName + N'] T01'                                      + CHAR(13);
   SET @sql = @sql + N'   INNER JOIN CTE_Count T02'                                                                  + CHAR(13);
   SET @sql = @sql + N'   ON'                                                                                        + CHAR(13);
   SET @sql = @sql + N'     T01.[' + @p_ID1Field + N'] = T02.[ID1Value]'                                             + CHAR(13);
   SET @sql = @sql + N'WHERE'                                                                                        + CHAR(13);
   SET @sql = @sql + N'      T02.[SysError]   > 0'                                                                   + CHAR(13);
   SET @sql = @sql + N'   OR T02.[SysWarning] > 0;'                                                                  + CHAR(13);

   SET @sql = @sql + N'SELECT @affectedRows_E = COALESCE(SUM(CASE WHEN [SysError]       IS NOT NULL THEN 1 ELSE 0 END), 0) FROM [' + @p_schemaName + '].[' + @p_tableName + '] WHERE [SysError]       IS NOT NULL' + CHAR(13);
   SET @sql = @sql + N'SELECT @affectedRows_W = COALESCE(SUM(CASE WHEN [SysWarning]     IS NOT NULL THEN 1 ELSE 0 END), 0) FROM [' + @p_schemaName + '].[' + @p_tableName + '] WHERE [SysWarning]     IS NOT NULL' + CHAR(13);
   --SET @sql = @sql + N'SELECT @affectedRows_I = SUM(CASE WHEN [SysInformation] IS NOT NULL THEN 1 ELSE 0 END) FROM [' + @p_schemaName + '].[' + @p_tableName + '] WHERE [SysInformation] IS NOT NULL' + CHAR(13);

   PRINT @sql

   SET @parameterDefinition = N'@affectedRows_W int OUTPUT, @affectedRows_E int OUTPUT';
   --SET @parameterDefinition = N'@affectedRows_I int OUTPUT, @affectedRows_W int OUTPUT, @affectedRows_E int OUTPUT';
   
   EXEC [dbo].[sp_executesql] @sql, @parameterDefinition, @affectedrows_W = @p_Warning OUTPUT, @affectedrows_E = @p_Error OUTPUT;
   --EXEC [dbo].[sp_executesql] @sql, @parameterDefinition, @affectedRows_I = @p_Information OUTPUT, @affectedrows_W = @p_Warning OUTPUT, @affectedrows_E = @p_Error OUTPUT;

   SET @message   = ERROR_MESSAGE();
   SET @errorCode = @@ERROR;

   IF @errorCode > 0
      BEGIN
         EXEC [dbo].[spRaiseError] @message, @component;
         RETURN @errorCode;
      END;
   RETURN 0;  
END
-- [T1].[spUpdateDatasetError] 

/*
DECLARE @p_executionId int;
DECLARE @p_schemaName  nvarchar(128);
DECLARE @p_tableName   nvarchar(128);
DECLARE @p_ID1Field    nvarchar(128);
DECLARE @p_ID2Field    nvarchar(128);
DECLARE @p_ID3Field    nvarchar(128);
DECLARE @p_Error       AS int;
DECLARE @p_Warning     AS int;
DECLARE @p_Information AS int;

SET @p_executionId = 1;
SET @p_schemaName  = 'T1';
SET @p_tableName   = 'Test';
SET @p_ID1Field    = 'PK';
SET @p_ID2Field    = NULL;
SET @p_ID3Field    = NULL;

EXECUTE [T1].[spUpdateDatasetError] 
   @p_executionId 
  ,@p_schemaName  
  ,@p_tableName   
  ,@p_ID1Field    
  ,@p_ID2Field    
  ,@p_ID3Field    
  ,@p_Error       OUTPUT
  ,@p_Warning     OUTPUT
  ,@p_Information OUTPUT
*/