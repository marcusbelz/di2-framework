# di2f-0003: Bash-Runner für DB-Setup, Deploy & Teardown der 4 Schemas

- **Priorität:** P0
- **Status:** Geplant
- **Schema(s):** — (DB-Tooling; betrifft alle vier Schemas `config`/`etl`/`helper`/`log` über die Lade-Reihenfolge, legt aber kein neues DB-Objekt an)

## Problem / Motivation
`db/scripts/` ist aktuell leer. Das Framework braucht — **analog zum Parallelprojekt `di2`** — Bash-Runner (Ausführung unter Linux), die das einmalige Datenbank-/Rollen-/User-Setup, das idempotente Deployen der Schema-Objekte und das Abräumen (Schema-Objekte bzw. ganze DB) reproduzierbar und ohne manuelle Klick-Schritte erledigen.

Im Parallelprojekt gibt es nur **ein** Schema `app`; hier sind es die **vier** Schemas `config`, `etl`, `helper`, `log`. Die im Parallelprojekt vorhandene **Schema-Auswahl** als Skript-Parameter soll erhalten bleiben und um eine Option `all` (alle vier in abhängigkeitssicherer Reihenfolge) erweitert werden.

## User Stories
- Als **Entwickler** möchte ich mit `bash db/scripts/create.sh <env>` das einmalige DB-/Rollen-/User-Setup einer Umgebung anstoßen, damit die Datenbank reproduzierbar aufgebaut wird.
- Als **Entwickler/Deployer** möchte ich mit `bash db/scripts/deploy.sh <schema> <env>` die Objekte eines Schemas (oder `all`) idempotent ausrollen, damit Re-Deploys ohne manuelle Eingriffe funktionieren.
- Als **Entwickler** möchte ich mit `bash db/scripts/clean.sh <schema> <env>` die Objekte eines Schemas (oder `all`) entfernen, ohne die ganze Datenbank zu verlieren, damit ich gezielt neu aufsetzen kann.
- Als **Entwickler** möchte ich mit `bash db/scripts/drop.sh <env>` die komplette Datenbank einer Umgebung abräumen, damit ich einen sauberen Neustart machen kann.
- Als **Sicherheitsbewusster** möchte ich, dass Passwörter nie in Dateien stehen (außer `local`), sondern per Umgebungsvariable/Prompt kommen, damit keine Secrets ins Repo gelangen.

## Scope
Vier Bash-Skripte unter `db/scripts/` (Vorlage: `di2/db/scripts/`), angepasst auf die vier Schemas und das Rollenmodell des Frameworks (DB-Owner `di2_<env>_owner`, Schema-Owner `di2_<env>_fw`, RW-Rolle `di2_<env>_rw`, Service-Account `di2_<env>_sa`):

- **`create.sh <env>`** — einmaliges Bootstrap: ruft `db/database/01…10`-Skripte (DB, Extensions, vier Schemas, Rollen, User) in deterministischer Reihenfolge; verbindet als `postgres`-Superuser.
- **`deploy.sh <schema> <env>`** — deployt Schema-Objekte aus `db/schemas/<schema>/` (Tables → Policies → Functions → Procedures → Triggers → Views → Data). `<schema>` ∈ {`config`, `etl`, `helper`, `log`, `all`}; bei `all` alle vier in fester, **abhängigkeitssicherer** Reihenfolge.
- **`clean.sh <schema> <env>`** — entfernt Schema-Objekte (ohne DB-Drop). `<schema>` analog; bei `all` in **umgekehrter** Reihenfolge.
- **`drop.sh <env>`** — droppt die gesamte Datenbank (`db/database/99.drop.database.sql`).

Gemeinsame Mechanik (aus `di2` übernommen):
- `<env>` ∈ {`local`, `dev`, `int`, `test`, `prod`}; Default `local`. Unbekannte Umgebung → Fehler/Abbruch.
- Lädt `db/config/<env>.env` (Shell-Variablen) und übergibt `db/config/<env>.env.sql` (`\set`-Variablen) an `psql`.
- Passwörter: `local` hardcodiert (`pw`); sonst über Umgebungsvariablen (`DB_ADMIN_PASSWORD_POSTGRES`, `DB_OWNER_PASSWORD`, `DB_FW_PASSWORD`, `DB_SA_PASSWORD`) bzw. interaktiver Prompt — **nie** in Dateien.
- `set -e` (Abbruch bei Fehler); sprechende `echo`-Statusausgaben.

## Nicht-Ziele
- **Keine** GitHub-Actions-Workflows — die sind di2f-0004.
- **Keine** Secret-Anlage/-Verwaltung — Teil von di2f-0004.
- **Keine** neuen DB-Objekte (Tabellen/Prozeduren/Views) — nur Orchestrierung vorhandener Skripte.
- **Keine** Datenmigration — Bootstrap ist drop-and-recreate (gemäß CLAUDE.md); Schema-Objekte bleiben idempotent.
- **Keine** Windows-/PowerShell-Variante — Ausführung unter Linux/Bash.

## Datenmodell-Auswirkung
Keine. Die Skripte führen bestehende DDL/DML aus, definieren aber selbst keine Objekte.

## Protokollierungs-Integration
Keine direkte (Execution/Component/Trace/Error unberührt). Die Skripte deployen u. a. die `log`-Objekte, sind aber selbst kein Laufzeit-Pfad der Protokollierung.

## Akzeptanzkriterien
1. `bash db/scripts/create.sh <env>` baut für die angegebene Umgebung DB, Extensions, die vier Schemas, Rollen und User auf (ruft `db/database/01…10` in fester Reihenfolge).
2. `bash db/scripts/deploy.sh <schema> <env>` deployt für `<schema>` ∈ {config, etl, helper, log} die Objekte dieses Schemas in der Sektionsreihenfolge (Tables → … → Data).
3. `bash db/scripts/deploy.sh all <env>` deployt alle vier Schemas in einer festen, abhängigkeitssicheren Reihenfolge.
4. `bash db/scripts/clean.sh <schema> <env>` entfernt die Objekte des gewählten Schemas, ohne die Datenbank zu droppen; `clean.sh all <env>` räumt alle vier in umgekehrter Reihenfolge.
5. `bash db/scripts/drop.sh <env>` droppt die komplette Datenbank der Umgebung.
6. Jedes Skript akzeptiert `<env>` aus {local, dev, int, test, prod}; eine unbekannte Umgebung führt zu Fehlermeldung und Exit ≠ 0 ohne DB-Änderung.
7. Ein unbekannter `<schema>`-Wert (nicht config/etl/helper/log/all) führt zu Fehlermeldung und Exit ≠ 0.
8. Alle Skripte laden `db/config/<env>.env` und übergeben `db/config/<env>.env.sql` an `psql`.
9. Für Nicht-`local`-Umgebungen werden Passwörter aus Umgebungsvariablen gelesen bzw. abgefragt; kein Passwort steht im Skript oder in einer versionierten Datei (außer `local`).
10. Re-Run von `deploy.sh` auf einer bereits deployten DB ist idempotent (kein Fehler durch `IF NOT EXISTS` / `CREATE OR REPLACE`).

## Edge Cases
- **Unbekannte Umgebung** (`bash deploy.sh log foo`) → klare Fehlermeldung, kein `psql`-Aufruf.
- **Unbekanntes Schema** (`bash deploy.sh xyz dev`) → klare Fehlermeldung, kein Deploy.
- **`deploy.sh` vor `create.sh`** (Schemas/Rollen fehlen) → bricht mit verständlichem Fehler ab, kein Teil-Deploy ohne Owner.
- **Fehlende Passwort-Variable** in nicht-`local` (z. B. `DB_FW_PASSWORD` leer) → Prompt bzw. expliziter Abbruch statt stillem Weiterlaufen.
- **`clean.sh all`** muss die Schemas in **umgekehrter** Abhängigkeitsreihenfolge räumen, damit FK-/Objekt-Abhängigkeiten nicht brechen.
- **`local`-Umgebung** nutzt hardcodierte Passwörter (`pw`) — bewusst, nur lokal.
- **Wiederholtes `drop.sh`** auf bereits gedroppter DB → idempotent/tolerant (kein harter Abbruch, der Folgeschritte blockiert).

## Abhängigkeiten
- Setzt voraus: bestehende `db/database/01…10` + `99.drop.database.sql` und `db/config/<env>.env(.sql)` (bereits vorhanden).
- Relates: PRD-Roadmap „Deploy-/Teardown-Skripte (db/scripts/, Bash/Linux)" (P0).
- Wird genutzt von: di2f-0004 (Workflows rufen diese Skripte über SSH auf).
- Vorlage: `c:/sandbox/github/di2/db/scripts/{create,deploy,clean,drop}.sh`.
