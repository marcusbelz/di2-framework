-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vTraceStateProcessing]
AS
   SELECT 
      * 
   FROM 
      [LOG].[Trace] 
   WHERE 
      [State] = 'processing';