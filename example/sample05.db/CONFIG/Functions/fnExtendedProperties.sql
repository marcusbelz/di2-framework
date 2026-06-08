-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 27.09.2018
-- Description: Returns extended properties for objects or columns
--              - [SchemaName]            sysname
--              - [TableName]             sysname
--              - [ColumnName]            sysname
--              - [Datatype]              sysname
--              - [ExtendedPropertyName]  sysname
--              - [ExtendedPropertyValue] sql_variant
--              - [MaxLength]             smallint
--              - [IsNullable]            bit
--              - [Collation]             sysname
--              - [TableCreatedOn]        datetime 
--              - [TableModifiedOn]       datetime 
-- --------------------------------------------------------------------------------
CREATE FUNCTION [CONFIG].[fnExtendedProperties](@p_schemaName AS sysname, @p_tableName AS sysname)
RETURNS @returnValue TABLE 
(
    [SchemaName]            sysname
   ,[TableName]             sysname
   ,[ColumnName]            sysname
   ,[ExtendedPropertyName]  sysname
   ,[ExtendedPropertyValue] sql_variant
   ,[Datatype]              sysname
   ,[MaxLength]             smallint
   ,[IsNullable]            bit
   ,[Collation]             sysname
   ,[TableCreatedOn]        datetime 
   ,[TableModifiedOn]       datetime 
)   
AS
BEGIN
   INSERT INTO @returnvalue 
   (
       [SchemaName]
      ,[TableName]
      ,[ColumnName]
      ,[ExtendedPropertyName]
      ,[ExtendedPropertyValue]
      ,[Datatype]
      ,[MaxLength]
      ,[IsNullable]
      ,[Collation]
      ,[TableCreatedOn]
      ,[TableModifiedOn]
   )   
   SELECT
       T06.[name]                                       AS [SchemaName]
      ,T01.[name]                                       AS [TableName]
      ,T04.[name]                                       AS [ColumnName]
      ,T02.[name]                                       AS [ExtendedPropertyName]
      ,T02.[value]                                      AS [ExtendedPropertyValue]
      ,T05.[name]                                       AS [DataType]
      ,CASE WHEN T05.[name] = 'nvarchar' OR T05.[name] = 'nchar' OR T05.[name] = 'sysname'  
          THEN T03.[max_length] / 2 
          ELSE T03.[max_length] 
       END                                              AS [MaxLength] 
      ,T03.[is_nullable]                                AS [IsNullable]
      ,COALESCE(T03.[collation_name], '')               AS [Collation]
      ,T04.[create_date]                                AS [TableCreatedOn]
      ,T04.[modify_date]                                AS [TableModifiedOn]
   FROM 
      [sys].[tables] AS T01
      LEFT JOIN [sys].[extended_properties] AS T02
      ON 
        T02.[major_id] = T01.[object_id]
      LEFT JOIN [sys].[columns] AS T03
      ON 
            T02.[major_id] = T03.[object_id]
        AND T02.[minor_id] = T03.[column_id]
      LEFT JOIN [sys].[objects] as T04
      ON 
        T01.[object_id] = T04.[object_id]
      INNER JOIN [sys].[types] AS T05
      ON 
        T03.[user_type_id] = T05.[user_type_id]
      LEFT JOIN [sys].[schemas] T06
      ON
        T01.[schema_id] = T06.[schema_id]
   WHERE 
          T02.[class] = 1        
      AND T06.[name] = @p_schemaName
      AND T01.[name] = @p_tableName;

   RETURN;
END;
-- SELECT * FROM [CONFIG].[fnExtendedProperties]('LOG', 'Execution')