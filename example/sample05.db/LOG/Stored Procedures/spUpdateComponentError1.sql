-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates [LOG].[Component] with [State] = 'error' and [Success] = '0'. 
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_componentId          AS int
--       User::componentID
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
CREATE PROCEDURE [LOG].[spUpdateComponentError1]
   @p_componentId            AS int           -- @p_componentId int            > User::componentId
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateComponent]
       @p_componentId        -- @p_componentId    int           > User::componentID
      ,NULL                  -- @p_description    nvarchar(max) 
      ,'error'               -- @p_state          nvarchar(100) 
      ,0;                    -- @p_Success        bit
END;
-- [LOG].[spUpdateComponentError1]

-- EXEC [LOG].[spUpdateComponentError1] 1;
