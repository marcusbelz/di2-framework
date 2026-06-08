CREATE TABLE [LOG].[Trace] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [ExecutionID]  INT            NOT NULL,
    [ComponentID]  INT            NOT NULL,
    [Source]       NVARCHAR (5)   NOT NULL,
    [Component]    NVARCHAR (128) NOT NULL,
    [Task]         NVARCHAR (128) NULL,
    [Entity]       NVARCHAR (128) NULL,
    [Step]         NVARCHAR (MAX) NOT NULL,
    [Description]  NVARCHAR (MAX) NULL,
    [Action]       NVARCHAR (100) NULL,
    [AffectedRows] INT            NULL,
    [State]        NVARCHAR (100) NOT NULL,
    [Success]      BIT            NOT NULL,
    [CreatedOn]    DATETIME       CONSTRAINT [DF_LOG_Trace_CreatedOn] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]    NVARCHAR (100) CONSTRAINT [DF_LOG_Trace_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ModifiedOn]   DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (128) NULL,
    CONSTRAINT [PK_LOG_Trace] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LOG_Trace_ComponentID] FOREIGN KEY ([ComponentID]) REFERENCES [LOG].[Component] ([ID]),
    CONSTRAINT [FK_LOG_Trace_ExecutionID] FOREIGN KEY ([ExecutionID]) REFERENCES [LOG].[Execution] ([ID])
);










GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  17:00:11', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user that has last modified the row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date of creation of the log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ModifiedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'03.01.2019  13:18:33', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'The user that has created the row.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'EMEA\TechUser1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date of creation of the log entry', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'CreatedOn';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1 -or- 0', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Success';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates, whether the task was successful', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Success';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'processing -or- warning -or- success -or- error', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'State of the task execution', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'0', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'AffectedRows';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Number of affected rows/files/…', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'AffectedRows';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Insert -or- Update -or- Delete -or- Copy -or- …', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Action';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Short Identifier for a specific action.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Action';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'General description', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Inserting Data', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Overall description of what the component is doing.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Step';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Country', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Entity';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Overall entity, the component is dealing with.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Entity';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Calculate Something', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Task';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Describes the underlying action of the trace entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Task';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'T-SQL Procedure -or- SSIS-Package', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Name of the component, that has written this log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Component';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'T-SQL -or- SSIS', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Source';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Indicates the artifact, that has written this log entry.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'Source';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ComponentID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Foreign key to the table Component.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ComponentID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Foreign key to the table Execution.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ExecutionID';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Identifier', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'Table Name', @value = N'Trace', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace';


GO
EXECUTE sp_addextendedproperty @name = N'Table Description', @value = N'Table contains logging information for a single action in the ETL package.', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace';


GO
EXECUTE sp_addextendedproperty @name = N'PK Type', @value = N'NONCLUSTERD', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace';


GO
EXECUTE sp_addextendedproperty @name = N'Database Schema', @value = N'LOG', @level0type = N'SCHEMA', @level0name = N'LOG', @level1type = N'TABLE', @level1name = N'Trace';


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
CREATE TRIGGER [LOG].[TR_LOG_Trace_Update]
ON [LOG].[Trace]
FOR UPDATE
AS
BEGIN
SET NOCOUNT ON

   UPDATE [LOG].[Trace]
      SET 
          [ModifiedOn] = GETUTCDATE()
         ,[ModifiedBy] = SYSTEM_USER
   FROM 
      [LOG].[Trace]
      INNER JOIN inserted
      ON 
        inserted.[ID] = [LOG].[Trace].[ID];
END