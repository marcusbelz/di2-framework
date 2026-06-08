
-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vExecutionDuration]
AS
   WITH
   CTE_Seconds AS
   (
      SELECT 
          [ID]     AS [ExecutionID] 
         ,[Start]  AS [Start] 
         ,[End]    AS [End] 
         ,DATEDIFF(SECOND, [Start], [End])         AS [TotalSeconds]
         ,DATEDIFF(SECOND, [Start], [End])/3600    AS [Hours]
         ,DATEDIFF(SECOND, [Start], [End])/60  %60 AS [Minutes]
         ,DATEDIFF(SECOND, [Start], [End])     %60 AS [Seconds]
      FROM 
         [LOG].[Execution]
   )
   SELECT 
       [ExecutionID] 
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