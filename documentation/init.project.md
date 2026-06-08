# Projekt-Initialisierung — Protokoll (Nachweis Neuentwicklung)

> **Zweck dieses Dokuments:** Nachweis, dass das **di2-framework** vollständig **neu** aufgebaut
> wurde. Es protokolliert chronologisch die Entstehung des Projekts (Entscheidungen,
> erstellte Artefakte, verwendete Vorlagen) in einem frisch initialisierten Git-Repository.

## Rahmendaten

| Feld | Wert |
|------|------|
| Repository | `c:\sandbox\github\di2-framework` |
| Ausgangslage | Leeres Git-Repo auf Branch `main`, **0 Commits, 0 Dateien** |
| Zeitraum | 2026-06-08 – 2026-06-09 |
| Zielplattform | PostgreSQL 17 (PL/pgSQL; PL/Python nur wo nötig) |
| Arbeitssprache | Deutsch |
| Beteiligte | marcus (marcus.belz@gmx.de) · Claude Code (Assistent) |

## Projektzweck (laut Auftrag)

Ein wiederverwendbares **PostgreSQL-Framework** aus Tabellen, Prozeduren und Funktionen für:
- **Prozessprotokollierung auf 3 Ebenen:** `Execution` (Prozessebene), `Component`
  (Komponenten-/Prozedur-/Python-Funktions-Ebene), `Trace` (detaillierteste Ebene; Insert beim
  Start, Update mit Status bei Erfolg/Fehler).
- **Fehlerprotokollierung** (`Error`-Tabelle für Datenfehler).
- **Konfiguration** der einbindenden Anwendung (`config`-Schema).

Grundlage/Vorlage: ein bestehendes **SQL-Server-Framework** (abgelegt unter `example/sample05.db/`),
das nach PostgreSQL 17 **portiert und erweitert** wird.

## Verwendete Vorlagen / Referenzen (transparent)

Die Neuentwicklung nutzte folgende, klar abgegrenzte Quellen als **Vorlage** (kein 1:1-Kopieren;
jeweils adaptiert):
- `example/sample05.db/` — bestehendes SQL-Server-Framework als fachliche Basis der Portierung.
- Paralleles Projekt `c:\sandbox\github\di2\` — Workflow-Definition, Skill-Struktur und
  Konfigurations-/Setup-Skripte als Strukturvorlage. Alle übernommenen Teile wurden auf dieses
  reine DB-Framework umgeschrieben (App-/UI-/Auth-Bezüge entfernt).

## Chronologie

### 1 · Initialisierung & Rahmen (2026-06-08)
- `/init` ausgeführt; festgestellt: Repository ist vollständig leer (keine Commits/Dateien).
- Projektziele geklärt: (a) Developer-Workflow-/VS-Projekt-Dokumentation, (b) PostgreSQL-Framework.
- Entscheidungen: Zielversion **PostgreSQL 17**; Reihenfolge „Workflow-Doku zuerst";
  Quellmaterial wird vom Auftraggeber ins Repo gelegt.

### 2 · Verzeichnisstruktur & CLAUDE.md (2026-06-08)
- Verzeichnisstruktur dokumentiert: `db/{database,schemas,scripts,tests}`, Schemas
  `config`, `etl`, `helper`, `log` mit ihren Unterordnern.
- `CLAUDE.md` angelegt (Projektzweck, Struktur, Konventionen, Schema-Mapping SQL Server → PG).
- Korrektur: unterste Protokollierungsebene heißt **`Trace`** (nicht „Trades").

### 3 · Developer-Workflow als Skills + Rules (2026-06-08)
- 8 slash-aufrufbare Skills unter `.claude/skills/` erstellt: `requirements`, `architecture`,
  `backend`, `frontend` (= Views), `qa`, `review`, `deploy`, `security` — inkl. Gates
  (`/review` vor erstem Deploy; dev→int/test-Promotion; prod nur bei grünem `/security`).
- 6 Konventions-Rules unter `.claude/rules/`: `tables`, `procedures`, `functions`, `views`,
  `policies`, `trigger` (PostgreSQL-17-/PL-pgSQL-Templates).

### 4 · Product Requirements Document (2026-06-08)
- `docs/product-requirements.md` angelegt: Vision, Target Users, Core-Features-Roadmap
  (P0/P1/P2), Success Metrics, Infrastructure, Constraints, Non-Goals — inhaltlich auf das
  Framework gemünzt. Feature-ID-Schema festgelegt: `di2f-XXXX` unter `docs/features/`.

### 5 · Bug-Tracking (2026-06-08)
- `/bug`-Skill aus dem Parallelprojekt übernommen und adaptiert (Verzeichnis `docs/bug/`,
  ohne `/ux`/`/keycloak`, Fix-Routing Views→`/frontend` / sonst→`/backend`, Präfix `di2f-`).
- `docs/bug/INDEX.md` initialisiert.

### 6 · Skills auf Basis des Parallelprojekts vertieft (2026-06-08)
- Die 8 Skills auf die Tiefe der Parallel-Skills gehoben (Scope Boundary, Before Starting,
  Workflow, Context Recovery, Bug-Fix-Modus, Checkliste, Handoff, Git Commit) und vollständig
  auf das DB-Framework adaptiert (kein React/Next/shadcn/Zod; „Frontend" = Views).
- Bewusst nicht übernommen: `ux`, `di2-design`, `keycloak`, `check-updates` (App-spezifisch).

### 7 · Konfiguration & Datenbank-Setup adaptiert (2026-06-09)
- `db/config/` (env-Paare je Umgebung) und `db/database/` (Setup-Skripte) aus dem
  Parallelprojekt übernommen und vom **App-Schema `app`** auf die **vier Framework-Schemas**
  umgebaut.
- Rollenmodell festgelegt: **ein Framework-Schema-Owner + eine RW-Rolle + ein Service-Account**
  (`di2_<env>_owner` / `di2_<env>_fw` / `di2_<env>_rw` / `di2_<env>_sa`), DB-Name `di2_<env>`.
- Keycloak-/`auth`-Reste entfernt, Nummerierung bereinigt (`01`–`10`, `99`), `public` gehärtet.

### 8 · Dieses Protokoll (2026-06-09)
- Verzeichnis `documentation/` + diese Datei `init.project.md` als Nachweis der Neuentwicklung
  angelegt.

### 9 · Initialer Commit (2026-06-09)
- Erster Commit im bis dahin commit-freien Repository — Baseline des neu entwickelten Frameworks
  (alle bis hier erstellten Artefakte auf Branch `main`). `.gitignore` ergänzt (Office-Sperrdateien).

### 10 · SQL-Styleguide integriert (2026-06-09)
- `.claude/rules/sql.md` (maßgeblicher SQL-Styleguide aus dem Parallelprojekt) als verbindliche
  Grundlage gesetzt. Die sechs Objekt-Rules (`tables`/`procedures`/`functions`/`views`/`policies`/
  `trigger`) verweisen nun darauf und ergänzen nur framework-spezifische Punkte; kollidierende
  Platzhalter-Vorgaben (Naming/Layout) wurden entfernt.
- Skills `backend`, `frontend`, `review` lesen zuerst `sql.md`.
- CLAUDE.md um die App→Framework-Anpassungen zu `sql.md` ergänzt (Schema-Variablen, nicht
  anwendbare Abschnitte).
- Festgelegt: Die **Tabellen-Gruppen-Nummerierung** aus `sql.md` (`NNN.<objekt>.sql`, eine Tabelle
  = eine Nummer, je Schema) wird übernommen — **innerhalb** der Unterordner pro Objekttyp; in den
  6 Objekt-Rules in den `Ablage`-Zeilen verankert. Ladereihenfolge über den Deploy-Runner.

### 11 · sql.md framework-nativ angepasst (2026-06-09)
- `sql.md` von der diapp auf das Framework umgestellt: Schema-Variablen `:schema_app_*` → `:schema_name`
  (Platzhalter) / `:schema_owner`; Abschnitt „Foreign Keys to `app.account`" durch generischen
  FK-Abschnitt ersetzt; „File Naming & Numbering" auf Unterordner-Layout + Deploy-Runner umgeschrieben;
  BUG-0337-Pfad auf `08.create.role.rw.sql` korrigiert; JOIN-/PK-Beispiele auf Framework-Bezug
  (`log`-Schema, generischer External-Identifier) umgestellt; `diapp-XXXX`-Banner → `di2f-XXXX`.
  Verifiziert: keine `app.*`/Keycloak/`deploy.sql`-Reste mehr.

## Erstellte Artefakte (Stand 2026-06-09)

```
CLAUDE.md
.gitignore
.claude/skills/{requirements,architecture,backend,frontend,qa,review,deploy,security,bug}/SKILL.md
.claude/rules/sql.md  (maßgeblicher SQL-Styleguide)
.claude/rules/{tables,procedures,functions,views,policies,trigger}.md
docs/product-requirements.md
docs/bug/INDEX.md
documentation/init.project.md
db/config/{local,dev,int,test,prod}.env
db/config/{local,dev,int,test,prod}.env.sql
db/config/README.md
db/database/01.create.database.sql
db/database/02.create.extension.sql
db/database/03.create.user.fw.sql
db/database/04.create.schema.config.sql
db/database/05.create.schema.etl.sql
db/database/06.create.schema.helper.sql
db/database/07.create.schema.log.sql
db/database/08.create.role.rw.sql
db/database/09.create.user.sa.sql
db/database/10.grant.role.sa.sql
db/database/99.drop.database.sql
db/database/README.md
db/schemas/{config,etl,helper,log}/...        (Verzeichnisgerüst; Objekte noch zu erstellen)
db/scripts/                                    (Bash-Runner noch zu erstellen)
db/tests/                                      (Testskripte noch zu erstellen)
example/sample05.db/...                        (SQL-Server-Vorlage, nicht Teil des Deployments)
```

## Offene Punkte (Stand 2026-06-09)

- Bash-Runner `db/scripts/{create,drop,deploy}.sh` (Env laden, Passwörter via `-v`).
- Portierung der Framework-Objekte (`db/schemas/...`) aus der SQL-Server-Vorlage.
- VS-Projekt-/Developer-Workflow-Dokumentation.
- Klärung des `agents/`-Ordners aus dem Parallelprojekt.

---

*Dieses Protokoll ist ein Schnappschuss des Initialisierungsverlaufs und kann bei weiteren
Meilensteinen fortgeschrieben werden.*
