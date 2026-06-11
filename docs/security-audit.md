# Security Audit

<!-- Wird von /security automatisch aktualisiert. Nicht manuell bearbeiten. -->

## Status

| Feld | Wert |
|------|------|
| Zuletzt geprüft | 2026-06-11 |
| Geprüfte Bereiche | Alle (1–8) |
| Go-Live-Empfehlung | ✅ JA (für aktuellen Skelett-Scope; keine offenen Critical/High) |
| Kritische Findings | 0 offen / 0 behoben |
| Hohe Findings | 0 offen / 0 behoben |

> **Scope-Hinweis:** Das Framework ist noch im Aufbau — `etl` (generisches Dynamic SQL) ist **leer**, die Logging-Prozeduren (`sp_*_execution/component/trace`, Schreibpfad nach `log.error`) sind **noch nicht gebaut**. Die zwei größten künftigen Angriffsflächen (Dynamic-SQL-Injection in `etl`, Secrets/PII in den Log-Schreibpfaden) existieren im Code daher noch nicht. **Erneuter `/security`-Lauf Pflicht, sobald `etl` bzw. die Logging-Prozeduren entstehen.**

## Findings

### Kritisch
_Keine._

### Hoch
_Keine._

### Mittel

#### M1 — RLS auf keiner Tabelle aktiviert (sensible `log.*` ungeschützt auf Row-Ebene)
- **Bereich:** 2. Row Level Security & Policies (D1)
- **Wo:** projektweit — kein `ENABLE ROW LEVEL SECURITY` / `CREATE POLICY` in `db/` (Grep: 0 Treffer); `db/database/08.create.role.rw.sql` gibt `role_rw` volle DML auf **alle** Schemas.
- **Status:** ❌ Offen
- **Risiko:** Zugriffskontrolle stützt sich allein auf Rollen-Grants; `role_rw` (an `_sa` vererbt) liest/schreibt alle Zeilen aller Tabellen. Framework-Konventionen (`.claude/rules/policies.md`, `tables.md`) und PRD-Roadmap (P1 „RLS-Policies & Rollenrechte (Schema log)") fordern RLS auf `log.*`. Solange es nur **eine** RW-Rolle und **kein** Multi-Tenant-/Row-Isolations-Requirement gibt, ist das Risiko begrenzt — wird aber zum Problem, sobald mehrere Mandanten/Akteure dieselbe DB teilen.
- **Fix:** RLS-Feature umsetzen (P1): `ALTER TABLE :schema_log.<t> ENABLE ROW LEVEL SECURITY;` (sensible Tabellen zusätzlich `FORCE`), Policy je Befehl mit `USING`/`WITH CHECK`, Default-Deny, Rollen explizit (`TO :role_rw`). Siehe `policies.md`.

#### M2 — `log.error`/`log.trace` fassen per Design Datensatz-Werte (potenziell PII)
- **Bereich:** 6. Sensible Daten in Logs (D4)
- **Wo:** [db/schemas/log/tables/004.error.sql](../db/schemas/log/tables/004.error.sql) (`id1_value`/`id2_value`/`id3_value`, `error_value`, `description`); analog `log.trace`.
- **Status:** ❌ Offen
- **Risiko:** Die Fehlertabelle ist dafür gebaut, Werte der fehlerhaften Datensätze festzuhalten — je nach Anwendung können das PII (E-Mail, Namen, IDs) sein. Ohne RLS (M1) und mit breiter `role_rw` kann jede DML-Rolle diese Werte lesen. Für die aktuelle Single-Role-/Skelett-Phase vertretbar; bei echten Produktivdaten mit PII nachschärfen.
- **Fix:** Bei PII-Daten: RLS (M1) + ggf. Maskierung/Verzicht auf Klartext-Werte in `*_value`-Spalten; dokumentieren, welche Datenklassen in `log.error` zulässig sind. Beim Bau der Logging-Prozeduren: keine Secrets/Passwörter in `description`/`error_value`/`SQLERRM` schreiben.

#### M3 — CI `dry-run-deploy` führt PR-SQL real aus (RCE-Fläche auf dem Runner)
- **Bereich:** 8. Deployment & CI/CD (D7)
- **Wo:** [.github/workflows/ci.yml](../.github/workflows/ci.yml) (Job `dry-run-deploy`: `create.sh local` führt `db/database/*.sql` als `postgres`-Superuser im ephemeren Service aus).
- **Status:** ❌ Offen
- **Risiko:** Ein PR, der `db/database/*.sql` manipuliert, könnte als Superuser `COPY … TO PROGRAM '…'` ausführen → Codeausführung auf dem CI-Runner. Mitigiert durch: ephemeren Runner, **keine** Secrets, `permissions: contents: read`, und GitHub-Default „Fork-PRs Erstbeitragender brauchen Maintainer-Freigabe". Für ein **internes** Repo praktisch sehr gering; relevant, falls je externe Fork-PRs gemergt werden.
- **Fix:** Bewusste Entscheidung dokumentieren. Falls externe Forks: `dry-run-deploy` auf Nicht-Fork-PRs beschränken (`if: github.event.pull_request.head.repo.fork == false`) bzw. in stärker isolierter Umgebung fahren.

### Niedrig / Informational
- **N1 (D6, Niedrig):** Keine SSL/TLS-Anforderung (`sslmode`/`hostssl`) für Prod-Verbindungen dokumentiert. Empfehlung: für `prod` `sslmode=require` (oder `verify-full`) festlegen.
- **I1 (D8, Info):** Logging-Prozeduren (`sp_*_execution/component/trace`, Schreibpfad nach `log.error`) noch nicht gebaut — beim Bau Status deterministisch + ohne Secrets in `SQLERRM`/Werten protokollieren (Konvention steht in `procedures.md`/`sql.md`).
- **I2 (D2, Info):** `etl`-Schema (generisches Dynamic SQL) noch leer — Haupt-Injection-Fläche existiert noch nicht. Bei Bau `/security dynsql` erneut fahren (`%I`/`%L`/`USING`, Whitelist gegen Katalog).

### Abgedeckt ✅
- **Rollenmodell / Least Privilege:** getrennte Rollen (DB-Owner `_owner`, Schema-Owner `_fw`, RW-Gruppe `_rw` NOLOGIN, Service-Account `_sa` LOGIN/INHERIT); kein produktiver Superuser-Login; keine `PUBLIC`-Grants.
- **`public`-Härtung:** `REVOKE CREATE ON SCHEMA public FROM PUBLIC` ([02](../db/database/02.create.extension.sql)) + `REVOKE CONNECT ON DATABASE … FROM PUBLIC` ([01](../db/database/01.create.database.sql)). Keine Objekte in `public`.
- **SECURITY DEFINER:** keine vorhanden — alle Routinen laufen mit Caller-Rechten (kein Escalation-Pfad); `search_path` der Rollen fix via `ALTER USER … SET search_path`.
- **Dynamic SQL (aktuell):** `clean.schema.sql` baut DROP-Statements mit `quote_ident()` über whitelisted `:'schema_target'` (clean.sh prüft `config|etl|helper|log|all`); läuft als `_fw` (kein Superuser). Prozeduren `sp_*_process` nutzen `format()` nur für Fehlermeldungen, kein `EXECUTE` von Eingaben.
- **Secrets:** keine Klartext-Secrets im Repo. `local` nutzt bewusst `pw`; `dev/int/test/prod`-Passwörter via `-v`/Env bzw. GitHub-Environment-Secrets; `.gitignore` deckt `*.local.secret` und `docker/docker.di2f.*.env` ab (Beispiel `*.example` versioniert). Kein Private Key committet.
- **Extensions:** nur `pgcrypto` (trusted); **kein** `plpython3u`.
- **CI/CD (di2f-0004):** Secrets ausschließlich via `${{ secrets.* }}`, Übergabe per `envs:` (kein `echo $SECRET`); Deploy-User `fupi` (kein root); Workflows nur `workflow_dispatch` bzw. `pull_request`→`main` / `push`→`dev`. di2f-0005-CI ohne Secrets, `contents: read`, fork-sicher (`pull_request`, nicht `pull_request_target`).

## DB-Risiko-Kurzcheck

| # | Kategorie | Status | Anmerkung |
|---|-----------|--------|-----------|
| D1 | Broken Access Control | ⚠️ | Rollen/Least-Priv ✅, `public` gehärtet ✅; **RLS fehlt** auf allen Tabellen (M1, P1-Roadmap). |
| D2 | SQL Injection | ✅ | Aktueller Code injection-sicher (`quote_ident`/`format()`-Messages, Whitelist). `etl` noch leer (I2). |
| D3 | Privilege Escalation | ✅ | Kein `SECURITY DEFINER`; fixe `search_path`; Owner korrekt. |
| D4 | Sensitive Data Exposure | ⚠️ | `log.error`/`trace` halten Datensatz-Werte (PII-fähig), ohne RLS breit lesbar (M2). |
| D5 | Secrets Management | ✅ | Keine hardcodierten Secrets; `.gitignore` deckt ab; nur `local` `pw`. |
| D6 | Insecure Config | ✅ | `public` gehärtet, nur `pgcrypto`. SSL für Prod offen (N1). |
| D7 | CI/CD Integrity | ⚠️ | Secrets sauber, Deploy-User minimal; aber Dry-Run führt PR-SQL aus (M3). |
| D8 | Logging Failures | ✅ | Aktueller Code ohne Secrets in Messages; Logging-Prozeduren noch nicht gebaut (I1). |

## Audit-Historie

| Datum | Bereiche | Kritisch | Hoch | Go-Live |
|-------|---------|----------|------|---------|
| 2026-06-11 | Alle (1–8) | 0 | 0 | ✅ (Skelett-Scope; 3 Mittel als Roadmap-/Daten-Items) |
