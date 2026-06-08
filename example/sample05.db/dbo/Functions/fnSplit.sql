-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Extracts the elements of a comma separated list and returns the 
--              values as a table
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_value     varchar(max)
--       Comma separated List
--    @p_separator char(1)
--       Separator
-- --------------------------------------------------------------------------------
-- Return Value
--       Table with elements 
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnSplit](@p_value AS varchar(max), @p_separator AS char(1))
RETURNS @returnValue TABLE ([Value] varchar(255))
AS
BEGIN
   DECLARE @item      varchar(max);
   DECLARE @rest      varchar(max);
   DECLARE @nextsepat bigint;
   DECLARE @break     bit;
      
   SET @rest      = @p_value;
   SET @nextsepat = CHARINDEX(@p_separator, @p_value);
   SET @break     = 0;
      
   WHILE (@nextsepat is not NULL and @rest <> '') 
      BEGIN
         IF (@nextsepat = 0) 
            BEGIN
               INSERT INTO @returnvalue VALUES(@rest);
               BREAK;
            END
         ELSE
            BEGIN 
               SET @item = LEFT(@rest, @nextsepat -1) ;

               INSERT INTO @returnvalue values(@item);
               
               SET @rest = right(@rest, LEN(@rest)  - @nextsepat);
               SET @nextsepat = CHARINDEX(@p_separator, @rest);
            END;
      END;
      
   RETURN;
END
-- [dbo].[fnSplit] 

-- SELECT * FROM [dbo].[fnSplit] ('A,B,C', ',');
-- SELECT * FROM [dbo].[fnSplit] ('A,B,C,', ',');
-- SELECT * FROM [dbo].[fnSplit] (NULL, ',');
