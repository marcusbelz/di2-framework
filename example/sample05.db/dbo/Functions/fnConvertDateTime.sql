-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 20180101
-- Description: Converts a date or datetime value of any format into a 
--              value with type of datetime.
-- Acknowledgement:
--              This procedure was ariginally developped by 
--              Andreas Ludwig (Daimler TSS).
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_date        AS varchar(50)
--    @p_dateStyle   AS varchar(50)
--       Valid parts of the format string are:
--         'yyyy' as    'YEAR'
--         'yy'   as    'YEAR'
--         'mm'   as    'MONTH'
--         'dd'   as    'DAY'
--         'hh'   as    'HOUR'
--         'mi'   as    'MINUTE'
--         'ss'   as    'SECOND'
--         'mmm'  as    'MILLISECOND'
--         'am'   as    'AMPM'
--
-- --------------------------------------------------------------------------------
-- Return Value
--       Value with type of datetime
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnConvertDateTime] (@p_date AS nvarchar(50), @p_dateStyle nvarchar(50))
RETURNS datetime
AS
BEGIN
   DECLARE @returnValue AS datetime;

   SET @p_dateStyle = LOWER(@p_dateStyle)
      IF @p_dateStyle IN 
	        (   
			    N'yyyy.mm.dd'                   ,'102' -- ANSI
               ,N'yyyy-mm-dd hh:mi:ss'          ,'120' -- ODBC canonical
               ,N'yyyy-mm-dd hh:mi:ss.mmm'      ,'121' -- ODBC canonical (with milliseconds) default for time, date, datetime2, and datetimeoffset
               ,N'yyyy-mm-ddthh:mi:ss.mmm'      ,'126' -- ISO8601
               ,N'yyyy-mm-ddthh:mi:ss.mmmz'     ,'127' -- ISO8601 with time zone Z
               ,N'yyyy/mm/dd'                   ,'111' -- JAPAN
               ,N'yyyymmdd'                     ,'112' -- ISO
               ,N'mon dd yyyy hh:miam'          ,'100' -- Default for datetime and smalldatetime
               ,N'mm/dd/yyyy'                   ,'101' -- U.S.
               ,N'mon dd yyyy hh:mi:ss:mmmam'   ,'109' -- Default + milliseconds
               ,N'mm-dd-yyyy'                   ,'110' -- USA
               ,N'dd mon yyyy hh:mi:ss:mmm'     ,'113' -- Europe default + milliseconds
               ,N'dd mon yyyy hh:mi:ss:mmmam'   ,'130' -- Hijri 
               ,N'dd/mm/yyyy hh:mi:ss:mmmam'    ,'131' -- Hijri
               ,N'hh:mm:ss'                     ,'108' -- These style values return nondeterministic results. Includes all (yy) (without century) styles and a subset of (yyyy) (with century) styles.
               ,N'hh:mi:ss:mmm'                 ,'114' -- These style values return nondeterministic results. Includes all (yy) (without century) styles and a subset of (yyyy) (with century) styles.
               ,N'mon dd, yyyy'                 ,'107' -- These style values return nondeterministic results. Includes all (yy) (without century) styles and a subset of (yyyy) (with century) styles.
               ,N'dd mon yyyy'                  ,'106' -- These style values return nondeterministic results. Includes all (yy) (without century) styles and a subset of (yyyy) (with century) styles.
			)
         BEGIN
            SET @returnValue = TRY_CONVERT(datetime, @p_date, 121);
         END
      ELSE IF @p_dateStyle IN 
	       (
		       N'dd/mm/yyyy'                   ,'103'
              ,N'dd.mm.yyyy'                   ,'104'
              ,N'dd-mm-yyyy'                   ,'105'
           )
        BEGIN
           SET @returnValue = TRY_CONVERT(date, @p_date, 103);
        END
      ELSE 
         BEGIN
            SET @returnValue = TRY_CONVERT(datetime, @p_date);
         END
   RETURN @returnValue;
END
-- [dbo].[fnConvertDateTime]

/*
          SELECT [dbo].[fnConvertDateTime]('2018.08.17'                 ,'YYYY.MM.DD'                 )
UNION ALL SELECT [dbo].[fnConvertDateTime]('2018/08/17'                 ,'YYYY/MM/DD'                 )
UNION ALL SELECT [dbo].[fnConvertDateTime]('20180817'                   ,'YYYYMMDD'                   )
UNION ALL SELECT [dbo].[fnConvertDateTime]('2018-08-17 12:27:40'        ,'YYYY-MM-DD hh:mi:ss'        )
UNION ALL SELECT [dbo].[fnConvertDateTime]('2018-08-17 12:27:40.654'    ,'YYYY-MM-DD hh:mi:ss.mmm'    )
UNION ALL SELECT [dbo].[fnConvertDateTime]('2018-08-17T12:27:40.654'    ,'YYYY-MM-DDThh:mi:ss.mmm'    )
UNION ALL SELECT [dbo].[fnConvertDateTime]('2018-08-17T12:27:40.654'    ,'YYYY-MM-DDThh:mi:ss.mmmz'   )
UNION ALL SELECT [dbo].[fnConvertDateTime]('Aug 17 2018 12:27PM'        ,'MON DD YYYY hh:miAM'        )
UNION ALL SELECT [dbo].[fnConvertDateTime]('08/17/2018'                 ,'MM/DD/YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDateTime]('Aug 17, 2018'               ,'MON DD, YYYY'               )
UNION ALL SELECT [dbo].[fnConvertDateTime]('08-17-2018'                 ,'MM-DD-YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDateTime]('Aug 17 2018 12:27:40:654PM' ,'MON DD YYYY hh:mi:ss:mmmAM' )
UNION ALL SELECT [dbo].[fnConvertDateTime]('17/08/2018 12:27:40:654PM'  ,'DD/MM/YYYY HH:mi:ss:mmmAM'  )
UNION ALL SELECT [dbo].[fnConvertDateTime]('17/08/2018'                 ,'DD/MM/YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDateTime]('17.08.2018'                 ,'DD.MM.YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDateTime]('17-08-2018'                 ,'DD-MM-YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDateTime]('17 Aug 2018 12:27:40:654PM' ,'DD MON YYYY hh:mi:ss:mmmAM' )
UNION ALL SELECT [dbo].[fnConvertDateTime]('17 Aug 2018 12:27:40:654'   ,'DD MON YYYY hh:mi:ss:mmm'   )
UNION ALL SELECT [dbo].[fnConvertDateTime]('17 Aug 2018'                ,'DD MON YYYY'                )
UNION ALL SELECT [dbo].[fnConvertDateTime]('12:27:40:654'               ,'hh:mi:ss:mmm'               )
UNION ALL SELECT [dbo].[fnConvertDateTime]('12:08:40'                   ,'hh:mm:ss'                   )
*/