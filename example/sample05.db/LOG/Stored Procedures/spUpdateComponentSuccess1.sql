-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates [LOG].[Component] with [State] = 'success' and [Success] = '1'. 
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
CREATE PROCEDURE [LOG].[spUpdateComponentSuccess1]
   @p_componentId            AS int           -- @p_componentId int            > User::componentId
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateComponent]
       @p_componentId        -- @p_componentId    int           > User::componentId
      ,NULL                  -- @p_Description    nvarchar(max)
      ,'success'             -- @p_state          nvarchar(100) 
      ,1;                    -- @p_Success        bit
END;
-- [LOG].[spUpdateComponentSuccess1]

-- EXEC [LOG].[spUpdateComponentSuccess1] 1;
