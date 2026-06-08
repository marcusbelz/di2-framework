-- --------------------------------------------------------------------------------
-- Step 0: Common statements
-- --------------------------------------------------------------------------------
-- TRUNCATE TABLE [LOG].[Error]
-- TRUNCATE TABLE [LOG].[Trace]
-- DELETE FROM [LOG].[Component]
-- DELETE FROM [LOG].[Execution] 
-- TRUNCATE TABLE [E1].[Test]
-- TRUNCATE TABLE [T1].[Test]
-- TRUNCATE TABLE [T2].[Test]
-- --------------------------------------------------------------------------------
-- Step 1: Explain EXCEL document
-- --------------------------------------------------------------------------------
-- > sample05.db\_data\sample05.data.xlsx
--

-- --------------------------------------------------------------------------------
-- Step 2: Configure the period for periodical search
-- --------------------------------------------------------------------------------
TRUNCATE TABLE [CONFIG].[Configuration];

INSERT INTO [CONFIG].[Configuration] ([Group], [Code], [Value], [Description]) VALUES ('CheckBotCode', 'DateCreated Period' ,   60, 'Period in seconds for the identififcation of potential attacks by the columns ''DateCreated''. The process looks for half of the period into the past and the future and counts the number of records.');
INSERT INTO [CONFIG].[Configuration] ([Group], [Code], [Value], [Description]) VALUES ('CheckBotCode', 'DateModified Period',   60, 'Period in seconds for the identififcation of potential attacks by the columns ''DateModified''. The process looks for half of the period into the past and the future and counts the number of records.');

-- --------------------------------------------------------------------------------
-- Step 3: Configure key words that are searched for
-- --------------------------------------------------------------------------------
TRUNCATE TABLE [sec].[BotCodeKeyword];

INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('true'   ,  5, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('false'  ,  5, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('eval'   ,  7, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('compile', 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('range'  , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('import' , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('sleep'  , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('\n'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('{'      , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('}'      , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('['      , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES (']'      , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('./'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('../'    , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('.ini'   , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('.reg'   , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('.bat'   , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('.cmd'   , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('.sql'   , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('--'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('++'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES (':='     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('\'      , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('\\'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('/'      ,  3, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('//'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('&'      ,  3, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('&&'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('|'      ,  6, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('||'     , 10, 1);
INSERT INTO [sec].[BotCodeKeyword] ([Keyword], [Weight], [Active]) VALUES ('win.ini', 10, 1);

-- --------------------------------------------------------------------------------
-- Step 4: Configure rules, that ware regarded as warnings or errors based on the 
--         number of findings
-- --------------------------------------------------------------------------------
TRUNCATE TABLE [CONFIG].[CheckConstraint];

WITH 
CTE_CheckUserDefinedConstraints AS
(
   SELECT 
       [ProcedureName]
      ,[ErrorType]
      ,[Task]
      ,[Entity]
      ,[Step]
      ,[SchemaName]
      ,[TableName]
      ,[Id1_FieldName]
      ,[Id2_FieldName]
      ,[Id3_FieldName]
      ,[Check_FieldName]
      ,[Constraint]
      ,[MaxOccurance]
      ,[Message]
      ,[Description]
      ,[ActiveFlag]
      ,[ManualFlag]
   FROM 
      (VALUES
           ('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateCreated'    , '[DateCreated_Count]     > 60 AND [DateCreated_Count]     <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateModified'   , '[DateModified_Count]    > 60 AND [DateModified_Count]    <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'MappedToContact', '[MappedToContact_Count] > 60 AND [MappedToContact_Count] <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'IPv4Address'    , '[IPv4Address_Count]     > 60 AND [IPv4Address_Count]     <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Salutation'     , '[Salutation_Count]      > 1 AND [Salutation_Count]       <= 5'  , NULL, '1 < value <= 5'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'FirstName'      , '[FirstName_Count]       > 1 AND [FirstName_Count]        <= 5'  , NULL, '1 < value <= 5'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'LastName'       , '[LastName_Count]        > 1 AND [LastName_Count]         <= 5'  , NULL, '1 < value <= 5'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field1'         , '[Field1_Count]          > 1 AND [Field1_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field2'         , '[Field2_Count]          > 1 AND [Field2_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field3'         , '[Field3_Count]          > 1 AND [Field3_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field4'         , '[Field4_Count]          > 1 AND [Field4_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)  -- <<<
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Salutation'     , '[Salutation_Count]      > 5'                                    , NULL, 'value >   5'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'FirstName'      , '[FirstName_Count]       > 5'                                    , NULL, 'value >   5'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'LastName'       , '[LastName_Count]        > 5'                                    , NULL, 'value >   5'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field1'         , '[Field1_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field2'         , '[Field2_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field3'         , '[Field3_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field4'         , '[Field4_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateCreated'    , '[DateCreated_Count]     > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateModified'   , '[DateModified_Count]    > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'MappedToContact', '[MappedToContact_Count] > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'IPv4Address'    , '[IPv4Address_Count]     > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
      )
      AS UserDefinedConstraints ([ProcedureName], [ErrorType], [Task], [Entity], [Step], [SchemaName], [TableName], [Id1_FieldName], [Id2_FieldName], [Id3_FieldName], [Check_FieldName], [Constraint], [MaxOccurance], [Message], [Description], [ActiveFlag], [ManualFlag])
)
INSERT INTO [CONFIG].[CheckConstraint]
(
    [ProcedureName]
   ,[ErrorType]
   ,[Task]
   ,[Entity]
   ,[Step]
   ,[SchemaName]
   ,[TableName]
   ,[Id1_FieldName]
   ,[Id2_FieldName]
   ,[Id3_FieldName]
   ,[Check_FieldName]
   ,[Constraint]
   ,[MaxOccurance]
   ,[Message]
   ,[Description]
   ,[ActiveFlag]
   ,[ManualFlag]
)
SELECT  [ProcedureName], [ErrorType], [Task], [Entity], [Step], [SchemaName], [TableName], [Id1_FieldName], [Id2_FieldName], [Id3_FieldName], [Check_FieldName], [Constraint], [MaxOccurance], [Message], [Description], [ActiveFlag], [ManualFlag] FROM CTE_CheckUserDefinedConstraints

-- --------------------------------------------------------------------------------
-- Step 5: Helper statements (data) for analysis purposes
-- --------------------------------------------------------------------------------
SELECT TOP 100 * FROM [E1].[Test];
SELECT TOP 100 * FROM [T1].[Test];
SELECT TOP 100 * FROM [T2].[Test];

SELECT COUNT(*) FROM [E1].[Test];
SELECT COUNT(*) FROM [T1].[Test];
SELECT COUNT(*) FROM [T2].[Test];


-- --------------------------------------------------------------------------------
-- Step 6: Helper statements (log tables)
-- --------------------------------------------------------------------------------

SELECT * FROM [LOG].[Execution] ORDER BY 1 DESC;

SELECT * FROM [LOG].[Component] WHERE [ExecutionID] = 22 ORDER BY 1 DESC;
SELECT * FROM [LOG].[Trace]     WHERE [ExecutionID] = 22 ORDER BY 1 DESC;

SELECT * FROM [LOG].[Error]     WHERE [ExecutionID] = 22 AND ErrorType = 'E';
SELECT * FROM [LOG].[Error]     WHERE [ExecutionID] = 22 AND ErrorType = 'W';


SELECT * FROM [T1].[Test] WHERE [IPv4Address] = '10.22.187.7' OR [IPv4Address] = '10.22.187.8';
SELECT * FROM [T2].[Test];
SELECT * FROM [LOG].[Error] WHERE [ID1Value] IN (96223, 96224) AND [ExecutionID] = 22;

SELECT * FROM [LOG].[vExecutionDuration];
SELECT * FROM [LOG].[vTraceDuration];
SELECT * FROM [LOG].[vErrorByErrortypeComponentEntityStep];
