-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Writes a text to the specified filename including a path. 
-- Note       : You must specifiy a filename that is accessible fpor SQL Server.
--
--              In order to use Ole Automation Procedures, please execute the 
--              following statements:
--
--                  sp_configure 'Ole Automation Procedures', 1 
--                  GO 
--                  RECONFIGURE; 
--                  GO
--
--              Be aware that this activation of Ole Automation Procedures imposes 
--              a security risk to the SQL server isntallation.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int
--       Execution ID of the current execution.
--    @p_fileName       nvarchar(1024)
--       File name
--    @p_text           nvarchar(max) OUT
--       Content of the file
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 : error
--    = 0 : success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
--------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spSaveFile]
    @p_executionId           AS int
   ,@p_fileName              AS nvarchar(1024) 
   ,@p_text                  AS nvarchar(max)
AS
BEGIN

   -- Error Variables
   DECLARE @error_message           AS nvarchar(max);
   DECLARE @error_number            AS int;
   DECLARE @error_line              AS int;
   DECLARE @error_state             AS nvarchar(max);

   DECLARE @error_object            AS int;
   DECLARE @error_source            AS varchar(255);
   DECLARE @error_description       AS varchar(255);
   DECLARE @error_helpfile          AS varchar(255);
   DECLARE @error_helpid            AS int;

   -- Logging Variables
   DECLARE @component               AS nvarchar(256);
   DECLARE @task                    AS nvarchar(128);
   DECLARE @schema                  AS nvarchar(128);
   DECLARE @table                   AS nvarchar(128);
   DECLARE @source                  AS nvarchar(5);
   DECLARE @step                    AS nvarchar(max);
   DECLARE @entity                  AS nvarchar(max);
   DECLARE @message                 AS nvarchar(max);
   DECLARE @traceid                 AS int; 
   DECLARE @componentid             AS int;
   DECLARE @description             AS nvarchar(max);
   DECLARE @affectedrows            AS int;

   DECLARE @fs                      AS int;
   DECLARE @oleResult               AS int;  

   -- Logging
   SET @message        = NULL;
   SET @description    = NULL;
   SET @affectedrows   = 0;

   SET @component      = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
   SET @source         = 'T-SQL';
   SET @componentid    = NEXT VALUE FOR [LOG].[SEQ];
   SET @entity         = '<File>';

   BEGIN TRY
      -- --------------------------------------------------------------------------------
      -- Check input parameters for integrity
      -- --------------------------------------------------------------------------------
      IF (@p_executionId IS NULL)
         BEGIN
            SET @message = 'The parameter ''p_executionId'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;
      IF [dbo].[fnIsNullOrEmpty](@p_fileName, 1) = 1
         BEGIN
            SET @message = 'The parameter ''p_fileName'' is NULL.';
            EXEC [dbo].[spRaiseError] @message,  @component;
            RETURN -1;
         END;
         
      -- --------------------------------------------------------------------------------
      -- Start Component Log
      -- --------------------------------------------------------------------------------
      SET @step        = 'Save file ' + @p_fileName;
      SET @description = NULL;
      EXEC [LOG].[spInsertComponent] @p_executionId, @componentid OUTPUT, @source, @component, NULL, @entity, @step, @description;


      -- --------------------------------------------------------------------------------
      -- Start Trace Log
      -- --------------------------------------------------------------------------------
      SET @task        = 'Save file';
      SET @step        = 'Save file';
      SET @description = @p_fileName; 
      EXEC [LOG].[spInsertTrace] @p_executionId, @componentid, @traceid OUTPUT, @source, @component, @task, @entity, @step, @description, 'Save file', NULL, 'processing', 0;

      -- ----------------------------------------------------------------------
      -- 
      -- ----------------------------------------------------------------------
      EXECUTE @oleResult = sp_OACreate 'ADODB.Stream', @fs OUT;
      IF (@oleResult <> 0) 
         BEGIN
            EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
            SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
            SET @error_message     = @component + ':sp_OACreate(ADODB.Stream) returns an error [' + CAST(@oleResult as nvarchar(100)) + ':' + @error_description + '].';
            RAISERROR (@error_message,16,1);
         END;

      -- ----------------------------------------------------------------------
      -- 
      -- ----------------------------------------------------------------------
      EXECUTE @oleResult = sp_OASetProperty @fs, 'Type', 2;
      IF (@oleResult <> 0) 
         BEGIN
            EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
            SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
            SET @error_message     = @component + ':sp_OASetProperty(Type) returns an error [' + CAST(@oleResult as nvarchar(100)) + ':' + @error_description + '].';
            RAISERROR (@error_message,16,1);
         END;

      -- ----------------------------------------------------------------------
      -- 
      -- ----------------------------------------------------------------------
      EXECUTE @oleResult = sp_OAMethod @fs, 'Open';
      IF (@oleResult <> 0) 
         BEGIN
            EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
            SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
            SET @error_message     = @component + ':sp_OAMethod(Open) returns an error [' + CAST(@oleResult AS NVARCHAR(100)) + ':' + @error_description + '].';
            RAISERROR (@error_message,16,1);
         END;

      -- ----------------------------------------------------------------------
      -- 
      -- ----------------------------------------------------------------------
      SET @p_text = COALESCE(@p_text, '', @p_text);

      EXECUTE @oleResult = sp_OAMethod @fs, 'WriteText', NULL, @p_text, 1;
      IF (@oleResult <> 0) 
         BEGIN
            EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
            SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
            SET @error_message     = @component + ':sp_OAMethod(WriteText) returns an error [' + CAST(@oleResult AS NVARCHAR(100)) + ':' + @error_description + '].';
            RAISERROR (@error_message,16,1);
         END;

      -- ----------------------------------------------------------------------
      -- 
      -- ----------------------------------------------------------------------
      EXECUTE @oleResult = sp_OAMethod @fs, 'SaveToFile', NULL, @p_fileName, 2;
      IF (@oleResult <> 0) 
         BEGIN
            EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
            SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
            SET @error_message     = @component + ':sp_OAMethod(SaveToFile) returns an error [' + CAST(@oleResult AS NVARCHAR(100)) + ':' + @error_description + '].';
            RAISERROR (@error_message,16,1);
         END;

      -- ----------------------------------------------------------------------
      -- 
      -- ----------------------------------------------------------------------
      EXECUTE @oleResult = sp_OAMethod @fs, 'Close'
      IF (@oleResult <> 0) 
         BEGIN
            EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
            SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
            SET @error_message     = @component + ':sp_OAMethod(Close) returns an error [' + CAST(@oleResult AS NVARCHAR(100)) + ':' + @error_description + '].';
            RAISERROR (@error_message,16,1);
         END;

      -- ----------------------------------------------------------------------
      -- Destroy ADODB.Stream
      -- ----------------------------------------------------------------------
      EXEC @oleResult = sp_OADestroy @fs;   
      IF (@oleResult <> 0) 
         BEGIN
            EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
            SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
            SET @error_message     =  @component + ':sp_OADestroy returns an error [' + CAST(@oleResult as nvarchar(100)) + ':' + @error_description + '].';
            RAISERROR (@error_message,16,1);
         END

      -- --------------------------------------------------------------------------------
      -- End Trace Log
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateTraceSuccess1] @traceid, N'Save file', NULL;

      -- --------------------------------------------------------------------------------
      -- End Component Log
      -- --------------------------------------------------------------------------------
      EXEC [LOG].[spUpdateComponentSuccess1] @componentid;

      RETURN 0;
   END TRY
   BEGIN CATCH
      SET @error_message = ERROR_MESSAGE();
      SET @error_number  = ERROR_NUMBER();
      SET @error_line    = ERROR_LINE();
      SET @error_state   = ERROR_STATE();

      IF @p_executionId IS NOT NULL
         BEGIN
            EXEC [LOG].[spUpdateTraceError1] @traceid;
            EXEC [LOG].[spUpdateComponentError1] @componentid;
            EXEC [LOG].[spInsertError] @p_executionId, @componentid, @traceid, N'E', @source, @component, NULL, NULL, @step, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @p_fileName, @error_number, @error_message, @error_line, @error_state;
         END;
      THROW;
      RETURN @error_number;
   END CATCH; 
END;
-- [dbo].[spSaveFile]