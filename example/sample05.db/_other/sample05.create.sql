-- --------------------------------------------------------------------------------
-- Kill all processes accessing the database
-- --------------------------------------------------------------------------------
USE [master];
GO

DECLARE @kill varchar(8000) = '';
SELECT
   @kill = @kill + 'kill ' + CONVERT(varchar(5), [session_id]) + '; '
FROM
   [sys].[dm_exec_sessions]
WHERE
   [database_id]  = db_id('sample05_Create');

EXEC(@kill);
GO

-- --------------------------------------------------------------------------------
-- Drop and create database
-- --------------------------------------------------------------------------------
USE [master];
GO

IF EXISTS(SELECT* from [sys].[databases] WHERE [name]='sample05_Create')
   BEGIN
      DROP DATABASE [sample05_Create];
   END;
GO

CREATE DATABASE [sample05_Create];
GO

ALTER DATABASE [sample05_Create] SET RECOVERY SIMPLE;
GO

-- --------------------------------------------------------------------------------
-- Use database [sample05_Create]
-- --------------------------------------------------------------------------------
USE [sample05_Create]
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Database Name'    , @value = 'sample05_Create';
EXEC [sys].[sp_addextendedproperty] @name = 'Database Version' , @value = '1.0.0.0';
EXEC [sys].[sp_addextendedproperty] @name = 'Last Modification', @value = '01.01.2019';
EXEC [sys].[sp_addextendedproperty] @name = 'Description'      , @value = 'Description of the database';
GO

-- --------------------------------------------------------------------------------
-- Author              : ETL Framework (Marcus Belz)
-- 
-- Database Date       : 01.01.2019
-- Database Name       : sample05_Create
-- Database Description: Description of the database
-- Database Version    : 1.0.0.0
-- --------------------------------------------------------------------------------

CREATE SCHEMA [E1];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'E1', @value = 'Data Extraction Layer';
GO

CREATE SCHEMA [T1];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'T1', @value = 'Transformation Layer 1';
GO

CREATE SCHEMA [T2];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'T2', @value = 'Transformation Layer 2';
GO

CREATE SCHEMA [LOG];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'LOG', @value = 'Logging Layer';
GO

CREATE SCHEMA [CONFIG];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'CONFIG', @value = 'Configuration Layer';
GO

CREATE SCHEMA [L1];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'L1', @value = 'Data warehouse';
GO

CREATE SCHEMA [L2];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'L2', @value = 'Datamart';
GO

CREATE SCHEMA [sec];
GO

EXEC [sys].[sp_addextendedproperty] @name = 'Description', @level0type=N'SCHEMA', @level0name=N'sec', @value = 'Security Layer';
GO



-- --------------------------------------------------------------------------------
-- Drop table [E1].[Test]
-- --------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[E1].[Test]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
      DROP TABLE [E1].[Test]; 
   END;

-- --------------------------------------------------------------------------------
-- Create table Test
-- --------------------------------------------------------------------------------
CREATE TABLE [E1].[Test]
(
    [Status]                       nvarchar(max)        NULL
   ,[DateCreated]                  nvarchar(max)        NULL
   ,[DateModified]                 nvarchar(max)        NULL
   ,[MappedToContact]              nvarchar(max)        NULL
   ,[NotificationEmailAddress1]    nvarchar(max)        NULL
   ,[NotificationEmailAddress2]    nvarchar(max)        NULL
   ,[Salutation]                   nvarchar(max)        NULL
   ,[FirstName]                    nvarchar(max)        NULL
   ,[LastName]                     nvarchar(max)        NULL
   ,[Field1]                       nvarchar(max)        NULL
   ,[Field2]                       nvarchar(max)        NULL
   ,[Field3]                       nvarchar(max)        NULL
   ,[Field4]                       nvarchar(max)        NULL
   ,[IPv4Address]                  nvarchar(max)        NULL
   ,[SysCreatedOn]                 datetime2(7)         NULL
   ,[SysCreatedBy]                 nvarchar(50)         NULL
   ,[SysSource]                    nvarchar(256)        NULL
) ON [PRIMARY];

-- --------------------------------------------------------------------------------
-- Extended properties for table [E1].[Test]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty] @name=N'Database Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name='E1', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Name', @value=N'Test', @level0type=N'SCHEMA', @level0name='E1', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Description', @value=N'Test data', @level0type=N'SCHEMA', @level0name='E1', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'PK Type', @value=N'CLUSTERED', @level0type=N'SCHEMA', @level0name='E1', @level1type=N'TABLE', @level1name='Test'
;

-- --------------------------------------------------------------------------------
-- Extended properties for columns table [E1].[Test]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Registered', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Domain\TechUser1', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Mapped to Contact', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 1', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 2', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Salutation', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Mr.', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'IP Address', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'192.168.0.21', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Domain\TechUser1', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Source System or Source File Name', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'File Name of the file that contains the row.', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Country.csv', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'E1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
GO



-- --------------------------------------------------------------------------------
-- Drop table [T1].[Test]
-- --------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[T1].[Test]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
      DROP TABLE [T1].[Test]; 
   END;

-- --------------------------------------------------------------------------------
-- Create table Test
-- --------------------------------------------------------------------------------
CREATE TABLE [T1].[Test]
(
    [ID]                           int IDENTITY     NOT NULL
   ,[Status]                       nvarchar(50)         NULL
   ,[DateCreated]                  datetime2(7)         NULL
   ,[DateModified]                 nvarchar(50)         NULL
   ,[MappedToContact]              nvarchar(256)        NULL
   ,[NotificationEmailAddress1]    nvarchar(256)        NULL
   ,[NotificationEmailAddress2]    nvarchar(256)        NULL
   ,[Salutation]                   nvarchar(100)        NULL
   ,[FirstName]                    nvarchar(100)        NULL
   ,[LastName]                     nvarchar(100)        NULL
   ,[Field1]                       nvarchar(100)        NULL
   ,[Field2]                       nvarchar(200)        NULL
   ,[Field3]                       nvarchar(500)        NULL
   ,[Field4]                       nvarchar(1000)      NULL
   ,[IPv4Address]                  nvarchar(15)         NULL
   ,[Status_E1]                    nvarchar(max)        NULL
   ,[DateCreated_E1]               nvarchar(max)        NULL
   ,[DateModified_E1]              nvarchar(max)        NULL
   ,[MappedToContact_E1]           nvarchar(max)        NULL
   ,[NotificationEmailAddress1_E1]  nvarchar(max)        NULL
   ,[NotificationEmailAddress2_E1]  nvarchar(max)        NULL
   ,[Salutation_E1]                nvarchar(max)        NULL
   ,[FirstName_E1]                 nvarchar(max)        NULL
   ,[LastName_E1]                  nvarchar(max)        NULL
   ,[Field1_E1]                    nvarchar(max)        NULL
   ,[Field2_E1]                    nvarchar(max)        NULL
   ,[Field3_E1]                    nvarchar(max)        NULL
   ,[Field4_E1]                    nvarchar(max)        NULL
   ,[IPv4Address_E1]               nvarchar(max)        NULL
   ,[Salutation_Count]             int                  NULL
   ,[FirstName_Count]              int                  NULL
   ,[LastName_Count]               int                  NULL
   ,[Field1_Count]                 int                  NULL
   ,[Field2_Count]                 int                  NULL
   ,[Field3_Count]                 int                  NULL
   ,[Field4_Count]                 int                  NULL
   ,[DateCreated_Count]            int                  NULL
   ,[DateModified_Count]           int                  NULL
   ,[MappedToContact_Count]        int                  NULL
   ,[IPv4Address_Count]            int                  NULL
   ,[SysCreatedOn]                 datetime2(7)         NULL
   ,[SysCreatedBy]                 nvarchar(50)         NULL
   ,[SysWarning]                   int                  NULL
   ,[SysError]                     int                  NULL
   ,[SysSource]                    nvarchar(256)        NULL
   , CONSTRAINT [PK_T1_Test] PRIMARY KEY CLUSTERED ( [ID] )
) ON [PRIMARY];

-- --------------------------------------------------------------------------------
-- Extended properties for table [T1].[Test]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty] @name=N'Database Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name='T1', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Name', @value=N'Test', @level0type=N'SCHEMA', @level0name='T1', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Description', @value=N'Test data', @level0type=N'SCHEMA', @level0name='T1', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'PK Type', @value=N'CLUSTERED', @level0type=N'SCHEMA', @level0name='T1', @level1type=N'TABLE', @level1name='Test'
;

-- --------------------------------------------------------------------------------
-- Extended properties for columns table [T1].[Test]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'ID', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'123', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Registered', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Status', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'DateCreated', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Domain\TechUser1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'DateModified', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Mapped to Contact', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'MappedToContact', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'NotificationEmailAddress1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 2', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'NotificationEmailAddress2', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Salutation', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Mr.', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Salutation', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'FirstName', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'LastName', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field2', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field3', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field4', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'IP Address', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'192.168.0.21', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'IPv4Adress', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Registered', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Status', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'DateCreated', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Domain\TechUser1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'DateModified', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Mapped to Contact', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'MappedToContact', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'NotificationEmailAddress1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 2', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'NotificationEmailAddress2', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Salutation', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Mr.', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Salutation', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'FirstName', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'LastName', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field2', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field3', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field4', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'IP Address', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'192.168.0.21', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'IPv4Adress', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_E1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address_Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'SysCreatedOn', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'datetime2(7)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'EMEA\TechUser1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'E1', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'SysCreatedBy', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(256)', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Number of Errors', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysWarning'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'NULL', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysWarning'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysWarning'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Number of Warnings', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysError'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysError'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysError'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Source System or Source File Name', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'File Name of the file that contains the row.', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'Derived', @level0type=N'SCHEMA', @level0name=N'T1', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
GO



-- --------------------------------------------------------------------------------
-- Drop table [T2].[Test]
-- --------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[T2].[Test]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
      DROP TABLE [T2].[Test]; 
   END;

-- --------------------------------------------------------------------------------
-- Create table Test
-- --------------------------------------------------------------------------------
CREATE TABLE [T2].[Test]
(
    [ID]                           int              NOT NULL
   ,[Status]                       nvarchar(50)         NULL
   ,[DateCreated]                  datetime2(7)         NULL
   ,[DateModified]                 nvarchar(50)         NULL
   ,[MappedToContact]              nvarchar(256)        NULL
   ,[NotificationEmailAddress1]    nvarchar(256)    NOT NULL
   ,[NotificationEmailAddress2]    nvarchar(256)    NOT NULL
   ,[Salutation]                   nvarchar(100)        NULL
   ,[FirstName]                    nvarchar(100)        NULL
   ,[LastName]                     nvarchar(100)        NULL
   ,[Field1]                       nvarchar(100)        NULL
   ,[Field2]                       nvarchar(200)        NULL
   ,[Field3]                       nvarchar(500)        NULL
   ,[Field4]                       nvarchar(1000)      NULL
   ,[IPv4Address]                  nvarchar(15)     NOT NULL
   ,[ExecutionID]                  int              NOT NULL
   ,[SysCreatedOn]                 datetime2(7)     NOT NULL
   ,[SysCreatedBy]                 nvarchar(50)     NOT NULL
   ,[SysModifiedOn]                datetime2(7)         NULL
   ,[SysModifiedBy]                nvarchar(50)         NULL
   ,[SysSource]                    nvarchar(256)    NOT NULL
   , CONSTRAINT [PK_T2_Test] PRIMARY KEY CLUSTERED ( [ID], [ExecutionID] )
) ON [PRIMARY];

-- --------------------------------------------------------------------------------
-- Extended properties for table [T2].[Test]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty] @name=N'Database Schema', @value=N'T2', @level0type=N'SCHEMA', @level0name='T2', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Name', @value=N'Test', @level0type=N'SCHEMA', @level0name='T2', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Description', @value=N'Test data', @level0type=N'SCHEMA', @level0name='T2', @level1type=N'TABLE', @level1name='Test'
EXEC [sys].[sp_addextendedproperty] @name=N'PK Type', @value=N'CLUSTERED', @level0type=N'SCHEMA', @level0name='T2', @level1type=N'TABLE', @level1name='Test'
;

-- --------------------------------------------------------------------------------
-- Extended properties for columns table [T2].[Test]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'ID', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'123', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'ID', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'int', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Registered', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Status', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Status'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'DateCreated', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateCreated'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Domain\TechUser1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'DateModified', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'DateModified'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Mapped to Contact', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'MappedToContact', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'MappedToContact'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'NotificationEmailAddress1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Notification Email Address 2', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'name@domain.com', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'NotificationEmailAddress2', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'NotificationEmailAddress2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Salutation', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Mr.', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Salutation', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Salutation'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'First Name', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'FirstName', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'FirstName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Last Name', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'LastName', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'LastName'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field1'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field2', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field2'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field3', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field3'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Any Text', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'Field4', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'Field4'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'IP Address', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'192.168.0.21', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'IPv4Adress', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(max)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'IPv4Address'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Execution ID', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'123', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'ExecutionID', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'int', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'SysCreatedOn', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'datetime2(7)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'EMEA\TechUser1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'SysCreatedBy', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(256)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysCreatedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created On in case of on Update', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'When was the row inserted?', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'2019-01-03 01:02:03', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'SysCreatedOn', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'datetime2(7)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedOn'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Created By in case of on Update', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'User who inserted the row', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'EMEA\TechUser1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'SysCreatedBy', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(256)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysModifiedBy'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Source System or Source File Name', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Description', @value=N'File Name of the file that contains the row.', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'Country.csv', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source System', @value=N'DB', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Schema', @value=N'T1', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Table', @value=N'Test', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Field Name', @value=N'SysSource', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Source Datatype', @value=N'nvarchar(256)', @level0type=N'SCHEMA', @level0name=N'T2', @level1type=N'TABLE', @level1name=N'Test', @level2type=N'COLUMN', @level2name=N'SysSource'; 
GO



-- --------------------------------------------------------------------------------
-- Drop table [sec].[BotCodeKeyword]
-- --------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[sec].[BotCodeKeyword]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
      DROP TABLE [sec].[BotCodeKeyword]; 
   END;

-- --------------------------------------------------------------------------------
-- Create table BotCodeKeyword
-- --------------------------------------------------------------------------------
CREATE TABLE [sec].[BotCodeKeyword]
(
    [Keyword]                      nvarchar(100)    NOT NULL
   ,[Weight]                       int              NOT NULL
   ,[Active]                       bit              NOT NULL
   , CONSTRAINT [PK_sec_BotCodeKeyword] PRIMARY KEY CLUSTERED ( [Keyword] )
) ON [PRIMARY];

-- --------------------------------------------------------------------------------
-- Extended properties for table [sec].[BotCodeKeyword]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty] @name=N'Database Schema', @value=N'sec', @level0type=N'SCHEMA', @level0name='sec', @level1type=N'TABLE', @level1name='BotCodeKeyword'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Name', @value=N'BotCodeKeyword', @level0type=N'SCHEMA', @level0name='sec', @level1type=N'TABLE', @level1name='BotCodeKeyword'
EXEC [sys].[sp_addextendedproperty] @name=N'PK Type', @value=N'CLUSTERED', @level0type=N'SCHEMA', @level0name='sec', @level1type=N'TABLE', @level1name='BotCodeKeyword'
;

-- --------------------------------------------------------------------------------
-- Extended properties for columns table [sec].[BotCodeKeyword]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Keyword', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeyword', @level2type=N'COLUMN', @level2name=N'Keyword'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'commit', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeyword', @level2type=N'COLUMN', @level2name=N'Keyword'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Count', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeyword', @level2type=N'COLUMN', @level2name=N'Weight'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'1', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeyword', @level2type=N'COLUMN', @level2name=N'Weight'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Active', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeyword', @level2type=N'COLUMN', @level2name=N'Active'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'1', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeyword', @level2type=N'COLUMN', @level2name=N'Active'; 
GO



-- --------------------------------------------------------------------------------
-- Drop table [sec].[BotCodeKeywordCounter]
-- --------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[sec].[BotCodeKeywordCounter]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
      DROP TABLE [sec].[BotCodeKeywordCounter]; 
   END;

-- --------------------------------------------------------------------------------
-- Create table BotCodeKeywordCounter
-- --------------------------------------------------------------------------------
CREATE TABLE [sec].[BotCodeKeywordCounter]
(
    [ExecutionID]                  int              NOT NULL
   ,[ID]                           int              NOT NULL
   ,[Keyword]                      nvarchar(100)    NOT NULL
   ,[Count]                        int              NOT NULL
   , CONSTRAINT [PK_sec_BotCodeKeywordCounter] PRIMARY KEY CLUSTERED ( [ExecutionID], [ID], [Keyword] )
) ON [PRIMARY];

-- --------------------------------------------------------------------------------
-- Extended properties for table [sec].[BotCodeKeywordCounter]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty] @name=N'Database Schema', @value=N'sec', @level0type=N'SCHEMA', @level0name='sec', @level1type=N'TABLE', @level1name='BotCodeKeywordCounter'
EXEC [sys].[sp_addextendedproperty] @name=N'Table Name', @value=N'BotCodeKeywordCounter', @level0type=N'SCHEMA', @level0name='sec', @level1type=N'TABLE', @level1name='BotCodeKeywordCounter'
EXEC [sys].[sp_addextendedproperty] @name=N'PK Type', @value=N'CLUSTERED', @level0type=N'SCHEMA', @level0name='sec', @level1type=N'TABLE', @level1name='BotCodeKeywordCounter'
;

-- --------------------------------------------------------------------------------
-- Extended properties for columns table [sec].[BotCodeKeywordCounter]
-- --------------------------------------------------------------------------------
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Execution ID', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'123', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'ExecutionID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'ID', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'123', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'ID'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Keyword', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'Keyword'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'commit', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'Keyword'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Display Name', @value=N'Count', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'Count'; 
EXEC [sys].[sp_addextendedproperty]  @name=N'Example Values', @value=N'1', @level0type=N'SCHEMA', @level0name=N'sec', @level1type=N'TABLE', @level1name=N'BotCodeKeywordCounter', @level2type=N'COLUMN', @level2name=N'Count'; 
GO

-- --------------------------------------------------------------------------------
-- Foreign Keys
-- --------------------------------------------------------------------------------
