-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Checks whether the passed value is either an empty string or NULL.
-- --------------------------------------------------------------------------------
-- Parameters : 
--   @input AS nvarchar(max)
--      Input string to be checked.
--   @trim  AS bit
--      Specifies, whether the input string is to be trimmed prior to checking the 
--      input string for an empty string or NULL.
-- --------------------------------------------------------------------------------
-- Return Value
--    Is NULL -or- empty = 1
--    ELSE               = 0
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnIsNullOrEmpty] (@input AS nvarchar(max), @trim AS bit) RETURNS bit
AS
BEGIN
   DECLARE @result bit;
   SET @result = 0;
   
   IF (@input is NULL)          
      SET @result = 1
   ELSE 
      BEGIN
         IF @trim = 1 
            BEGIN
               SET @input = LTRIM(LTRIM(@input));
            END;

         IF DATALENGTH(@input) = 0 
            BEGIN
               SET @result = 1;
            END
         ELSE
            BEGIN
               SET @result = 0;
            END
      END;   
   RETURN @result;
END
--[dbo].[fnIsNullOrEmpty]

--SELECT [dbo].[fnIsNullOrEmpty] (NULL , 0) -- expected result: 1
--SELECT [dbo].[fnIsNullOrEmpty] (NULL , 1) -- expected result: 1
--SELECT [dbo].[fnIsNullOrEmpty] (''   , 0) -- expected result: 1
--SELECT [dbo].[fnIsNullOrEmpty] (''   , 1) -- expected result: 1
--SELECT [dbo].[fnIsNullOrEmpty] (' '  , 0) -- expected result: 0
--SELECT [dbo].[fnIsNullOrEmpty] (' '  , 1) -- expected result: 1
--SELECT [dbo].[fnIsNullOrEmpty] ('  ' , 0) -- expected result: 0
--SELECT [dbo].[fnIsNullOrEmpty] ('  ' , 1) -- expected result: 1
--SELECT [dbo].[fnIsNullOrEmpty] (' X ', 0) -- expected result: 0
--SELECT [dbo].[fnIsNullOrEmpty] (' X ', 1) -- expected result: 0
