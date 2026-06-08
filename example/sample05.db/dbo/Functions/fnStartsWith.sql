-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Checks whether the input value starts with the passed 
--              pattern. Note, that this function is working case sensitive.
-- --------------------------------------------------------------------------------
-- Parameters : 
--   @p_input   nvarchar(max)
--      Value to be checked
--   @p_pattern nvarchar(max)
--      Value to be checked
--   @p_trim     bit
--      Specifies, whether the value is to be trimmed prior to be checking for 
--      an empty string or NULL.
-- --------------------------------------------------------------------------------
-- Return Value
--    Is NULL or empty = 1
--    Else             = 0
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnStartsWith] (@p_input nvarchar(max), @p_pattern nvarchar(max), @p_trim bit) RETURNS bit
AS
BEGIN
   DECLARE @result bit;
   SET @result = 0;
	
   IF (@p_input is NULL)          
      BEGIN
         SET @result = 0;
      END
   ELSE IF (@p_pattern is NULL)          
      BEGIN
         SET @result = 0;
      END
   ELSE 
      BEGIN
         IF @p_trim <> 0 
            BEGIN
               SET @p_input = LTRIM(RTRIM(@p_input))
            END;
         IF PATINDEX(@p_pattern +'%', @p_input COLLATE SQL_Latin1_General_CP1_CS_AS) > 0
            BEGIN
               SET @result = 1;
            END
         ELSE 
            BEGIN
               SET @result = 0;
            END
      END

   RETURN @result;
END
-- [dbo].[fnStartsWith]

-- SELECT [dbo].[fnStartsWith] (' abcde ', 'a' , 0) -- expected result: 0
-- SELECT [dbo].[fnStartsWith] (' abcde ', 'a' , 1) -- expected result: 1
-- SELECT [dbo].[fnStartsWith] (' abcde ', 'ab', 0) -- expected result: 0
-- SELECT [dbo].[fnStartsWith] (' abcde ', 'ab', 1) -- expected result: 1
-- SELECT [dbo].[fnStartsWith] (' abcde ', 'Ab', 0) -- expected result: 0
-- SELECT [dbo].[fnStartsWith] (' abcde ', 'Ab', 1) -- expected result: 0
