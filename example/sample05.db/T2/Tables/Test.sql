CREATE TABLE [T2].[Test] (
    [ID]                        INT             NOT NULL,
    [Status]                    NVARCHAR (50)   NULL,
    [DateCreated]               DATETIME2 (7)   NULL,
    [DateModified]              NVARCHAR (50)   NULL,
    [MappedToContact]           NVARCHAR (256)  NULL,
    [NotificationEmailAddress1] NVARCHAR (256)  NOT NULL,
    [NotificationEmailAddress2] NVARCHAR (256)  NOT NULL,
    [Salutation]                NVARCHAR (100)  NULL,
    [FirstName]                 NVARCHAR (100)  NULL,
    [LastName]                  NVARCHAR (100)  NULL,
    [Field1]                    NVARCHAR (100)  NULL,
    [Field2]                    NVARCHAR (200)  NULL,
    [Field3]                    NVARCHAR (500)  NULL,
    [Field4]                    NVARCHAR (1000) NULL,
    [IPv4Address]               NVARCHAR (15)   NOT NULL,
    [ExecutionID]               INT             NOT NULL,
    [SysCreatedOn]              DATETIME2 (7)   NOT NULL,
    [SysCreatedBy]              NVARCHAR (50)   NOT NULL,
    [SysModifiedOn]             DATETIME2 (7)   NULL,
    [SysModifiedBy]             NVARCHAR (50)   NULL,
    [SysSource]                 NVARCHAR (256)  NOT NULL,
    CONSTRAINT [PK_T2_Test] PRIMARY KEY CLUSTERED ([ID] ASC, [ExecutionID] ASC)
);








GO



GO



GO



GO



GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'ExecutionID', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'int', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'123', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Execution ID', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO



GO



GO



GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field4', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field3', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field2', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'LastName', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'FirstName', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Salutation', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Mr.', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Salutation', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'NotificationEmailAddress2', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 2', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'NotificationEmailAddress1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'MappedToContact', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Mapped to Contact', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'DateModified', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Domain\TechUser1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'DateCreated', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Status', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Registered', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'ID', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'int', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'123', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'ID', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Test data', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'CLUSTERED', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'T2', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'SysSource', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(256)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Country.csv', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Source System or Source File Name', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'File Name of the file that contains the row.', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'SysCreatedOn', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'datetime2(7)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On in case of on Update', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'SysCreatedBy', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(256)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By in case of on Update', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'SysCreatedOn', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'datetime2(7)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'SysCreatedBy', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(256)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'IPv4Adress', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'192.168.0.21', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'IP Address', @level0type = N'SCHEMA', @level0name = N'T2', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';

