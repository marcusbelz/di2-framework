-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: This procedure inserts statements into [T1].[TableMetadata]. 
--              Based on this meta data the procedure [T1].[spLoadData] can build 
--              dynamic SQL statements for loading data from e.g. E1 to T1.
--
--              The meta data will be derived form a table that contains the final 
--              data types. The overall assumption is, that the same table existist 
--              in three layers:
--                E1 = Extraction
--                T1 = Checking Datatypes
--                T2 = Persists data (historisation)
--
--              Please note, that the column [PrimaryKey] must be set manually.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_schemaName            AS nvarchar(128)
--       Schema name of the table, that will be used to derive the meta data
--    @p_tableName             AS nvarchar(128)
--       Table name of the table, that will be used to derive the meta data
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 error
--      0 = success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180603 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [CONFIG].[spInsertTableMetadata]
(
    @p_schemaName            AS nvarchar(128)
   ,@p_tableName             AS nvarchar(128)
)
AS
BEGIN
   SET NOCOUNT ON

   -- --------------------------------------------------------------------------------
   -- Delete data 
   -- --------------------------------------------------------------------------------
   DELETE FROM [CONFIG].[TableMetadata] 
   WHERE 
          [SchemaName] = @p_schemaName
      AND [TableName]  = @p_tableName

   -- --------------------------------------------------------------------------------
   -- Insert data 
   -- --------------------------------------------------------------------------------
   INSERT INTO [CONFIG].[TableMetadata]
   (
       [SchemaName]
      ,[SchemaID]
      ,[TableID]
      ,[TableName]
      ,[ColumnID]
      ,[ColumnName]
      ,[Datatype]
      ,[MaxLength]
      ,[Precision]
      ,[Scale]
      ,[IsNullable]
      ,[IsIdentity]
      ,[IsUserDefined]
      ,[Collation]
      ,[IndexPrimaryKey]
      ,[IndexNonPrimaryKey]
   )
   SELECT
       T01.[SchemaName]
      ,T01.[SchemaID]
      ,T01.[TableID]
      ,T01.[TableName]
      ,T01.[ColumnID]
      ,T01.[ColumnName]
      ,T01.[Datatype]
      ,T01.[MaxLength]
      ,T01.[Precision]
      ,T01.[Scale]
      ,T01.[IsNullable]
      ,T01.[IsIdentity]
      ,T01.[IsUserDefined]
      ,T01.[Collation]
      ,T01.[IndexPrimaryKey]
      ,T01.[IndexNonPrimaryKey]
   FROM 
      [CONFIG].[fnTableDefinition](@p_schemaName, @p_tableName) T01
   WHERE
          T01.[IsUserDefined] = 1
      AND T01.[ColumnName] NOT IN ( 'ID'                  -- Include all columns from the T2 table, 
                                   ,'ExecutionID'         -- that are not part of the E1 table. 
                                  )                       --
      AND T01.[ColumnName] NOT LIKE 'Sys%';               -- Exclude column names beginning with the prefix "Sys"

   RETURN 0;
END;
-- [CONFIG].[spInsertTableMetadata]

-- EXEC [CONFIG].[spInsertTableMetadata] 'T2', 'Test';
-- SELECT * FROM [CONFIG].[TableMetadata]
-- TRUNCATE TABLE [CONFIG].[TableMetadata]
-- DELETE FROM [CONFIG].[TableMetadata] WHERE [TableName] = ''