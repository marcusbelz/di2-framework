# BUG-0002: sqlfluff PG01-Fehlalarm auf konventionellem CREATE INDEX
- **Bereich:** CI/CD-Qualitäts-Gate (di2f-0005) — sqlfluff-Konfig [.sqlfluff](../../.sqlfluff), Lint-Helfer [.github/sqlfluff-lint.sh](../../.github/sqlfluff-lint.sh), [features/di2f-0005-db-ci-dry-run-deploy-lint.md](../../features/di2f-0005-db-ci-dry-run-deploy-lint.md)
- **Status:** ❌ Offen
- **Schweregrad:** Mittel
- **Quelle:** qa

**Beschreibung:** Der `lint`-Job der DB-CI (di2f-0005) wirft über sqlfluff die Regel **`PG01` (postgres.excessive_locks)** — „CREATE INDEX should use CONCURRENTLY to avoid locking the table during the build" — auf **konventionellen** Index-DDL. Die Hauskonvention (`sql.md`) schreibt `CREATE [UNIQUE] INDEX IF NOT EXISTS <name> ON <table> (…)` **ohne** `CONCURRENTLY` vor (CONCURRENTLY ist im transaktionalen `psql -f`-Deploy ohnehin nicht erlaubt). Erwartet: konventionskonforme Skripte lösen **keinen** Lint-Fehler aus (AC 5 von di2f-0005). Tatsächlich: jede Datei unter `db/schemas/**` mit einem `CREATE INDEX` färbt den `lint`-Job **rot** und blockiert damit Merges.

**Root Cause:** In [.sqlfluff](../../.sqlfluff) listet `exclude_rules = layout, references.keywords, capitalisation.identifiers` die Regel `PG01` (`postgres.excessive_locks`) **nicht**. Das empirische Tuning beim Bau von di2f-0005 erfasste PG01 nicht, weil die damaligen Beispieldateien **keinen** `CREATE INDEX` enthielten. PG01 kollidiert grundsätzlich mit der Index-Konvention aus `sql.md` und ist damit ein Fehlalarm im Sinne von AC 5.

**Betroffene Datei(en):**
- [.sqlfluff](../../.sqlfluff) Zeile ~20 (`exclude_rules`)

**Reproduktion:**
1. Eine SQL-Datei unter `db/schemas/**` anlegen, die ein `CREATE INDEX … ON … (…);` enthält (z. B. die di2f-0001-WIP mit Index auf `log.execution`).
2. `bash .github/sqlfluff-lint.sh` ausführen (bzw. den `lint`-Job der CI).
3. Ergebnis: `PG01 | CREATE INDEX should use CONCURRENTLY …` → Exit ≠ 0 (Job rot), obwohl das SQL konventionskonform ist.

**Fix:** In [.sqlfluff](../../.sqlfluff) `postgres.excessive_locks` (PG01) zu `exclude_rules` hinzufügen — analog zu den übrigen bewusst deaktivierten, mit dem Hausstil kollidierenden Regeln. Danach `/qa`-Re-Test mit der Repro (Index-Datei) → Lint muss grün sein, kaputtes SQL weiterhin rot. Betrifft kein DB-Objekt und keinen View → Routing `/backend`.
