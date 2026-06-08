-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Returns for the passed key the value from table 
--              [CONFIG].[Configuration].
-- --------------------------------------------------------------------------------
-- Parameters : 
--   @key nvarchar(100)
--      Key for which the value is to be retrieved.
-- --------------------------------------------------------------------------------
-- Return  :
--       Value from table [CONFIG].[Configuration].
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [CONFIG].[fnFetchConfigValue] (@p_group AS nvarchar(32), @p_code AS nvarchar(32)) RETURNS nvarchar(max)
AS 
BEGIN
   DECLARE @result    nvarchar(max);

   IF @p_group IS NULL OR LTRIM(RTRIM(@p_group)) = '' OR @p_code IS NULL OR LTRIM(RTRIM(@p_code)) = ''
      BEGIN
         SET @result = NULL;
      END
   ELSE
      BEGIN
         SET @p_group = LOWER(LTRIM(RTRIM(@p_group)));
         SET @p_code  = LOWER(LTRIM(RTRIM(@p_code )));
         SELECT 
            @result = [Value] 
         FROM 
            [CONFIG].[Configuration] 
         WHERE 
                LOWER([Group]) = @p_group
            AND LOWER([Code])  = @p_code;

      END;

   RETURN @result;
END
--[CONFIG].[fnFetchConfigValue] 

-- SELECT [CONFIG].[fnFetchConfigValue]('a','b')