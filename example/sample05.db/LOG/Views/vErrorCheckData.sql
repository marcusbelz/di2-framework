-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vErrorCheckData]
AS
   SELECT 
       T01.[ExecutionID]                                       AS [ExecutionID]
      ,T01.[ComponentID]                                       AS [ComponentID]
      ,T01.[TraceID]                                           AS [TraceID]
      ,T02.[Process]                                           AS [Process]
      ,T03.[Component]                                         AS [Component]
      ,T01.[Entity]                                            AS [Entity]
      ,SUM(CASE WHEN T01.[ErrorType] = N'I' THEN 1 ELSE 0 END) AS [Information]
      ,SUM(CASE WHEN T01.[ErrorType] = N'W' THEN 1 ELSE 0 END) AS [Warning]
      ,SUM(CASE WHEN T01.[ErrorType] = N'E' THEN 1 ELSE 0 END) AS [Error]
   FROM 
      [LOG].[Error] T01
      LEFT JOIN [LOG].[Execution] T02
      ON
        T01.[ExecutionID] = T02.[ID]
      LEFT JOIN [LOG].[Component] T03
      ON
        T01.[ComponentID] = T03.[ID]
   WHERE
          T01.[Component] = N'IL.spDataCheck'
      AND T01.[ErrorType] IN (N'I', N'W', N'E')
   GROUP BY 
       T01.[ExecutionID]
      ,T01.[ComponentID]
      ,T01.[TraceID]
      ,T02.[Process]
      ,T03.[Component]
      ,T01.[Entity];