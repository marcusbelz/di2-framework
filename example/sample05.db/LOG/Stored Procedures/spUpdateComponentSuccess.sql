-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Updates [LOG].[Component] with [State] = 'success' and [Success] = '1'. 
--              Designed for usage in SSIS.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_componentId          AS int
--       User::componentId
--    @p_description          AS nvarchar(max)
--       User::componentDescription
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
CREATE PROCEDURE [LOG].[spUpdateComponentSuccess]
   @p_componentId            AS int           -- @p_componentId int            > User::componentId
  ,@p_description   AS nvarchar(max)          -- @p_description  nvarchar(max) > User::componentDescription
AS
BEGIN
   SET NOCOUNT ON;   

   EXEC [LOG].[spUpdateComponent]
       @p_componentId          -- @p_componentId    int           > User::componentId
      ,@p_description          -- @p_description    nvarchar(max) > User::componentDescription
      ,'success'               -- @p_state          nvarchar(100) 
      ,1;                      -- @p_Success        bit
END;
-- [LOG].[spUpdateComponentSuccess]

-- EXEC [LOG].[spUpdateComponentSuccess] 1, 'process successfully finished';
