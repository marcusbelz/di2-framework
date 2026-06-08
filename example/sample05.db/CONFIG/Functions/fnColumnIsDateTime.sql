-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2017
-- Description: The function checks in table [T1].[TableMetadata] whether 
--              the specified column is of type datetime. 
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_TableName             AS nvarchar(128)
--         
--    @p_ColumnName            AS nvarchar(128)
--         
-- --------------------------------------------------------------------------------
-- Return Value
--       1 = WHEN [DataType] = 'datetime'
--       0 = Else
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [CONFIG].[fnColumnIsDateTime] (@p_SchemaName AS nvarchar(128), @p_TableName AS nvarchar(128), @p_ColumnName AS nvarchar(128))
RETURNS bit
AS
BEGIN
  DECLARE @returnValue AS bit;

  
  SELECT    
      @returnValue = CASE WHEN [Datatype] = 'datetime' THEN 1 ELSE 0 END 
  FROM 
     [CONFIG].[TableMetadata]
  WHERE 
        [SchemaName] = @p_SchemaName
    AND [TableName]  = @p_TableName
    AND [ColumnName] = @p_ColumnName;

   RETURN @returnValue;
END
-- [CONFIG].[fnColumnIsDateTime]
