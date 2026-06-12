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

> **Architektur-Annahmen / Threat-Model (User-Entscheid 2026-06-12 — maßgeblich für die Bewertung):**
> 1. **Single-Tenant:** Es teilen sich **nie** mehrere Mandanten eine DB. → Row-Isolation (RLS) hat
>    keinen Anwendungsfall (M1 akzeptiert).
> 2. **Kein öffentlicher DB-Zugriff:** Die Datenbank ist **nicht** öffentlich/aus dem Internet
>    erreichbar; Verbindungen laufen intern/lokal (Deploy + App via `localhost` auf dem Hetzner-Host).
>    → Externe Angreifer haben keine direkte DB-Fläche; Netz-Verschlüsselung (SSL) ist Optional statt
>    Pflicht (N1 entschärft), und die Exponierung sensibler Log-Werte beschränkt sich auf
>    **vertrauenswürdige** interne Rollen (M2 entschärft).
> 3. **Eine effektive RW-Rolle** (`role_rw` → `_sa`), die legitim alle Zeilen braucht.
>
> Diese Annahmen verschieben den Fokus weg von Zugriffs-Isolation (RLS/Netz) hin zu **Build-Hygiene**
> für die noch ungebauten Teile (`etl`-Dynamic-SQL, Logging-Schreibpfade) — dort liegt die reale
> künftige Angriffsfläche.

> **Scope-Hinweis:** Das Framework ist im Aufbau. Gebaut & auditiert: `config.process` (Tabelle,
> CRUD-Prozeduren, Seed, modified-Trigger); **`config.db_version` + `config.sp_ins_db_version`**
> (di2f-0006); die **`deploy.sh`-Versionszeile** (di2f-0007); die **acht `helper`-Funktionen**
> (di2f-0008/0009: `fn_is_null_or_empty`/`fn_starts_with`/`fn_ends_with`/`fn_split` +
> `fn_convert_bit`/`fn_convert_date`/`fn_convert_datetime`/`fn_convert_datetime2`); die `log`-Tabellen
> (`execution`/`component`/`trace`/`error`/`import_file`/`export_file` + `tf_set_modified`-Trigger).
> **Noch leer/ungebaut:** `etl` (generisches Dynamic SQL) und die Logging-Schreib-Prozeduren
> (`sp_*_execution/component/trace`, Schreibpfad nach `log.error`). Die zwei größten künftigen
> Angriffsflächen (Dynamic-SQL-Injection in `etl`, Secrets/PII in den Log-Schreibpfaden) existieren im
> Code daher noch nicht. **Erneuter `/security`-Lauf Pflicht, sobald `etl` bzw. die Logging-Prozeduren
> entstehen.**
>
> **Voll-Audit 2026-06-12 (deckt di2f-0006…0009 nach):** Schließt die zuvor offene Audit-Lücke des
> Prod-Deploys `a78e83d`. Geprüft: `config.db_version` (nicht-sensible Deploy-Metadaten — Version,
> Commit, Tag, Env, Zeit; keine PII/Secrets), `sp_ins_db_version` (statischer Insert, **kein** Dynamic
> SQL, SECURITY INVOKER), die acht `helper`-Funktionen (**kein** Dynamic SQL / Konkatenation, **kein**
> `SECURITY DEFINER`, `IMMUTABLE`/`STABLE`, `fn_convert_datetime2` fängt nur `data_exception` ab),
> `deploy.sh`-Versionszeile (`:'…'`-gequotet → keine Injection; Werte aus Env/git, **keine**
> Secret-Ausgabe), `db-deploy.yml` (`git fetch --tags`, Secrets via `${{ secrets.* }}`). **Keine neuen
> Critical/High/Mittel.** Ein neuer Info-Punkt (I4, PUBLIC-EXECUTE-Default, mitigiert). **Neubewertung
> nach Architektur-Annahmen (oben):** **M1 akzeptiert** (RLS ohne Anwendungsfall bei Single-Tenant),
> **M2 → Niedrig** (kein öffentlicher Zugriff + eine vertrauenswürdige Rolle → Build-Hygiene), **N1
> entschärft**. Verbleibendes „echtes" Mittel: nur **M3** (CI-Dry-Run, internes Repo, mitigiert).

## Findings

### Kritisch
_Keine._

### Hoch
_Keine._

### Akzeptierte Risiken / Bewusste Entscheidungen

#### M1 — Keine RLS (Row Level Security) — **bewusst zurückgestellt / Won't-fix**
- **Bereich:** 2. Row Level Security & Policies (D1)
- **Wo:** projektweit — kein `ENABLE ROW LEVEL SECURITY` / `CREATE POLICY` in `db/`.
- **Status:** ✅ **Akzeptiert (2026-06-12)** — kein offenes Finding mehr.
- **Begründung:** RLS isoliert **Zeilen** zwischen Mandanten/Akteuren. **Architektur-Entscheid (User,
  2026-06-12): es teilen sich NIE mehrere Mandanten eine DB**, und es gibt **eine** effektive
  RW-Rolle (`role_rw` → `_sa`), die legitim **alle** Zeilen braucht. Damit bringt RLS **keinen**
  Isolationswert — kein Akteur, gegen den isoliert würde. Zugriffskontrolle über die (minimalen,
  `public`-gehärteten) Rollen-Grants ist für diese Single-Tenant-/Single-Role-Architektur **ausreichend**.
- **Konsequenz:** Die `tables.md`/`policies.md`-Empfehlung „RLS auf `log.*`" und der PRD-P1-Eintrag
  „RLS-Policies" sind für diese Architektur **nicht mehr erforderlich** (Empfehlung: PRD-Roadmap-Eintrag
  streichen/entschärfen; Konventions-Hinweis als „nur falls je Row-Isolation nötig" relativieren).
- **Rest-Hinweis:** Was bleibt, ist **kein** RLS-Thema, sondern **Daten-Hygiene** beim Logging — siehe M2.

#### M2 — `log.error`/`log.trace` fassen per Design Datensatz-Werte (potenziell PII) → **Niedrig (Daten-Hygiene)**
- **Bereich:** 6. Sensible Daten in Logs (D4)
- **Wo:** [db/schemas/log/tables/004.error.sql](../db/schemas/log/tables/004.error.sql)
  (`id1_value`/`id2_value`/`id3_value`, `error_value`, `description`); analog `log.trace`.
- **Status:** ⚠️ **Niedrig / Daten-Hygiene** (von „Mittel" herabgestuft 2026-06-12)
- **Risiko (neu bewertet):** Die Fehlertabelle hält Werte fehlerhafter Datensätze (ggf. PII). Mit den
  Architektur-Annahmen (kein öffentlicher Zugriff, **eine** vertrauenswürdige RW-Rolle) ist das **kein**
  Zugriffs-Isolationsproblem mehr — RLS ist gegenstandslos (M1). Es bleibt eine reine **Build-Hygiene**:
  beim Bau der Logging-Prozeduren keine **Secrets/Passwörter** und nur die nötigen Datenwerte in
  `description`/`error_value`/`*_value`/`SQLERRM` schreiben.
- **Fix:** Logging-Prozeduren so bauen, dass keine Secrets/Tokens in Klartext geloggt werden; bei echten
  PII-Spalten dokumentieren, welche Datenklassen zulässig sind. (Überschneidet sich mit I1.)

#### M3 — CI `dry-run-deploy` führt PR-SQL real aus (RCE-Fläche auf dem Runner)
- **Bereich:** 8. Deployment & CI/CD (D7)
- **Wo:** [.github/workflows/ci.yml](../.github/workflows/ci.yml) (Job `dry-run-deploy`: `create.sh
  local` + `deploy.sh all local` 2× als `postgres`-Superuser im ephemeren Service).
- **Status:** ❌ Offen
- **Risiko:** Ein PR, der `db/database/*.sql` manipuliert, könnte als Superuser `COPY … TO PROGRAM`
  ausführen → Codeausführung auf dem Runner. Mitigiert: ephemerer Runner, **keine** Secrets,
  `permissions: contents: read`, `pull_request` (nicht `pull_request_target`). Für ein **internes** Repo
  praktisch sehr gering; relevant nur bei gemergten externen Fork-PRs. (2026-06-12: unverändert; der
  di2f-0008/0009-Deploy fügt nur reine helper-Funktionen hinzu — kein neuer Vektor.)
- **Fix:** Bewusste Entscheidung dokumentieren. Bei externen Forks: `dry-run-deploy` auf Nicht-Fork-PRs
  beschränken (`if: github.event.pull_request.head.repo.fork == false`).

### Niedrig / Informational
- **N1 (D6, Niedrig — entschärft 2026-06-12):** SSL/TLS für DB-Verbindungen ist **optional**, da die DB
  **nicht öffentlich** erreichbar ist und Verbindungen intern/lokal laufen (`localhost` auf dem
  Hetzner-Host → keine Netz-Traversierung). Empfehlung **nur**, falls Verbindungen je eine
  Vertrauensgrenze im Netz überqueren: dann `sslmode=require`/`verify-full`.
- **I1 (D8, Info):** Logging-Prozeduren (`sp_*_execution/component/trace`, Schreibpfad nach `log.error`)
  noch nicht gebaut — beim Bau Status deterministisch + ohne Secrets in `SQLERRM`/Werten protokollieren.
- **I2 (D2, Info):** `etl`-Schema (generisches Dynamic SQL) noch leer — Haupt-Injection-Fläche existiert
  noch nicht. Bei Bau `/security dynsql` (`%I`/`%L`/`USING`, Whitelist gegen Katalog).
- **I3 (D2/D7, Info — geprüft ✅):** Bootstrap-Preflight
  [db/database/00.preflight.create.sql](../db/database/00.preflight.create.sql) ist **read-only**
  (`SELECT EXISTS` + `RAISE EXCEPTION`), nur `:'…'`-String-Literale (gequotet), **kein** `EXECUTE`.
  `create.sh` gibt keine Secrets aus.
- **I4 (D1/D3, Info — neu 2026-06-12, mitigiert):** PostgreSQL grantet neuen Funktionen implizit
  `EXECUTE` an `PUBLIC`; der Bootstrap [08.create.role.rw.sql](../db/database/08.create.role.rw.sql)
  `REVOKE`t das nicht (betrifft die 8 `helper`-Funktionen + `sp_ins_db_version` + `sp_*_process`).
  **Praktisch neutralisiert**, weil `PUBLIC` weder `CONNECT` auf die DB
  ([01.create.database.sql](../db/database/01.create.database.sql)) noch `USAGE` auf die Schemas hat
  (nur `:role_rw` erhält `USAGE`) — ein Aufrufer ohne diese Grants erreicht die Funktionen nicht. Reine
  `helper`-Funktionen sind zudem zustandslos (kein Datenzugriff). *Defense-in-Depth (optional):*
  `ALTER DEFAULT PRIVILEGES FOR ROLE :schema_owner IN SCHEMA :schema_helper, :schema_config REVOKE
  EXECUTE ON ROUTINES FROM PUBLIC;` + einmalig `REVOKE EXECUTE ON ALL ROUTINES … FROM PUBLIC;`.

### Abgedeckt ✅
- **Rollenmodell / Least Privilege:** getrennte Rollen (DB-Owner `_owner`, Schema-Owner `_fw`,
  RW-Gruppe `_rw` NOLOGIN/NOINHERIT/**NOBYPASSRLS**, Service-Account `_sa` LOGIN/INHERIT); kein
  produktiver Superuser-Login. `role_rw` erhält DML/USAGE/EXECUTE **explizit** je Schema + Default
  Privileges (kein pauschaler `GRANT … TO PUBLIC`; impliziter PUBLIC-EXECUTE-Default s. I4, mitigiert).
- **`public`-Härtung:** `REVOKE CREATE ON SCHEMA public FROM PUBLIC`
  ([02](../db/database/02.create.extension.sql)) + `REVOKE CONNECT ON DATABASE … FROM PUBLIC`
  ([01](../db/database/01.create.database.sql)). Keine Objekte in `public`.
- **SECURITY DEFINER:** keine vorhanden (Grep 2026-06-12: 0 Treffer) — alle Routinen (`sp_*_process`,
  `sp_ins_db_version`, 8× `helper.fn_*`, `tf_set_modified`-Trigger) laufen mit Caller-Rechten
  (INVOKER); kein Escalation-Pfad; `search_path` der Rollen fix via `ALTER USER … SET search_path`.
- **`helper`-Funktionen (di2f-0008/0009):** **kein** Dynamic SQL / String-Konkatenation in `EXECUTE`
  (Grep: 0 Treffer), keine Secrets/PII; `IMMUTABLE` (reine String-Logik) bzw. `STABLE` (Datums-Parsen,
  DateStyle/Locale-abhängig — korrekt nicht IMMUTABLE); `fn_convert_datetime2` fängt nur
  `data_exception` (SQLSTATE 22) → NULL ab (maskiert keine Programmierfehler).
- **Dynamic SQL (aktuell):** `clean.schema.sql` baut DROP-Statements mit `quote_ident()` über
  whitelisted `:'schema_target'`; `sp_*_process`/`sp_ins_db_version` nutzen statisches DML bzw.
  `format($$…$$, …)` nur für Fehlermeldungen (indizierte `%n$s`), **kein** `EXECUTE` von Eingaben;
  `deploy.sh`-Versionszeile reicht Werte über `psql -v` + `:'…'`-Quoting (= `%L`) durch — keine
  Konkatenation.
- **Secrets:** keine Klartext-Secrets im Repo (Grep 2026-06-12, inkl. der neuen Dateien). `local` nutzt
  bewusst `pw`; Rollen-Passwörter via `-v`/Env bzw. GitHub-Environment-Secrets; `deploy.sh`
  (`DB_FW_PASSWORD` aus Env, **nicht** geloggt; die `>>> db_version: recording …`-Zeile zeigt nur
  Version/Commit/Tag/Env). `.gitignore` deckt lokale Secret-/Env-Dateien ab.
- **Extensions:** nur `pgcrypto` (trusted); **kein** `plpython3u`; kein `COPY … TO PROGRAM` in `db/`.
- **CI/CD:** Secrets ausschließlich via `${{ secrets.* }}` (`envs:`, kein `echo $SECRET`); Deploy-
  Workflows (`db-*.yml`) nur `workflow_dispatch`; `ci.yml` ohne Secrets, `permissions: contents: read`,
  ephemere DB, fork-sicher (`pull_request`/`push`, kein `pull_request_target`). `db-deploy.yml`
  `git fetch --tags` ohne Security-Impact.

## DB-Risiko-Kurzcheck

| # | Kategorie | Status | Anmerkung |
|---|-----------|--------|-----------|
| D1 | Broken Access Control | ✅ | Rollen/Least-Priv ✅, `public` gehärtet ✅, PUBLIC-EXECUTE-Default mitigiert (I4). RLS bewusst **nicht** umgesetzt — bei Single-Tenant + einer RW-Rolle ohne Mehrwert (M1 akzeptiert). |
| D2 | SQL Injection | ✅ | Aktueller Code injection-sicher (`quote_ident`/`format()`-Messages, `:'…'`-Quoting in deploy.sh, helper ohne Dynamic SQL). `etl` noch leer (I2). |
| D3 | Privilege Escalation | ✅ | Kein `SECURITY DEFINER`; fixe `search_path`; Owner korrekt; helper/db_version INVOKER. |
| D4 | Sensitive Data Exposure | ✅ | Kein öffentlicher Zugriff + eine vertrauenswürdige Rolle → kein Exposure-Problem; verbleibt Build-Hygiene beim Logging (M2, niedrig). `config.db_version` nicht-sensibel. |
| D5 | Secrets Management | ✅ | Keine hardcodierten Secrets; `.gitignore` deckt ab; nur `local` `pw`; deploy.sh loggt kein Passwort. |
| D6 | Insecure Config | ✅ | `public` gehärtet, nur `pgcrypto`. SSL für Prod offen (N1). |
| D7 | CI/CD Integrity | ⚠️ | Secrets sauber, fork-sicher; Dry-Run führt PR-SQL als Superuser aus (M3, internes Repo). |
| D8 | Logging Failures | ✅ | Aktueller Code ohne Secrets in Messages; Logging-Prozeduren noch nicht gebaut (I1). |

## Audit-Historie

| Datum | Bereiche | Kritisch | Hoch | Go-Live |
|-------|---------|----------|------|---------|
| 2026-06-11 | Alle (1–8) | 0 | 0 | ✅ (Skelett-Scope; 3 Mittel als Roadmap-/Daten-Items) |
| 2026-06-12 | Alle (1–8) | 0 | 0 | ✅ (Re-Audit nach config.process-Umbau + Bootstrap-Preflight; Lage unverändert) |
| 2026-06-12 | Deploy prod (Gate: Audit 2026-06-12) | 0 | 0 | ✅ — Go-Live di2f-0001 prod `6290cd6`, Release-Tag `v1.0.0` |
| 2026-06-12 | Deploy prod di2f-0006…0009 (`a78e83d`) | — | — | ⚠️ ohne deckenden Audit ausgerollt — **nachträglich gedeckt durch Voll-Audit unten** |
| 2026-06-12 | **Voll-Audit (Alle 1–8) — deckt di2f-0006…0009** | 0 | 0 | ✅ — neue Fläche clean; +I4 (mitigiert); Neubewertung per Architektur-Annahmen: **M1 akzeptiert** (Single-Tenant), **M2→Niedrig** + **N1 entschärft** (kein öffentlicher DB-Zugriff); offenes Mittel nur M3 (CI, internes Repo) |
