\echo "## CREATE FUNCTION :schema_helper.fn_convert_date"

DROP FUNCTION IF EXISTS :schema_helper.fn_convert_date(varchar, varchar);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_value       varchar
--       Zu konvertierender Datums-/Zeit-String
--    p_date_style  varchar
--       Format-Hinweis (Style-Token, case-insensitiv); siehe fn_convert_datetime2
-- --------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION :schema_helper.fn_convert_date
(
    IN    p_value       varchar
   ,IN    p_date_style  varchar
)
RETURNS date
LANGUAGE plpgsql
STABLE
AS $function$
BEGIN

   -- delegiert an die Kern-Konvertierung und verwirft den Zeitanteil
   RETURN helper.fn_convert_datetime2(p_value, p_date_style)::date;

END;
$function$;

ALTER FUNCTION :schema_helper.fn_convert_date(varchar, varchar) OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- di2f-0009:
--    Portabilitäts-Helfer: Text + Style -> date (Zeitanteil verworfen). Dünner Cast
--    über fn_convert_datetime2 (eine gemeinsame Style->Masken-Tabelle). NULL/unbekannter
--    Style/unparsbar -> NULL. STABLE (delegiert an STABLE-Kern).
-- --------------------------------------------------------------------------------

\echo "## CREATE FUNCTION :schema_helper.fn_convert_date - DONE"
