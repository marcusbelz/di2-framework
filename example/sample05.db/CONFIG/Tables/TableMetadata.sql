CREATE TABLE [CONFIG].[TableMetadata] (
    [SchemaID]           INT            NOT NULL,
    [SchemaName]         NVARCHAR (128) NOT NULL,
    [TableID]            INT            NOT NULL,
    [TableName]          NVARCHAR (128) NOT NULL,
    [ColumnID]           INT            NOT NULL,
    [ColumnName]         NVARCHAR (128) NOT NULL,
    [Datatype]           NVARCHAR (128) NOT NULL,
    [MaxLength]          INT            NULL,
    [Precision]          INT            NULL,
    [Scale]              INT            NULL,
    [IsNullable]         BIT            NULL,
    [IsIdentity]         BIT            NULL,
    [IsUserDefined]      BIT            NULL,
    [Collation]          NVARCHAR (128) NULL,
    [IndexPrimaryKey]    INT            NULL,
    [IndexNonPrimaryKey] INT            NULL,
    [NullHandling]       CHAR (1)       NULL,
    [CheckData]          BIT            CONSTRAINT [DF_CONFIG_TableMetadata_CheckData] DEFAULT ((1)) NOT NULL,
    [DecodeXML]          BIT            CONSTRAINT [DF_CONFIG_TableMetadata_DecodeXML] DEFAULT ((0)) NOT NULL,
    [DateStyle]          NVARCHAR (50)  NULL,
    CONSTRAINT [PK_CONFIG_TableMetadata] PRIMARY KEY CLUSTERED ([SchemaName] ASC, [TableName] ASC, [ColumnName] ASC)
);
























GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'In case of date, datetime or similar base types, this column holds common format strings that describe the format of date/dateti', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'DateStyle';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates, whether the procedure spLoadData must decode specical XML characters (e.g. &amp;) when loading data from schema E1 to', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'DecodeXML';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates, whether the procedure spLoadData must check the data format when loading data from schema E1 to T1. Checking the data', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'CheckData';




GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'I -or- W -or- E', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'NullHandling';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates whether nullable columns are to be checked for NULLs.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'NullHandling';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Missing values in not nullable columns will always be logged as an error.
Missing values in nullable columns can be additionally', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'NullHandling';

























GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Collation Name', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Collation';




GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Coulmn is Nullable', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsNullable';




GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Datatype Scale', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Scale';




GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Datatype Precision', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Precision';




GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Datatype Length', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'MaxLength';




GO





GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Column Name', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Table Name', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'TableMetadata', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'One row in the table [T1].[TableMetadata] 
represents one column in a table of the source system.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata';
















GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'CONFIG', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[tables]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[name]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Scale';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Scale';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[scale]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Scale';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Precision';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Precision';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[precision]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Precision';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'MaxLength';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'MaxLength';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'MaxLength';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[max_length]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'MaxLength';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'This values specifies the number o characters and not the number o bytes.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'MaxLength';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsNullable';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsNullable';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[is_nullable]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsNullable';


GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[name]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Collation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Collation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[collation]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Collation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[tables]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[object_id]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Table ID', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableID';


GO
EXECUTE sp_addextendedproperty @name = N'AK1', @value = N'X', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'TableID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[schemas]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[name]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Destination Schema', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[schemas]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[schema_id]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Schema ID', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaID';


GO
EXECUTE sp_addextendedproperty @name = N'AK1', @value = N'X', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'SchemaID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Table is User Defined', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsUserDefined';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'True if [sys].[tables].[type] = ''U''', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsUserDefined';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsIdentity';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsIdentity';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[is_identity]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsIdentity';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Coulmn is Identity', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IsIdentity';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[index_columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexPrimaryKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexPrimaryKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[index_column_id]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexPrimaryKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Index of Primary Key Columns', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexPrimaryKey';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'The index will be used to automatically calculate a hash value over the primary columns. 
If a primary key covers more than one ', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexPrimaryKey';








GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexNonPrimaryKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Index of Non Primary Key Columns', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexNonPrimaryKey';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'All non primary key columns are indexed beginning with one along the column [sys].[columns].[column_id].', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'IndexNonPrimaryKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[columns]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[column_id]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Table ID', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnID';


GO
EXECUTE sp_addextendedproperty @name = N'AK1', @value = N'X', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'ColumnID';


GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'[types]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Datatype';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'[sys]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Datatype';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'[Datatype]', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Datatype';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SQL Server Datatype Name', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'TableMetadata', @level2type = N'COLUMN', @level2name = N'Datatype';

