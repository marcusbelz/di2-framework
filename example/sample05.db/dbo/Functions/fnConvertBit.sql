-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Converts a character ('J', 'N', ' ') to into a value with type of 
--              bit. 
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_value as nvarchar(8)
--       Boolean values: e.g. 'J', 'N', '1', '0', ' '
-- --------------------------------------------------------------------------------
-- Return Value
--       1    = When @p_value = 'J' (case-insensitive)
--       1    = When @p_value = '1'
--       0    = When @p_value = 'N' (case-insensitive)
--       0    = When @p_value = '0'
--       0    = When @p_value = ' '
--       0    = When @p_value = ''
--       NULL = Else
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnConvertBit] (@p_value AS nvarchar(5))
RETURNS bit
AS
BEGIN
   DECLARE @returnValue AS bit;

   IF @p_value IS NULL
      BEGIN
         SET @returnValue = NULL;
      END
   ELSE
      BEGIN
         SET @p_value = UPPER(LTRIM(@p_value));
         SET @returnValue = CASE @p_value
                               WHEN '1'     THEN 1
                               WHEN '0'     THEN 0
                               WHEN 'J'     THEN 1
                               WHEN 'N'     THEN 0
                               WHEN 'TRUE'  THEN 1
                               WHEN 'FALSE' THEN 0
                               WHEN ''      THEN 0
                               ELSE NULL
                            END;
      END;

   RETURN @returnValue;
END
-- [dbo].[fnConvertBit]

-- SELECT [dbo].[fnConvertBit]('1')
-- SELECT [dbo].[fnConvertBit]('0')
-- SELECT [dbo].[fnConvertBit]('J')
-- SELECT [dbo].[fnConvertBit]('N')
-- SELECT [dbo].[fnConvertBit](' ')
-- SELECT [dbo].[fnConvertBit]('X')
-- SELECT [dbo].[fnConvertBit](NULL)
-- SELECT [dbo].[fnConvertBit]('true')
-- SELECT [dbo].[fnConvertBit]('false')
