CREATE TABLE [LOG].[Component] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [ExecutionID]  INT            NULL,
    [Source]       NVARCHAR (5)   NULL,
    [Component]    NVARCHAR (128) NULL,
    [VersionBuild] INT            NULL,
    [Entity]       NVARCHAR (128) NULL,
    [Step]         NVARCHAR (MAX) NULL,
    [Description]  NVARCHAR (MAX) NULL,
    [State]        NVARCHAR (100) NULL,
    [Success]      BIT            NULL,
    [CreatedOn]    DATETIME       CONSTRAINT [DF_LOG_Component_CreatedOn] DEFAULT (getutcdate()) NULL,
    [CreatedBy]    NVARCHAR (128) CONSTRAINT [DF_LOG_Component_CreatedBy] DEFAULT (suser_sname()) NULL,
    [ModifiedOn]   DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (128) NULL,
    CONSTRAINT [PK_LOG_Component] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LOG_Component_ExecutionID] FOREIGN KEY ([ExecutionID]) REFERENCES [LOG].[Execution] ([ID])
);










GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  17:00:11', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user that has last modified the row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date of creation of the log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  13:18:33', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user that has created the row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date of creation of the log entry', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1 -or- 0', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Success';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates, whether the execution was successful', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Success';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'processing -or- warning -or- success -or- error', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'State of the component execution (Stored Procedure or SSIS Package)', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'General description', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Inserting Data', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Overall description of what the component is doing.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Country', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Entity';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Overall entity, the component is dealing with.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Entity';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Version Build Number of the calling SSIS Package.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'VersionBuild';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'T-SQL Procedure -or- SSIS-Package', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Name of the component, that has written this log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'T-SQL -or- SSIS', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Source';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates the artifact, that has written this log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'Source';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Foreign key to the table Execution.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifier', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Component', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Table contains logging information for each component (e.g. SSIS package -or- SQL Proceure) of the process', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'LOG', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Component';


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
CREATE TRIGGER [LOG].[TR_LOG_Component_Update]
ON [LOG].[Component]
FOR UPDATE
AS
BEGIN
SET NOCOUNT ON

   UPDATE [LOG].[Component]
      SET 
          [ModifiedOn] = GETUTCDATE()
         ,[ModifiedBy] = SYSTEM_USER
   FROM 
      [LOG].[Component]
      INNER JOIN inserted
      ON 
        inserted.[ID] = [LOG].[Component].[ID];
END