-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 20.09.2019
-- Description: Returns the number of requests (DateCreated) with in a specified 
--              period. The period is given by a datetime value and the number of 
--              secondes. This functions looks for a period of half of the seconds 
--              into the past and half of the seconds into the future to count the 
--              requests.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_datetime              AS datetime
--       datetime value for counting the requests.
--    @p_datetime              AS int
--       Number of seconds specifies the duration of the period.
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20190920 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------
CREATE FUNCTION [T1].[fnGetRequestsByPeriod_Created] (@p_datetime AS datetime, @p_seconds AS int)
RETURNS int
BEGIN
   DECLARE @counter AS int;
   
   SELECT 
      @counter = COUNT(*)
   FROM 
      [T1].[Test]
   WHERE
          DATEADD(SECOND, ROUND(CAST(@p_seconds AS float) / 2, 0) * -1, @p_datetime) <= [DateCreated] 
      AND [DateCreated] <= DATEADD(SECOND, ROUND(CAST(@p_seconds AS float) / 2, 0)     , @p_datetime)

   SET @counter = COALESCE(@counter, 0);

   RETURN @counter;
END;
-- [T1].[fnGetRequestsByPeriod_Created]
-- SELECT [T1].[fnGetRequestsByPeriod_Created](DATEADD(SECOND, -30, CAST('2019-08-31 04:29:47' AS datetime)), 600)