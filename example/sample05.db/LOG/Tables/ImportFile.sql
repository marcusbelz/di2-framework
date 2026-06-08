CREATE TABLE [LOG].[ImportFile] (
    [ID]               INT             IDENTITY (1, 1) NOT NULL,
    [ExecutionID]      INT             NOT NULL,
    [FileName_Source]  NVARCHAR (1024) NOT NULL,
    [FileName_Working] NVARCHAR (1024) NOT NULL,
    [FileName_Archive] NVARCHAR (1024) NULL,
    [Created]          DATETIME        NULL,
    [FileSize]         BIGINT          NULL,
    [ImportDate]       DATETIME        NULL,
    CONSTRAINT [PK_LOG_ImportFile] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LOG_ImportFile_ExecutionID] FOREIGN KEY ([ExecutionID]) REFERENCES [LOG].[Execution] ([ID])
);




GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ImportFile', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'ImportFile', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ImportFile';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Table contains information about the files to import into the E1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ImportFile';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ImportFile';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'LOG', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ImportFile';

