-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates [LOG].[Component] with [State] = 'warning' and [Success] = '1'. 
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_componentId          AS int
--       User::componentId
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 : error
--    = 0 : success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [LOG].[spUpdateComponentWarning1]
   @p_componentId            AS int           -- @p_componentId int            > User::componentId
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateComponent]
       @p_componentId       -- @p_componentId    int           > User::componentId
      ,NULL                 -- @p_description    nvarchar(max)
      ,'warning'            -- @p_state          nvarchar(100) 
      ,1;                   -- @p_success        bit
END;
-- [LOG].[spUpdateComponentWarning1]

-- EXEC [LOG].[spUpdateComponentWarning1] 1;