CREATE TABLE [CONFIG].[CheckConstraint] (
    [ID]              INT             IDENTITY (1, 1) NOT NULL,
    [ProcedureName]   NVARCHAR (128)  NOT NULL,
    [ErrorType]       CHAR (1)        NOT NULL,
    [Task]            NVARCHAR (128)  NULL,
    [Entity]          NVARCHAR (MAX)  NOT NULL,
    [Step]            NVARCHAR (MAX)  NOT NULL,
    [SchemaName]      NVARCHAR (10)   NOT NULL,
    [TableName]       NVARCHAR (64)   NOT NULL,
    [Id1_FieldName]   NVARCHAR (64)   NOT NULL,
    [Id2_FieldName]   NVARCHAR (64)   NULL,
    [Id3_FieldName]   NVARCHAR (64)   NULL,
    [Check_FieldName] NVARCHAR (1000) NOT NULL,
    [Constraint]      NVARCHAR (256)  NOT NULL,
    [MaxOccurance]    NCHAR (10)      NULL,
    [Message]         NVARCHAR (MAX)  NOT NULL,
    [Description]     NVARCHAR (MAX)  NULL,
    [ActiveFlag]      BIT             NOT NULL,
    [ManualFlag]      BIT             NULL,
    CONSTRAINT [PK_CONFIG_CheckConstraint] PRIMARY KEY CLUSTERED ([ID] ASC)
);










GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates, wther the check was created manually.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'ManualFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates whether the check will be executed.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'ActiveFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Description of the check.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Message that will be logged with each error.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Message';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'With respect to unique check, this column holds the maximum count of grouped records.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'MaxOccurance';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'WHERE clause that will be checked. ', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Constraint';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Field name of the field that contains the error.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Check_FieldName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Primary key 3 field name of the record the error is related to.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Id3_FieldName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Primary key 2 field name of the record the error is related to.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Id2_FieldName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Primary key 1 field name of the record the error is related to.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Id1_FieldName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Specifies the table name of the table that contains the error.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Specifies the schema name of the table that contains the error.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Describe the step, that invokes this check.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Name of the table that is involved in this check.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Entity';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Task Name', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Task';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'SSIS specific', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'Task';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'I -or- W -or- E', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'ErrorType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Severity of the error.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'ErrorType';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'All rows that match the WHERE clause will be logged with the specified severity. Possible values:
I = Information
W = Warning
E ', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'ErrorType';








GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Name of the procedrue to be executed in order to check this constraint.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'ProcedureName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifier', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'CheckConstraint', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Table contains check constraint to be checked while loading data.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'CONFIG', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'CheckConstraint';

