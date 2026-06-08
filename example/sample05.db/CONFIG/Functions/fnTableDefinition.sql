-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 29.07.2019
-- Description: Returns column definitions of user defined tables
--              - [SchemaID]           int
--              - [SchemaName]         sysname
--              - [TableID]            int
--              - [TableName]          sysname
--              - [ColumnID]           int
--              - [ColumnName]         sysname
--              - [Datatype]           sysname
--              - [MaxLength]          smallint
--              - [Precision]          tinyint
--              - [Scale]              tinyint
--              - [IsNullable]         bit
--              - [IsIdentity]         bit
--              - [IsUserDefined]      bit       -> [sys].[tables].[type] = 'U' 
--              - [Collation]          sysname
--              - [IndexPrimaryKey]    int
--              - [IndexNonPrimaryKey] int
-- --------------------------------------------------------------------------------
CREATE FUNCTION [CONFIG].[fnTableDefinition](@p_schemaName AS sysname, @p_tableName AS sysname)
RETURNS @returnValue TABLE 
(
    [SchemaID]           int
   ,[SchemaName]         sysname
   ,[TableID]            int
   ,[TableName]          sysname
   ,[ColumnID]           int
   ,[ColumnName]         sysname
   ,[Datatype]           sysname
   ,[MaxLength]          smallint
   ,[Precision]          tinyint
   ,[Scale]              tinyint
   ,[IsNullable]         bit
   ,[IsIdentity]         bit
   ,[IsUserDefined]      bit
   ,[Collation]          sysname
   ,[IndexPrimaryKey]    int
   ,[IndexNonPrimaryKey] int
)   
AS
BEGIN
   WITH
   CTE_base AS
   (
      SELECT
          T01.[schema_id]                    AS [SchemaID]
         ,T01.[name]                         AS [SchemaName]
         ,T02.[object_id]                    AS [TableID]
         ,T02.[name]                         AS [TableName]
         ,T03.[column_id]                    AS [ColumnID]
         ,T03.[name]                         AS [ColumnName]
         ,T04.[name]                         AS [Datatype]
         ,CASE WHEN T04.[name] = N'nvarchar' OR T04.[name] = N'nchar' OR T04.[name] = N'sysname'  
             THEN T03.[max_length] / 2 
             ELSE T03.[max_length] 
          END                                AS [MaxLength] 
         ,T03.[precision]                    AS [Precision]
         ,T03.[scale]                        AS [Scale]
         ,T03.[is_nullable]                  AS [IsNullable]
         ,T03.[is_identity]                  AS [IsIdentity]   
         ,CAST(CASE WHEN T02.[type] = 'U' THEN 1 ELSE 0 END AS bit) AS [IsUserDefined]
         ,COALESCE(T03.[collation_name], '') AS [Collation]
         ,CASE WHEN T05.[IndexColumnID] IS NOT NULL THEN T05.[IndexColumnID] ELSE 0 END AS [IndexPrimaryKey]
      FROM 
         [sys].[schemas] T01
         LEFT JOIN [sys].[tables] T02
         ON
           T01.[schema_id] = T02.[schema_id]
         LEFT JOIN [sys].[columns] T03
         ON
           T02.[object_id] = T03.[object_id]
         LEFT JOIN [sys].[types] T04
         ON
           T03.[system_type_id] = T04.[user_type_id]
         LEFT JOIN [CONFIG].[fnTablePrimaryKey](@p_schemaName, @p_tableName) T05
         ON
               T01.[schema_id] = T05.[SchemaID] 
           AND T02.[object_id] = T05.[TableID]
           AND T03.[column_id] = T05.[IndexColumnID]
      WHERE
             T02.[type] = 'U'
         AND T01.[name] = @p_schemaName
         AND T02.[name] = @p_tableName
   )
   ,CTE_sortedNonPrimaryKeyColumns AS
   (
      SELECT
          [SchemaID]
         ,[TableID]
         ,[ColumnID]
         ,ROW_NUMBER() OVER (ORDER BY [ColumnID]) [IndexNonPrimaryKey]
      FROM 
         CTE_base
      WHERE 
         [IndexPrimaryKey] = 0
   )
   INSERT INTO @returnvalue 
   (
       [SchemaID]
      ,[SchemaName]
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
       T01.[SchemaID]                        AS [SchemaID]
      ,T01.[SchemaName]                      AS [SchemaName]
      ,T01.[TableID]                         AS [TableID]
      ,T01.[TableName]                       AS [TableName]
      ,T01.[ColumnID]                        AS [ColumnID]
      ,T01.[ColumnName]                      AS [ColumnName]
      ,T01.[Datatype]                        AS [DataType]
      ,T01.[MaxLength]                       AS [MaxLength] 
      ,T01.[Precision]                       AS [precision]
      ,T01.[Scale]                           AS [scale]
      ,T01.[IsNullable]                      AS [IsNullable]
      ,T01.[IsIdentity]                      AS [IsIdentity]
      ,T01.[IsUserDefined]                   AS [IsUserDefined]
      ,T01.[Collation]                       AS [Collation]
      ,T01.[IndexPrimaryKey]                 AS [IndexPrimaryKey]
      ,COALESCE(T02.[IndexNonPrimaryKey], 0) AS [IndexNonPrimaryKey]
   FROM 
      CTE_base T01
      LEFT JOIN CTE_sortedNonPrimaryKeyColumns T02
      ON
            T01.[SchemaID] = T02.[SchemaID]
        AND T01.[TableID]  = T02.[TableID]
        AND T01.[ColumnID] = T02.[ColumnID]   

   RETURN;
END;
-- SELECT * FROM [CONFIG].[fnTableDefinition]('CONFIG', 'TableMetadata')
--SELECT * FROM [sys].[columns]