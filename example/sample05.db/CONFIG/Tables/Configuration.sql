CREATE TABLE [CONFIG].[Configuration] (
    [Group]       NVARCHAR (32)  NOT NULL,
    [Code]        NVARCHAR (32)  NOT NULL,
    [Value]       NVARCHAR (MAX) NOT NULL,
    [Description] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CONFIG_Configuration] PRIMARY KEY CLUSTERED ([Group] ASC, [Code] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Description', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Description related to the configuration setting.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Value', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Configured Value', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Code', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Code';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Name of a configuration settting. The name must be unique within a group name.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Code';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Group', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Group';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'This column can be used to group logically similar configuration settings. All logicallly similar settings will get the same gro', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration', @level2type = N'COLUMN', @level2name = N'Group';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Configuration', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Configuration Values', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'CONFIG', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'Configuration';

