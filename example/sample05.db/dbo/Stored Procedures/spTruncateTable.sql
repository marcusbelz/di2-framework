-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Truncates the specified table with EXECUTE AS OWNER statement
-- --------------------------------------------------------------------------------
-- Parameters
--    @p_tableSchema           AS nvarchar(128)
--       Schema of the table to be truncated
--    @p_tableName             AS nvarchar(128)
--       Table name of the table to be truncated
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 error
--      0 = success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spTruncateTable]
    @p_tableSchema           AS nvarchar(128)
   ,@p_tableName             AS nvarchar(128)
WITH EXECUTE AS OWNER
AS 
BEGIN
   SET NOCOUNT ON;

   DECLARE @sql nvarchar(max);

   SET @sql = N'TRUNCATE TABLE [' + @p_tableSchema + N'].[' + @p_tableName + N']';

   EXEC [dbo].[sp_executesql] @sql;

   RETURN 0;
END
-- [dbo].[spTruncateTable]

-- EXEC [dbo].[spTruncateTable] N'T1', N'Test'