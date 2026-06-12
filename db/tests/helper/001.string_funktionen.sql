-- --------------------------------------------------------------------------------
-- TEST: helper String-/Prädikat-Funktionen (di2f-0008, AK 1-9 + Edge Cases)
-- --------------------------------------------------------------------------------
-- Reines psql + Assertions (DO-Block / ASSERT), keine Extension. Gleiche Konvention
-- wie db/tests/config/005.process.sql.
--
-- Aufruf gegen eine frisch deployte DB (Schema-Variablen aus <env>.env.sql laden):
--   psql -h <host> -U <user> -d <db> -v ON_ERROR_STOP=1 \
--        -f db/config/<env>.env.sql -f db/tests/helper/001.string_funktionen.sql
--
-- Reine IMMUTABLE-Funktionen ohne Seiteneffekte -> transaktional + ROLLBACK nur der
-- Form halber (es entstehen ohnehin keine Daten). Wertetabellen aus den Testfaellen
-- der SQL-Server-Vorlage abgeleitet.
-- --------------------------------------------------------------------------------
\set ON_ERROR_STOP on

\echo "## TEST helper string functions"

BEGIN;

SET LOCAL search_path = :schema_helper, pg_temp;

DO $test$
BEGIN
   -- =============================================================================
   -- AK1: fn_is_null_or_empty
   -- =============================================================================
   ASSERT fn_is_null_or_empty(NULL, false) = true , 'AK1 (NULL,false)';
   ASSERT fn_is_null_or_empty(NULL, true ) = true , 'AK1 (NULL,true)';
   ASSERT fn_is_null_or_empty('',   false) = true , 'AK1 ('''',false)';
   ASSERT fn_is_null_or_empty('',   true ) = true , 'AK1 ('''',true)';
   ASSERT fn_is_null_or_empty(' ',  false) = false, 'AK1 (space,false)';
   ASSERT fn_is_null_or_empty(' ',  true ) = true , 'AK1 (space,true)';
   ASSERT fn_is_null_or_empty('  ', false) = false, 'AK1 (2space,false)';
   ASSERT fn_is_null_or_empty('  ', true ) = true , 'AK1 (2space,true)';
   ASSERT fn_is_null_or_empty(' X ',false) = false, 'AK1 (X,false)';
   ASSERT fn_is_null_or_empty(' X ',true ) = false, 'AK1 (X,true)';

   -- =============================================================================
   -- AK2: fn_starts_with (case-sensitiv, literal)
   -- =============================================================================
   ASSERT fn_starts_with(' abcde ', 'a',  false) = false, 'AK2 a/false';
   ASSERT fn_starts_with(' abcde ', 'a',  true ) = true , 'AK2 a/true';
   ASSERT fn_starts_with(' abcde ', 'ab', false) = false, 'AK2 ab/false';
   ASSERT fn_starts_with(' abcde ', 'ab', true ) = true , 'AK2 ab/true';
   ASSERT fn_starts_with(' abcde ', 'Ab', true ) = false, 'AK2 Ab/true (case)';

   -- =============================================================================
   -- AK3: fn_ends_with (case-sensitiv, literal)
   -- =============================================================================
   ASSERT fn_ends_with(' abcde ', 'e',  false) = false, 'AK3 e/false';
   ASSERT fn_ends_with(' abcde ', 'e',  true ) = true , 'AK3 e/true';
   ASSERT fn_ends_with(' abcde ', 'de', false) = false, 'AK3 de/false';
   ASSERT fn_ends_with(' abcde ', 'de', true ) = true , 'AK3 de/true';
   ASSERT fn_ends_with(' abcde ', 'De', true ) = false, 'AK3 De/true (case)';

   -- =============================================================================
   -- AK4: NULL-Eingaben -> false (keine Exception)
   -- =============================================================================
   ASSERT fn_starts_with(NULL, 'a',  true) = false, 'AK4 starts NULL input';
   ASSERT fn_starts_with('a',  NULL, true) = false, 'AK4 starts NULL pattern';
   ASSERT fn_ends_with(NULL, 'a',  true)   = false, 'AK4 ends NULL input';
   ASSERT fn_ends_with('a',  NULL, true)   = false, 'AK4 ends NULL pattern';

   -- =============================================================================
   -- AK5: leeres Pattern -> true
   -- =============================================================================
   ASSERT fn_starts_with('abc', '', false) = true, 'AK5 starts empty pattern';
   ASSERT fn_ends_with('abc',   '', false) = true, 'AK5 ends empty pattern';

   -- =============================================================================
   -- AK6-9: fn_split
   -- =============================================================================
   -- AK6: A,B,C -> 3 Zeilen
   ASSERT (SELECT count(*)                FROM fn_split('A,B,C', ',')) = 3,       'AK6 count';
   ASSERT (SELECT string_agg(value, '|')  FROM fn_split('A,B,C', ',')) = 'A|B|C', 'AK6 values';
   -- AK7: NULL / leer -> 0 Zeilen
   ASSERT (SELECT count(*) FROM fn_split(NULL, ',')) = 0, 'AK7 NULL value';
   ASSERT (SELECT count(*) FROM fn_split('',   ',')) = 0, 'AK7 empty value';
   -- AK8: innere Leer-Elemente bleiben
   ASSERT (SELECT string_agg(value, '|') FROM fn_split('A,,C', ',')) = 'A||C', 'AK8 inner empty';
   -- AK9: abschliessendes Trennzeichen -> leeres Schluss-Element
   ASSERT (SELECT count(*)               FROM fn_split('A,B,C,', ',')) = 4,        'AK9 trailing count';
   ASSERT (SELECT string_agg(value, '|') FROM fn_split('A,B,C,', ',')) = 'A|B|C|', 'AK9 trailing value';

   -- =============================================================================
   -- Edge Cases
   -- =============================================================================
   -- p_trim NULL wird wie "nicht trimmen" behandelt
   ASSERT fn_is_null_or_empty(' ', NULL)        = false, 'Edge trim NULL -> no trim';
   ASSERT fn_starts_with(' abc', 'a', NULL)     = false, 'Edge starts trim NULL';
   -- Tab wird NICHT getrimmt (btrim entfernt nur Leerzeichen, wie die Vorlage)
   ASSERT fn_is_null_or_empty(E'\t', true)      = false, 'Edge tab not trimmed';
   -- Pattern laenger als Wert -> false
   ASSERT fn_starts_with('ab', 'abc', false)    = false, 'Edge pattern longer (starts)';
   ASSERT fn_ends_with('ab', 'abc', false)      = false, 'Edge pattern longer (ends)';
   -- NULL/leeres Trennzeichen -> ganzer Wert als eine Zeile (kein Split)
   ASSERT (SELECT string_agg(value, '|') FROM fn_split('x,y', NULL)) = 'x,y', 'Edge split NULL sep';
   ASSERT (SELECT string_agg(value, '|') FROM fn_split('x,y', ''))   = 'x,y', 'Edge split empty sep';
   -- nur Trennzeichen -> zwei leere Elemente
   ASSERT (SELECT count(*) FROM fn_split(',', ',')) = 2, 'Edge split only-separator';
   -- Unicode zeichen-basiert
   ASSERT fn_ends_with('grüße', 'ße', false)   = true, 'Edge unicode ends';
   ASSERT fn_starts_with('Äpfel', 'Äp', false) = true, 'Edge unicode starts';

   RAISE NOTICE '### ALL ASSERTIONS PASSED (AK 1-9 + Edge Cases)';
END;
$test$;

ROLLBACK;

\echo "## TEST helper string functions - DONE"
