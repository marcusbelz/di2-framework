# Product Requirements Document — di2-framework

## Vision
Ein wiederverwendbares **PostgreSQL-Framework** (Tabellen, Prozeduren, Funktionen), das **Prozessprotokollierung, Fehlerprotokollierung und Konfiguration** für daten- und ETL-getriebene Anwendungen standardisiert. Anwendungen binden das Framework ein, statt Logging-, Fehler- und Konfigurationslogik jedes Mal neu zu bauen.

Kern ist eine **Protokollierung auf drei Ebenen**:
- **Execution** (Prozessebene) — ein Eintrag pro Prozessausführung.
- **Component** (Komponentenebene) — ein Datensatz pro Ausführung einer Prozedur oder Python-Funktion; wird nach Erfolg/Fehler aktualisiert.
- **Trace** (detaillierteste Ebene) — Insert beim Start, Update mit Status nach Erfolg/Fehler.

Dazu kommen eine **Error**-Tabelle für Datenfehler und ein **config**-Schema für die Konfiguration der einbindenden Anwendung. Das Framework wird aus einem bestehenden **SQL-Server-Framework** (`example/sample05.db/`) nach **PostgreSQL 17** portiert und erweitert.

Ziel: konsistente, nachvollziehbare und wiederverwendbare Logging-/Monitoring-/Konfigurations-Infrastruktur über Projekte hinweg.

## Target Users
Interne Datenbank-, BI- und ETL-Entwickler (kleine Teams, 2–5 Personen), die PostgreSQL-basierte Datenprozesse bauen. Schmerzpunkte: jede Anwendung erfindet Logging, Fehlerbehandlung und Konfiguration neu; uneinheitliche Protokollierung erschwert Monitoring und Fehlersuche. Das Framework liefert dafür einheitliche, getestete Bausteine.

## Core Features (Roadmap)
Priorisierung **P0/P1/P2**. Feature-IDs (`di2f-XXXX`) werden vergeben, sobald per `/requirements` eine Spec unter `features/` entsteht.

| Priority | Feature | Status | Implementierung |
|----------|---------|--------|-----------------|
| P0 (MVP) | Datenbank-, Schema- & Rollen-Setup (`db/database/`) | Geplant | — |
| P0 (MVP) | Schema `log` — Tabellen `Execution`, `Component`, `Trace`, `Error` | Geplant | — |
| P0 (MVP) | Prozessprotokollierung `Execution` (Insert/Update) | Geplant | — |
| P0 (MVP) | Komponentenprotokollierung `Component` (Insert/Update inkl. Erfolg/Fehler/Warnung) | Geplant | — |
| P0 (MVP) | Trace-Protokollierung (Insert beim Start, Update mit Status) | Geplant | — |
| P0 (MVP) | Fehlerprotokollierung `Error` (Datenfehler) | Geplant | — |
| P0 (MVP) | Schema `config` — `Configuration`-Tabelle + Lese-/Schreibfunktionen | Geplant | — |
| P0 (MVP) | Deploy-/Teardown-Skripte (`db/scripts/`, Bash/Linux) | Deployed | [di2f-0003](../features/archive/di2f-0003-bash-runner-deploy-teardown.md) |
| P1 | Schema `etl` — generische Dynamic-SQL-Prozeduren | Geplant | — |
| P1 | Schema `helper` — String-/Prädikat-Funktionen (starts_with, ends_with, is_null_or_empty, split) | Deployed | [di2f-0008](../features/archive/di2f-0008-helper-string-funktionen.md) |
| P1 | Schema `helper` — Konvertierungsfunktionen (convert_bit, convert_date/datetime/datetime2) | Deployed | [di2f-0009](../features/archive/di2f-0009-helper-konvertierungs-funktionen.md) |
| P1 | Konfigurations-Stammdaten (`config/data/`) | Geplant | — |
| P1 | Log-Views — Monitoring/Auswertung (Dauer, Fehler, Status) | Geplant | — |
| — | ~~RLS-Policies (Schema `log`)~~ — **entfällt** (Single-Tenant-Entscheid 2026-06-12: keine Row-Isolation nötig; Rollenrechte bereits im Bootstrap `08.create.role.rw.sql`) | Entfällt | — |
| P1 | Audit-Trigger (Setzen von Audit-Spalten) | Geplant | — |
| P1 | Finalisierung `config.process` (Umzug aus log, CRUD, Seed, Test) | Deployed | [di2f-0001](../features/archive/di2f-0001-finalisierung-config-process.md) |
| P1 | DB-Versionierung — `config.db_version` (Deploy-Historie: Version, Commit, Tag, Env) | Deployed | [di2f-0006](../features/archive/di2f-0006-config-db-version.md) |
| P1 | Deploy schreibt db_version-Zeile (deploy.sh + Workflows verdrahten) | Deployed | [di2f-0007](../features/archive/di2f-0007-deploy-db-version-verdrahtung.md) |
| P1 | Test-Suite (`db/tests/`) | Geplant | — |
| P1 | DB-CI — Dry-Run-Deploy + Lint (GitHub Actions, Required-Gate) | Deployed | [di2f-0005](../features/archive/di2f-0005-db-ci-dry-run-deploy-lint.md) |
| P1 | GitHub-Actions-Deployment (dev / int / test / prod) | Deployed | [di2f-0004](../features/archive/di2f-0004-github-actions-db-workflows-secrets.md) |
| P1 | Git-Branch- & Deployment-Strategie (Branch→Umgebung, main-Schutz) | Deployed | [di2f-0002](../features/archive/di2f-0002-git-branch-und-deploy-strategie.md) |
| P2 | Import/Export-File-Protokollierung (`ImportFile`/`ExportFile`) | Geplant | — |
| P2 | HTML-Erfolgs-/Fehlerberichte (`spHTMLSuccess`/`spHTMLError`) | Geplant | — |
| P2 | Erweiterte Monitoring-Views & Kennzahlen | Geplant | — |
| P2 | Weitere Helper-/Konvertierungsfunktionen nach Bedarf | Geplant | — |

## Success Metrics
- Anzahl Anwendungen/Prozesse, die das Framework einbinden.
- Abdeckung: Anteil der Prozeduren/Funktionen, die über das Framework protokollieren (Ziel: ~100% der produktiven Komponenten).
- Zeit bis zur Integration der Protokollierung in einen neuen Prozess (Ziel: gering, da nur Aufrufe der Framework-Prozeduren nötig).
- Nachvollziehbarkeit: Anteil der Fehler, die über `Error`/`Trace` bis zur Ursache rückverfolgbar sind.
- Re-Deploy-Stabilität: Deployment ist idempotent und ohne manuelle Eingriffe wiederholbar.

## Infrastructure
- **Datenbank:** PostgreSQL 17, self-hosted auf **Hetzner Cloud VPS**.
- **Umgebungen:** `dev`, `int`, `test`, `prod`.
- **Deployment:** GitHub Actions → SSH → Hetzner; nutzt die Bash-Skripte unter `db/scripts/` sowie `db/database/` + `db/schemas/`.
- **Prozeduren/Funktionen:** PL/pgSQL; PL/Python (`plpython3u`) nur, wo zwingend nötig.
- **Kein Vercel, kein Supabase.**

## Constraints
- Zieldialekt ausschließlich **PostgreSQL 17 / PL/pgSQL**. Das SQL-Server-Framework dient nur als **Vorlage** (`example/sample05.db/`), nicht als Laufzeitziel.
- **Ein Skript pro Objekt**, abgelegt nach Schema/Objekttyp (siehe `CLAUDE.md`).
- Deployments sind **idempotent** (re-deploybar): `CREATE … IF NOT EXISTS` / `CREATE OR REPLACE`.
- Konventionen je Objekttyp sind verbindlich (`.claude/rules/`).
- Qualität vor Geschwindigkeit.

## Non-Goals
- **Keine Anwendungslogik und kein UI** — das Framework liefert nur Datenbank-Bausteine (die App ist ein separates Projekt, vgl. „diapp").
- **Kein anderer Ziel-Dialekt** als PostgreSQL (kein SQL Server / MySQL / Oracle als Laufzeitziel).
- **Keine Orchestrierung/Scheduling** der Prozesse — das Framework protokolliert und konfiguriert, startet aber keine Pipelines.
- **Kein automatisches Ausführen** fachlicher ETL-Strecken; das Framework stellt nur generische, wiederverwendbare Bausteine bereit.

---

Nutze `/requirements`, um für jeden Roadmap-Eintrag oben eine detaillierte Feature-Spezifikation unter `features/` zu erstellen.
