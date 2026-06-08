CREATE TABLE [T1].[Test] (
    [ID]                           INT             IDENTITY (1, 1) NOT NULL,
    [Status]                       NVARCHAR (50)   NULL,
    [DateCreated]                  DATETIME2 (7)   NULL,
    [DateModified]                 NVARCHAR (50)   NULL,
    [MappedToContact]              NVARCHAR (256)  NULL,
    [NotificationEmailAddress1]    NVARCHAR (256)  NULL,
    [NotificationEmailAddress2]    NVARCHAR (256)  NULL,
    [Salutation]                   NVARCHAR (100)  NULL,
    [FirstName]                    NVARCHAR (100)  NULL,
    [LastName]                     NVARCHAR (100)  NULL,
    [Field1]                       NVARCHAR (100)  NULL,
    [Field2]                       NVARCHAR (200)  NULL,
    [Field3]                       NVARCHAR (500)  NULL,
    [Field4]                       NVARCHAR (1000) NULL,
    [IPv4Address]                  NVARCHAR (15)   NULL,
    [Status_E1]                    NVARCHAR (MAX)  NULL,
    [DateCreated_E1]               NVARCHAR (MAX)  NULL,
    [DateModified_E1]              NVARCHAR (MAX)  NULL,
    [MappedToContact_E1]           NVARCHAR (MAX)  NULL,
    [NotificationEmailAddress1_E1] NVARCHAR (MAX)  NULL,
    [NotificationEmailAddress2_E1] NVARCHAR (MAX)  NULL,
    [Salutation_E1]                NVARCHAR (MAX)  NULL,
    [FirstName_E1]                 NVARCHAR (MAX)  NULL,
    [LastName_E1]                  NVARCHAR (MAX)  NULL,
    [Field1_E1]                    NVARCHAR (MAX)  NULL,
    [Field2_E1]                    NVARCHAR (MAX)  NULL,
    [Field3_E1]                    NVARCHAR (MAX)  NULL,
    [Field4_E1]                    NVARCHAR (MAX)  NULL,
    [IPv4Address_E1]               NVARCHAR (MAX)  NULL,
    [Salutation_Count]             INT             NULL,
    [FirstName_Count]              INT             NULL,
    [LastName_Count]               INT             NULL,
    [Field1_Count]                 INT             NULL,
    [Field2_Count]                 INT             NULL,
    [Field3_Count]                 INT             NULL,
    [Field4_Count]                 INT             NULL,
    [DateCreated_Count]            INT             NULL,
    [DateModified_Count]           INT             NULL,
    [MappedToContact_Count]        INT             NULL,
    [IPv4Address_Count]            INT             NULL,
    [SysCreatedOn]                 DATETIME2 (7)   NULL,
    [SysCreatedBy]                 NVARCHAR (50)   NULL,
    [SysWarning]                   INT             NULL,
    [SysError]                     INT             NULL,
    [SysSource]                    NVARCHAR (256)  NULL,
    CONSTRAINT [PK_T1_Test] PRIMARY KEY CLUSTERED ([ID] ASC)
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



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field4', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field3', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field2', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'LastName', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'FirstName', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Salutation', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Mr.', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Salutation', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'NotificationEmailAddress2', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 2', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'NotificationEmailAddress1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'MappedToContact', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Mapped to Contact', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'DateModified', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Domain\TechUser1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'DateCreated', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Status', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Registered', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status_E1';


GO



GO



GO



GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field4', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field3', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field2', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Field1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Any Text', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'LastName', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Last Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'FirstName', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Salutation', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Mr.', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Salutation', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'NotificationEmailAddress2', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 2', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress2';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'NotificationEmailAddress1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Notification Email Address 1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'NotificationEmailAddress1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'MappedToContact', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'name@domain.com', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Mapped to Contact', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'DateModified', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Domain\TechUser1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'DateCreated', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'Status', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Registered', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'123', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'ID', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Test data', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'CLUSTERED', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'T1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysWarning';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'NULL', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysWarning';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Number of Errors', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysWarning';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Source System or Source File Name', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'File Name of the file that contains the row.', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysSource';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysError';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysError';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Number of Warnings', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysError';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'SysCreatedOn', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'datetime2(7)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 01:02:03', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created On', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'When was the row inserted?', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'SysCreatedBy', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(256)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Created By', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'User who inserted the row', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'SysCreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Salutation_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'LastName_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'FirstName_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field4_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field3_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field2_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'Field1_Count';


GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'MappedToContact_Count';


GO



GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'IPv4Adress', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'192.168.0.21', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'IP Address', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_E1';


GO
EXECUTE sp_addextendedproperty @name = N'Source Table', @value = N'Test', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source Schema', @value = N'E1', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source Field Name', @value = N'IPv4Adress', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source Datatype', @value = N'nvarchar(max)', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'192.168.0.21', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'IP Address', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateModified_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'DateCreated_Count';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'T1', @level1type = N'TABLE', @level1name = N'Test', @level2type = N'COLUMN', @level2name = N'IPv4Address_Count';

