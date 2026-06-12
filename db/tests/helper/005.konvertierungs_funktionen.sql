-- --------------------------------------------------------------------------------
-- TEST: helper Konvertierungs-Funktionen (di2f-0009, AK 1-10)
-- --------------------------------------------------------------------------------
-- Reines psql + Assertions (DO-Block / ASSERT), keine Extension. Gleiche Konvention
-- wie db/tests/config/005.process.sql. Wertetabellen aus den UNION-ALL-Testfaellen
-- der SQL-Server-Vorlage (fnConvert*) abgeleitet.
--
-- Aufruf gegen eine frisch deployte DB:
--   psql -h <host> -U <user> -d <db> -v ON_ERROR_STOP=1 \
--        -f db/config/<env>.env.sql -f db/tests/helper/005.konvertierungs_funktionen.sql
--
-- Hinweis: die Datums-Funktionen sind STABLE (DateStyle/Locale-abhaengig); der Test
-- setzt keinen speziellen DateStyle voraus, prueft aber zonenlose Wandwerte.
-- --------------------------------------------------------------------------------
\set ON_ERROR_STOP on

\echo "## TEST helper conversion functions"

BEGIN;

SET LOCAL search_path = :schema_helper, pg_temp;

DO $test$
BEGIN
   -- =============================================================================
   -- AK1: fn_convert_bit
   -- =============================================================================
   ASSERT fn_convert_bit('1')     = true , 'AK1 1';
   ASSERT fn_convert_bit('0')     = false, 'AK1 0';
   ASSERT fn_convert_bit('J')     = true , 'AK1 J';
   ASSERT fn_convert_bit('N')     = false, 'AK1 N';
   ASSERT fn_convert_bit('Y')     = true , 'AK1 Y';
   ASSERT fn_convert_bit('y')     = true , 'AK1 y (ci)';
   ASSERT fn_convert_bit('true')  = true , 'AK1 true';
   ASSERT fn_convert_bit('false') = false, 'AK1 false';
   ASSERT fn_convert_bit('')      = false, 'AK1 empty';
   ASSERT fn_convert_bit(' ')     = false, 'AK1 space';
   ASSERT fn_convert_bit('j')     = true , 'AK1 j (ci)';
   ASSERT fn_convert_bit('X')     IS NULL, 'AK1 X -> NULL';
   ASSERT fn_convert_bit('YES')   IS NULL, 'AK1 YES -> NULL (nur Y)';
   ASSERT fn_convert_bit('NO')    IS NULL, 'AK1 NO -> NULL (nur N)';
   ASSERT fn_convert_bit(NULL)    IS NULL, 'AK1 NULL';

   -- =============================================================================
   -- AK2/AK10: fn_convert_datetime2 — Gold-Standard-Stylefaelle aus der Vorlage
   -- =============================================================================
   ASSERT fn_convert_datetime2('2018.08.17',              'YYYY.MM.DD')                 = TIMESTAMP '2018-08-17 00:00:00',     'YYYY.MM.DD';
   ASSERT fn_convert_datetime2('2018/08/17',              'YYYY/MM/DD')                 = TIMESTAMP '2018-08-17 00:00:00',     'YYYY/MM/DD';
   ASSERT fn_convert_datetime2('20180817',                'YYYYMMDD')                   = TIMESTAMP '2018-08-17 00:00:00',     'YYYYMMDD';
   ASSERT fn_convert_datetime2('2018-08-17 12:27:40',     'YYYY-MM-DD hh:mi:ss')        = TIMESTAMP '2018-08-17 12:27:40',     'YYYY-MM-DD hh:mi:ss';
   ASSERT fn_convert_datetime2('2018-08-17 12:27:40.654', 'YYYY-MM-DD hh:mi:ss.mmm')    = TIMESTAMP '2018-08-17 12:27:40.654', 'with ms';
   ASSERT fn_convert_datetime2('2018-08-17T12:27:40.654', 'YYYY-MM-DDThh:mi:ss.mmm')    = TIMESTAMP '2018-08-17 12:27:40.654', 'ISO T';
   ASSERT fn_convert_datetime2('2018-08-17T12:27:40.654', 'YYYY-MM-DDThh:mi:ss.mmmz')   = TIMESTAMP '2018-08-17 12:27:40.654', 'ISO T Z (Z entfernt)';
   ASSERT fn_convert_datetime2('Aug 17 2018 12:27PM',     'MON DD YYYY hh:miAM')        = TIMESTAMP '2018-08-17 12:27:00',     'MON 12h PM';
   ASSERT fn_convert_datetime2('08/17/2018',              'MM/DD/YYYY')                 = TIMESTAMP '2018-08-17 00:00:00',     'MM/DD/YYYY';
   ASSERT fn_convert_datetime2('Aug 17, 2018',            'MON DD, YYYY')               = TIMESTAMP '2018-08-17 00:00:00',     'MON DD, YYYY';
   ASSERT fn_convert_datetime2('08-17-2018',              'MM-DD-YYYY')                 = TIMESTAMP '2018-08-17 00:00:00',     'MM-DD-YYYY';
   ASSERT fn_convert_datetime2('Aug 17 2018 12:27:40:654PM','MON DD YYYY hh:mi:ss:mmmAM')= TIMESTAMP '2018-08-17 12:27:40.654','MON full 12h';
   ASSERT fn_convert_datetime2('17/08/2018 12:27:40:654PM','DD/MM/YYYY hh:mi:ss:mmmAM') = TIMESTAMP '2018-08-17 12:27:40.654', 'DD/MM full 12h';
   ASSERT fn_convert_datetime2('17/08/2018',              'DD/MM/YYYY')                 = TIMESTAMP '2018-08-17 00:00:00',     'DD/MM/YYYY';
   ASSERT fn_convert_datetime2('17.08.2018',              'DD.MM.YYYY')                 = TIMESTAMP '2018-08-17 00:00:00',     'DD.MM.YYYY';
   ASSERT fn_convert_datetime2('17-08-2018',              'DD-MM-YYYY')                 = TIMESTAMP '2018-08-17 00:00:00',     'DD-MM-YYYY';
   ASSERT fn_convert_datetime2('17 Aug 2018 12:27:40:654','DD MON YYYY hh:mi:ss:mmm')   = TIMESTAMP '2018-08-17 12:27:40.654', 'DD MON full 24h';
   ASSERT fn_convert_datetime2('17 Aug 2018',             'DD MON YYYY')                = TIMESTAMP '2018-08-17 00:00:00',     'DD MON YYYY';

   -- =============================================================================
   -- AK3: Tag-/Monat-Reihenfolge eindeutig (nicht vertauscht)
   -- =============================================================================
   ASSERT fn_convert_datetime('17.08.2018','DD.MM.YYYY') = TIMESTAMP '2018-08-17 00:00:00', 'AK3 dd.mm';
   ASSERT fn_convert_datetime('08/17/2018','MM/DD/YYYY') = TIMESTAMP '2018-08-17 00:00:00', 'AK3 mm/dd';

   -- =============================================================================
   -- AK4: fn_convert_date verwirft Zeitanteil
   -- =============================================================================
   ASSERT fn_convert_date('2018-08-17 12:27:40','YYYY-MM-DD hh:mi:ss') = DATE '2018-08-17', 'AK4 date drops time';
   ASSERT fn_convert_date('17 Aug 2018','DD MON YYYY')                 = DATE '2018-08-17', 'AK4 date MON';

   -- =============================================================================
   -- AK5: fn_convert_datetime2 behaelt Sub-Sekunden (Mikrosekunden-Typ)
   -- =============================================================================
   ASSERT fn_convert_datetime2('2018-08-17T12:27:40.654','YYYY-MM-DDThh:mi:ss.mmm') = TIMESTAMP '2018-08-17 12:27:40.654', 'AK5 ms';

   -- =============================================================================
   -- AK6: unparsbarer Wert -> NULL (keine Exception)
   -- =============================================================================
   ASSERT fn_convert_date('nonsense','YYYY-MM-DD')      IS NULL, 'AK6 date nonsense';
   ASSERT fn_convert_datetime('nonsense','YYYY-MM-DD')  IS NULL, 'AK6 datetime nonsense';
   ASSERT fn_convert_datetime2('nonsense','YYYY-MM-DD') IS NULL, 'AK6 datetime2 nonsense';

   -- =============================================================================
   -- AK7: NULL-Wert / unbekannter Style -> NULL
   -- =============================================================================
   ASSERT fn_convert_datetime2(NULL,'YYYY-MM-DD')       IS NULL, 'AK7 null value';
   ASSERT fn_convert_datetime2('2018-08-17','BOGUS')    IS NULL, 'AK7 unknown style';
   ASSERT fn_convert_date('2018-08-17','BOGUS')         IS NULL, 'AK7 unknown style (date)';

   -- =============================================================================
   -- AK8: Style case-insensitiv
   -- =============================================================================
   ASSERT fn_convert_datetime2('17.08.2018','dd.mm.yyyy') = TIMESTAMP '2018-08-17 00:00:00', 'AK8 ci style';
   ASSERT fn_convert_datetime2('20180817','yyyymmdd')     = TIMESTAMP '2018-08-17 00:00:00', 'AK8 ci yyyymmdd';

   RAISE NOTICE '### ALL ASSERTIONS PASSED (AK 1-10, Gold-Standard-Styles)';
END;
$test$;

ROLLBACK;

\echo "## TEST helper conversion functions - DONE"
