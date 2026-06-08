CREATE TABLE [CONFIG].[DBVersion] (
    [ReleaseVersion]  NVARCHAR (50) NOT NULL,
    [InternalVersion] NVARCHAR (50) NULL,
    CONSTRAINT [PK_CONFIG_DBVersion] PRIMARY KEY CLUSTERED ([ReleaseVersion] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1.0.0.0', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion', @level2type = N'COLUMN', @level2name = N'InternalVersion';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Internal version of the release.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion', @level2type = N'COLUMN', @level2name = N'InternalVersion';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1.0.0.0', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion', @level2type = N'COLUMN', @level2name = N'ReleaseVersion';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Version of the Release.', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion', @level2type = N'COLUMN', @level2name = N'ReleaseVersion';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'DBVersion', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Database Version', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'CONFIG', @level0type = N'SCHEMA', @level0name = N'CONFIG', @level1type = N'TABLE', @level1name = N'DBVersion';

