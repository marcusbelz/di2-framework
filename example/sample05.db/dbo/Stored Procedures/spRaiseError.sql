-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Fires an execption with the passed parameters, severity and state.
-- --------------------------------------------------------------------------------
-- Parameters :
--    @p_message   AS nvarchar(255)
--       Error messsage
--    @p_procedure AS nvarchar(128)
--       Object name of the calling object.
--    @p_severity  AS int = 16
--       Severity of the error
--    @p_state     AS int = 1
--       State of the error
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spRaiseError] 
	 @p_message   AS nvarchar(max)
	,@p_procedure AS nvarchar(128)
	,@p_severity  AS int          = 16
	,@p_state     AS int          = 1
AS
BEGIN
   IF @p_message IS NULL
      BEGIN
         RAISERROR ('An error occured in stored procedure ''%s''.', @p_severity, @p_state, @p_procedure);	
      END
   ELSE
      BEGIN
         RAISERROR  ('An error occured in stored procedure ''%s'': %s', @p_severity, @p_state, @p_procedure, @p_message);	
      END;	
END
--[dbo].[spRaiseError]