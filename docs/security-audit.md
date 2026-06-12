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
> für die noch ungebauten Teile (`etl`-Dynamic-SQL, restliche Logging-Schreibpfade) — dort liegt die
> reale künftige Angriffsfläche.

> **Scope-Hinweis:** Das Framework ist im Aufbau. Gebaut & auditiert: `config.process` (Tabelle,
> CRUD-Prozeduren, Seed, modified-Trigger); **`config.db_version` + `config.sp_ins_db_version`**
> (di2f-0006); die **`deploy.sh`-Versionszeile** (di2f-0007); die **acht `helper`-Funktionen**
> (di2f-0008/0009); die `log`-Tabellen (`execution`/`component`/`trace`/`error`/`import_file`/
> `export_file` + `tf_set_modified`-Trigger); **`log.sp_ins_execution` + `log.sp_upd_execution` +
> die 4 Wrapper** (di2f-0010 — Execution-Insert/Update). **Noch leer/ungebaut:** `etl` (generisches
> Dynamic SQL) und die **Component-/Trace-/Error-Schreibpfade** (`sp_*_component/trace`, Schreibpfad
> nach `log.error`). Die zwei größten künftigen Angriffsflächen (Dynamic-SQL-Injection in `etl`,
> Secrets/PII in den verbleibenden Log-Schreibpfaden) existieren im Code daher noch nicht. **Erneuter
> `/security`-Lauf Pflicht, sobald `etl` bzw. die Component-/Trace-/Error-Prozeduren entstehen.**
>
> **Voll-Audit 2026-06-12 (deckt di2f-0006…0009 nach):** Schließt die zuvor offene Audit-Lücke des
> Prod-Deploys `a78e83d`. Geprüft: `config.db_version` (nicht-sensible Deploy-Metadaten), `sp_ins_db_version`
> (statischer Insert, **kein** Dynamic SQL, SECURITY INVOKER), die acht `helper`-Funktionen (**kein**
> Dynamic SQL / Konkatenation, **kein** `SECURITY DEFINER`, `IMMUTABLE`/`STABLE`), `deploy.sh`-Versionszeile
> (`:'…'`-gequotet → keine Injection), `db-deploy.yml`. **Keine neuen Critical/High/Mittel.** Ein neuer
> Info-Punkt (I4, PUBLIC-EXECUTE-Default, mitigiert). **Neubewertung nach Architektur-Annahmen:**
> **M1 akzeptiert**, **M2 → Niedrig**, **N1 entschärft**. Verbleibendes „echtes" Mittel: nur **M3**.
>
> **Voll-Audit 2026-06-12 (di2f-0010 — `log.execution` Insert/Update-Prozeduren):** Deckt die seit dem
> letzten Audit per **PR #7** nach `main` gemergte neue Fläche: `log.sp_ins_execution`,
> `log.sp_upd_execution` + 4 Wrapper (`_error`/`_success`/`_warning`/`_information`). Geprüft: **kein**
> Dynamic SQL (alle SELECT/INSERT/UPDATE statisch; `format()` nur für Fehler-Messages mit indizierten
> `%n$s`; `p_state` allowlist-validiert und nur als **Wert**, nie als Identifier — Grep: kein `EXECUTE`
> von Eingaben), **kein** `SECURITY DEFINER` (INVOKER; Grep 0 Treffer), Body schema-qualifiziert
> hartkodiert (`log.execution`/`config.process`/`config.db_version`) → kein `search_path`-Hijack.
> Geschriebene Werte sind operative Metadaten (Zeitstempel, `user_name = current_user` = DB-Rolle,
> caller-`machine`/`instance`, `version`, `state`, `success`) — **keine** Secrets/PII; Fehler werden an
> den Aufrufer ge-`RAISE`t (**kein** `SQLERRM` in eine Tabelle). Least-Privilege als Laufzeitrolle
> `di2f_sa` (erbt `di2f_rw`) in QA verifiziert (Cross-Schema-Read `config` + Write `log` mit
> Standard-Grants, kein `permission denied`). **Keine neuen Critical/High/Mittel.** I1 für den
> **Execution-Schreibpfad** damit erfüllt (component/trace/error weiter offen); I4 erweitert sich auf
> die 6 neuen log-Routinen (weiter mitigiert); neuer Info-Punkt **I5** (Daten-Integrität:
> state-Normalisierung ohne `CHECK`-Constraint, mitigiert).

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
  Isolationswert. di2f-0010 fügt **kein** RLS hinzu — konsistent mit dieser Entscheidung.
- **Rest-Hinweis:** Was bleibt, ist **kein** RLS-Thema, sondern **Daten-Hygiene** beim Logging — siehe M2/I1.

#### M2 — `log.error`/`log.trace` fassen per Design Datensatz-Werte (potenziell PII) → **Niedrig (Daten-Hygiene)**
- **Bereich:** 6. Sensible Daten in Logs (D4)
- **Wo:** [db/schemas/log/tables/004.error.sql](../db/schemas/log/tables/004.error.sql)
  (`id1_value`/`id2_value`/`id3_value`, `error_value`, `description`); analog `log.trace`.
- **Status:** ⚠️ **Niedrig / Daten-Hygiene** (von „Mittel" herabgestuft 2026-06-12)
- **Risiko:** Die Fehler-/Trace-Tabellen halten Werte fehlerhafter Datensätze (ggf. PII). Mit den
  Architektur-Annahmen (kein öffentlicher Zugriff, **eine** vertrauenswürdige RW-Rolle) ist das **kein**
  Zugriffs-Isolationsproblem — reine **Build-Hygiene** beim Bau der **Component-/Trace-/Error**-Prozeduren.
- **Hinweis di2f-0010:** Der nun gebaute **Execution**-Schreibpfad ist davon **nicht** betroffen — er
  schreibt nur operative Metadaten, keine Datensatz-Werte. M2 bleibt offen für die noch ungebauten
  trace/error-Schreibpfade.

#### M3 — CI `dry-run-deploy` führt PR-SQL real aus (RCE-Fläche auf dem Runner)
- **Bereich:** 8. Deployment & CI/CD (D7)
- **Wo:** [.github/workflows/ci.yml](../.github/workflows/ci.yml) (Job `dry-run-deploy`: `create.sh
  local` + `deploy.sh all local` 2× als `postgres`-Superuser im ephemeren Service).
- **Status:** ❌ Offen
- **Risiko:** Ein PR, der `db/database/*.sql` manipuliert, könnte als Superuser `COPY … TO PROGRAM`
  ausführen → Codeausführung auf dem Runner. Mitigiert: ephemerer Runner, **keine** Secrets,
  `permissions: contents: read`, `pull_request` (nicht `pull_request_target`). Für ein **internes** Repo
  praktisch sehr gering. (2026-06-12: unverändert; di2f-0010 fügt nur reine log-Prozeduren hinzu — kein
  neuer Vektor.)
- **Fix:** Bewusste Entscheidung dokumentieren. Bei externen Forks: `dry-run-deploy` auf Nicht-Fork-PRs
  beschränken (`if: github.event.pull_request.head.repo.fork == false`).

### Niedrig / Informational
- **N1 (D6, Niedrig — entschärft 2026-06-12):** SSL/TLS für DB-Verbindungen ist **optional**, da die DB
  **nicht öffentlich** erreichbar ist und Verbindungen intern/lokal laufen. Empfehlung **nur**, falls
  Verbindungen je eine Vertrauensgrenze im Netz überqueren: dann `sslmode=require`/`verify-full`.
- **I1 (D8, Info — teilweise erfüllt 2026-06-12 durch di2f-0010):** Der **Execution-Schreibpfad**
  (`sp_ins_execution`/`sp_upd_execution` + Wrapper) ist gebaut und sauber: Status deterministisch
  (`state`/`success`/`end_on`), Fehler via `RAISE` ohne Secrets, **kein** `SQLERRM` in Tabellenwerte.
  **Noch offen:** die **Component-/Trace-/Error**-Schreibpfade (`sp_*_component/trace`, Schreibpfad nach
  `log.error`) sind weiter ungebaut — beim Bau dieselbe Hygiene (keine Secrets/PII in
  `description`/`*_value`/`SQLERRM`).
- **I2 (D2, Info):** `etl`-Schema (generisches Dynamic SQL) noch leer — Haupt-Injection-Fläche existiert
  noch nicht. Bei Bau `/security dynsql` (`%I`/`%L`/`USING`, Whitelist gegen Katalog).
- **I3 (D2/D7, Info — geprüft ✅):** Bootstrap-Preflight
  [db/database/00.preflight.create.sql](../db/database/00.preflight.create.sql) ist **read-only**
  (`SELECT EXISTS` + `RAISE EXCEPTION`), nur `:'…'`-String-Literale (gequotet), **kein** `EXECUTE`.
- **I4 (D1/D3, Info — neu 2026-06-12, mitigiert; Scope 2026-06-12 erweitert):** PostgreSQL grantet neuen
  Funktionen implizit `EXECUTE` an `PUBLIC`; der Bootstrap
  [08.create.role.rw.sql](../db/database/08.create.role.rw.sql) `REVOKE`t das nicht (betrifft die 8
  `helper`-Funktionen + `sp_ins_db_version` + `sp_*_process` + **die 6 `log.sp_*_execution`-Routinen,
  di2f-0010**). **Praktisch neutralisiert**, weil `PUBLIC` weder `CONNECT` auf die DB noch `USAGE` auf
  die Schemas hat (nur `:role_rw` erhält `USAGE`) — ein Aufrufer ohne diese Grants erreicht die
  Routinen nicht. *Defense-in-Depth (optional):* `ALTER DEFAULT PRIVILEGES … REVOKE EXECUTE ON ROUTINES
  FROM PUBLIC;` + einmalig `REVOKE EXECUTE ON ALL ROUTINES … FROM PUBLIC;`.
- **I5 (D1/D4, Info — neu 2026-06-12, mitigiert):** Der Delta-Wasserzeichen-Filter in `sp_ins_execution`
  (`state IN ('success','warning')`,
  [001.sp_ins_execution.sql:96](../db/schemas/log/procedures/001.sp_ins_execution.sql#L96)) ist
  case-sensitiv und verlässt sich darauf, dass `sp_upd_execution` `state` per `lower(trim())`
  normalisiert ([001.sp_upd_execution.sql:79](../db/schemas/log/procedures/001.sp_upd_execution.sql#L79)).
  `log.execution.state` hat **keinen** `CHECK`-Constraint → ein direkter Out-of-band-INSERT/UPDATE (an den
  Prozeduren vorbei) könnte ein nicht-normalisiertes `state` (z. B. `'Success'`) speichern und damit aus
  dem Wasserzeichen-Fenster fallen. **Mitigiert:** einziger Schreibpfad sind die Prozeduren
  (normalisieren), und es gibt nur **eine** vertrauenswürdige RW-Rolle (Single-Tenant). Reine
  **Daten-Integrität**, keine externe Angriffsfläche. *Defense-in-Depth (optional):* `CHECK (state IN
  ('processing','error','warning','information','success'))` bzw. die volle `(state,success)`-Kombinatorik
  als Constraint auf `log.execution`.

### Abgedeckt ✅
- **Rollenmodell / Least Privilege:** getrennte Rollen (DB-Owner `_owner`, Schema-Owner `_fw`,
  RW-Gruppe `_rw` NOLOGIN/NOINHERIT/**NOBYPASSRLS**, Service-Account `_sa` LOGIN/INHERIT); kein
  produktiver Superuser-Login. `role_rw` erhält DML/USAGE/EXECUTE **explizit** je Schema + Default
  Privileges. **di2f-0010:** `di2f_sa` (erbt `di2f_rw`) führt `sp_ins_execution` +
  `sp_upd_execution_*` inkl. Cross-Schema-Read (`config.process`/`config.db_version`) mit
  Standard-Grants aus — in QA verifiziert, **kein** `permission denied`.
- **`public`-Härtung:** `REVOKE CREATE ON SCHEMA public FROM PUBLIC`
  ([02](../db/database/02.create.extension.sql)) + `REVOKE CONNECT ON DATABASE … FROM PUBLIC`
  ([01](../db/database/01.create.database.sql)). Keine Objekte in `public` (auch di2f-0010 nicht).
- **SECURITY DEFINER:** keine vorhanden (Grep 2026-06-12: 0 Treffer) — alle Routinen, inkl. der 6
  neuen `log.sp_*_execution` (di2f-0010), laufen mit Caller-Rechten (INVOKER); kein Escalation-Pfad;
  `search_path` der Rollen fix via `ALTER USER … SET search_path`.
- **Dynamic SQL (aktuell):** `clean.schema.sql` baut DROP-Statements mit `quote_ident()` über
  whitelisted `:'schema_target'`; `sp_*_process`/`sp_ins_db_version`/**`sp_*_execution` (di2f-0010)**
  nutzen statisches DML bzw. `format($$…$$, …)` nur für Fehlermeldungen (indizierte `%n$s`), **kein**
  `EXECUTE` von Eingaben; `p_state` wird gegen eine Allowlist validiert und nur als **Wert** verwendet;
  `deploy.sh`-Versionszeile reicht Werte über `psql -v` + `:'…'`-Quoting durch — keine Konkatenation.
- **Sensible Daten (di2f-0010):** Der Execution-Schreibpfad schreibt nur operative Metadaten
  (Zeitstempel, `user_name = current_user` = DB-Rolle, `machine`/`instance`, `version`, `state`,
  `success`) — **keine** Secrets/PII; Fehlermeldungen enthalten nur numerische IDs + allowlistete
  States; kein `SQLERRM` in Tabellenwerte.
- **Secrets:** keine Klartext-Secrets im Repo (Grep 2026-06-12, inkl. der neuen di2f-0010-Dateien).
  `local` nutzt bewusst `pw`; Rollen-Passwörter via `-v`/Env bzw. GitHub-Environment-Secrets.
  `.gitignore` deckt lokale Secret-/Env-Dateien ab.
- **Extensions:** nur `pgcrypto` (trusted); **kein** `plpython3u`; kein `COPY … TO PROGRAM` in `db/`.
- **CI/CD:** Secrets ausschließlich via `${{ secrets.* }}`; Deploy-Workflows (`db-*.yml`) nur
  `workflow_dispatch`; `ci.yml` ohne Secrets, `permissions: contents: read`, ephemere DB, fork-sicher
  (`pull_request`/`push`, kein `pull_request_target`).

## DB-Risiko-Kurzcheck

| # | Kategorie | Status | Anmerkung |
|---|-----------|--------|-----------|
| D1 | Broken Access Control | ✅ | Rollen/Least-Priv ✅ (di2f-0010 least-priv als `di2f_sa` verifiziert), `public` gehärtet ✅, PUBLIC-EXECUTE-Default mitigiert (I4, Scope inkl. log-Procs). RLS bewusst **nicht** umgesetzt (M1 akzeptiert). |
| D2 | SQL Injection | ✅ | Aktueller Code injection-sicher; `log.execution`-Prozeduren (di2f-0010) ohne Dynamic SQL, `p_state` allowlist-validiert. `etl` noch leer (I2). |
| D3 | Privilege Escalation | ✅ | Kein `SECURITY DEFINER` (Grep 0, inkl. di2f-0010); fixe `search_path`; Owner korrekt; INVOKER. |
| D4 | Sensitive Data Exposure | ✅ | Execution-Schreibpfad nur operative Metadaten (kein PII/Secret); kein öffentlicher Zugriff + eine vertrauenswürdige Rolle. Verbleibende Build-Hygiene bei trace/error (M2, niedrig). |
| D5 | Secrets Management | ✅ | Keine hardcodierten Secrets (inkl. di2f-0010); `.gitignore` deckt ab; nur `local` `pw`. |
| D6 | Insecure Config | ✅ | `public` gehärtet, nur `pgcrypto`. SSL für Prod offen (N1). |
| D7 | CI/CD Integrity | ⚠️ | Secrets sauber, fork-sicher; Dry-Run führt PR-SQL als Superuser aus (M3, internes Repo). |
| D8 | Logging Failures | ✅ | Execution-Schreibpfad (di2f-0010) deterministisch + ohne Secrets; component/trace/error-Schreibpfade offen (I1). |

## Audit-Historie

| Datum | Bereiche | Kritisch | Hoch | Go-Live |
|-------|---------|----------|------|---------|
| 2026-06-11 | Alle (1–8) | 0 | 0 | ✅ (Skelett-Scope; 3 Mittel als Roadmap-/Daten-Items) |
| 2026-06-12 | Alle (1–8) | 0 | 0 | ✅ (Re-Audit nach config.process-Umbau + Bootstrap-Preflight; Lage unverändert) |
| 2026-06-12 | Deploy prod (Gate: Audit 2026-06-12) | 0 | 0 | ✅ — Go-Live di2f-0001 prod `6290cd6`, Release-Tag `v1.0.0` |
| 2026-06-12 | Deploy prod di2f-0006…0009 (`a78e83d`) | — | — | ⚠️ ohne deckenden Audit ausgerollt — nachträglich gedeckt durch Voll-Audit |
| 2026-06-12 | Voll-Audit (Alle 1–8) — deckt di2f-0006…0009 | 0 | 0 | ✅ — neue Fläche clean; +I4 (mitigiert); M1 akzeptiert, M2→Niedrig, N1 entschärft; offenes Mittel nur M3 |
| 2026-06-12 | **Voll-Audit (Alle 1–8) — deckt di2f-0010 (log.execution Insert/Update)** | 0 | 0 | ✅ — neue Fläche clean (kein Dynamic SQL/Secrets, INVOKER, least-priv als `di2f_sa` verifiziert); I1 für Execution-Schreibpfad erfüllt; +I5 (state-Normalisierung, mitigiert) |
| 2026-06-12 | Deploy prod di2f-0010 (Gate: Audit 2026-06-12) | 0 | 0 | ✅ — Go-Live di2f-0010 prod `00775cf` (PR #8), Release-Tag `v1.1.0` |
