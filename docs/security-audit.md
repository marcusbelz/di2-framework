# Security Audit

<!-- Wird von /security automatisch aktualisiert. Nicht manuell bearbeiten. -->

## Status

| Feld | Wert |
|------|------|
| Zuletzt geprüft | 2026-06-12 |
| Geprüfte Bereiche | Alle (1–8) |
| Go-Live-Empfehlung | ✅ JA (für aktuellen Scope; keine offenen Critical/High) |
| Kritische Findings | 0 offen / 0 behoben |
| Hohe Findings | 0 offen / 0 behoben |

> **Scope-Hinweis:** Das Framework ist im Aufbau. Gebaut & reviewt: `config.process` (Tabelle, CRUD-Prozeduren `sp_ins/upd/del_process`, Seed, modified-Trigger) und die `log`-Tabellen (`execution`/`component`/`trace`/`error`/`import_file`/`export_file` + `tf_set_modified`-Trigger). **Noch leer/ungebaut:** `etl` (generisches Dynamic SQL) und `helper`; die Logging-Schreib-Prozeduren (`sp_*_execution/component/trace`, Schreibpfad nach `log.error`). Die zwei größten künftigen Angriffsflächen (Dynamic-SQL-Injection in `etl`, Secrets/PII in den Log-Schreibpfaden) existieren im Code daher noch nicht. **Erneuter `/security`-Lauf Pflicht, sobald `etl` bzw. die Logging-Prozeduren entstehen.**
>
> **Re-Audit 2026-06-12:** ausgelöst durch Änderungen seit dem Erst-Audit (Konventions-Umbau `a82eeb4`, Signatur-Fix `2c5dcdd`, Bootstrap-Preflight `6f5a004`, Lint-SKIP `25cf522`). Ergebnis: Sicherheitslage **unverändert** — die Procedure-/Tabellen-Änderungen sind rein formal/additiv (Layout, Kommentare, Parameter-Reihenfolge), die neuen Bootstrap-/CI-Dateien injection-sicher und ohne Secret-Exposure (siehe I3). Keine neuen Findings; M1–M3 + N1/I1/I2 bestehen unverändert.

## Findings

### Kritisch
_Keine._

### Hoch
_Keine._

### Mittel

#### M1 — RLS auf keiner Tabelle aktiviert (sensible `log.*` ungeschützt auf Row-Ebene)
- **Bereich:** 2. Row Level Security & Policies (D1)
- **Wo:** projektweit — kein `ENABLE ROW LEVEL SECURITY` / `CREATE POLICY` in `db/` (Grep: 0 Treffer, 2026-06-12 erneut bestätigt); `db/database/08.create.role.rw.sql` gibt `role_rw` volle DML auf **alle** Schemas.
- **Status:** ❌ Offen
- **Risiko:** Zugriffskontrolle stützt sich allein auf Rollen-Grants; `role_rw` (an `_sa` vererbt) liest/schreibt alle Zeilen aller Tabellen. Framework-Konventionen (`.claude/rules/policies.md`, `tables.md`) und PRD-Roadmap (P1 „RLS-Policies & Rollenrechte (Schema log)") fordern RLS auf `log.*`. Solange es nur **eine** RW-Rolle und **kein** Multi-Tenant-/Row-Isolations-Requirement gibt, ist das Risiko begrenzt — wird aber zum Problem, sobald mehrere Mandanten/Akteure dieselbe DB teilen.
- **Fix:** RLS-Feature umsetzen (P1): `ALTER TABLE :schema_log.<t> ENABLE ROW LEVEL SECURITY;` (sensible Tabellen zusätzlich `FORCE`), Policy je Befehl mit `USING`/`WITH CHECK`, Default-Deny, Rollen explizit (`TO :role_rw`). Siehe `policies.md`.

#### M2 — `log.error`/`log.trace` fassen per Design Datensatz-Werte (potenziell PII)
- **Bereich:** 6. Sensible Daten in Logs (D4)
- **Wo:** [db/schemas/log/tables/004.error.sql](../db/schemas/log/tables/004.error.sql) (`id1_value`/`id2_value`/`id3_value`, `error_value`, `description`); analog `log.trace`. Spaltenkommentare (2026-06-12 ergänzt) dokumentieren den Inhalt explizit (z. B. „Wert der 1. Identifizierungsspalte des fehlerhaften Datensatzes").
- **Status:** ❌ Offen
- **Risiko:** Die Fehlertabelle ist dafür gebaut, Werte der fehlerhaften Datensätze festzuhalten — je nach Anwendung können das PII (E-Mail, Namen, IDs) sein. Ohne RLS (M1) und mit breiter `role_rw` kann jede DML-Rolle diese Werte lesen. Für die aktuelle Single-Role-/Aufbau-Phase (noch keine Produktivdaten) vertretbar; bei echten Produktivdaten mit PII nachschärfen.
- **Fix:** Bei PII-Daten: RLS (M1) + ggf. Maskierung/Verzicht auf Klartext-Werte in `*_value`-Spalten; dokumentieren, welche Datenklassen in `log.error` zulässig sind. Beim Bau der Logging-Prozeduren: keine Secrets/Passwörter in `description`/`error_value`/`SQLERRM` schreiben.

#### M3 — CI `dry-run-deploy` führt PR-SQL real aus (RCE-Fläche auf dem Runner)
- **Bereich:** 8. Deployment & CI/CD (D7)
- **Wo:** [.github/workflows/ci.yml](../.github/workflows/ci.yml) (Job `dry-run-deploy`: `create.sh local` führt `db/database/*.sql` als `postgres`-Superuser im ephemeren Service aus — seit `6f5a004` inkl. `00.preflight.create.sql`, danach `deploy.sh all local` 2×).
- **Status:** ❌ Offen
- **Risiko:** Ein PR, der `db/database/*.sql` manipuliert, könnte als Superuser `COPY … TO PROGRAM '…'` ausführen → Codeausführung auf dem CI-Runner. Mitigiert durch: ephemeren Runner, **keine** Secrets, `permissions: contents: read`, `pull_request` (nicht `pull_request_target` → Fork-PRs erhalten keine Secrets) und GitHub-Default „Fork-PRs Erstbeitragender brauchen Maintainer-Freigabe". Für ein **internes** Repo praktisch sehr gering; relevant, falls je externe Fork-PRs gemergt werden. (2026-06-12: unverändert; Preflight liegt innerhalb derselben ausgeführten Fläche, kein zusätzlicher Vektor.)
- **Fix:** Bewusste Entscheidung dokumentieren. Falls externe Forks: `dry-run-deploy` auf Nicht-Fork-PRs beschränken (`if: github.event.pull_request.head.repo.fork == false`) bzw. in stärker isolierter Umgebung fahren.

### Niedrig / Informational
- **N1 (D6, Niedrig):** Keine SSL/TLS-Anforderung (`sslmode`/`hostssl`) für Prod-Verbindungen dokumentiert. Empfehlung: für `prod` `sslmode=require` (oder `verify-full`) festlegen. (2026-06-12: unverändert offen.)
- **I1 (D8, Info):** Logging-Prozeduren (`sp_*_execution/component/trace`, Schreibpfad nach `log.error`) noch nicht gebaut — beim Bau Status deterministisch + ohne Secrets in `SQLERRM`/Werten protokollieren (Konvention steht in `procedures.md`/`sql.md`).
- **I2 (D2, Info):** `etl`-Schema (generisches Dynamic SQL) noch leer — Haupt-Injection-Fläche existiert noch nicht. Bei Bau `/security dynsql` erneut fahren (`%I`/`%L`/`USING`, Whitelist gegen Katalog).
- **I3 (D2/D7, Info — neu 2026-06-12, geprüft ✅):** Bootstrap-Preflight [db/database/00.preflight.create.sql](../db/database/00.preflight.create.sql) (via [create.sh](../db/scripts/create.sh)) ist **read-only** (`SELECT EXISTS` gegen `pg_database`/`pg_roles`) + `RAISE EXCEPTION`; nutzt ausschließlich `:'…'`-String-Literal-Platzhalter (psql-seitig gequotet → keine Injection), **kein** `EXECUTE`/Dynamic SQL. `create.sh` gibt keine Secrets aus (Preflight ohne Passwort-`-v`, Ausgabe nach `/dev/null`, statische Fehlertexte). Der sqlfluff-SKIP der Datei (`25cf522`) schwächt **kein** Security-Gate — das SQL-Gate ist der Dry-Run-Deploy (führt die Preflight real aus), nicht der Style-Lint.

### Abgedeckt ✅
- **Rollenmodell / Least Privilege:** getrennte Rollen (DB-Owner `_owner`, Schema-Owner `_fw`, RW-Gruppe `_rw` NOLOGIN, Service-Account `_sa` LOGIN/INHERIT); kein produktiver Superuser-Login; keine `PUBLIC`-Grants. `role_rw` erhält DML/USAGE/EXECUTE explizit je Schema + Default Privileges (kein pauschales `PUBLIC`).
- **`public`-Härtung:** `REVOKE CREATE ON SCHEMA public FROM PUBLIC` ([02](../db/database/02.create.extension.sql)) + `REVOKE CONNECT ON DATABASE … FROM PUBLIC` ([01](../db/database/01.create.database.sql)). Keine Objekte in `public`.
- **SECURITY DEFINER:** keine vorhanden (Grep 2026-06-12: 0 Treffer) — alle Routinen (3× `sp_*_process`, 4× `tf_set_modified`-Trigger) laufen mit Caller-Rechten (kein Escalation-Pfad); `search_path` der Rollen fix via `ALTER USER … SET search_path`.
- **Dynamic SQL (aktuell):** `clean.schema.sql` baut DROP-Statements mit `quote_ident()` über whitelisted `:'schema_target'` (clean.sh prüft `config|etl|helper|log|all`); läuft als `_fw` (kein Superuser). Prozeduren `sp_*_process` nutzen `format($$…$$, …)` nur für Fehlermeldungen (indizierte `%n$s`), **kein** `EXECUTE` von Eingaben. Trigger nutzen `EXECUTE FUNCTION` (DDL-Syntax, kein Dynamic SQL).
- **Secrets:** keine Klartext-Secrets im Repo (Grep 2026-06-12). `local` nutzt bewusst `pw`; Rollen-Passwörter via `-v`/Env bzw. GitHub-Environment-Secrets (`CREATE ROLE/USER … PASSWORD :'…_password'`); `.gitignore` deckt `*.local.secret` und `docker/docker.di2f.*.env` ab (`*.example` versioniert). Kein Private Key committet.
- **Extensions:** nur `pgcrypto` (trusted); **kein** `plpython3u`; kein `COPY … TO PROGRAM` in `db/`.
- **CI/CD:** Secrets ausschließlich via `${{ secrets.* }}`, Übergabe per `envs:` (kein `echo $SECRET`); Deploy-Workflows (`db-*.yml`) nur `workflow_dispatch`. CI (`ci.yml`) ohne Secrets, `permissions: contents: read`, ephemere DB (`pw`), fork-sicher (`pull_request`/`push`, **kein** `pull_request_target`). sqlfluff exakt gepinnt (`3.5.0`).

## DB-Risiko-Kurzcheck

| # | Kategorie | Status | Anmerkung |
|---|-----------|--------|-----------|
| D1 | Broken Access Control | ⚠️ | Rollen/Least-Priv ✅, `public` gehärtet ✅; **RLS fehlt** auf allen Tabellen (M1, P1-Roadmap). |
| D2 | SQL Injection | ✅ | Aktueller Code injection-sicher (`quote_ident`/`format()`-Messages, Whitelist; Preflight `:'…'`-gequotet, I3). `etl` noch leer (I2). |
| D3 | Privilege Escalation | ✅ | Kein `SECURITY DEFINER`; fixe `search_path`; Owner korrekt. |
| D4 | Sensitive Data Exposure | ⚠️ | `log.error`/`trace` halten Datensatz-Werte (PII-fähig), ohne RLS breit lesbar (M2). |
| D5 | Secrets Management | ✅ | Keine hardcodierten Secrets; `.gitignore` deckt ab; nur `local` `pw`. |
| D6 | Insecure Config | ✅ | `public` gehärtet, nur `pgcrypto`. SSL für Prod offen (N1). |
| D7 | CI/CD Integrity | ⚠️ | Secrets sauber, Deploy-User minimal, fork-sicher; aber Dry-Run führt PR-SQL als Superuser aus (M3). |
| D8 | Logging Failures | ✅ | Aktueller Code ohne Secrets in Messages; Logging-Prozeduren noch nicht gebaut (I1). |

## Audit-Historie

| Datum | Bereiche | Kritisch | Hoch | Go-Live |
|-------|---------|----------|------|---------|
| 2026-06-11 | Alle (1–8) | 0 | 0 | ✅ (Skelett-Scope; 3 Mittel als Roadmap-/Daten-Items) |
| 2026-06-12 | Alle (1–8) | 0 | 0 | ✅ (Re-Audit nach config.process-Umbau + Bootstrap-Preflight; Lage unverändert, 3 Mittel offen als Roadmap-/Daten-Items) |
| 2026-06-12 | Deploy prod (Gate: Audit 2026-06-12) | 0 | 0 | ✅ — Go-Live di2f-0001 prod `6290cd6`, Release-Tag `v1.0.0` |
