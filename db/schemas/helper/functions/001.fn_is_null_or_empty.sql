\echo "## CREATE FUNCTION :schema_helper.fn_is_null_or_empty"

DROP FUNCTION IF EXISTS :schema_helper.fn_is_null_or_empty(varchar, boolean);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_input       varchar
--       Zu prüfender Wert
--    p_trim        boolean
--       true = Wert vor der Leer-Prüfung beidseitig trimmen
-- --------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION :schema_helper.fn_is_null_or_empty
(
    IN    p_input       varchar
   ,IN    p_trim        boolean
)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $function$
DECLARE
   l_value                   varchar;
BEGIN

   IF p_input IS NULL THEN
      RETURN true;
   END IF;

   IF p_trim THEN
      l_value := btrim(p_input);
   ELSE
      l_value := p_input;
   END IF;

   RETURN char_length(l_value) = 0;

END;
$function$;

ALTER FUNCTION :schema_helper.fn_is_null_or_empty(varchar, boolean) OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- di2f-0008:
--    Portabilitäts-Helfer: true, wenn der Wert NULL oder leer ist. p_trim schaltet
--    ein beidseitiges Trimmen vor der Leer-Prüfung ein (' ' -> mit Trim leer, ohne
--    Trim nicht leer). Reine Berechnung (IMMUTABLE), wirft nie.
-- --------------------------------------------------------------------------------

\echo "## CREATE FUNCTION :schema_helper.fn_is_null_or_empty - DONE"
