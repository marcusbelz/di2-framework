-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Example Procedure using the logging procedures
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_executionId          AS int OUT
--       Returns the ID of the new row in [LOG].[Execution].
--    @p_process              AS nvarchar(max)   
--       Name of the execution process.
--    @p_machine              AS nvarchar(128)
--       Optional: Machine Name
--    @p_instance             AS nvarchar(50)
--       Optional: Instance SSIS GUID (System::ExecutionInstanceGUID)
--    @p_versionBuild         AS int
--       Optional: Instance SSIS GUID (System::ExecutionInstanceGUID)
--    @p_lastUpdate           AS datetime = NULL
--       Date and time of the last update of the row.
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

-- --------------------------------------------------------------------------------
-- Section Comment
-- --------------------------------------------------------------------------------


-- Single Line Comment


