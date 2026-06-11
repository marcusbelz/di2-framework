# di2f-0006: DB-Versionierung (`config.db_version` Historie)

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** config

## Problem / Motivation
Beim Deployen des Frameworks ist heute nicht nachvollziehbar, **welcher Stand** in einer
Umgebung läuft. Es existiert lediglich ein Tabellen-Stub `config.db_version` mit zwei vagen
Spalten (`release_version`, `internal_version`) — ohne Feature-Spec, ohne Befüllungs-Mechanismus,
ohne klare Bedeutung der zweiten Spalte.

Gebraucht wird eine **nachvollziehbare DB-Versionierung**: zu jedem Deploy soll festgehalten
werden, welche **menschlich lesbare Release-Version** (major.minor.build) mit welchem **Git-Stand**
(Commit, ggf. Tag) **wann** und in **welcher Umgebung** ausgerollt wurde. Das ergibt einen
Audit-Trail über alle Deploys hinweg und beantwortet jederzeit „welche Version läuft hier?".

## User Stories
- Als **DB-Entwickler** möchte ich nach einem Deploy die aktuell ausgerollte DB-Version sehen,
  damit ich weiß, welcher Stand in `dev`/`int`/`test`/`prod` aktiv ist.
- Als **DB-Entwickler** möchte ich die komplette Deploy-Historie einer Umgebung einsehen, damit ich
  nachvollziehen kann, wann welche Version mit welchem Commit ausgerollt wurde.
- Als **Support/Betrieb** möchte ich einer laufenden Umgebung den exakten **Git-Commit** zuordnen,
  damit ich einen gemeldeten Fehler auf den richtigen Quellstand beziehen kann.
- Als **Release-Verantwortlicher** möchte ich beim Deploy die Version programmatisch in die DB
  schreiben (eine Prozedur), damit der Eintrag konsistent und ohne manuelles SQL entsteht.
- Als **Auswertender** möchte ich Versionen korrekt vergleichen können (`1.4.10` ist neuer als
  `1.4.9`), damit „neuer/älter"-Abfragen verlässlich sind.

## Scope
- **Tabelle `config.db_version`** (ersetzt den bestehenden Stub) — **Historientabelle**, eine Zeile
  je Deploy, mit:
  - Surrogat-PK `id bigserial` (`release_version` ist **nicht** mehr PK → mehrere Zeilen mit gleicher
    Version erlaubt: Re-Deploys, gleiche Version in mehreren Umgebungen).
  - Versionsnummer **getrennt**: `major`, `minor`, `build` (je `int`) — sortier-/vergleichbar.
  - Lesbare Darstellung `release_version` (z. B. `1.4.207`), abgeleitet aus major/minor/build.
  - Provenance: `git_commit` (Commit-SHA des Stands), `git_tag` (Git-Release-Tag, optional).
  - Deploy-Metadaten: `deployed_on` (Zeitpunkt), `environment` (`dev`/`int`/`test`/`prod`).
  - Audit-Spalten gemäß Framework-Konvention.
- **Prozedur** (Vorschlag `config.sp_ins_db_version`) — legt bei Aufruf **genau eine** neue
  Historienzeile mit den übergebenen Werten an und gibt die neue `id` zurück. Der Deploy-Runner soll
  sie künftig am Ende eines Deploys mit Werten aus `<env>.env` (App-Version) + CI-Variablen
  (Commit/Tag/Environment) aufrufen.

## Nicht-Ziele
- **Keine Verdrahtung in die Bash-Deploy-Runner** (`db/scripts/`) in diesem Feature — der tatsächliche
  Aufruf der Prozedur am Deploy-Ende ist ein **Folgeschritt** (eigenes Feature / `/architecture`).
  Hier entstehen nur Tabelle + Prozedur als aufrufbare Bausteine.
- **Keine eigene `internal_version`-Spalte** mehr — die ursprünglich angedachte vage zweite Spalte
  wird bewusst durch die expliziten `git_commit` / `git_tag` ersetzt.
- **Kein Versions-Bumping / keine Release-Logik** — major/minor/build werden außerhalb gepflegt
  (App-Version in `<env>.env`); das Framework schreibt nur, was ihm übergeben wird.
- **Keine View** in diesem Feature (eine `vw_db_version_current` o. Ä. kann später folgen — der
  neueste Eintrag ist über `max(id)` / `deployed_on` trivial ermittelbar).
- Kein Rollback-/Downgrade-Handling.

## Datenmodell-Auswirkung
- **`config.db_version` wird neu modelliert** (Stub wird gedroppt + neu erstellt; er ist nicht
  befüllt, keine Datenmigration nötig). Tabellen-Gruppennummer bleibt **003** (alle Objekte des
  Features tragen `003.`).
- Spalten (final in `/architecture` / `/backend`):

  | Spalte            | Typ            | Null | Bemerkung                                             |
  |-------------------|----------------|------|-------------------------------------------------------|
  | `id`              | `bigserial`    | NOT  | Surrogat-PK (`pk_db_version`)                         |
  | `major`           | `int`          | NOT  | Hauptversion                                          |
  | `minor`           | `int`          | NOT  | Nebenversion                                          |
  | `build`           | `int`          | NOT  | Build-Nummer                                          |
  | `release_version` | `varchar`      | NOT  | Lesbare Darstellung „major.minor.build" (abgeleitet)  |
  | `git_commit`      | `varchar`      | NOT  | Commit-SHA des deployten Stands                       |
  | `git_tag`         | `varchar`      | NULL | Git-Release-Tag (nicht jeder Deploy ist getaggt)      |
  | `environment`     | `varchar`      | NOT  | `dev`/`int`/`test`/`prod` (CHECK-Constraint)          |
  | `deployed_on`     | `timestamptz`  | NOT  | Deploy-Zeitpunkt (`DEFAULT now()`)                    |
  | `created_on`      | `timestamptz`  | NOT  | Audit (`DEFAULT now()`)                               |
  | `created_by`      | `varchar(100)` | NOT  | Audit                                                 |

  > Offene Detailfrage für `/architecture`/`/backend`: ob `release_version` eine **generierte
  > Spalte** (`GENERATED ALWAYS AS`) oder von der Prozedur gesetzt wird; ob `build` ggf. `bigint`
  > sein muss (falls an CI-Run-Nummern gekoppelt). `modified_*`-Spalten nur, falls Zeilen je
  > aktualisiert werden — bei reiner Append-Historie nicht nötig.

## Protokollierungs-Integration
- Die Prozedur läuft zur **Deploy-Zeit**, außerhalb eines fachlichen Prozesskontexts. Deshalb
  **bewusst minimale** Logging-Integration: kein zwingender Execution/Component/Trace-Aufbau
  (die Log-Kette ist hier nicht der richtige Hebel — der Deploy selbst ist das „Ereignis").
- **Fehlerpfad:** ungültige/fehlende Pflichtwerte → `RAISE EXCEPTION` (deterministischer Abbruch
  des Deploys), **nicht** stiller `NULL`-Insert und **kein** `log.error` (Datenfehler-Tabelle ist
  für fachliche Datenfehler gedacht, nicht für Deploy-Bookkeeping).
- Finale Entscheidung über das Logging-Maß trifft `/architecture`.

## Akzeptanzkriterien
1. Tabelle `config.db_version` existiert mit den oben gelisteten Spalten; PK ist der Surrogat-Key
   `id bigserial` (`CONSTRAINT pk_db_version`), **nicht** `release_version`.
2. `major`, `minor`, `build`, `release_version`, `git_commit`, `environment`, `deployed_on` sind
   `NOT NULL`; `git_tag` ist nullable.
3. `release_version` ist konsistent zu `major`/`minor`/`build` (für `1`/`4`/`207` ergibt sich
   `'1.4.207'`).
4. `environment` lässt nur `dev`/`int`/`test`/`prod` zu (CHECK-Constraint); ein anderer Wert wird
   abgelehnt.
5. Die Prozedur (z. B. `sp_ins_db_version`) legt bei Aufruf **genau eine** neue Zeile mit den
   übergebenen Werten an und gibt die neue `id` zurück (`INOUT p_id bigint`).
6. Aufruf der Prozedur ohne einen Pflichtwert (z. B. ohne `major` oder ohne `git_commit`) schlägt
   mit aussagekräftiger Fehlermeldung fehl (`RAISE EXCEPTION`), ohne Teil-Zeile zu schreiben.
7. Mehrere Aufrufe erzeugen mehrere Historienzeilen; die **aktuell ausgerollte Version** ist über
   den neuesten Eintrag (`ORDER BY deployed_on DESC, id DESC` bzw. `max(id)`) ermittelbar.
8. Re-Deploy desselben Stands (gleicher `git_commit`/gleiche `release_version`) erzeugt **bewusst**
   eine weitere Historienzeile (kein `UNIQUE` auf Commit/Version).
9. Deploy-Skripte für Tabelle + Prozedur sind **idempotent** wiederholbar
   (`CREATE TABLE IF NOT EXISTS`, `CREATE OR REPLACE PROCEDURE`, FK/Constraints per
   `DROP … IF EXISTS` + `ADD`).
10. Tabelle und fachliche Spalten tragen `COMMENT ON TABLE` / `COMMENT ON COLUMN` gemäß
    `tables.md`.

## Edge Cases
- **Re-Deploy desselben Commits:** legt eine neue Zeile an (gewollt — es ist ein realer Deploy-Vorgang);
  kein `UNIQUE`-Konflikt.
- **Ungetaggter Deploy:** `git_tag` ist `NULL` — gültig, kein Fehler.
- **Versionsvergleich `1.4.10` vs. `1.4.9`:** muss über die int-Spalten erfolgen (`10 > 9`), nicht
  über String-Vergleich von `release_version` (dort wäre `'1.4.10' < '1.4.9'`).
- **Gleiche Version in mehreren Umgebungen:** identische `release_version`/`git_commit` in `dev` und
  `int` ist erlaubt; `environment` unterscheidet die Einträge.
- **Fehlende App-Version aus `<env>.env`:** die Prozedur/der Aufrufer reagiert definiert (Fehler statt
  `NULL`-/Leer-Zeile) — siehe Akzeptanzkriterium 6.
- **Sehr schnelle aufeinanderfolgende Deploys (gleicher `deployed_on`-Sekundenwert):** `id` dient als
  eindeutiger Tie-Breaker für „neueste Zeile".
- **Sehr hohe Build-Nummer:** `int` deckt bis ~2,1 Mrd. ab; falls `build` an CI-Run-Nummern o. Ä.
  gekoppelt wird, in `/backend` ggf. `bigint` wählen.

## Abhängigkeiten
- **Requires:** `config`-Schema-Setup (Schema `config` + Rollen/Owner) muss vorhanden sein.
- **Verwandt (kein harter Requires):** Deploy-Runner (`db/scripts/`, di2f-0003) und
  GitHub-Actions-Deployment (di2f-0004) liefern später die Werte (App-Version, Commit, Tag,
  Environment) und rufen die Prozedur auf — **diese Verdrahtung ist Folgeschritt**, nicht Teil von
  di2f-0006.
