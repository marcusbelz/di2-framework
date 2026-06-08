




-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Counts in all text columns of the table [T1].[Test] all ocurrances 
--              of those key words configured in table [sec].[BotCodeKeyword].
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20190930 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE VIEW [T1].[vTestCountByKeyword]
AS
WITH
CTE_Replace AS
( 
   SELECT 
       T01.[ID]
      ,T02.[Keyword]
      ,T02.[Weight]
      ,T01.[Salutation]
      ,T01.[FirstName]
      ,T01.[LastName]
      ,T01.[Field1]
      ,T01.[Field2]
      ,T01.[Field3]
      ,T01.[Field4]
      ,REPLACE(T01.[Salutation], T02.[Keyword], N'') AS [Salutation_Replaced]
      ,REPLACE(T01.[FirstName] , T02.[Keyword], N'') AS [FirstName_Replaced]
      ,REPLACE(T01.[LastName]  , T02.[Keyword], N'') AS [LastName_Replaced]
      ,REPLACE(T01.[Field1]    , T02.[Keyword], N'') AS [Field1_Replaced]
      ,REPLACE(T01.[Field2]    , T02.[Keyword], N'') AS [Field2_Replaced]
      ,REPLACE(T01.[Field3]    , T02.[Keyword], N'') AS [Field3_Replaced]
      ,REPLACE(T01.[Field4]    , T02.[Keyword], N'') AS [Field4_Replaced]
   FROM
      [T1].[Test] T01
      CROSS JOIN [sec].[BotCodeKeyword] T02
   WHERE
      T02.[Active] = 1
)
,CTE_Count AS
(
   SELECT 
       [ID]
      ,[Keyword]
      ,[Weight]
      ,[Salutation]
      ,[FirstName]
      ,[LastName]
      ,[Field1]
      ,[Field2]
      ,[Field3]
      ,[Field4]
      ,(DATALENGTH([Salutation]) - DATALENGTH([Salutation_Replaced])) / DATALENGTH([Keyword]) AS [Salutation_Count]
      ,(DATALENGTH([FirstName] ) - DATALENGTH([FirstName_Replaced] )) / DATALENGTH([Keyword]) AS [FirstName_Count]
      ,(DATALENGTH([LastName]  ) - DATALENGTH([LastName_Replaced]  )) / DATALENGTH([Keyword]) AS [LastName_Count]
      ,(DATALENGTH([Field1]    ) - DATALENGTH([Field1_Replaced]    )) / DATALENGTH([Keyword]) AS [Field1_Count]
      ,(DATALENGTH([Field2]    ) - DATALENGTH([Field2_Replaced]    )) / DATALENGTH([Keyword]) AS [Field2_Count]
      ,(DATALENGTH([Field3]    ) - DATALENGTH([Field3_Replaced]    )) / DATALENGTH([Keyword]) AS [Field3_Count]
      ,(DATALENGTH([Field4]    ) - DATALENGTH([Field4_Replaced]    )) / DATALENGTH([Keyword]) AS [Field4_Count]
   FROM
      CTE_Replace T01
)
SELECT 
    [ID]                       AS [ID]
   ,[Keyword]                  AS [Keyword]
   ,[Weight]                   AS [Weight]
   ,[Salutation]               AS [Salutation]
   ,[FirstName]                AS [FirstName]
   ,[LastName]                 AS [LastName]
   ,[Field1]                   AS [Field1]
   ,[Field2]                   AS [Field2]
   ,[Field3]                   AS [Field3]
   ,[Field4]                   AS [Field4]
   ,[Salutation_Count]         AS [Salutation_Count]
   ,[FirstName_Count]          AS [FirstName_Count]
   ,[LastName_Count]           AS [LastName_Count]
   ,[Field1_Count]             AS [Field1_Count]
   ,[Field2_Count]             AS [Field2_Count]
   ,[Field3_Count]             AS [Field3_Count]
   ,[Field4_Count]             AS [Field4_Count]
FROM
   CTE_Count;