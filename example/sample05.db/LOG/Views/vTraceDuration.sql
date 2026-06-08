
-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vTraceDuration]
AS
   WITH
   CTE_Seconds AS
   (
      SELECT 
          [ExecutionID]                                                              AS [ExecutionID] 
         ,[ComponentID]                                                              AS [ComponentID] 
         ,[ID]                                                                       AS [Trace_ID] 
         ,[Component]                                                                AS [Component] 
         ,[Entity]                                                                   AS [Entity] 
         ,[Step]                                                                     AS [Step] 
         ,[CreatedOn]                                                                AS [Start] 
         ,COALESCE([ModifiedOn], [CreatedOn])                                        AS [End] 
         ,DATEDIFF(SECOND, [CreatedOn], COALESCE([ModifiedOn], [CreatedOn]))         AS [TotalSeconds]
         ,DATEDIFF(SECOND, [CreatedOn], COALESCE([ModifiedOn], [CreatedOn]))/3600    AS [Hours]
         ,DATEDIFF(SECOND, [CreatedOn], COALESCE([ModifiedOn], [CreatedOn]))/60  %60 AS [Minutes]
         ,DATEDIFF(SECOND, [CreatedOn], COALESCE([ModifiedOn], [CreatedOn]))     %60 AS [Seconds]
      FROM 
         [LOG].[Trace]
      WHERE 
         DATEDIFF(SECOND, [CreatedOn], COALESCE([ModifiedOn], [CreatedOn])) > 0
   )
   SELECT 
       [ExecutionID] 
      ,[ComponentID] 
      ,[Trace_ID] 
      ,[Component] 
      ,[Start] 
      ,[End] 
      ,CAST(([TotalSeconds]/3600.0) AS decimal(10,3)) AS [IndustrialHours]
      ,CONCAT( RIGHT('000' + CAST(FLOOR([Hours]/3600)   AS nvarchar(3)), 3), ':'
              ,RIGHT( '00' + CAST(FLOOR([Minutes]%  60) AS nvarchar(2)), 2), ':'
              ,RIGHT( '00' + CAST(FLOOR([Seconds]%  60) AS nvarchar(2)), 2)
             ) AS [Time]
      ,[TotalSeconds]
   FROM 
      CTE_Seconds;