\echo "## CREATE FUNCTION :schema_helper.fn_ends_with"

DROP FUNCTION IF EXISTS :schema_helper.fn_ends_with(varchar, varchar, boolean);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_input       varchar
--       Zu prüfender Wert
--    p_pattern     varchar
--       Muster (literaler String, kein Wildcard), auf das hin geprüft wird
--    p_trim        boolean
--       true = Wert vor der Prüfung beidseitig trimmen
-- --------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION :schema_helper.fn_ends_with
(
    IN    p_input       varchar
   ,IN    p_pattern     varchar
   ,IN    p_trim        boolean
)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $function$
DECLARE
   l_value                   varchar;
BEGIN

   IF p_input IS NULL OR p_pattern IS NULL THEN
      RETURN false;
   END IF;

   IF p_trim THEN
      l_value := btrim(p_input);
   ELSE
      l_value := p_input;
   END IF;

   -- kein PG-Bordmittel 'ends_with' -> literaler Suffix-Vergleich über right();
   -- leeres Muster -> right(...,0) = '' -> true; Muster länger als Wert -> false.
   RETURN right(l_value, char_length(p_pattern)) = p_pattern;

END;
$function$;

ALTER FUNCTION :schema_helper.fn_ends_with(varchar, varchar, boolean) OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- di2f-0008:
--    Portabilitäts-Helfer: true, wenn p_input mit p_pattern endet. Case-sensitiv,
--    p_pattern literal. p_input/p_pattern NULL -> false; leeres Muster -> true.
--    p_trim trimmt p_input vorab. Reine Berechnung (IMMUTABLE).
-- --------------------------------------------------------------------------------

\echo "## CREATE FUNCTION :schema_helper.fn_ends_with - DONE"
