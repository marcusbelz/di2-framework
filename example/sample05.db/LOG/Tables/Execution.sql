CREATE TABLE [LOG].[Execution] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Process]      NVARCHAR (MAX) NOT NULL,
    [Start]        DATETIME       NOT NULL,
    [End]          DATETIME       NULL,
    [DeltaStart]   DATETIME       NULL,
    [DeltaEnd]     DATETIME       NULL,
    [User]         NVARCHAR (128) NULL,
    [Machine]      NVARCHAR (128) NULL,
    [Instance]     NVARCHAR (50)  NULL,
    [VersionBuild] INT            NULL,
    [State]        NVARCHAR (128) NULL,
    [Success]      BIT            NULL,
    [CreatedOn]    DATETIME       CONSTRAINT [DF_LOG_Execution_CreatedOn] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]    NVARCHAR (100) CONSTRAINT [DF_LOG_Execution_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedOn]   DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (100) NULL,
    CONSTRAINT [PK_LOG_Execution] PRIMARY KEY CLUSTERED ([ID] ASC)
);












GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  17:00:11', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'ModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user that has last modified the row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'ModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'ModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date of creation of the log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'ModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  13:18:33', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user that has created the row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date of creation of the log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1 -or- 0', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Success';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates, whether the job execution was successful.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Success';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'processing -or- warning -or- success -or- error', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'State of the job execution.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'42', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'VersionBuild';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SSIS Version Build number of the initial SSIS Package.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'VersionBuild';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'GUID', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Instance';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'SSIS Instance', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Instance';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'ServerName', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Machine';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Server name', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Machine';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'User';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user for the exution of the job.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'User';


GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  17:00:11', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'End';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date and tim when the job was either successfully finished or terminated with an error.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'End';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  13:18:33', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Start';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date and tim when the job was started.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Start';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'project@MSBISS', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Process';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Name of a SQL Agent Job.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'Process';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifier', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Execution', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Table contains logging information for each execution of the process', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'LOG', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution';


GO
-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Creates a Trigger. The manual creation is necessary as the Kimball 
--              sheet does not et suppport trigger creation. the trigger will be 
--              created for the UPDATE of the following columns:
--               - [ModifiedOn] = GETUTCDATE()
--               - [ModifiedBy] = SYSTEM_USER
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE TRIGGER [LOG].[TR_LOG_Execution_Update]
ON [LOG].[Execution]
FOR UPDATE
AS
BEGIN
SET NOCOUNT ON

   UPDATE [LOG].[Execution]
      SET 
          [ModifiedOn] = GETUTCDATE()
         ,[ModifiedBy] = SYSTEM_USER
   FROM 
      [LOG].[Execution]
      INNER JOIN inserted
      ON 
        inserted.[ID] = [LOG].[Execution].[ID];
END
GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 13:18:33.177', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'DeltaStart';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Period of delta load (start)', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'DeltaStart';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'2019-01-03 13:18:33.177', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'DeltaEnd';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Period of delta load (end)', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Execution', @level2type = N'COLUMN', @level2name = N'DeltaEnd';

