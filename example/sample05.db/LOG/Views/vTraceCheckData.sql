-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vTraceCheckData]
AS
   SELECT 
       [ExecutionID]                                               AS [ExecutionID] 
      ,[Entity]                                                    AS [Entity] 
      ,CASE WHEN [Step] LIKE N'Check Constraint:%'     THEN N'Constraint'
            WHEN [Step] LIKE N'Check Unique Columns:%' THEN N'Uniqueness'
            ELSE N'unknown'
       END                                                         AS [Type] 
      ,CASE WHEN [Step] LIKE N'Check Constraint:%'     THEN LTRIM(RTRIM(REPLACE([Step], N'Check Constraint:'    , N'')))
            WHEN [Step] LIKE N'Check Unique Columns:%' THEN LTRIM(RTRIM(REPLACE([Step], N'Check Unique Columns:', N'')))
            ELSE N'unknown'
       END                                                         AS [Condition] 
      ,LTRIM(RTRIM(REPLACE([Description], 'Number of rows:', ''))) AS [AffectedRows]
   FROM 
      [LOG].[Trace] 
   WHERE 
          [Component]    = 'IL.sp_DataCheck' 
      AND (
                [Step] LIKE N'Check Constraint:%'
             OR [Step] LIKE N'Check Unique Columns:%'
          );
