-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vTraceNotSuccessfull]
AS
   SELECT 
      * 
   FROM 
      [LOG].[Trace] 
   WHERE 
      [Success] = 0;