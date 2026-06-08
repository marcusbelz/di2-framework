-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Checks whether the input value ends with the passed 
--              pattern. Note, that this function is working case sensitive.
-- --------------------------------------------------------------------------------
-- Parameters : 
--   @p_input   AS nvarchar(max)
--      Value to be checked
--   @p_pattern AS nvarchar(max)
--      Value to be checked
--   @p_trim    AS bit
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
CREATE FUNCTION [dbo].[fnEndsWith] (@p_input AS nvarchar(max), @p_pattern AS nvarchar(max), @p_trim AS bit) RETURNS bit
AS
BEGIN
   DECLARE @result    bit;
   DECLARE @substring nvarchar(max);

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
               SET @p_input = LTRIM(RTRIM(@p_input));
            END;
            
         IF PATINDEX('%' + @p_pattern, @p_input COLLATE SQL_Latin1_General_CP1_CS_AS) > 0
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
-- [dbo].[fnEndsWith]

-- SELECT [dbo].[fnEndsWith] (' abcde ', 'e' , 0) -- expected value: 0
-- SELECT [dbo].[fnEndsWith] (' abcde ', 'e' , 1) -- expected value: 1
-- SELECT [dbo].[fnEndsWith] (' abcde ', 'E' , 0) -- expected value: 0
-- SELECT [dbo].[fnEndsWith] (' abcde ', 'E' , 1) -- expected value: 0
-- SELECT [dbo].[fnEndsWith] (' abcde ', 'de', 0) -- expected value: 0
-- SELECT [dbo].[fnEndsWith] (' abcde ', 'de', 1) -- expected value: 1
-- SELECT [dbo].[fnEndsWith] (' abcde ', 'De', 0) -- expected value: 0
-- SELECT [dbo].[fnEndsWith] (' abcde ', 'De', 1) -- expected value: 0