-- --------------------------------------------------------------------------------
-- TEST: config.process — sp_ins/upd/del_process + Seed (di2f-0001, AK 6–15)
-- --------------------------------------------------------------------------------
-- Reines psql + Assertions (DO-Block / ASSERT), keine Extension. Erster Test im
-- Projekt -> Vorlage/Konvention fuer db/tests/.
--
-- Aufruf gegen eine frisch deployte DB (Schema-Variablen aus <env>.env.sql laden):
--   psql -h <host> -U <user> -d <db> -v ON_ERROR_STOP=1 \
--        -f db/config/<env>.env.sql -f db/tests/config/005.process.sql
--
-- Laeuft transaktional und macht am Ende ROLLBACK -> hinterlaesst keine Testdaten.
-- Deckt strukturelle AK 1-3 & 5 (Katalog-Checks), Verhaltens-AK 6-15 sowie Edge Cases ab.
-- AK 4 (log-Renumbering) ist eine Dateisystem-Tatsache und wird ueber Deploy/ls belegt.
-- --------------------------------------------------------------------------------
\set ON_ERROR_STOP on

\echo "## TEST config.process"

BEGIN;

SET LOCAL search_path = :schema_config, :schema_log, pg_temp;

DO $test$
DECLARE
   l_id          bigint;
   l_id2         bigint;
   l_name        varchar;
   l_created_by  varchar;
   l_modified    timestamptz;
   l_count       bigint;
   l_threw       boolean;
BEGIN
   -- AK1: process liegt in config, nicht mehr in log
   ASSERT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'config' AND tablename = 'process'),
      'AK1: config.process fehlt';
   ASSERT NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'log' AND tablename = 'process'),
      'AK1: log.process existiert noch';

   -- AK2: uq_process_name auf config.process
   ASSERT EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conname = 'uq_process_name' AND conrelid = 'config.process'::regclass),
      'AK2: uq_process_name fehlt';

   -- AK3: FK fk_execution_process_id zeigt auf config.process
   ASSERT EXISTS (
      SELECT 1
      FROM   pg_constraint T01
             INNER JOIN pg_class T02
             ON
               T02.oid = T01.confrelid
             INNER JOIN pg_namespace T03
             ON
               T03.oid = T02.relnamespace
      WHERE      T01.conname  = 'fk_execution_process_id'
         AND     T01.conrelid = 'log.execution'::regclass
         AND     T02.relname  = 'process'
         AND     T03.nspname  = 'config'
   ), 'AK3: FK fk_execution_process_id zeigt nicht auf config.process';

   -- AK5: Trigger tr_u_process auf config.process
   ASSERT EXISTS (SELECT 1 FROM pg_trigger
                  WHERE tgname = 'tr_u_process' AND tgrelid = 'config.process'::regclass),
      'AK5: tr_u_process fehlt';

   -- AK15: Seed liefert genau einen Default-Datensatz
   SELECT count(*) INTO l_count FROM process WHERE name = 'default';
   ASSERT l_count = 1, 'AK15: genau ein Seed-Datensatz default erwartet, war ' || l_count;

   -- AK15: Seed-Insert ist idempotent (ON CONFLICT)
   INSERT INTO process (name) VALUES ('default') ON CONFLICT (name) DO NOTHING;
   SELECT count(*) INTO l_count FROM process WHERE name = 'default';
   ASSERT l_count = 1, 'AK15: Seed nicht idempotent, default-Anzahl = ' || l_count;

   -- AK6: Insert Happy Path -> neue id + created_on/created_by per Default
   CALL sp_ins_process('di2f-0001 alpha', l_id);
   ASSERT l_id IS NOT NULL, 'AK6: sp_ins_process liefert keine id';
   SELECT created_by INTO l_created_by FROM process WHERE id = l_id;
   ASSERT l_created_by IS NOT NULL, 'AK6: created_by nicht gesetzt';

   -- AK7: doppelter Name beim Insert -> Ablehnung
   l_threw := false;
   BEGIN
      CALL sp_ins_process('di2f-0001 alpha', l_id2);
   EXCEPTION WHEN unique_violation THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK7: doppelter Insert haette abgelehnt werden muessen';

   -- AK8: NULL-Name -> Ablehnung
   l_threw := false;
   BEGIN
      CALL sp_ins_process(NULL, l_id2);
   EXCEPTION WHEN invalid_parameter_value THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK8: NULL-Name haette abgelehnt werden muessen';

   -- AK8: leerer / Whitespace-Name -> Ablehnung
   l_threw := false;
   BEGIN
      CALL sp_ins_process('   ', l_id2);
   EXCEPTION WHEN invalid_parameter_value THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK8: Whitespace-Name haette abgelehnt werden muessen';

   -- Edge: Name > 100 Zeichen (varchar(100)) -> definierter Fehler, kein stiller Cut
   l_threw := false;
   BEGIN
      CALL sp_ins_process(repeat('x', 101), l_id);
   EXCEPTION WHEN string_data_right_truncation THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'Edge >100 Zeichen: erwartet string_data_right_truncation (22001)';

   -- AK9: Update aendert Namen; modified_on per Trigger gesetzt
   CALL sp_upd_process(l_id, 'di2f-0001 alpha renamed');
   SELECT name, modified_on INTO l_name, l_modified FROM process WHERE id = l_id;
   ASSERT l_name = 'di2f-0001 alpha renamed', 'AK9: Name nicht aktualisiert';
   ASSERT l_modified IS NOT NULL, 'AK9: modified_on nicht durch Trigger gesetzt';

   -- AK9: Update auf identischen Namen -> No-op, kein Fehler
   CALL sp_upd_process(l_id, 'di2f-0001 alpha renamed');

   -- AK10: Update mit nicht existierender id -> Ablehnung
   l_threw := false;
   BEGIN
      CALL sp_upd_process(-1, 'egal');
   EXCEPTION WHEN no_data_found THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK10: Update auf unbekannte id haette abgelehnt werden muessen';

   -- AK11: Update auf Namen eines anderen Prozesses -> Ablehnung
   CALL sp_ins_process('di2f-0001 beta', l_id2);
   l_threw := false;
   BEGIN
      CALL sp_upd_process(l_id2, 'di2f-0001 alpha renamed');
   EXCEPTION WHEN unique_violation THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK11: Update auf fremden Namen haette abgelehnt werden muessen';

   -- AK12: Delete eines nicht referenzierten Prozesses
   CALL sp_ins_process('di2f-0001 deletable', l_id2);
   CALL sp_del_process(l_id2);
   ASSERT NOT EXISTS (SELECT 1 FROM process WHERE id = l_id2), 'AK12: Prozess nicht geloescht';

   -- AK13: Delete eines referenzierten Prozesses -> Ablehnung, Datensatz bleibt
   CALL sp_ins_process('di2f-0001 referenced', l_id2);
   INSERT INTO execution (process_id, start_on) VALUES (l_id2, now());
   l_threw := false;
   BEGIN
      CALL sp_del_process(l_id2);
   EXCEPTION WHEN foreign_key_violation THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK13: Loeschen eines referenzierten Prozesses haette abgelehnt werden muessen';
   ASSERT EXISTS (SELECT 1 FROM process WHERE id = l_id2), 'AK13: referenzierter Prozess muss erhalten bleiben';

   -- AK14: Delete mit nicht existierender id -> Ablehnung
   l_threw := false;
   BEGIN
      CALL sp_del_process(-1);
   EXCEPTION WHEN no_data_found THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK14: Delete auf unbekannte id haette abgelehnt werden muessen';

   RAISE NOTICE '### ALL ASSERTIONS PASSED (AK 1-3,5 strukturell + 6-15 + Edge >100)';
END;
$test$;

ROLLBACK;

\echo "## TEST config.process - DONE"
