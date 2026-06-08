CREATE TABLE [LOG].[Error] (
    [ID]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [ExecutionID]     INT            NOT NULL,
    [ComponentID]     INT            NULL,
    [TraceID]         INT            NULL,
    [ErrorType]       CHAR (1)       NOT NULL,
    [Source]          NVARCHAR (5)   NOT NULL,
    [Component]       NVARCHAR (128) NOT NULL,
    [TaskName]        NVARCHAR (128) NULL,
    [Entity]          NVARCHAR (128) NULL,
    [Step]            NVARCHAR (MAX) NULL,
    [SchemaName]      NVARCHAR (128) NULL,
    [TableName]       NVARCHAR (128) NULL,
    [ID1Value]        NVARCHAR (MAX) NULL,
    [ID1ColumnName]   NVARCHAR (128) NULL,
    [ID2Value]        NVARCHAR (MAX) NULL,
    [ID2ColumnName]   NVARCHAR (128) NULL,
    [ID3Value]        NVARCHAR (MAX) NULL,
    [ID3ColumnName]   NVARCHAR (128) NULL,
    [ErrorValue]      NVARCHAR (MAX) NULL,
    [ErrorColumnName] NVARCHAR (128) NULL,
    [FileName]        NVARCHAR (128) NULL,
    [Description]     NVARCHAR (MAX) NULL,
    [Number]          INT            NULL,
    [Line]            INT            NULL,
    [State]           NVARCHAR (MAX) NULL,
    [CreatedOn]       DATETIME       CONSTRAINT [DF_LOG_Error_CreatedOn] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]       NVARCHAR (100) CONSTRAINT [DF_LOG_Error_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_LOG_Error] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LOG_Error_ExecutionID] FOREIGN KEY ([ExecutionID]) REFERENCES [LOG].[Execution] ([ID])
);








GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  13:18:33', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user that has created the row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date of creation of the log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'T-SQL ERROR: Error State', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'T-SQL ERROR: Line Number', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Line';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'T-SQL ERROR: Error Number', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Number';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Description of the error.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Filename, if the error is related to a file.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the column name that holds the erroneous value.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ErrorColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the erroneous value.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ErrorValue';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the third column name of the Primary Key column if available.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID3ColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the third Primary Key value if available.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID3Value';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the second column name of the Primary Key column if available.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID2ColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the second Primary Key value if available.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID2Value';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the column name of the Primary Key column.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID1ColumnName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the Primary Key value.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID1Value';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the table that contains an erroneous row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifies the schema of the table that contains an erroneous row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Inserting Data', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Overall description of what the component is doing.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Country', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Entity';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Overall entity, the component is dealing with.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Entity';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Name of the SSIS Task if available.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'TaskName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'T-SQL Procedure -or- SSIS-Package', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Name of the component, that has written this log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'T-SQL -or- SSIS', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Source';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates the artifact, that has written this log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'Source';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'E -or- W -or- I', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ErrorType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates the severity of the error entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ErrorType';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'E=Error
W=Warning
I=Information', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ErrorType';






GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Foreign key to the table Trace.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'TraceID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ComponentID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Foreign key to the table Component.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ComponentID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Foreign key to the table Execution.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifier', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Error', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Table contains logging information for each defined trace in the ETL package', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'LOG', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Error';

