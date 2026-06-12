-- --------------------------------------------------------------------------------
-- TEST: config.db_version — Tabelle + sp_ins_db_version (di2f-0006, AK 1-10)
-- --------------------------------------------------------------------------------
-- Reines psql + Assertions (DO-Block / ASSERT), keine Extension. Gleiche Konvention
-- wie db/tests/config/005.process.sql.
--
-- Aufruf gegen eine frisch deployte DB (Schema-Variablen aus <env>.env.sql laden):
--   psql -h <host> -U <user> -d <db> -v ON_ERROR_STOP=1 \
--        -f db/config/<env>.env.sql -f db/tests/config/003.db_version.sql
--
-- Laeuft transaktional und macht am Ende ROLLBACK -> hinterlaesst keine Testdaten.
-- Deckt strukturelle AK 1-4 & 10 (Katalog-Checks) und Verhaltens-AK 3,5-9 + Edge Cases ab.
-- AK9 (Deploy-Idempotenz) wird zusaetzlich ueber den doppelten Deploy-Lauf belegt.
-- --------------------------------------------------------------------------------
\set ON_ERROR_STOP on

\echo "## TEST config.db_version"

BEGIN;

SET LOCAL search_path = :schema_config, pg_temp;

DO $test$
DECLARE
   l_id          bigint;
   l_id2         bigint;
   l_id3         bigint;
   l_rv          varchar;
   l_tag         varchar;
   l_count       bigint;
   l_threw       boolean;
   l_newest      bigint;
BEGIN
   -- =============================================================================
   -- Strukturelle Akzeptanzkriterien (Katalog)
   -- =============================================================================

   -- AK1: Tabelle existiert in config
   ASSERT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'config' AND tablename = 'db_version'),
      'AK1: config.db_version fehlt';

   -- AK1: PK ist Surrogat-id (pk_db_version) auf Spalte id, NICHT release_version
   ASSERT EXISTS (
      SELECT 1
      FROM   pg_constraint T01
             INNER JOIN pg_attribute T02
             ON
               T02.attrelid = T01.conrelid AND T02.attnum = ANY (T01.conkey)
      WHERE      T01.conname  = 'pk_db_version'
         AND     T01.contype  = 'p'
         AND     T01.conrelid = 'config.db_version'::regclass
         AND     T02.attname  = 'id'
   ), 'AK1: pk_db_version (id) fehlt oder falsche Spalte';

   ASSERT (SELECT count(*) FROM pg_constraint
           WHERE conrelid = 'config.db_version'::regclass AND contype = 'p') = 1,
      'AK1: genau ein PK erwartet';

   -- AK1: alter Stub-Spalte internal_version ist weg
   ASSERT NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_schema='config' AND table_name='db_version' AND column_name='internal_version'),
      'AK1: alte Stub-Spalte internal_version existiert noch';

   -- AK1: alle erwarteten Spalten vorhanden
   ASSERT (SELECT count(*) FROM information_schema.columns
           WHERE table_schema='config' AND table_name='db_version'
             AND column_name IN ('id','major','minor','build','release_version',
                                 'git_commit','git_tag','environment','deployed_on')) = 9,
      'AK1: nicht alle erwarteten Spalten vorhanden';

   -- AK2: NOT NULL auf Pflichtspalten, git_tag nullable
   ASSERT (SELECT bool_and(is_nullable = 'NO') FROM information_schema.columns
           WHERE table_schema='config' AND table_name='db_version'
             AND column_name IN ('major','minor','build','release_version',
                                 'git_commit','environment','deployed_on')),
      'AK2: eine Pflichtspalte ist faelschlich nullable';
   ASSERT (SELECT is_nullable = 'YES' FROM information_schema.columns
           WHERE table_schema='config' AND table_name='db_version' AND column_name='git_tag'),
      'AK2: git_tag muss nullable sein';

   -- AK4: CHECK-Constraint environment
   ASSERT EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conname='chk_db_version_environment' AND conrelid='config.db_version'::regclass AND contype='c'),
      'AK4: chk_db_version_environment fehlt';

   -- AK10: COMMENT ON TABLE + mind. die Spaltenkommentare vorhanden
   ASSERT obj_description('config.db_version'::regclass, 'pg_class') IS NOT NULL,
      'AK10: COMMENT ON TABLE fehlt';
   ASSERT col_description('config.db_version'::regclass,
            (SELECT attnum FROM pg_attribute WHERE attrelid='config.db_version'::regclass AND attname='git_commit')) IS NOT NULL,
      'AK10: COMMENT ON COLUMN git_commit fehlt';

   -- =============================================================================
   -- Verhaltens-Akzeptanzkriterien (Prozedur)
   -- =============================================================================

   -- AK5 + AK3: Happy Path -> eine Zeile, id zurueck, release_version generiert = '1.4.207'
   CALL sp_ins_db_version(l_id, 1, 4, 207, 'abc1234deadbeef', 'v1.4.207', 'prod');
   ASSERT l_id IS NOT NULL, 'AK5: sp_ins_db_version liefert keine id';
   SELECT count(*) INTO l_count FROM db_version WHERE id = l_id;
   ASSERT l_count = 1, 'AK5: genau eine Zeile erwartet, war ' || l_count;
   SELECT release_version INTO l_rv FROM db_version WHERE id = l_id;
   ASSERT l_rv = '1.4.207', 'AK3: release_version erwartet 1.4.207, war ' || coalesce(l_rv,'<NULL>');

   -- AK6: major NULL -> invalid_parameter_value, KEINE neue Zeile
   SELECT count(*) INTO l_count FROM db_version;
   l_threw := false;
   BEGIN
      CALL sp_ins_db_version(l_id2, NULL, 4, 207, 'abc', NULL, 'prod');
   EXCEPTION WHEN invalid_parameter_value THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK6: NULL major haette abgelehnt werden muessen';
   ASSERT (SELECT count(*) FROM db_version) = l_count, 'AK6: Teil-Zeile trotz Fehler geschrieben (major NULL)';

   -- AK6: git_commit leer -> invalid_parameter_value, keine Zeile
   SELECT count(*) INTO l_count FROM db_version;
   l_threw := false;
   BEGIN
      CALL sp_ins_db_version(l_id2, 1, 0, 0, '   ', NULL, 'prod');
   EXCEPTION WHEN invalid_parameter_value THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK6: leerer git_commit haette abgelehnt werden muessen';
   ASSERT (SELECT count(*) FROM db_version) = l_count, 'AK6: Teil-Zeile trotz Fehler (leerer commit)';

   -- AK6: negative Version -> invalid_parameter_value
   l_threw := false;
   BEGIN
      CALL sp_ins_db_version(l_id2, 1, -1, 0, 'abc', NULL, 'prod');
   EXCEPTION WHEN invalid_parameter_value THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK6: negative minor haette abgelehnt werden muessen';

   -- AK4 (Verhalten): ungueltige Umgebung ueber die Prozedur -> invalid_parameter_value
   l_threw := false;
   BEGIN
      CALL sp_ins_db_version(l_id2, 1, 0, 0, 'abc', NULL, 'staging');
   EXCEPTION WHEN invalid_parameter_value THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK4: ungueltige Umgebung staging haette abgelehnt werden muessen';

   -- AK4 (Defense-in-Depth): direkter Bad-Insert verletzt CHECK -> check_violation
   l_threw := false;
   BEGIN
      INSERT INTO db_version (major, minor, build, git_commit, environment)
      VALUES (1, 0, 0, 'abc', 'staging');
   EXCEPTION WHEN check_violation THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'AK4: CHECK haette direkten Bad-Insert (environment) blocken muessen';

   -- Edge: generierte Spalte release_version nicht direkt beschreibbar
   l_threw := false;
   BEGIN
      INSERT INTO db_version (major, minor, build, release_version, git_commit, environment)
      VALUES (9, 9, 9, '9.9.9', 'abc', 'prod');
   EXCEPTION WHEN generated_always THEN
      l_threw := true;
   END;
   ASSERT l_threw, 'Edge: direktes Schreiben in release_version haette fehlschlagen muessen';

   -- Edge: leerer git_tag -> NULL
   CALL sp_ins_db_version(l_id2, 2, 0, 0, 'commitA', '', 'dev');
   SELECT git_tag INTO l_tag FROM db_version WHERE id = l_id2;
   ASSERT l_tag IS NULL, 'Edge: leerer git_tag muss als NULL gespeichert werden';

   -- Edge: Whitespace git_tag -> NULL
   CALL sp_ins_db_version(l_id3, 2, 0, 1, 'commitB', '   ', 'dev');
   SELECT git_tag INTO l_tag FROM db_version WHERE id = l_id3;
   ASSERT l_tag IS NULL, 'Edge: Whitespace git_tag muss als NULL gespeichert werden';

   -- Edge: NULL git_tag -> NULL (kein Fehler)
   CALL sp_ins_db_version(l_id3, 2, 0, 2, 'commitC', NULL, 'dev');
   SELECT git_tag INTO l_tag FROM db_version WHERE id = l_id3;
   ASSERT l_tag IS NULL, 'Edge: NULL git_tag muss NULL bleiben';

   -- AK7 + AK8: mehrere Aufrufe -> mehrere Zeilen; Re-Deploy desselben Commits erlaubt
   SELECT count(*) INTO l_count FROM db_version WHERE git_commit = 'redeploy-sha';
   CALL sp_ins_db_version(l_id2, 1, 0, 0, 'redeploy-sha', 'v1.0.0', 'int');
   CALL sp_ins_db_version(l_id3, 1, 0, 0, 'redeploy-sha', 'v1.0.0', 'int');  -- identischer Stand
   ASSERT (SELECT count(*) FROM db_version WHERE git_commit = 'redeploy-sha') = l_count + 2,
      'AK8: Re-Deploy desselben Commits muss zweite Historienzeile erzeugen';
   ASSERT l_id2 <> l_id3, 'AK7: zwei Aufrufe muessen verschiedene ids liefern';

   -- AK7: "aktuell ausgerollte Version" = neueste Zeile (max id)
   SELECT id INTO l_newest FROM db_version ORDER BY deployed_on DESC, id DESC LIMIT 1;
   ASSERT l_newest = l_id3, 'AK7: neueste Zeile (max id) stimmt nicht';

   -- Edge: gleiche Version in mehreren Umgebungen erlaubt
   CALL sp_ins_db_version(l_id2, 5, 5, 5, 'multienv-sha', NULL, 'dev');
   CALL sp_ins_db_version(l_id3, 5, 5, 5, 'multienv-sha', NULL, 'int');
   ASSERT (SELECT count(DISTINCT environment) FROM db_version WHERE git_commit='multienv-sha') = 2,
      'Edge: gleiche Version in dev+int muss erlaubt sein';

   -- Edge: Versionsvergleich 1.4.9 vs 1.4.10 ueber int-Spalten (10 > 9)
   CALL sp_ins_db_version(l_id2, 1, 4, 9,  'cmp-sha', NULL, 'test');
   CALL sp_ins_db_version(l_id3, 1, 4, 10, 'cmp-sha', NULL, 'test');
   ASSERT (SELECT id FROM db_version WHERE git_commit='cmp-sha'
           ORDER BY major DESC, minor DESC, build DESC LIMIT 1) = l_id3,
      'Edge: 1.4.10 muss numerisch groesser als 1.4.9 sein';
   -- Gegenprobe: als String waere 1.4.10 < 1.4.9 (zeigt, warum int-Spalten noetig sind)
   ASSERT ('1.4.10' < '1.4.9'),
      'Edge-Sanity: String-Vergleich 1.4.10 < 1.4.9 erwartet (Begruendung fuer int-Spalten)';

   RAISE NOTICE '### ALL ASSERTIONS PASSED (AK 1-4,10 strukturell + 3,5-8 Verhalten + Edge Cases)';
END;
$test$;

ROLLBACK;

\echo "## TEST config.db_version - DONE"
