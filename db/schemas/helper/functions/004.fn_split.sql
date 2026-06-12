\echo "## CREATE FUNCTION :schema_helper.fn_split"

DROP FUNCTION IF EXISTS :schema_helper.fn_split(varchar, varchar);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_value       varchar
--       Zu zerlegender Wert
--    p_separator   varchar
--       Trenn-String (ein oder mehr Zeichen)
-- --------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION :schema_helper.fn_split
(
    IN    p_value       varchar
   ,IN    p_separator   varchar
)
RETURNS TABLE (value varchar)
LANGUAGE plpgsql
IMMUTABLE
AS $function$
BEGIN

   -- NULL/leerer Wert -> keine Zeilen
   IF p_value IS NULL OR p_value = '' THEN
      RETURN;
   END IF;

   -- NULL/leeres Trennzeichen -> kein Split: der ganze Wert als eine Zeile
   -- (faengt PostgreSQLs NULL-Delimiter-Verhalten ab, das in Einzelzeichen zerlegen wuerde)
   IF p_separator IS NULL OR p_separator = '' THEN
      RETURN QUERY
         SELECT p_value;
      RETURN;
   END IF;

   -- Standard-Split: innere und abschliessende Leer-Elemente bleiben erhalten
   RETURN QUERY
      SELECT T01.item::varchar
      FROM   string_to_table(p_value, p_separator) AS T01(item);

END;
$function$;

ALTER FUNCTION :schema_helper.fn_split(varchar, varchar) OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- di2f-0008:
--    Portabilitäts-Helfer: zerlegt p_value am Trennzeichen p_separator und liefert
--    die Elemente als Zeilenmenge (Spalte 'value'). NULL/leerer Wert -> 0 Zeilen;
--    NULL/leeres Trennzeichen -> ganzer Wert als eine Zeile. Innere und abschliessende
--    Leer-Elemente bleiben erhalten ('A,,C' -> A,'',C ; 'A,B,C,' -> A,B,C,'').
--    p_separator darf ein oder mehr Zeichen haben (string_to_table, z. B. '::').
--    Reine Berechnung (IMMUTABLE).
-- --------------------------------------------------------------------------------

\echo "## CREATE FUNCTION :schema_helper.fn_split - DONE"
