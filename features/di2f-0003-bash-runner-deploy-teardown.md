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

---

## Tech Design (Solution Architect)

> **Views nötig: Nein.** Reine Tooling-Schicht (Bash-Runner), keine DB-Objekte, kein Datenmodell. Nach Freigabe folgt die Umsetzung über `/backend` (Skripte unter `db/scripts/`); danach **kein** `/frontend`.

### A) Einordnung
di2f-0003 liefert die **vier Bash-Runner**, die vorhandene SQL-Skripte (`db/database/…` + `db/schemas/…`) in der richtigen Reihenfolge an `psql` übergeben. Sie sind das lokale Fundament; di2f-0004 ruft genau diese Runner später per SSH aus den Workflows auf. Wichtige Abweichung zur `di2`-Vorlage: di2 nutzt ein kuratiertes `deploy.sql`/`deploy.full.sql` pro Schema — das Framework verzichtet bewusst darauf (CLAUDE.md), die **Verzeichnisstruktur + Nummerierung ist die einzige Wahrheit**, und der Runner lädt daraus.

### B) Artefakt-Landschaft (flache Liste, keine Implementierung)
- `db/scripts/create.sh` — orchestriert das einmalige Bootstrap (`db/database/01…10`).
- `db/scripts/deploy.sh` — lädt die Objekte eines Schemas (oder `all`) sektionsweise.
- `db/scripts/clean.sh` — entfernt die Objekte eines Schemas (oder `all`).
- `db/scripts/drop.sh` — droppt die gesamte Datenbank (`db/database/99.drop.database.sql`).
- (Optional, falls beim Bauen nötig: ein wiederverwendbarer Grant-Schritt — siehe F/Clean.)

### C) Kern: Lade-Logik (das eigentliche „Wie viel WAS")
**Sektions-Reihenfolge innerhalb eines Schemas** (fest, runner-getrieben):
```
tables → policies → functions → procedures → trigger → views → data
```
Innerhalb jeder Sektion: Dateien nach 3-stelligem Nummern-Prefix sortiert (`001.…`, `002.…`). Nur vorhandene Sektionsordner werden geladen (helper hat z. B. kein `tables/`).

**Schema-Reihenfolge bei `all`** (eine zentrale, leicht änderbare Liste im Runner):
```
deploy:  helper → config → log → etl
clean:   etl → log → config → helper   (exakt umgekehrt)
```
Begründung: `helper` ist fundamentlos (reine Funktionen) → zuerst; `etl` integriert Logging + Helper → zuletzt; `config`/`log` liegen dazwischen. **Aktuell gibt es keine Cross-Schema-Referenzen** (per `grep` geprüft) — die Reihenfolge ist also noch nicht hart erzwungen, aber zukunftssicher gewählt. Sie liegt an **genau einer Stelle** im Runner und ist anzupassen, sobald echte schemaübergreifende Abhängigkeiten entstehen.

### D) Schnittstellen (Klartext, nur Zweck)
- `create.sh <env>` — baut DB, Extensions, 4 Schemas, Rollen, User (verbindet als `postgres`).
- `deploy.sh <schema> <env>` — rollt Objekte idempotent aus (`<schema>` = config|etl|helper|log|all).
- `clean.sh <schema> <env>` — entfernt Schema-Objekte ohne DB-Drop.
- `drop.sh <env>` — entfernt die ganze DB (verbindet als `postgres`).

Alle: `<env>` ∈ {local,dev,int,test,prod} (Default `local`); laden `db/config/<env>.env` + übergeben `<env>.env.sql` an `psql`.

### E) Verbindungs-Identitäten & Lebenszyklus
- **Bootstrap (`create.sh`, `drop.sh`)** verbindet als **`postgres`-Superuser** — legt Rollen/DB an bzw. droppt sie (braucht `DB_ADMIN_PASSWORD_POSTGRES`).
- **Objekt-Deploy/Clean (`deploy.sh`, `clean.sh`)** verbindet als **Schema-Owner `di2_<env>_fw`** (braucht `DB_FW_PASSWORD`) — so gehören erzeugte Objekte automatisch dem Framework-Owner (so vorgesehen in `db/config/<env>.env.sql`).
- Typischer Lebenszyklus: `create` (1×) → `deploy all` (wiederholbar) → bei Bedarf `clean`/`deploy` → `drop` (Reset).

### F) Tech-Entscheidungen (für PM begründet)
- **Runner lädt aus der Verzeichnisstruktur statt aus `deploy.sql`:** kein doppelt gepflegtes Change-Log, keine Drift zwischen „Wahrheit" und „Skript". Neue Objekte erscheinen automatisch, sobald die Datei mit korrektem Nummern-Prefix im richtigen Sektionsordner liegt. (Bewusste Abweichung von `di2`.)
- **`all`-Reihenfolge zentral, nicht verstreut:** eine einzige Liste bestimmt Deploy- und (gespiegelt) Clean-Reihenfolge → konsistent, an einer Stelle wartbar.
- **Least-Privilege-Verbindung:** Bootstrap als Superuser, Routine-Deploy als Schema-Owner — kein Superuser für Alltags-Deploys.
- **Idempotenz liegt in den Objekt-Skripten** (`CREATE OR REPLACE` / `IF NOT EXISTS`), nicht im Runner → Re-Deploy ist gefahrlos, der Runner bleibt dumm/robust (`set -e`).
- **Clean-Strategie (Entscheidung, am Review zu bestätigen):** Empfehlung `DROP SCHEMA <schema> CASCADE` + Schema neu anlegen + **Grants des Bootstrap-Schritts erneut anwenden**. Das ist robuster und einfacher als das Einzel-Drop jedes Objekts (Signaturen!), zieht aber einen **Grant-Reapply-Schritt** nach sich (sonst verliert `:role_rw` den Zugriff). Alternative wäre objektweises Droppen unter Erhalt der Schema-Grants — fehleranfälliger. → in `/backend` final entscheiden.

### G) Abhängigkeiten (Technik)
- Setzt die vorhandenen `db/database/01…10` + `99.drop.database.sql` und `db/config/<env>.env(.sql)` voraus.
- `deploy all` setzt voraus, dass `create.sh` bereits gelaufen ist (Schemas/Rollen existieren) — sonst klarer Abbruch.
- Linux/Bash + `psql`-Client auf der ausführenden Maschine (Workflow-Runner bzw. Hetzner).
- Wird vorausgesetzt von di2f-0004 (Workflows rufen die Runner).

---

## Backend-Umsetzung (Schnittstellen & Entscheidungen)

**Artefakte** (`db/scripts/`): `create.sh`, `deploy.sh`, `clean.sh`, `drop.sh`, `clean.schema.sql` (Helfer), `README.md`.

**CLI-Schnittstellen** (für di2f-0004-Workflows):
- `create.sh <env>` — verbindet als `postgres`; 2 psql-Schritte (01 gegen `postgres`-DB, 02–10 gegen `<DB_NAME>`).
- `deploy.sh <schema> <env>` — `<schema>` ∈ {config, etl, helper, log, **all**}; verbindet als `<DB_NAME>_fw`.
- `clean.sh <schema> <env>` — wie deploy; verbindet als `<DB_NAME>_fw`.
- `drop.sh <env>` — verbindet als `postgres`.
- Alle: `<env>` default `local`; `set -e` + `ON_ERROR_STOP=1`; Exit ≠ 0 bei unbekanntem env/schema oder fehlendem Passwort (nicht-local).

**Passwort-Mapping** (psql `-v` bzw. PGPASSWORD): `DB_ADMIN_PASSWORD_POSTGRES` (Superuser-Connect), `DB_OWNER_PASSWORD`→`database_owner_password` (01), `DB_FW_PASSWORD`→`schema_owner_password` (03) + fw-Connect, `DB_SA_PASSWORD`→`user_sa_password` (09). local → `pw`.

**Entscheidung Clean-Strategie (Verbesserung ggü. Tech-Design F):** Statt `DROP SCHEMA CASCADE` + Grant-Reapply droppt `clean.schema.sql` nur die **Objekte** im Schema (Views/Tabellen/Routinen/Sequenzen per Introspektion), das **Schema bleibt**. Weil `deploy.sh` als `fw` verbindet und `08.create.role.rw.sql` Default Privileges `FOR ROLE :schema_owner` setzt, werden neu deployte Objekte **automatisch** an `:role_rw` granted → **kein** Grant-Reapply nötig, kein BUG-0335-Äquivalent.

**Test-Stand:** Syntax (`bash -n`) ✓; Validierungspfade (unbekannt env/schema, Usage) ✓; Lade-Reihenfolge per Trockenlauf ✓.

**Live-Smoke-Test ✓ bestanden** (PostgreSQL 17.5 im isolierten `docker/`-Container `di2f_dev_postgres`, env `local`):
- `create.sh local` → DB, 4 Schemas, Rollen, User, Grants angelegt.
- `deploy.sh all local` → config (4 Tabellen) + log (7 Tabellen, `tf_set_modified`, 4 Trigger); helper/etl leer → übersprungen.
- Verifikation: `role_rw` hat **automatisch** SELECT/INSERT auf log-Tabellen (Default Privileges beim fw-Deploy greifen), Objekt-Owner = `di2_local_fw`.
- `deploy.sh all local` erneut → idempotent (exit 0).
- `clean.sh log local` → log-Objekte entfernt, **Schema `log` bleibt** bestehen.
- `deploy.sh log local` (re-deploy) → 7 Tabellen zurück, `role_rw` hat **weiterhin** INSERT-Recht → **kein Grant-Reapply nötig** (Kern-Designentscheidung bestätigt).
- `drop.sh local` → Datenbank + Rollen entfernt.

> **Setup-Hinweis (kein Bug der Runner):** Im `docker/`-Compose mountet `${GIT_REPO_PATH}:/di2` unter Windows wegen des Laufwerks-`C:` nach `/di2-framework` statt `/di2`. Die Runner sind davon unberührt (relative `SCRIPT_DIR`-Pfade). Für ein sauberes `/di2`-Ziel den Mount in `docker.di2f.yml` robuster notieren (z. B. long-syntax `type: bind`).
