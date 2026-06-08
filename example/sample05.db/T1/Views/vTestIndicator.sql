


-- --------------------------------------------------------------------------------
-- Author     : mbelz
-- Create date: 16.09.2019
-- Description: Calculates inidicators for Bot Code in the text columns of the 
--              table [T1].[Test].
-- Base Views : [T1].[vTestByKeyword]
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20190916 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE VIEW [T1].[vTestIndicator]
AS
WITH
CTE_Indicator AS
(
   SELECT 
       [ID]                               AS [ID]
      --,[Keyword]                          AS [Keyword]
      --,[Weight]                           AS [Weight]
      ,[Salutation]                       AS [Salutation]
      ,[FirstName]                        AS [FirstName]
      ,[LastName]                         AS [LastName]
      ,[Field1]                           AS [Field1]
      ,[Field2]                           AS [Field2]
      ,[Field3]                           AS [Field3]
      ,[Field4]                           AS [Field4]
      ,SUM([Salutation_Count]           ) AS [Salutation_Count]
      ,SUM([FirstName_Count]            ) AS [FirstName_Count]
      ,SUM([LastName_Count]             ) AS [LastName_Count]
      ,SUM([Field1_Count]               ) AS [Field1_Count]
      ,SUM([Field2_Count]               ) AS [Field2_Count]
      ,SUM([Field3_Count]               ) AS [Field3_Count]
      ,SUM([Field4_Count]               ) AS [Field4_Count]

      --,SUM([Salutation_Count] * [Weight]) AS [Salutation_WeightedCount]
      --,SUM([FirstName_Count]  * [Weight]) AS [FirstName_WeightedCount]
      --,SUM([LastName_Count]   * [Weight]) AS [LastName_WeightedCount]
      --,SUM([Field1_Count]     * [Weight]) AS [Field1_WeightedCount]
      --,SUM([Field2_Count]     * [Weight]) AS [Field2_WeightedCount]
      --,SUM([Field3_Count]     * [Weight]) AS [Field3_WeightedCount]
      --,SUM([Field4_Count]     * [Weight]) AS [Field4_WeightedCount]
   FROM
      [T1].[vTestCountByKeyword]
   GROUP BY
       [ID]
      --,[Keyword] 
      --,[Weight]  
      ,[Salutation]
      ,[FirstName]
      ,[LastName]
      ,[Field1]
      ,[Field2]
      ,[Field3]
      ,[Field4]
)
SELECT
    [ID]                          AS [ID]                       -- ID of the row to be checked
   ,[Salutation]                  AS [Salutation]               -- Text field: [E1].[Test].[Salutation]
   ,[FirstName]                   AS [FirstName]                -- Text field: [E1].[Test].[FirstName]
   ,[LastName]                    AS [LastName]                 -- Text field: [E1].[Test].[LastName]
   ,[Field1]                      AS [Field1]                   -- Text field: [E1].[Test].[Field1]
   ,[Field2]                      AS [Field2]                   -- Text field: [E1].[Test].[Field2]
   ,[Field3]                      AS [Field3]                   -- Text field: [E1].[Test].[Field3]
   ,[Field4]                      AS [Field4]                   -- Text field: [E1].[Test].[Field4]

   ,[Salutation_Count]            AS [Salutation_Count]         -- Keyword Count
   ,[FirstName_Count]             AS [FirstName_Count]          -- see [Salutation_Count]
   ,[LastName_Count]              AS [LastName_Count]           -- see [Salutation_Count]
   ,[Field1_Count]                AS [Field1_Count]             -- see [Salutation_Count]
   ,[Field2_Count]                AS [Field2_Count]             -- see [Salutation_Count]
   ,[Field3_Count]                AS [Field3_Count]             -- see [Salutation_Count]
   ,[Field4_Count]                AS [Field4_Count]             -- see [Salutation_Count]

   --,[Salutation_WeightedCount]    AS [Salutation_WeightedCount] -- Keyword Count multiplied with the Keyword-Weight
   --,[FirstName_WeightedCount]     AS [FirstName_WeightedCount]  -- see [Salutation_WeightedCount]
   --,[LastName_WeightedCount]      AS [LastName_WeightedCount]   -- see [Salutation_WeightedCount]
   --,[Field1_WeightedCount]        AS [Field1_WeightedCount]     -- see [Salutation_WeightedCount]
   --,[Field2_WeightedCount]        AS [Field2_WeightedCount]     -- see [Salutation_WeightedCount]
   --,[Field3_WeightedCount]        AS [Field3_WeightedCount]     -- see [Salutation_WeightedCount]
   --,[Field4_WeightedCount]        AS [Field4_WeightedCount]     -- see [Salutation_WeightedCount]
FROM
   CTE_Indicator;