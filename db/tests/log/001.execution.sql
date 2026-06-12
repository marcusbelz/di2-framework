-- --------------------------------------------------------------------------------
-- TEST: log.execution — sp_ins_execution / sp_upd_execution (+4 Wrapper) (di2f-0010)
-- --------------------------------------------------------------------------------
-- Reines psql + Assertions (DO-Block / ASSERT), keine Extension (Konvention di2f-0001).
--
-- Aufruf gegen eine deployte DB (Schema-Variablen aus <env>.env.sql laden):
--   psql -h <host> -U <user> -d <db> -v ON_ERROR_STOP=1 \
--        -f db/config/<env>.env.sql -f db/tests/log/001.execution.sql
--
-- Laeuft transaktional und macht am Ende ROLLBACK -> hinterlaesst keine Testdaten.
-- Deckt AK 1-18 sowie die Edge Cases ab (Kombinatorik, Delta-Wasserzeichen, version).
--
-- HINWEIS now(): innerhalb EINER Transaktion liefert now() denselben Zeitstempel.
-- Der Delta-WASSERZEICHEN-SELEKTOR (welcher Vorlauf gewinnt / Praedikat-Ausschluss)
-- wird daher ueber Sentinel-Fixtures mit distinkten start_on/delta_end deterministisch
-- geprueft (Block 3); die natuerliche Flow-Logik (Erstlauf NULL, Folgelauf =
-- Vorgaenger-delta_end) in Block 1.
-- --------------------------------------------------------------------------------
\set ON_ERROR_STOP on

\echo "## TEST log.execution"

BEGIN;

SET LOCAL search_path = log, config, pg_temp;

-- --------------------------------------------------------------------------------
-- Block 1: Insert-Felder + natuerliche Delta-Logik (AK 1,2,3,4,5,6,7,9)
-- --------------------------------------------------------------------------------
DO $test$
DECLARE
   l_p           bigint;
   l_e1          bigint;
   l_e2          bigint;
   l_start       timestamptz;
   l_end         timestamptz;
   l_dstart      timestamptz;
   l_dend        timestamptz;
   l_e1_dend     timestamptz;
   l_state       varchar;
   l_succ        boolean;
   l_user        varchar;
   l_machine     varchar;
   l_inst        varchar;
   l_count       bigint;
   l_threw       boolean;
BEGIN
   CALL config.sp_ins_process(l_p, 'di2f-0010 P1');

   -- AK2: process_id NULL -> Ablehnung
   l_threw := false;
   BEGIN
      CALL log.sp_ins_execution(l_e1, NULL, 'h', 'i');
   EXCEPTION WHEN invalid_parameter_value THEN l_threw := true;
   END;
   ASSERT l_threw, 'AK2: NULL process_id haette abgelehnt werden muessen';

   -- AK3: nicht existierender process_id -> Ablehnung (foreign_key_violation)
   l_threw := false;
   BEGIN
      CALL log.sp_ins_execution(l_e1, 999999999, 'h', 'i');
   EXCEPTION WHEN foreign_key_violation THEN l_threw := true;
   END;
   ASSERT l_threw, 'AK3: unbekannter process_id haette abgelehnt werden muessen';

   -- AK1: Happy-Path-Insert -> genau eine Zeile, id zurueck
   CALL log.sp_ins_execution(l_e1, l_p, 'host-1', 'inst-1');
   ASSERT l_e1 IS NOT NULL, 'AK1: sp_ins_execution liefert keine id';
   SELECT count(*) INTO l_count FROM log.execution WHERE id = l_e1;
   ASSERT l_count = 1, 'AK1: erwartet genau eine Execution-Zeile';

   SELECT start_on, end_on, delta_start, delta_end, state, success, user_name, machine, instance
   INTO   l_start, l_end, l_dstart, l_dend, l_state, l_succ, l_user, l_machine, l_inst
   FROM   log.execution WHERE id = l_e1;

   -- AK4: start_on gesetzt, end_on NULL, state='processing', success=false
   ASSERT l_start IS NOT NULL,       'AK4: start_on nicht gesetzt';
   ASSERT l_end   IS NULL,           'AK4: end_on muss beim Insert NULL sein';
   ASSERT l_state = 'processing',    'AK4: state muss processing sein, war ' || coalesce(l_state,'<null>');
   ASSERT l_succ  = false,           'AK4: success muss false sein';

   -- AK5: delta_end = start_on
   ASSERT l_dend = l_start, 'AK5: delta_end muss gleich start_on sein';

   -- AK7: Erstlauf -> delta_start NULL
   ASSERT l_dstart IS NULL, 'AK7: delta_start beim Erstlauf muss NULL sein';

   -- AK9: user_name=current_user, machine/instance aus Parametern
   ASSERT l_user = current_user, 'AK9: user_name muss current_user sein, war ' || coalesce(l_user,'<null>');
   ASSERT l_machine = 'host-1',  'AK9: machine nicht aus Parameter uebernommen';
   ASSERT l_inst = 'inst-1',     'AK9: instance nicht aus Parameter uebernommen';

   l_e1_dend := l_dend;

   -- Lauf 1 erfolgreich abschliessen -> qualifiziert als Wasserzeichen
   CALL log.sp_upd_execution_success(l_e1);

   -- AK6: Folgelauf -> delta_start = delta_end des letzten erfolgreichen Laufs
   CALL log.sp_ins_execution(l_e2, l_p, 'host-2', 'inst-2');
   SELECT delta_start, delta_end INTO l_dstart, l_dend FROM log.execution WHERE id = l_e2;
   ASSERT l_dstart = l_e1_dend, 'AK6: delta_start muss delta_end des erfolgreichen Vorlaufs sein';
   ASSERT l_dend  IS NOT NULL,  'AK6: delta_end des Folgelaufs muss gesetzt sein';

   RAISE NOTICE '### Block 1 OK (AK 1-7,9)';
END;
$test$;

-- --------------------------------------------------------------------------------
-- Block 2: Update-Validierung, Kombinatorik, Immutabilitaet, Wrapper
--          (AK 10,11,12,13,14,15,16,17,18)
-- --------------------------------------------------------------------------------
DO $test$
DECLARE
   l_p           bigint;
   l_e           bigint;
   l_ew          bigint;
   l_threw       boolean;
   l_state       varchar;
   l_succ        boolean;
   l_end         timestamptz;
   l_mod_on      timestamptz;
   l_mod_by      varchar;
   -- Immutable-Snapshot
   l_pid0        bigint;
   l_start0      timestamptz;
   l_dstart0     timestamptz;
   l_dend0       timestamptz;
   l_user0       varchar;
   l_machine0    varchar;
   l_inst0       varchar;
   l_version0    varchar;
   -- nach Update
   l_pid1        bigint;
   l_start1      timestamptz;
   l_dstart1     timestamptz;
   l_dend1       timestamptz;
   l_user1       varchar;
   l_machine1    varchar;
   l_inst1       varchar;
   l_version1    varchar;
   -- Kombinatorik-Tabellen
   l_bad_state   varchar[]   := ARRAY['processing','error','success'];
   l_bad_succ    boolean[]   := ARRAY[true,        true,   false];
   i             int;
BEGIN
   CALL config.sp_ins_process(l_p, 'di2f-0010 P2');
   CALL log.sp_ins_execution(l_e, l_p, 'host-x', 'inst-x');

   -- AK10: Pflicht-Parameter NULL/leer -> Ablehnung
   l_threw := false; BEGIN CALL log.sp_upd_execution(NULL, 'error', false);
      EXCEPTION WHEN invalid_parameter_value THEN l_threw := true; END;
   ASSERT l_threw, 'AK10: p_id NULL haette abgelehnt werden muessen';

   l_threw := false; BEGIN CALL log.sp_upd_execution(l_e, NULL, false);
      EXCEPTION WHEN invalid_parameter_value THEN l_threw := true; END;
   ASSERT l_threw, 'AK10: p_state NULL haette abgelehnt werden muessen';

   l_threw := false; BEGIN CALL log.sp_upd_execution(l_e, '   ', false);
      EXCEPTION WHEN invalid_parameter_value THEN l_threw := true; END;
   ASSERT l_threw, 'AK10: leerer p_state haette abgelehnt werden muessen';

   l_threw := false; BEGIN CALL log.sp_upd_execution(l_e, 'error', NULL);
      EXCEPTION WHEN invalid_parameter_value THEN l_threw := true; END;
   ASSERT l_threw, 'AK10: p_success NULL haette abgelehnt werden muessen';

   -- AK11: unbekannter state -> Ablehnung
   l_threw := false; BEGIN CALL log.sp_upd_execution(l_e, 'bogus', false);
      EXCEPTION WHEN invalid_parameter_value THEN l_threw := true; END;
   ASSERT l_threw, 'AK11: unbekannter state haette abgelehnt werden muessen';

   -- AK12: ungueltige (state,success)-Kombinationen -> Ablehnung
   FOR i IN 1 .. array_length(l_bad_state, 1) LOOP
      l_threw := false;
      BEGIN CALL log.sp_upd_execution(l_e, l_bad_state[i], l_bad_succ[i]);
         EXCEPTION WHEN invalid_parameter_value THEN l_threw := true; END;
      ASSERT l_threw, format('AK12: ungueltige Kombi %s/%s haette abgelehnt werden muessen',
                             l_bad_state[i], l_bad_succ[i]);
   END LOOP;

   -- AK12: ALLE gueltigen Kombinationen werfen NICHT (bare CALL -> Test faellt bei Wurf)
   CALL log.sp_upd_execution(l_e, 'processing',  false);
   CALL log.sp_upd_execution(l_e, 'error',       false);
   CALL log.sp_upd_execution(l_e, 'success',     true);
   CALL log.sp_upd_execution(l_e, 'warning',     false);
   CALL log.sp_upd_execution(l_e, 'warning',     true);
   CALL log.sp_upd_execution(l_e, 'information', false);
   CALL log.sp_upd_execution(l_e, 'information', true);

   -- AK15: Update auf nicht existierende id -> Ablehnung
   l_threw := false; BEGIN CALL log.sp_upd_execution(-1, 'error', false);
      EXCEPTION WHEN no_data_found THEN l_threw := true; END;
   ASSERT l_threw, 'AK15: Update auf unbekannte id haette abgelehnt werden muessen';

   -- AK13/AK14: Update aendert NUR state/success/end_on; Trigger setzt modified_*
   SELECT process_id, start_on, delta_start, delta_end, user_name, machine, instance, version
   INTO   l_pid0, l_start0, l_dstart0, l_dend0, l_user0, l_machine0, l_inst0, l_version0
   FROM   log.execution WHERE id = l_e;

   CALL log.sp_upd_execution(l_e, 'success', true);

   SELECT process_id, start_on, delta_start, delta_end, user_name, machine, instance, version,
          state, success, end_on, modified_on, modified_by
   INTO   l_pid1, l_start1, l_dstart1, l_dend1, l_user1, l_machine1, l_inst1, l_version1,
          l_state, l_succ, l_end, l_mod_on, l_mod_by
   FROM   log.execution WHERE id = l_e;

   ASSERT l_pid1     IS NOT DISTINCT FROM l_pid0,     'AK13: process_id veraendert';
   ASSERT l_start1   IS NOT DISTINCT FROM l_start0,   'AK13: start_on veraendert';
   ASSERT l_dstart1  IS NOT DISTINCT FROM l_dstart0,  'AK13: delta_start veraendert';
   ASSERT l_dend1    IS NOT DISTINCT FROM l_dend0,    'AK13: delta_end veraendert';
   ASSERT l_user1    IS NOT DISTINCT FROM l_user0,    'AK13: user_name veraendert';
   ASSERT l_machine1 IS NOT DISTINCT FROM l_machine0, 'AK13: machine veraendert';
   ASSERT l_inst1    IS NOT DISTINCT FROM l_inst0,    'AK13: instance veraendert';
   ASSERT l_version1 IS NOT DISTINCT FROM l_version0, 'AK13: version veraendert';
   ASSERT l_state = 'success' AND l_succ = true,      'AK13: state/success nicht aktualisiert';
   ASSERT l_end IS NOT NULL,                          'AK13: end_on muss beim Update gesetzt werden';
   ASSERT l_mod_on IS NOT NULL,                       'AK14: modified_on (Trigger) nicht gesetzt';
   ASSERT l_mod_by IS NOT NULL,                       'AK14: modified_by (Trigger) nicht gesetzt';

   -- AK16/17/18: Wrapper setzen den richtigen Status/Erfolg + finalisieren (end_on)
   -- error -> error/false
   CALL log.sp_ins_execution(l_ew, l_p, 'h', 'i');
   CALL log.sp_upd_execution_error(l_ew);
   SELECT state, success, end_on INTO l_state, l_succ, l_end FROM log.execution WHERE id = l_ew;
   ASSERT l_state='error' AND l_succ=false AND l_end IS NOT NULL, 'AK16: _error setzt nicht error/false/end_on';

   -- success -> success/true
   CALL log.sp_ins_execution(l_ew, l_p, 'h', 'i');
   CALL log.sp_upd_execution_success(l_ew);
   SELECT state, success, end_on INTO l_state, l_succ, l_end FROM log.execution WHERE id = l_ew;
   ASSERT l_state='success' AND l_succ=true AND l_end IS NOT NULL, 'AK16: _success setzt nicht success/true/end_on';

   -- warning -> warning, success frei (false)
   CALL log.sp_ins_execution(l_ew, l_p, 'h', 'i');
   CALL log.sp_upd_execution_warning(l_ew, false);
   SELECT state, success INTO l_state, l_succ FROM log.execution WHERE id = l_ew;
   ASSERT l_state='warning' AND l_succ=false, 'AK17: _warning(false) falsch';
   CALL log.sp_upd_execution_warning(l_ew, true);
   SELECT state, success INTO l_state, l_succ FROM log.execution WHERE id = l_ew;
   ASSERT l_state='warning' AND l_succ=true, 'AK17: _warning(true) falsch';

   -- information -> information, success frei (true und false)
   CALL log.sp_ins_execution(l_ew, l_p, 'h', 'i');
   CALL log.sp_upd_execution_information(l_ew, true);
   SELECT state, success INTO l_state, l_succ FROM log.execution WHERE id = l_ew;
   ASSERT l_state='information' AND l_succ=true, 'AK17: _information(true) falsch';
   CALL log.sp_upd_execution_information(l_ew, false);
   SELECT state, success INTO l_state, l_succ FROM log.execution WHERE id = l_ew;
   ASSERT l_state='information' AND l_succ=false, 'AK17: _information(false) falsch';

   RAISE NOTICE '### Block 2 OK (AK 10-18)';
END;
$test$;

-- --------------------------------------------------------------------------------
-- Block 3: Delta-Wasserzeichen-Selektor (Edge: Praedikat + Recency)
--          deterministisch via Sentinel-Fixtures (distinkte start_on/delta_end)
-- --------------------------------------------------------------------------------
DO $test$
DECLARE
   l_q           bigint;
   l_r           bigint;          -- Dummy fuer error-only-Prozess
   l_e           bigint;
   l_dstart      timestamptz;
BEGIN
   CALL config.sp_ins_process(l_q, 'di2f-0010 Q');

   -- Fixtures: abgeschlossene Vorlaeufe mit distinkten Zeitstempeln (delta_end=start_on).
   --   r1 success/true   2024-01  (qualifiziert)
   --   r2 warning/true   2024-02  (qualifiziert, juenger -> ERWARTETES Wasserzeichen)
   --   r3 information/true 2024-03 (NICHT qualifiziert -> Ausschluss-Test)
   --   r4 warning/false  2024-04  (NICHT qualifiziert)
   --   r5 error/false    2024-05  (NICHT qualifiziert)
   INSERT INTO log.execution (process_id, start_on, delta_end, state, success) VALUES
       (l_q, '2024-01-01 00:00:00+00', '2024-01-01 00:00:00+00', 'success',     true)
      ,(l_q, '2024-02-01 00:00:00+00', '2024-02-01 00:00:00+00', 'warning',     true)
      ,(l_q, '2024-03-01 00:00:00+00', '2024-03-01 00:00:00+00', 'information', true)
      ,(l_q, '2024-04-01 00:00:00+00', '2024-04-01 00:00:00+00', 'warning',     false)
      ,(l_q, '2024-05-01 00:00:00+00', '2024-05-01 00:00:00+00', 'error',       false);

   CALL log.sp_ins_execution(l_e, l_q, 'h', 'i');
   SELECT delta_start INTO l_dstart FROM log.execution WHERE id = l_e;

   -- Erwartet: r2 (juengster qualifizierender), NICHT r3/r4/r5
   ASSERT l_dstart = '2024-02-01 00:00:00+00'::timestamptz,
      'Edge Wasserzeichen: erwartet 2024-02-01 (warning/true), war ' || coalesce(l_dstart::text,'<null>');

   -- Edge: Prozess mit NUR nicht-qualifizierenden Vorlaeufen -> delta_start NULL
   CALL config.sp_ins_process(l_r, 'di2f-0010 R');
   INSERT INTO log.execution (process_id, start_on, delta_end, state, success) VALUES
       (l_r, '2024-01-01 00:00:00+00', '2024-01-01 00:00:00+00', 'error',       false)
      ,(l_r, '2024-02-01 00:00:00+00', '2024-02-01 00:00:00+00', 'information', true);
   CALL log.sp_ins_execution(l_e, l_r, 'h', 'i');
   SELECT delta_start INTO l_dstart FROM log.execution WHERE id = l_e;
   ASSERT l_dstart IS NULL, 'Edge: nur nicht-qualifizierende Vorlaeufe -> delta_start muss NULL sein';

   RAISE NOTICE '### Block 3 OK (Wasserzeichen-Selektor + Ausschluss)';
END;
$test$;

-- --------------------------------------------------------------------------------
-- Block 4: version aus config.db_version (AK 8 + Edge leere Tabelle)
-- --------------------------------------------------------------------------------
DO $test$
DECLARE
   l_p           bigint;
   l_e           bigint;
   l_version     varchar;
BEGIN
   CALL config.sp_ins_process(l_p, 'di2f-0010 V');

   -- AK8: juengste db_version-Zeile (hier future-dated 9.9.9) -> release_version
   INSERT INTO config.db_version (major, minor, build, git_commit, environment, deployed_on)
   VALUES (9, 9, 9, 'testsha', 'dev', now() + interval '1 day');

   CALL log.sp_ins_execution(l_e, l_p, 'h', 'i');
   SELECT version INTO l_version FROM log.execution WHERE id = l_e;
   ASSERT l_version = '9.9.9', 'AK8: version muss release_version 9.9.9 der juengsten Zeile sein, war '
                              || coalesce(l_version,'<null>');

   -- Edge: leere db_version -> version NULL (kein Fehler) [outer ROLLBACK stellt Daten wieder her]
   DELETE FROM config.db_version;
   CALL log.sp_ins_execution(l_e, l_p, 'h', 'i');
   SELECT version INTO l_version FROM log.execution WHERE id = l_e;
   ASSERT l_version IS NULL, 'Edge: leere db_version -> version muss NULL sein';

   RAISE NOTICE '### Block 4 OK (AK 8 + leere db_version)';
END;
$test$;

DO $test$ BEGIN RAISE NOTICE '### ALL ASSERTIONS PASSED (di2f-0010 AK 1-18 + Edge Cases)'; END; $test$;

ROLLBACK;

\echo "## TEST log.execution - DONE"
