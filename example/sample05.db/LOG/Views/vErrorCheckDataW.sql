-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vErrorCheckDataW]
AS
SELECT 
   * 
FROM 
   [LOG].[Error]
WHERE
       [Component] = N'IL.spDataCheck'
   AND [ErrorType] = N'W';