CREATE VIEW [LOG].[vErrorByErrortypeComponentEntityStep]
AS
   SELECT 
       [ExecutionID] 
      ,[ErrorType]
      ,[Component]
      ,[Entity]
      ,[Step]
      ,COUNT(*) AS [ErrorCount]
   FROM 
      [LOG].[Error]
   GROUP BY
       [ExecutionID] 
      ,[ErrorType]
      ,[Component]
      ,[Entity]
      ,[Step];