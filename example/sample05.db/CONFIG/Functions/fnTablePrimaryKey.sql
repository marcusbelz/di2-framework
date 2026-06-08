-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 29.07.2019
-- Description: Returns primary column definition of a user defined table
--              - [SchemaId]      int
--              - [SchemaName]    sysname
--              - [TableID]       int
--              - [TableName]     sysname
--              - [ColumnId]      int
--              - [ColumnName]    sysname
--              - [IndexId]       int
--              - [IndexName]     sysname
--              - [IndexColumnID] int
--              - [IsIdentity]    bit
-- --------------------------------------------------------------------------------
CREATE FUNCTION [CONFIG].[fnTablePrimaryKey](@p_schemaName AS sysname, @p_tableName AS sysname)
RETURNS @returnValue TABLE 
(
    [SchemaID]      int
   ,[SchemaName]    sysname
   ,[TableID]       int
   ,[TableName]     sysname
   ,[ColumnID]      int
   ,[ColumnName]    sysname
   ,[IndexID]       int
   ,[IndexName]     sysname
   ,[IndexColumnID] int
   ,[IsIdentity]    bit
)   
AS
BEGIN
   INSERT INTO @returnvalue 
   (
       [SchemaID]
      ,[SchemaName]
      ,[TableID]
      ,[TableName]
      ,[ColumnID]
      ,[ColumnName]
      ,[IndexID]
      ,[IndexName]
      ,[IndexColumnID]
      ,[IsIdentity]
   )  
   SELECT 
        T01.[schema_id]       AS [SchemaID]
       ,T01.[name]            AS [SchemaName]
       ,T02.[object_id]       AS [TableID]
       ,T02.[name]            AS [TableName]
       ,T05.[column_id]       AS [ColumnID]
       ,T05.[name]            AS [ColumnName]
       ,T03.[index_id]        AS [IndexID]
       ,T03.[name]            AS [IndexName]
       ,T04.[index_column_id] AS [IndexColumnID]
       ,T05.[is_identity]     AS [IsIdentity]
   FROM 
      
      [sys].[schemas] T01
      INNER JOIN [sys].[tables] T02
      ON
        T01.[schema_id] = T02.[schema_id] 
      INNER JOIN [sys].[indexes] T03
      ON
        T02.[object_id] = T03.[object_id] 
      INNER JOIN [sys].[index_columns] T04 
      ON 
            T03.[object_id] = T04.[object_id] 
        AND T03.[index_id]  = T04.[index_id]
      INNER JOIN [sys].[columns] T05 
      ON 
            T04.[object_id] = T05.[object_id] 
        AND T04.[column_id] = T05.[column_id]
   WHERE 
          T03.[is_primary_key] = 1
      AND T01.[name] = @p_schemaName
      AND T02.[name] = @p_tableName;

   RETURN;
END;
-- SELECT * FROM [CONFIG].[fnTablePrimaryKey]('LOG', 'Execution')