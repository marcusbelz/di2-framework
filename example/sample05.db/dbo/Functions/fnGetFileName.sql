-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Extractes the file name from a full file name.
-- 
-- --------------------------------------------------------------------------------
-- Parameters : 
--   @p_fullFileName  AS nvarchar(1024)
--      Full file name of the file to be parsed.
-- --------------------------------------------------------------------------------
-- Return Value
--    filename
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnGetFileName] (@p_fullFileName AS nvarchar(1024))
RETURNS nvarchar(1024)
AS
BEGIN
   --DECLARE @error_object      int;
   --DECLARE @error_message     nvarchar(max);
   --DECLARE @error_source      varchar(255);
   --DECLARE @error_description varchar(255);
   --DECLARE @error_helpfile    varchar(255);
   --DECLARE @error_helpid      int;

   DECLARE @result            nvarchar(1024);

   SET @p_fullFileName = LTRIM(RTRIM(@p_fullFileName));
   SET @result         = N'';

   IF CHARINDEX('\', REVERSE(@p_fullFileName)) = 0
      BEGIN
         SET @result = @p_fullFileName;  
      END
   ELSE
      BEGIN
         SET @result =  RIGHT(@p_fullFileName, CHARINDEX('\', REVERSE(@p_fullFileName)) -1);
      END;

   RETURN @result;
END
-- [dbo].[fnGetFileName]
-- EXEC [dbo].[fnGetFileName]('c:\temp\readme.txt');