CREATE TABLE [E1].[Test] (
    [Status]                    NVARCHAR (MAX) NULL,
    [DateCreated]               NVARCHAR (MAX) NULL,
    [DateModified]              NVARCHAR (MAX) NULL,
    [MappedToContact]           NVARCHAR (MAX) NULL,
    [NotificationEmailAddress1] NVARCHAR (MAX) NULL,
    [NotificationEmailAddress2] NVARCHAR (MAX) NULL,
    [Salutation]                NVARCHAR (MAX) NULL,
    [FirstName]                 NVARCHAR (MAX) NULL,
    [LastName]                  NVARCHAR (MAX) NULL,
    [Field1]                    NVARCHAR (MAX) NULL,
    [Field2]                    NVARCHAR (MAX) NULL,
    [Field3]                    NVARCHAR (MAX) NULL,
    [Field4]                    NVARCHAR (MAX) NULL,
    [IPv4Address]               NVARCHAR (MAX) NULL,
    [SysCreatedOn]              DATETIME2 (7)  NULL,
    [SysCreatedBy]              NVARCHAR (50)  NULL,
    [SysSource]                 NVARCHAR (256) NULL
);






GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Mr.', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Salutation', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 2', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 1', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Mapped to Contact', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Domain\TechUser1', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Registered', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Test data', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'CLUSTERED', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Country.csv', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Source System or Source File Name', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'File Name of the file that contains the row.', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Domain\TechUser1', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'192.168.0.21', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'IP Address', @level0type = N'SCHEMA', @level0name = N'E1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';

