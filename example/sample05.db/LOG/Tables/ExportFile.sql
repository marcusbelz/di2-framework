CREATE TABLE [LOG].[ExportFile] (
    [ID]              INT             IDENTITY (1, 1) NOT NULL,
    [ExecutionID]     INT             NOT NULL,
    [FileName_Export] NVARCHAR (1024) NOT NULL,
    [Exported_Rows]   INT             NOT NULL,
    [Error_Rows]      INT             NOT NULL,
    [Created]         DATETIME        NULL,
    [FileSize]        INT             NULL,
    [ExportDate]      DATETIME        NULL,
    CONSTRAINT [PK_LOG_ExportFile] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LOG_ExportFile_ExecutionID] FOREIGN KEY ([ExecutionID]) REFERENCES [LOG].[Execution] ([ID])
);




GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ExportFile', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'ExportFile', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ExportFile';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Table contains information about the files exported.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ExportFile';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ExportFile';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'LOG', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'ExportFile';

