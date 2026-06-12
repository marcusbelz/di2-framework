\echo "## CREATE FUNCTION :schema_helper.fn_convert_datetime2"

DROP FUNCTION IF EXISTS :schema_helper.fn_convert_datetime2(varchar, varchar);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_value       varchar
--       Zu konvertierender Datums-/Zeit-String
--    p_date_style  varchar
--       Format-Hinweis (Style-Token, case-insensitiv) — bestimmt v. a. die
--       Tag-/Monat-Reihenfolge; siehe Style->Masken-Tabelle unten
-- --------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION :schema_helper.fn_convert_datetime2
(
    IN    p_value       varchar
   ,IN    p_date_style  varchar
)
RETURNS timestamp(6)
LANGUAGE plpgsql
STABLE
AS $function$
DECLARE
   l_style                   varchar;
   l_value                   varchar;
   l_mask                    varchar;
BEGIN

   IF p_value IS NULL THEN
      RETURN NULL;
   END IF;

   l_style := lower(btrim(p_date_style));
   l_value := btrim(p_value);

   -- --------------------------------------------------------------------------------
   -- Style -> PostgreSQL-Format-Maske (zentrale, dokumentierte Zuordnung).
   -- Unbekannter Style -> NULL (kein Best-Effort-Raten, vgl. Tech Design E.2).
   -- --------------------------------------------------------------------------------
   l_mask := CASE l_style
                WHEN 'yyyy.mm.dd'                 THEN 'YYYY.MM.DD'
                WHEN 'yyyymmdd'                   THEN 'YYYYMMDD'
                WHEN 'yyyy/mm/dd'                 THEN 'YYYY/MM/DD'
                WHEN 'yyyy-mm-dd hh:mi:ss'        THEN 'YYYY-MM-DD HH24:MI:SS'
                WHEN 'yyyy-mm-dd hh:mi:ss.mmm'    THEN 'YYYY-MM-DD HH24:MI:SS.MS'
                WHEN 'yyyy-mm-ddthh:mi:ss.mmm'    THEN 'YYYY-MM-DD"T"HH24:MI:SS.MS'
                WHEN 'yyyy-mm-ddthh:mi:ss.mmmz'   THEN 'YYYY-MM-DD"T"HH24:MI:SS.MS'
                WHEN 'mm/dd/yyyy'                 THEN 'MM/DD/YYYY'
                WHEN 'mm-dd-yyyy'                 THEN 'MM-DD-YYYY'
                WHEN 'dd/mm/yyyy'                 THEN 'DD/MM/YYYY'
                WHEN 'dd.mm.yyyy'                 THEN 'DD.MM.YYYY'
                WHEN 'dd-mm-yyyy'                 THEN 'DD-MM-YYYY'
                WHEN 'mon dd yyyy'                THEN 'MON DD YYYY'
                WHEN 'mon dd, yyyy'               THEN 'MON DD, YYYY'
                WHEN 'dd mon yyyy'                THEN 'DD MON YYYY'
                WHEN 'mon dd yyyy hh:miam'        THEN 'MON DD YYYY HH12:MIAM'
                WHEN 'mon dd yyyy hh:mi:ss:mmmam' THEN 'MON DD YYYY HH12:MI:SS:MSAM'
                WHEN 'dd mon yyyy hh:mi:ss:mmm'   THEN 'DD MON YYYY HH24:MI:SS:MS'
                WHEN 'dd mon yyyy hh:mi:ss:mmmam' THEN 'DD MON YYYY HH12:MI:SS:MSAM'
                WHEN 'dd/mm/yyyy hh:mi:ss:mmmam'  THEN 'DD/MM/YYYY HH12:MI:SS:MSAM'
                WHEN 'hh:mm:ss'                   THEN 'HH24:MI:SS'
                WHEN 'hh:mi:ss:mmm'               THEN 'HH24:MI:SS:MS'
                ELSE NULL
             END;

   IF l_mask IS NULL THEN
      RETURN NULL;
   END IF;

   -- optionales ISO-Zeitzonen-'Z' am Wert-Ende entfernen (Style endet auf 'z')
   IF right(l_style, 1) = 'z' THEN
      l_value := regexp_replace(l_value, '[Zz]\s*$', '');
   END IF;

   -- to_timestamp liefert timestamptz; ::timestamp(6) gibt den zonenlosen Wandwert
   RETURN to_timestamp(l_value, l_mask)::timestamp(6);

EXCEPTION WHEN data_exception THEN
   -- unparsbarer/ungueltiger Wert (SQLSTATE-Klasse 22, z. B. 22007/22008) -> NULL;
   -- Datenfehler-Protokollierung ist Sache des Aufrufers. Andere Fehlerklassen
   -- (echte Programmierfehler) propagieren bewusst, statt still zu NULL zu werden.
   RETURN NULL;
END;
$function$;

ALTER FUNCTION :schema_helper.fn_convert_datetime2(varchar, varchar) OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- di2f-0009:
--    Kern-Konvertierung Text + Style -> timestamp(6) (höchste PG-Präzision; Gegenstück
--    zu SQL-Server datetime2). Hält die zentrale Style->Masken-Tabelle; fn_convert_date
--    und fn_convert_datetime casten dieses Ergebnis. STABLE, weil Text->Datum-Parsen
--    von DateStyle/Locale (Monatsnamen, AM/PM) abhängt. Unbekannter Style/unparsbar -> NULL.
-- --------------------------------------------------------------------------------

\echo "## CREATE FUNCTION :schema_helper.fn_convert_datetime2 - DONE"
