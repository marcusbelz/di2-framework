-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: 
-- --------------------------------------------------------------------------------
CREATE VIEW [LOG].[vErrorSystem]
AS
   SELECT 
      * 
   FROM 
      [LOG].[Error]
   WHERE
      [TableName] = N'<System>';