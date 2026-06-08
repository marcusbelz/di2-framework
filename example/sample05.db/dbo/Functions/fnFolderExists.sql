-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Checks whether the folder with the folder name passed in the 
--              parameter p_folderName does exist.
-- 
--              This function uses OLE Automation Procedures (e.g. sp_OACreate). 
--              Before using this procedure SQL must be configured to to allow 
--              the usage of OLE Automation prodedures.
--              see: https://msdn.microsoft.com/en-us/library/ms191188.aspx
-- --------------------------------------------------------------------------------
-- Parameters : 
--   @p_fileName   nvarchar(1024)
--      File name of the file to be checked.
-- --------------------------------------------------------------------------------
-- Return Value
--    1 = Folder exists
--    0 = Folder does not exist 
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnFolderExists] (@p_folderName varchar(1024))
RETURNS bit
AS
BEGIN
   --DECLARE @error_object      int;
   --DECLARE @error_message     nvarchar(max);
   --DECLARE @error_source      varchar(255);
   --DECLARE @error_description varchar(255);
   --DECLARE @error_helpfile    varchar(255);
   --DECLARE @error_helpid      int;

   DECLARE @fs            AS int;
   DECLARE @oleResult     AS int;  
   DECLARE @folderExists  AS varchar(20);
   DECLARE @result        AS bit;

   SET @result       = 0;
   SET @p_folderName = LTRIM(RTRIM(@p_folderName));

   -- ----------------------------------------------------------------------
   -- Create File System Object
   -- ----------------------------------------------------------------------
   EXECUTE @oleResult = sp_OACreate 'Scripting.FileSystemObject', @fs OUT;
   --IF (@oleResult <> 0) 
   --   BEGIN
   --      EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
   --      SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
   --      SET @error_message     = CAST('Stored Function ' + OBJECT_NAME(@@PROCID) + ':sp_OACreate(Scripting.FileSystemObject) returns an error [' + CAST(@oleResult as nvarchar(100)) + ':' + @error_description + '].' AS int);
   --      RAISERROR (@error_message,16,1);
   --   END;

   -- ----------------------------------------------------------------------
   -- Call function 'FolderExists'
   -- ----------------------------------------------------------------------
   EXECUTE @oleResult = sp_OAMethod @fs, 'FolderExists', @folderExists OUT, @p_folderName;
   --IF (@oleResult <> 0) 
   --   BEGIN
   --      EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
   --      SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
   --      SET @error_message =  CAST('Stored Function ' + OBJECT_NAME(@@PROCID) + ':sp_OACreate(FolderExists) returns an error [' + CAST(@oleResult as nvarchar(100)) + ':' + @error_description + '].' AS int);
   --      RAISERROR (@error_message,16,1);
   --   END;

   -- ----------------------------------------------------------------------
   -- Destroy File System Object
   -- ----------------------------------------------------------------------
   EXEC @oleResult = sp_OADestroy @fs;   
   --IF (@oleResult <> 0) 
   --   BEGIN
   --      EXECUTE sp_OAGetErrorInfo @error_object, @error_source OUTPUT, @error_description OUTPUT, @error_helpfile OUTPUT,@error_helpid OUTPUT;
   --      SET @error_description = COALESCE(@error_description,'<no description available>', @error_description);
   --      SET @error_message =  CAST('Stored Function ' + OBJECT_NAME(@@PROCID) + ':sp_OADestroy returns an error [' + CAST(@oleResult as nvarchar(100)) + ':' + @error_description + '].' AS int);
   --      RAISERROR (@error_message,16,1);
   --   END

   SET @result = CASE WHEN @folderExists = 'True' THEN 1 ELSE 0 END;

   RETURN @result;
END
-- [dbo].[fnFolderExists]