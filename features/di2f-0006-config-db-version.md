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

---

## Tech Design (Solution Architect)

### Views nötig: **Nein**
Das Feature ist rein schreibend (Tabelle + eine Insert-Prozedur). Die „aktuell ausgerollte Version"
ist der jeweils neueste Historieneintrag und ohne View per einfacher Abfrage ermittelbar. Eine
Komfort-View (`vw_db_version_current`) bleibt eine **mögliche spätere** Ergänzung (Non-Goal hier).
→ Nach `/backend` ist **kein** `/frontend` nötig.

### A) Objekt-Landschaft
```
- config.db_version          — Historientabelle: eine Zeile je Deploy (Version + Git-Stand + Umgebung)
- config.sp_ins_db_version   — Prozedur: legt eine neue Historienzeile an, gibt die neue id zurück
```
Beide tragen die Tabellen-Gruppennummer **003** (`003.db_version.sql` existiert bereits als Stub und
wird ersetzt; die Prozedur wird `003.sp_ins_db_version.sql`). Kein Trigger, keine Funktion, keine
View, kein `etl`-Dynamic-SQL.

### B) Datenmodell (Klartext)
Jeder **Deploy** erzeugt genau einen Eintrag in `config.db_version`. Ein Eintrag hält:
- eine **eindeutige laufende ID** (Surrogat-Schlüssel; macht jeden Deploy-Eintrag eindeutig, auch bei
  gleicher Version);
- die **Versionsnummer in drei Zahlen**: `major`, `minor`, `build` — getrennt gespeichert, damit
  „neuer/älter" rechnerisch korrekt ist;
- die **lesbare Versionsdarstellung** (`release_version`, z. B. `1.4.207`) — wird von der Datenbank
  **automatisch** aus den drei Zahlen gebildet (siehe Tech-Entscheidung 1), kann also nie abweichen;
- den **Git-Stand**: `git_commit` (Commit-SHA, Pflicht) und `git_tag` (Release-Tag, optional/leer);
- die **Umgebung** (`environment`: `dev`/`int`/`test`/`prod`, auf diese vier Werte beschränkt);
- den **Deploy-Zeitpunkt** (`deployed_on`).

Gespeichert in: `config.db_version`. **Append-only** — Einträge werden nur angelegt, nie geändert
oder gelöscht; daher keine `modified_*`-Spalten und kein Update-Trigger.

### C) Schnittstelle (Zweck, nicht Code)
```
- config.sp_ins_db_version(  id  [out],
                             major, minor, build,
                             git_commit, git_tag,
                             environment )
       — validiert die Pflichtwerte, legt EINE neue Historienzeile an und gibt die
         vergebene id an den Aufrufer zurück.
```
- Reihenfolge gemäß Konvention: **Identifier zuerst** (`id` als `INOUT`, Rückgabe des neuen
  Schlüssels), danach die beschreibenden Felder.
- `git_tag` darf leer sein; alle übrigen Felder sind Pflicht — fehlt einer, bricht die Prozedur mit
  klarer Meldung ab (kein Teil-Insert).
- `deployed_on` wird **nicht** übergeben, sondern beim Insert automatisch auf „jetzt" gesetzt.
- Baugleich zum bestehenden, bewusst **schlanken** Muster von `config.sp_ins_process`
  (kein `lc_messages`/`PG_CONTEXT`, fester Komponenten-Name, `RETURNING id`,
  `format()`-Fehlermeldungen).

### D) Datenfluss & Protokollierung
1. Die **Release-Version** (`major.minor.build`) wird außerhalb gepflegt — als App-Version in
   `db/config/<env>.env` (existiert bereits) und beim Release hochgezählt.
2. Der **Deploy** (GitHub Actions) kennt den **Commit-SHA**, ggf. den **Git-Tag** und die
   **Zielumgebung**.
3. **Am Ende eines erfolgreichen Deploys** ruft der Runner `config.sp_ins_db_version(…)` mit diesen
   Werten auf → eine neue Historienzeile entsteht.
4. **Abfrage:** der neueste Eintrag (höchste `id` / jüngstes `deployed_on`) = die aktuell in dieser
   Umgebung laufende Version; alle Zeilen zusammen = die Deploy-Historie.

**Protokollierungs-Integration bewusst minimal:** Die Prozedur läuft zur Deploy-Zeit, außerhalb eines
fachlichen Prozesslaufs — daher **keine** Execution/Component/Trace-Kette und **kein** `log.error`.
Fehler (fehlende Pflichtwerte) führen zu einem harten Abbruch des Deploys (`RAISE EXCEPTION`), nicht zu
einer stillen oder unvollständigen Zeile.

> **Abgrenzung:** Schritt 3 — das **tatsächliche Aufrufen** der Prozedur aus `db/scripts/` bzw. der
> GitHub-Actions-Workflow, der Commit/Tag/Umgebung durchreicht — ist **Folgeschritt** (eigenes
> Feature). di2f-0006 liefert nur die **aufrufbaren Bausteine** (Tabelle + Prozedur).

### E) Tech-Entscheidungen (begründet)
1. **`release_version` wird von der Datenbank automatisch berechnet** (generierte Spalte aus
   `major`/`minor`/`build`), statt sie separat zu übergeben.
   *Warum:* Die lesbare Darstellung kann dadurch **nie** von den drei Zahlen abweichen — eine
   Inkonsistenz (z. B. Zahlen `1/4/207`, Text aber `1.4.206`) ist technisch ausgeschlossen, und der
   Aufrufer muss die Darstellung nicht selbst zusammenbauen. *(Löst die offene Frage aus der Spec.)*
2. **`major`/`minor`/`build` als ganze Zahlen** (nicht als ein Text „1.4.207").
   *Warum:* Nur so ist „welche Version ist neuer?" rechnerisch korrekt — als Text wäre `1.4.10`
   fälschlich „kleiner" als `1.4.9`. `build` als normale Ganzzahl genügt (Reichweite ~2,1 Mrd.); erst
   falls `build` später an fortlaufende CI-Lauf-Nummern gekoppelt würde, wäre ein größerer Zahlentyp
   nötig — aktuell **nicht**. *(Löst die zweite offene Frage aus der Spec: `int`, nicht `bigint`.)*
3. **Historie statt Einzelzeile** (Surrogat-ID als Schlüssel, kein eindeutiger Zwang auf
   Version/Commit).
   *Warum:* Der Wert liegt im Audit-Trail — jeder Deploy (auch ein Re-Deploy desselben Stands oder
   dieselbe Version in mehreren Umgebungen) ist ein eigener, nachvollziehbarer Vorgang.
4. **Keine generischen Framework-Audit-Spalten (`created_on`/`created_by`)** — Abweichung von der
   `tables.md`-Konvention.
   *Warum:* `deployed_on` **ist** hier der fachliche Zeitstempel und würde `created_on` nur
   duplizieren; ein Akteur (`created_by`) wurde nicht gefordert. Die bestehende `config.configuration`
   trägt ebenfalls keine Audit-Spalten — die Abweichung ist also präzedenzkonform. *(Falls „wer hat
   deployt?" später gewünscht ist, lässt sich eine `deployed_by`-Spalte ergänzen.)*
5. **Schlanke Prozedur ohne Komponenten-Protokollierung**, analog `sp_ins_process`.
   *Warum:* Konsistenz mit dem etablierten `config`-Muster; das volle Logging gehört zu fachlichen
   Prozessläufen, nicht zu Deploy-Bookkeeping.

### F) Abhängigkeiten
- **Requires:** `config`-Schema + Rollen/Owner (`db/database/`).
- **Verwandt (Folgeschritt, kein harter Requires):** Deploy-Runner (di2f-0003) und GitHub-Actions
  (di2f-0004) für die spätere Verdrahtung (Werte liefern + Prozedur aufrufen).
- **Keine** PostgreSQL-Extensions, **kein** `etl`-Dynamic-SQL, **keine** RLS (Tabelle nicht sensibel).

---

## Implementierung (Backend)

**Objekte** (beide Tabellen-Gruppennummer `003`):
- `db/schemas/config/tables/003.db_version.sql` — Tabelle (ersetzt den Stub).
- `db/schemas/config/procedures/003.sp_ins_db_version.sql` — Insert-Prozedur.

**Implementierte Schnittstelle:**
```
config.sp_ins_db_version(
   INOUT p_id           bigint,   -- Rückgabe der neuen Historien-id
   IN    p_major        int,      -- Pflicht, >= 0
   IN    p_minor        int,      -- Pflicht, >= 0
   IN    p_build        int,      -- Pflicht, >= 0
   IN    p_git_commit   varchar,  -- Pflicht, nicht leer
   IN    p_git_tag      varchar,  -- optional; leer/Whitespace -> NULL
   IN    p_environment  varchar   -- Pflicht, einer von dev/int/test/prod
)
```
- Legt **eine** neue Zeile an, gibt die `id` über `p_id` zurück; `release_version` und `deployed_on`
  werden automatisch gesetzt (generierte Spalte bzw. `DEFAULT now()`).
- **Fehlerverhalten:** fehlende/ungültige Pflichtwerte → `RAISE EXCEPTION` mit `ERRCODE
  'invalid_parameter_value'`, kein Teil-Insert. Validierungen (NULL/leer/negativ/Umgebung) liegen im
  `Check parameter`-Block; die `CHECK`-Constraints der Tabelle sind Defense-in-Depth.
- **Schlank** wie `config.sp_ins_process` (kein `lc_messages`/`PG_CONTEXT`, kein Component-Logging).

**Smoke-Test:** gegen PostgreSQL 17 (Docker) verifiziert — Happy Path (`release_version` generiert),
leerer Tag → NULL, alle Fehlerpfade (NULL/negativ/leerer Commit/ungültige Umgebung), Versionsvergleich
`1.4.9 < 1.4.10` über die int-Spalten, CHECK-Constraint blockt direkten Bad-Insert, generierte Spalte
nicht direkt beschreibbar, **Re-Deploy idempotent**.

**Idempotenz-Hinweis (Struktur-Änderung):** Die Tabelle wechselt den PK (`release_version` →
Surrogat-`id`) und Spalten gegenüber dem alten Stub. `CREATE TABLE IF NOT EXISTS` allein migriert eine
**bereits vorhandene** Stub-Tabelle nicht — auf einer Umgebung mit altem Stub muss vor dem Deploy
`db/scripts/clean.sh config <env>` laufen (droppt die Objekte, Schema bleibt), dann `deploy.sh`. Bei
frischer DB (Bootstrap drop+create) entfällt das.

**Folgeschritt (nicht Teil von di2f-0006):** Der Deploy-Runner liefert bereits `:db_version`
(`APP_VERSION_MAJOR/MINOR/BUILD` → `1.0.0`) und `:git_sha` als psql-Variablen
([deploy.sh](../db/scripts/deploy.sh)), reicht aber **noch nicht** die gesplitteten Versionsteile,
`git_tag` oder den Umgebungsnamen durch und ruft die Prozedur nicht auf. Die Verdrahtung (Data-Skript
`config/data/003.db_version.sql` o. Ä. + Runner-Variablen) ist ein eigenes Feature.
