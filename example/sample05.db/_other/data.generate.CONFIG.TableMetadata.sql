-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 17.09.2019
-- Description: Inserts metadata into table [CONFIG].[TableMetadata]
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------


USE [sample05]
GO
-- --------------------------------------------------------------------------------
-- Insert data for [T2].[Test]
-- --------------------------------------------------------------------------------
DELETE FROM [CONFIG].[TableMetadata] 
WHERE
       [SchemaName] = N'T2'
   AND [TableName]  = N'Test';

EXEC [CONFIG].[spInsertTableMetadata] N'T2', N'Test';

-- --------------------------------------------------------------------------------
-- Statements for a manual update on specific columns
-- --------------------------------------------------------------------------------
UPDATE [CONFIG].[TableMetadata]
   SET 
      [DateStyle] = 'yyyy-mm-dd hh:mi:ss'
WHERE 
      [SchemaName] = 'T2'
  AND [ColumnName] IN ('DateCreated', 'DateModified');

-- --------------------------------------------------------------------------------
-- [TableMetadata].[NullHandling]
-- --------------------------------------------------------------------------------
-- Indicates whether nullable columns are to be checked for NULLs.
--
-- Missing values in not nullable columns will always be logged as an error.
-- Missing values in nullable columns can be additionally logged in the 
-- table [LOG].[Error] if the column [NullHandling] is set to either I, W or E.
--   I = Information
--   W = Warning
--   E = Error
-- This setting will queried by those SQL statements that populate the table 
-- [CONFIG].[CheckConstraint].
-- --------------------------------------------------------------------------------
--DECLARE @schema AS nvarchar(128);
--DECLARE @table  AS nvarchar(128);
--DECLARE @column AS nvarchar(128);
--SET @schema  = 'T1';
--SET @table   = 'Country';
--SET @column  = 'CountryLanguageCode';
--UPDATE [CONFIG].[TableMetaData] SET [NullHandling] = 'W' WHERE [DestinationSchemaName] = @schema AND [TableName] = @table AND [ColumnName] = @column;

-- --------------------------------------------------------------------------------
-- [TableMetadata].[PrimaryKey]
-- --------------------------------------------------------------------------------
-- Indicates whether a column is part of the primary key in the source system. 
-- If a primary key covers more than one column, the primary key columns must be 
-- indexed in ths field beginning with 1.
-- 
-- The index will be used to automaticlly a hash value over the primary columns. 
-- This hash value will be used for identifying the action (INSERT, UPDATE) of 
-- a row.
-- --------------------------------------------------------------------------------
--DECLARE @schema AS nvarchar(128);
--DECLARE @table  AS nvarchar(128);
--SET @schema  = 'T1';
--SET @table   = 'Language';
--UPDATE [CONFIG].[TableMetaData] SET [PrimaryKey] = 1 WHERE [DestinationSchemaName] = @schema AND [TableName] = @table AND [ColumnName] = 'LanguageCode';
--UPDATE [CONFIG].[TableMetaData] SET [PrimaryKey] = 2 WHERE [DestinationSchemaName] = @schema AND [TableName] = @table AND [ColumnName] = 'LanguageName';

-- --------------------------------------------------------------------------------
-- [TableMetadata].[CheckData]
-- --------------------------------------------------------------------------------
-- Indicates, whether to check the data for a specific field. By default, this 
-- value for all data columns.
-- If this value is set to 1 then the corresponding table in schema T1 must 
-- have an additional column with the suffix _T1.
-- The procedure [T1].[spLoadData] uses two columns to identify problems with 
-- data conversions:
--    [columName]
--    [columName_E1]
-- If this value is set to 0 the value will be passed without any check to schema 
-- T1. In this case you must make sure, that no exception will occur when passing 
-- data from E1 to T1. Otherwise any transaction (single INSERT statement) will 
-- fail.
-- --------------------------------------------------------------------------------
--DECLARE @schema AS nvarchar(128);
--DECLARE @table  AS nvarchar(128);
--SET @schema  = 'T1';
--SET @table   = 'Language';
--UPDATE [CONFIG].[TableMetaData] SET [CheckData] = 0 WHERE [DestinationSchemaName] = @schema AND [TableName] = @table AND [ColumnName] = 'LanguageCode';

-- --------------------------------------------------------------------------------
-- [TableMetadata].[DecodeXML]
-- --------------------------------------------------------------------------------
-- Indicates, whether the procedure [T1].[spLoadData] must decode specical XML 
-- characters (e.g. &amp;) when loading data from schema E1 to T1. This applies 
-- only to field with the underlying data type 'text'.
-- --------------------------------------------------------------------------------
--DECLARE @schema AS nvarchar(128);
--DECLARE @table  AS nvarchar(128);
--SET @schema  = 'T1';
--SET @table   = 'Language';
--UPDATE [CONFIG].[TableMetaData] SET [DecodeXML] = 0 WHERE [DestinationSchemaName] = @schema AND [TableName] = @table AND [ColumnName] = 'LanguageCode';

-- --------------------------------------------------------------------------------
-- [TableMetadata].[DateStyle]
-- --------------------------------------------------------------------------------
-- In case of date, datetime or similar base types, this column holds common 
-- format strings that describe the format of date/datetime values. This applies 
-- only to field with the underlying data type 'date' ore 'datetime'.
-- --------------------------------------------------------------------------------
--DECLARE @schema AS nvarchar(128);
--DECLARE @table  AS nvarchar(128);
--SET @schema  = 'T1';
--SET @table   = 'Language';
--UPDATE [CONFIG].[TableMetaData] SET [DateStyle] = 'DD/MM/YYYY HH:mi:ss:mmmAM' WHERE [DestinationSchemaName] = @schema AND [TableName] = @table AND [ColumnName] = 'CreatedOn';
