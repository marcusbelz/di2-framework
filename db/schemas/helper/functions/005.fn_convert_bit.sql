\echo "## CREATE FUNCTION :schema_helper.fn_convert_bit"

DROP FUNCTION IF EXISTS :schema_helper.fn_convert_bit(varchar);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_value       varchar
--       Zu konvertierender Wert (z. B. 'J', 'N', '1', '0', 'true', 'false')
-- --------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION :schema_helper.fn_convert_bit
(
    IN    p_value       varchar
)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $function$
DECLARE
   l_value                   varchar;
BEGIN

   IF p_value IS NULL THEN
      RETURN NULL;
   END IF;

   l_value := upper(btrim(p_value));

   RETURN CASE l_value
             WHEN '1'     THEN true
             WHEN 'J'     THEN true
             WHEN 'TRUE'  THEN true
             WHEN '0'     THEN false
             WHEN 'N'     THEN false
             WHEN 'FALSE' THEN false
             WHEN ''      THEN false
             ELSE NULL
          END;

END;
$function$;

ALTER FUNCTION :schema_helper.fn_convert_bit(varchar) OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- di2f-0009:
--    Portabilitäts-Helfer: wandelt einen Text in boolean. '1'/'J'/'TRUE' -> true;
--    '0'/'N'/'FALSE'/'' -> false; NULL -> NULL; alles andere -> NULL. Case-insensitiv,
--    vorab getrimmt. Reine Berechnung (IMMUTABLE). Token-Liste zentral erweiterbar.
-- --------------------------------------------------------------------------------

\echo "## CREATE FUNCTION :schema_helper.fn_convert_bit - DONE"
