# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Zusammenarbeit erfolgt auf **Deutsch**.

## Zweck des Projekts

`di2-framework` portiert und erweitert ein bestehendes **SQL-Server-Framework** zu einem **PostgreSQL-17-Framework** aus Tabellen, Prozeduren und Funktionen. Prozeduren/Funktionen in **PL/pgSQL** (Python-Funktionen via PL/Python, wo nötig).

Aufgaben des Frameworks:
- **Prozessprotokollierung auf 3 Ebenen** (im Schema `log`):
  1. **Prozessebene** — ein Eintrag pro Prozessausführung (entspricht `Execution`).
  2. **Komponentenebene** — ein Datensatz pro Ausführung einer Prozedur / Python-Funktion; wird nach Erfolg/Fehler aktualisiert (entspricht `Component`).
  3. **Trace** — detaillierteste Ebene; Insert + späteres Update mit Status.
- **Fehlertabelle** — Protokollierung von Datenfehlern (`Error`).
- **Konfigurationstabelle** — Konfiguration einer Anwendung (`Configuration`).

Die Vorlage liegt unter `example/sample05.db/` (SQL Server). Schema-Mapping SQL Server → PostgreSQL:
`LOG → log` (`Execution` = Prozessebene, `Component` = Komponentenebene, `Trace` = unterste Ebene, `Error` = Fehlertabelle), `CONFIG → config`, `dbo → helper` (generische Helfer), generisches ETL/Dynamic-SQL → `etl`.

## Verzeichnisstruktur

### `db/` — das neue PostgreSQL-Framework

- **`db/database/`** — Skripte zum Erstellen der Datenbank, der Schemas und der Rollen sowie zum **Abräumen** der Datenbank.
- **`db/schemas/`** — pro Schema ein Unterverzeichnis (4 Schemas: `config`, `etl`, `helper`, `log`).
- **`db/scripts/`** — **Bash-Skripte** (Ausführung unter Linux) zum Abräumen der DB, Leeren der Schemas und Neu-Deployen der Datenbank.
- **`db/tests/`** — Testskripte, die die Prozeduren bzw. das Framework testen.

### Schemas unter `db/schemas/`

**`config/`** — Konfiguration der Anwendung:
- `tables/` — je Tabelle des Schemas ein Skript.
- `functions/` — gespeicherte Funktionen zum **Lesen** aus und **Schreiben** in die Config-Tabellen.
- `data/` — Skripte, die die Konfigurationsdaten in den Tabellen bereitstellen (befüllen).

**`etl/`** — generische Prozeduren, die **dynamische SQL-Statements** erstellen und ausführen. Fester Bestandteil des Frameworks.
- `procedures/`
- `functions/`

**`helper/`** — Hilfsfunktionen, z. B. Konvertierung von einem Datentyp in einen anderen. Prozeduren ebenfalls möglich.
- `functions/`
- `procedures/`

**`log/`** — Prozessprotokollierung (3 Ebenen) + Fehlerprotokollierung. Sechs Unterverzeichnisse; je Tabelle/Policy/Prozedur/… ein Skript:
- `tables/`
- `procedures/`
- `policies/`
- `trigger/`
- `views/`
- `data/`

### Konfiguration & Datenbank-Setup (`db/config/`, `db/database/`)

**`db/config/` — zwei Config-Dateien pro Umgebung** (`local`, `dev`, `int`, `test`, `prod`):
- `<env>.env` — Shell-Variablen für die Bash-Skripte (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_NAME`, App-Version).
- `<env>.env.sql` — psql-`\set`-Variablen (`database_name`, `database_owner`, Schema-/Rollen-/User-Namen). Per `\i` in die SQL-Skripte geladen.

**`db/database/` — einmaliges Setup** (DB, Extensions, Schemas, Rollen):
- Nummerierte Skripte (`01.create.database.sql` … `08.grant…`, `99.drop.database.sql`); Reihenfolge deterministisch.
- Rollenmodell: DB-Owner (DDL) → Schema-Owner → RW-Gruppenrolle (NOLOGIN, DML) → Service-Account (LOGIN, erbt RW).
- Passwörter: lokal hardcodiert (`pw`), auf Hetzner per `-v` aus Env-Variablen (`DB_OWNER_PASSWORD` etc.) — **nie** in Dateien.
- **Bootstrap-Skripte sind drop-and-recreate** (nicht idempotent): erst `drop.sh`, dann `create.sh`. Das gilt nur für DB/Rollen-Setup — die **Schema-Objekte** (`db/schemas/…`) bleiben idempotent (`IF NOT EXISTS`/`CREATE OR REPLACE`).
- Bash-Runner liegen unter `db/scripts/` (`create.sh`, `drop.sh`, `deploy.sh`), Aufruf mit Env-Argument, Default `local`.

> **Adaptionsbedarf:** `db/config/` und `db/database/` stammen aus dem App-Parallelprojekt und bilden noch **ein** Schema `app` (Namensschema `di_dev_*`, Keycloak-Reste, Nummernlücken `03`/`06`). Für das Framework müssen sie auf die **vier Schemas** `config`, `etl`, `helper`, `log` umgebaut werden.

### `example/` — Vorlagen / Referenz (nicht Teil des Deployments)

- **`example/sample05.db/`** — bestehendes **SQL-Server-Framework**, dient als Basis für die Portierung. Relevante Ordner: `LOG/`, `CONFIG/`, `dbo/`, plus anwendungsspezifische Schemas (`E1`, `L1`, `T1`, `T2`), `Security/`, `_other/` (u. a. `styleguide.header.sql`, `step-by-step.sql`).
- **`example/di2-db/`** — (Platzhalter/Zielbeispiel).

## Konventionen aus der SQL-Server-Vorlage

- Objekt-Namenspräfixe: `sp` = Stored Procedure, `fn` = Function, `v` = View, `SEQ` = Sequence.
- Header-/Style-Vorgaben siehe `example/sample05.db/_other/styleguide.header.sql`.
- Bei der Portierung: SQL-Server-Konstrukte nach PostgreSQL 17 übersetzen (z. B. `IDENTITY`/Sequenzen, `NVARCHAR`→`text`, `MERGE`/`OUTPUT`, T-SQL → PL/pgSQL, schema-qualifizierte Objektnamen statt `dbo.`).

## Developer-Workflow (Skills)

Slash-aufrufbare Skills unter `.claude/skills/` bilden den Workflow ab (Reihenfolge):

1. `/requirements` — Feature-Spec aus Idee (`docs/specs/`).
2. `/architecture` — technische Architektur, PM-freundlich, ohne Code (`docs/architecture/`). Kein Component Tree (→ `/ux`).
3. `/backend` — Tabellen, Prozeduren, Funktionen bauen.
4. `/frontend` — Views.
5. `/qa` — Akzeptanzkriterien, Edge Cases, Regression + feature-scoped Security.
6. `/review` — Code-Review der Diff gegen Spec & Konventionen; Approve / Request Changes (vor erstem Deploy).
7. `/deploy <env>` — Deploy auf Hetzner via GitHub Actions. `dev` nach `/review`; `int`/`test` als Promotion; `prod` nur nach grünem `/security`.
8. `/security` — projektweiter Audit (`docs/security-audit.md`). Pflicht-Gate vor `/deploy prod`, nach größeren Änderungen, quartalsweise — nicht pro Feature.

Quer dazu (jederzeit triggerbar, kein fester Schritt):
- `/bug` — Bug erfassen/aktualisieren/schließen; eine Datei pro Bug unter `docs/bug/` (+ `docs/bug/INDEX.md`, Archiv `docs/bug/archive/YYYY-QN/`). Fix-Routing: Views → `/frontend`, sonst → `/backend`.

## Konventions-Regeln (Rules)

- **`.claude/rules/sql.md` ist der maßgebliche *übergreifende* SQL-Styleguide** (Naming `sp_`/`fn_`/`tf_`/`tr_`/`vw_`, snake_case/singular, PK `id bigserial`, Timestamps `_on`, tabellarisches Alignment, Dollar-Quoting, File Naming & Numbering, generische Layout-Prinzipien: Datei-Gerüst, Banner-Blöcke, SELECT/DML, CTE). **Bei Widerspruch gilt sql.md.**
- **Objekt-spezifische Regeln sind in die Objekt-Dateien ausgelagert** (dort maßgeblich für ihren Objekttyp; für Übergreifendes verweisen sie zurück auf `sql.md`):
  - `tables.md` — CREATE-TABLE-Layout, Foreign Keys / Unique, Comments (Tabelle & Spalten), INSERT/Seed, Datentypen, Audit-Spalten, RLS.
  - `procedures.md` — Parameter-Reihenfolge (ID zuerst), Parameter-Dokumentation, Body-Struktur „Get name / Check parameter / Workload", `format()`-Fehlermeldungen, Single Responsibility, Procedure-Skelett.
  - `functions.md` — Function-Skelett, Volatilität; geteilte Body-Regeln via Verweis auf `procedures.md`.
  - `trigger.md` — Trigger-/Trigger-Function-Skelett, `TG_OP`-Logik.
  - `views.md`, `policies.md` — View- bzw. RLS-Policy-Konventionen.
- `/backend`, `/frontend`, `/review` lesen **`sql.md` (übergreifend) plus die jeweilige Objekt-Datei** (Tabellen → `tables.md`, Prozeduren → `procedures.md`, Funktionen → `functions.md`, Trigger → `trigger.md`, Views → `views.md`, Policies → `policies.md`).

`sql.md` wurde von der diapp **auf dieses Framework angepasst** (framework-nativ):
- **Schema-Variablen:** Beispiele nutzen `:schema_name` als Platzhalter für die konkreten `:schema_config`/`:schema_etl`/`:schema_helper`/`:schema_log`; Owner `:schema_owner`.
- **Datei-Layout:** Tabellen-Gruppen-Nummerierung (`NNN.<objekt>.sql`, eine Tabelle = eine Nummer, je Schema) **innerhalb** der Unterordner pro Objekttyp; Ladereihenfolge über den Deploy-Runner (`db/scripts/`), kein zentrales `deploy.sql`.
- **FK-Abschnitt** generisch (kein `app.account`/Keycloak); `created_by`/`modified_by`-Audit nur wo fachlich sinnvoll.
- **`lc_messages` (BUG-0337):** Grant an `:role_rw` nur nötig, falls die Logging-Konvention `SET LOCAL lc_messages` genutzt wird (kommentierter Hinweis in `db/database/08.create.role.rw.sql`).

## Dokumentation (`features/` + `docs/`)

- `features/di2f-XXXX-<slug>.md` — Feature-Specs (erzeugt durch `/requirements`); ID-Schema `di2f-XXXX`. Liegt im **Projekt-Root** (nicht unter `docs/`).
- `features/INDEX.md` — zentrales Feature-Tracking (aktiv) + „Nächste freie ID"; deployte Features wandern via `git mv` nach `features/archive/` und in `features/archive/INDEX.md` (gepflegt von `/requirements` und `/deploy prod`).
- `docs/product-requirements.md` — **PRD**: Vision, Target Users, Core-Features-Roadmap (P0/P1/P2 mit Status & Implementierung), Success Metrics, Infrastructure, Constraints, Non-Goals.
- `docs/architecture/<feature>.md` — Architektur-Dokumente (`/architecture`).
- `docs/security-audit.md` — Befunde aus `/security`; Gate für `/deploy prod`.
- `docs/bug/` — Bug-Tracking (`/bug`): `INDEX.md`, offene Bugs flach, geschlossene unter `archive/YYYY-QN/`.

## Status / offene Punkte

- Workflow-Definition liegt vor und ist als Skills + Rules abgebildet.
- PRD angelegt (`docs/product-requirements.md`) mit framework-spezifischer Roadmap.
- **Offen:** Markdown-Doku „Neues Visual-Studio-Projekt + Developer-Workflow" (kann jetzt erstellt werden).
- **Offen:** Klärung, ob ein `agents/`-Ordner (Backend-/Frontend-/QA-Agent) aus dem Parallelprojekt übernommen wird.
- **Offen:** Portierung des SQL-Server-Frameworks (`example/sample05.db/`) nach PostgreSQL 17.
