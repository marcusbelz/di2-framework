-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Decodes XML/HTML encoded special characters like &amp; etc.
--              The following characters will be decoded:
--                 & , ", ', Ä, ä, Ö, ö, Ü, ü, ß, § , €, £ 
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_inputString as nvarchar(max)
--       Encoded XML/HTML string
-- --------------------------------------------------------------------------------
-- Return Value
--    @p_inputString          AS narchar(max)
--       Decoded XML/HTML string
-- --------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnDecodeXML] (@p_inputString AS nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
   DECLARE @returnString nvarchar(max)

   SET @returnString = @p_inputString;

   SET @returnString = REPLACE(@returnString, '&amp;'  , '&');   
   SET @returnString = REPLACE(@returnString, '&quot;'  , '"');
   SET @returnString = REPLACE(@returnString, '&apos;'  , '''''');   
   SET @returnString = REPLACE(@returnString, '&Auml;'  , 'Ä');
   SET @returnString = REPLACE(@returnString, '&auml;'  , 'ä');
   SET @returnString = REPLACE(@returnString, '&Ouml;'  , 'Ö');
   SET @returnString = REPLACE(@returnString, '&ouml;'  , 'ö');
   SET @returnString = REPLACE(@returnString, '&Uuml;'  , 'Ü');
   SET @returnString = REPLACE(@returnString, '&uuml;'  , 'ü');
   SET @returnString = REPLACE(@returnString, '&szlig;' , 'ß');
   SET @returnString = REPLACE(@returnString, '&sect;'  , '§');   
   SET @returnString = REPLACE(@returnString, '&euro;'  , '€');
   SET @returnString = REPLACE(@returnString, '&pound;' , '£');

   --SET @returnString = REPLACE(@returnString, '&lt;'	 , '<');
   --SET @returnString = REPLACE(@returnString, '&gt;'	 , '>');

   RETURN @returnString;

END;
-- [dbo].[fnDecodeXML]