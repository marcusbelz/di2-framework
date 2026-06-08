-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 20180101
-- Description: Converts a date or datetime value of any format into a 
--              value with type of date.
-- Acknowledgement:
--              This procedure was ariginally developped by 
--              Andreas Ludwig (Daimler TSS).
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_Date                 AS narchar(50)
--       Value to be converted
--    @p_DateStyle            AS narchar(50)
--       Format string, that describes the format of the date string
--         'yyyy' as    'YEAR'
--         'yy'   as    'YEAR'
--         'mm'   as    'MONTH'
--         'dd'   as    'DAY'
--         'hh'   as    'HOUR'
--         'mi'   as    'MINUTE'
--         'ss'   as    'SECOND'
--         'mmm'  as    'MILLISECOND'
--         'am'   as    'AMPM'
-- --------------------------------------------------------------------------------
-- Return Value
--       Value with type of date, regardles of whether the passed parameter 
--       contains a time or not.
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnConvertDate] (@p_Date AS nvarchar(50), @p_DateStyle nvarchar(50))
RETURNS date
AS
BEGIN
   DECLARE @returnValue AS date;
   SET @p_DateStyle = LOWER(@p_DateStyle)

      IF      @p_DateStyle IN ('yyyy.mm.dd'                   ,'102'
                              ,'yyyy-mm-dd hh:mi:ss'          ,'120'
                              ,'yyyy-mm-dd hh:mi:ss.mmm'      ,'121'
                              ,'yyyy-mm-ddthh:mi:ss.mmm'      ,'126'
                              ,'yyyy-mm-ddthh:mi:ss.mmmz'     ,'127'
                              ,'yyyy/mm/dd'                   ,'111'
                              ,'yyyymmdd'                     ,'112'
                              
                              ,'hh:mm:ss'                     ,'108'
                              ,'hh:mi:ss:mmm'                 ,'114'
                              
                              ,'mon dd yyyy hh:miam'          ,'100'
                              ,'mm/dd/yyyy'                   ,'101'
                              ,'mon dd, yyyy'                 ,'107'
                              ,'mon dd yyyy hh:mi:ss:mmmam'   ,'109'
                              ,'mm-dd-yyyy'                   ,'110'
                              
                              ,'dd mon yyyy'                  ,'106'
                              ,'dd mon yyyy hh:mi:ss:mmm'     ,'113'
                              ,'dd mon yyyy hh:mi:ss:mmmam'   ,'130')
         BEGIN
            SET @returnValue = try_convert(date, CONVERT(varchar(64), @p_Date, 121));
         END
      ELSE IF @p_DateStyle IN ('dd/mm/yyyy'                   ,'103'
                              ,'dd.mm.yyyy'                   ,'104'
                              ,'dd-mm-yyyy'                   ,'105'
                              ,'dd/mm/yyyy hh:mi:ss:mmmam'    ,'131')
         BEGIN
            SET @returnValue = TRY_CONVERT(date, CONVERT(varchar(64), @p_Date, 121), 103);
         END
      ELSE 
         BEGIN
            SET @returnValue = NULL;
         END
   RETURN @returnValue;
END
/*
          SELECT [dbo].[fnConvertDate]('2018.08.17'                 ,'YYYY.MM.DD'                 )
UNION ALL SELECT [dbo].[fnConvertDate]('2018/08/17'                 ,'YYYY/MM/DD'                 )
UNION ALL SELECT [dbo].[fnConvertDate]('20180817'                   ,'YYYYMMDD'                   )
UNION ALL SELECT [dbo].[fnConvertDate]('2018-08-17 12:27:40'        ,'YYYY-MM-DD hh:mi:ss'        )
UNION ALL SELECT [dbo].[fnConvertDate]('2018-08-17 12:27:40.654'    ,'YYYY-MM-DD hh:mi:ss.mmm'    )
UNION ALL SELECT [dbo].[fnConvertDate]('2018-08-17T12:27:40.654'    ,'YYYY-MM-DDThh:mi:ss.mmm'    )
UNION ALL SELECT [dbo].[fnConvertDate]('2018-08-17T12:27:40.654'    ,'YYYY-MM-DDThh:mi:ss.mmmz'   )
UNION ALL SELECT [dbo].[fnConvertDate]('Aug 17 2018 12:27PM'        ,'MON DD YYYY hh:miAM'        )
UNION ALL SELECT [dbo].[fnConvertDate]('08/17/2018'                 ,'MM/DD/YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDate]('Aug 17, 2018'               ,'MON DD, YYYY'               )
UNION ALL SELECT [dbo].[fnConvertDate]('08-17-2018'                 ,'MM-DD-YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDate]('Aug 17 2018 12:27:40:654PM' ,'MON DD YYYY hh:mi:ss:mmmAM' )
UNION ALL SELECT [dbo].[fnConvertDate]('17/08/2018 12:27:40:654PM'  ,'DD/MM/YYYY HH:mi:ss:mmmAM'  )
UNION ALL SELECT [dbo].[fnConvertDate]('17/08/2018'                 ,'DD/MM/YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDate]('17.08.2018'                 ,'DD.MM.YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDate]('17-08-2018'                 ,'DD-MM-YYYY'                 )
UNION ALL SELECT [dbo].[fnConvertDate]('17 Aug 2018 12:27:40:654PM' ,'DD MON YYYY hh:mi:ss:mmmAM' )
UNION ALL SELECT [dbo].[fnConvertDate]('17 Aug 2018 12:27:40:654'   ,'DD MON YYYY hh:mi:ss:mmm'   )
UNION ALL SELECT [dbo].[fnConvertDate]('17 Aug 2018'                ,'DD MON YYYY'                )
UNION ALL SELECT [dbo].[fnConvertDate]('12:27:40:654'               ,'hh:mi:ss:mmm'               )
UNION ALL SELECT [dbo].[fnConvertDate]('12:08:40'                   ,'hh:mm:ss'                   )
*/