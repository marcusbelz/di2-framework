# di2f-0007: Deploy schreibt db_version-Zeile (deploy.sh + Workflows verdrahten)

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** config (nutzt `config.sp_ins_db_version` / `config.db_version` — **keine neuen
  DB-Objekte**; Umsetzung ist Runner-/CI-Verdrahtung, vgl. di2f-0002/0003/0004/0005)

## Problem / Motivation
di2f-0006 hat die **Bausteine** der DB-Versionierung gebaut — die Tabelle `config.db_version` und die
Prozedur `config.sp_ins_db_version` — aber **bewusst nicht** den Aufruf beim Deploy verdrahtet (war
dort Non-Goal). Folge: Nach einem Deploy bleibt `config.db_version` **leer**; es entsteht kein
Audit-Trail, und die eigentliche Frage „welche Version läuft in dieser Umgebung?" bleibt unbeantwortet.

Dieses Feature schließt die Lücke: Am Ende eines erfolgreichen Deploys soll der Deploy-Runner
(`db/scripts/deploy.sh`) zusammen mit dem GitHub-Actions-Workflow **genau eine Historienzeile** in
`config.db_version` schreiben — mit der Release-Version (major/minor/build), dem deployten
Git-Commit, optionalem Git-Tag und der Zielumgebung. Erst damit liefert die in di2f-0006 angelegte
Tabelle ihren Zweck.

## User Stories
- Als **DB-Entwickler** möchte ich, dass jeder erfolgreiche Deploy automatisch eine Versionszeile
  schreibt, damit ich ohne manuelles SQL sehe, welcher Stand in `dev`/`int`/`test`/`prod` läuft.
- Als **Release-Verantwortlicher** möchte ich, dass Version, Commit und Umgebung **konsistent vom
  Deploy selbst** kommen, damit der Eintrag nicht von Hand gepflegt werden muss und nicht abweichen kann.
- Als **Support/Betrieb** möchte ich nach einem gemeldeten Fehler den exakten Git-Commit der
  laufenden Umgebung aus `config.db_version` ablesen, damit ich den richtigen Quellstand finde.
- Als **DevOps** möchte ich, dass ein fehlgeschlagenes Schreiben der Versionszeile den Deploy **rot**
  macht, damit keine stillen Lücken in der Deploy-Historie entstehen.

## Scope
Verdrahtung der bestehenden di2f-0006-Bausteine in den Deploy-Pfad. Betroffene **Bausteine** (Zweck;
das genaue „Wie" entscheidet `/architecture`):
- **`db/scripts/deploy.sh`** — am Ende eines **erfolgreichen `all`-Deploys** in eine
  **Nicht-`local`-Umgebung** `config.sp_ins_db_version(…)` aufrufen und dabei übergeben:
  `major`/`minor`/`build` (aus `APP_VERSION_MAJOR/MINOR/BUILD` der `<env>.env`), `git_commit` (der
  deployte `GIT_SHA`), `git_tag` (Release-Tag des Stands, falls vorhanden) und `environment` (das
  Ziel-`ENV`). `deploy.sh` kennt `GIT_SHA` und `APP_VERSION` bereits, splittet/übergibt sie aber noch
  nicht an die Prozedur.
- **`.github/workflows/db-deploy.yml`** — den **Git-Tag** des deployten Stands ermitteln und an den
  Runner durchreichen (Commit/Umgebung sind dort bereits bekannt).
- **`db/config/<env>.env`** — Quelle der Versionsteile (`APP_VERSION_*`, bereits vorhanden); ggf.
  ergänzende Variable für die Tag-Durchreichung (entscheidet `/architecture`).
- **Konsument** der bestehenden `config.db_version` + `config.sp_ins_db_version` (di2f-0006) — **kein**
  neues DB-Objekt.

## Nicht-Ziele
- **Keine Änderung an Tabelle oder Prozedur** aus di2f-0006 — die bleiben unverändert (reine Nutzung).
- **Kein Versions-Bumping / keine Release-Logik** — `major/minor/build` werden weiterhin außerhalb in
  `<env>.env` gepflegt; das Feature schreibt nur, was dort steht.
- **Kein Schreiben bei Einzelschema-Deploys** (`config`/`log`/… allein) und **kein Schreiben bei
  `local`** — siehe Akzeptanzkriterien.
- **Keine Komfort-View** (`vw_db_version_current`) — bleibt mögliche spätere Ergänzung.
- **Kein Rückschreiben/Backfill** historischer (vor diesem Feature liegender) Deploys.

## Datenmodell-Auswirkung
- **Keine.** Es werden ausschließlich **Zeilen** in die bestehende `config.db_version` eingefügt
  (append-only Historie). Keine neuen/geänderten Tabellen, Spalten oder Constraints.

## Protokollierungs-Integration
- Wie in di2f-0006 festgelegt **bewusst minimal**: kein Execution/Component/Trace-Aufbau, kein
  `log.error`. Der Deploy selbst ist das „Ereignis".
- **Fehlerpfad:** Kann die Versionszeile nicht geschrieben werden (fehlende/ungültige Werte,
  DB nicht erreichbar, Prozedur wirft `RAISE EXCEPTION`), bricht der Deploy **hart** ab (Workflow rot)
  — kein stilles Weiterlaufen, keine Teil-Zeile.

## Akzeptanzkriterien
1. Nach einem **erfolgreichen `all`-Deploy** in eine Umgebung aus `{dev, int, test, prod}` existiert
   in `config.db_version` **genau eine neue Zeile** mit den Werten dieses Deploys.
2. Die geschriebene Zeile trägt: `major`/`minor`/`build` aus `APP_VERSION_MAJOR/MINOR/BUILD` der
   `<env>.env`; `git_commit` = der deployte Commit-SHA; `environment` = die Ziel-Umgebung;
   `release_version` (generiert) konsistent zu major/minor/build; `deployed_on` ≈ Deploy-Zeitpunkt.
3. `git_tag` enthält den Release-Tag des deployten Stands, **falls vorhanden**; ist kein Tag
   vorhanden (z. B. branch-basierter dev/int-Deploy), wird `git_tag` als **NULL** geschrieben — der
   Deploy läuft trotzdem durch (untagged Deploys sind erlaubt).
4. Ein **Einzelschema-Deploy** (`schema=config`/`log`/`helper`/`etl`, nicht `all`) schreibt **keine**
   db_version-Zeile.
5. Ein **`local`-Deploy** (`env=local`) schreibt **keine** Zeile (die Umgebung `local` ist in
   `config.db_version.environment` nicht zulässig — CHECK erlaubt nur dev/int/test/prod).
6. Schlägt das Schreiben der Zeile fehl (fehlender/ungültiger Pflichtwert, leerer Commit-SHA,
   DB-Fehler), **schlägt der Deploy fehl** (Exit ≠ 0 / Workflow rot); es wird **keine Teil-Zeile**
   hinterlassen.
7. Schlägt schon der **Schema-Deploy** (eine der `db/schemas/`-Sektionen) fehl, wird **gar keine**
   db_version-Zeile geschrieben (der Aufruf erfolgt erst **nach** erfolgreichem Abschluss aller Schemas).
8. Ein **Re-Deploy desselben Stands** (gleicher Commit + Version + Umgebung) schreibt **bewusst** eine
   weitere Historienzeile (kein Skip, kein UNIQUE-Konflikt).
9. Die **aktuell ausgerollte Version** je Umgebung ist nach dem Deploy über den neuesten Eintrag
   (`environment` + `max(id)` / jüngstes `deployed_on`) ablesbar.
10. Der db_version-Schreibschritt ist **idempotent wiederholbar** im Sinne der Skript-Mechanik (ein
    erneuter Deploy-Lauf funktioniert fehlerfrei und erzeugt eine weitere Zeile — siehe AK8); er bricht
    bestehende Deploy-Funktionalität nicht (Schema-Deploy bleibt unverändert erfolgreich).

## Edge Cases
- **`local`-Deploy:** kein Schreiben (AK5) — sonst würde der `environment`-CHECK die Zeile ablehnen
  und den lokalen Deploy unnötig brechen.
- **Untagged Deploy:** `git_tag` = NULL, Deploy grün (AK3) — der Normalfall für dev/int.
- **Leerer/nicht ermittelbarer Commit-SHA:** `git_commit` ist Pflicht (NOT NULL/nicht leer) → der
  Schreibschritt schlägt fehl → Deploy rot (AK6). Kein Schreiben einer Zeile ohne Commit.
- **Fehlende/nicht-numerische `APP_VERSION_*`:** die Prozedur lehnt ab (di2f-0006-Validierung) →
  Deploy rot (AK6).
- **Schema-Deploy bricht mittendrin ab:** keine db_version-Zeile (AK7) — die Version darf nur einen
  **vollständig** ausgerollten Stand markieren.
- **Sehr schnelle aufeinanderfolgende Deploys (gleicher `deployed_on`-Sekundenwert):** `id` bleibt
  eindeutiger Tie-Breaker für „neueste Zeile" (di2f-0006-Design).
- **Gleiche Version in mehreren Umgebungen** (z. B. dev und int) ist erlaubt; `environment`
  unterscheidet die Zeilen.

## Abhängigkeiten
- **Requires:** di2f-0006 (Tabelle `config.db_version` + Prozedur `config.sp_ins_db_version`) — die
  hier genutzten Bausteine.
- **Requires:** di2f-0003 (Deploy-Runner `db/scripts/deploy.sh`) und di2f-0004 (GitHub-Actions-Deploy
  `db-deploy.yml`) — die hier erweiterten Pfade.
- **Verwandt:** di2f-0002 (Branch→Umgebung-Strategie) liefert den Umgebungskontext.

---

## Tech Design (Solution Architect)

### Views nötig: **Nein**
Reines Verdrahtungs-Feature im Deploy-Pfad — keine DB-Objekte, keine lesende Sicht. Die „aktuell
ausgerollte Version" ist (wie in di2f-0006) der neueste Eintrag in `config.db_version` und ohne View
abfragbar. → Nach `/backend` (hier: Runner/Workflow-Änderungen) ist **kein** `/frontend` nötig.

### A) Objekt-Landschaft (keine neuen DB-Objekte)
Dieses Feature führt **keine** Tabelle/Prozedur/Funktion/View ein. Es **erweitert** drei bestehende
Tooling-Bausteine und **nutzt** die di2f-0006-Bausteine:
```
- db/scripts/deploy.sh            — ruft am Ende eines erfolgreichen all-Deploys die Insert-Prozedur
                                     (genutzt, nicht geändert: config.sp_ins_db_version aus di2f-0006)
- .github/workflows/db-deploy.yml — stellt sicher, dass Git-Tags auf dem Deploy-Host verfügbar sind
- db/config/<env>.env             — liefert die Versionsteile (APP_VERSION_*, bereits vorhanden)
- config.db_version (di2f-0006)   — Zieltabelle: erhält je all-Deploy eine neue Historienzeile
```

### B) Datenmodell (Klartext)
**Unverändert.** Es entsteht kein neues Modell; es werden nur **Zeilen** in die bestehende
`config.db_version` geschrieben (append-only). Jede Zeile beschreibt — wie in di2f-0006 — einen
**vollständig ausgerollten** Stand: Version (major/minor/build → generierte `release_version`),
Git-Commit, optionaler Git-Tag, Umgebung, Zeitpunkt.

### C) Schnittstelle (Zweck, kein Code)
Es kommt **keine** neue Schnittstelle hinzu. Genutzt wird die bestehende Prozedur aus di2f-0006:
```
config.sp_ins_db_version( id[out], major, minor, build, git_commit, git_tag, environment )
   — der Deploy-Runner sammelt diese Werte und ruft die Prozedur EINMAL am Ende eines
     erfolgreichen all-Deploys auf; die Prozedur validiert und legt eine Historienzeile an.
```
Die „Schnittstelle" dieses Features ist also ein **neuer, finaler Schritt im Runner**, der die schon
vorhandenen Werte einsammelt und durchreicht — nicht ein neues DB-Objekt.

### D) Datenfluss & Protokollierung
1. **Versionsteile** kommen aus `db/config/<env>.env` (`APP_VERSION_MAJOR/MINOR/BUILD`) — `deploy.sh`
   liest sie ohnehin schon ein.
2. **Commit-SHA** kennt `deploy.sh` bereits (`GIT_SHA` = der ausgecheckte/deployte Stand).
3. **Git-Tag** wird aus dem deployten Commit ermittelt (der Release-Tag, falls der Commit getaggt
   ist; sonst „kein Tag" → NULL). Symmetrisch zur bestehenden `GIT_SHA`-Ermittlung im Runner.
4. **Umgebung** ist das `ENV`-Argument des Deploys (`dev`/`int`/`test`/`prod`).
5. **Reihenfolge & Guard:** Erst werden — wie bisher — alle Schemas ausgerollt. **Nur** wenn das
   vollständig erfolgreich war **und** `schema=all` **und** `env ≠ local` ist, macht der Runner
   **einen** abschließenden Aufruf von `config.sp_ins_db_version(…)` → genau eine neue Zeile.
6. **Abfrage:** Der neueste Eintrag je `environment` (höchste `id` / jüngstes `deployed_on`) = die
   aktuell dort laufende Version.

**Protokollierung** bleibt — wie in di2f-0006 — bewusst minimal: keine Execution/Component/Trace-Kette,
kein `log.error`. Schlägt der Schreibschritt fehl, bricht der Deploy **hart** ab (der Fehler des
finalen Aufrufs propagiert → Skript-Exit ≠ 0 → Workflow rot); es bleibt keine Teil-Zeile.

### E) Tech-Entscheidungen (für PM begründet)
1. **Aufruf im Runner am Ende — nicht als Data-Skript** (`config/data/…`).
   *Warum:* Nur so lässt sich „**nur** bei `all`", „**nach** allen Schemas erfolgreich" und „**nicht**
   bei `local`" sauber steuern. Ein Data-Skript liefe als Teil **jedes** (auch Einzelschema-)Deploys
   mitten im Ablauf und käme nicht an den Git-Tag — es könnte die Akzeptanzkriterien 4/5/7 nicht
   erfüllen. *(Löst die in di2f-0006 offen gelassene „Data-Skript o. Ä."-Frage.)*
2. **Schreiben nur für `all`-Deploys** (nicht je Einzelschema).
   *Warum:* Eine `db_version`-Zeile steht für den **Gesamtstand** der DB. Teil-Deploys (nur `config`,
   nur `log`, …) sind kein eigener „DB-Versionsstand" und würden die Historie verrauschen (AK4).
3. **`local` schreibt nicht.**
   *Warum:* `config.db_version.environment` lässt per CHECK nur `dev/int/test/prod` zu. Würde der
   lokale Deploy schreiben, bräche der CHECK den (sonst erfolgreichen) lokalen Lauf grundlos (AK5).
4. **Schreibfehler = harter Deploy-Abbruch** (statt stiller Warnung).
   *Warum:* Die Deploy-Historie soll lückenlos und verlässlich sein — ein „grüner" Deploy ohne
   Versionszeile wäre irreführend. Der finale Aufruf läuft mit Stop-on-Error; sein Fehler macht den
   Workflow rot (AK6).
5. **Git-Tag im Runner ermitteln; der Workflow stellt nur die Tags bereit.**
   *Warum:* `deploy.sh` ermittelt den Commit bereits selbst — den Tag dort daneben zu ermitteln hält
   die Logik an **einer** Stelle und funktioniert auch bei manuellen lokalen Läufen. Der
   GitHub-Workflow muss dafür lediglich sicherstellen, dass die **Tags** auf den Deploy-Host gelangen
   (der heutige Branch-Fetch holt keine Tags) — sonst bliebe `git_tag` selbst bei getaggten
   Prod-Releases fälschlich leer.
6. **Werte kommen aus dem Deploy selbst — nichts wird von Hand übergeben.**
   *Warum:* Version (`<env>.env`), Commit/Tag/Umgebung (Runner-Kontext) sind beim Deploy ohnehin
   bekannt; das ist die Kern-User-Story „konsistent ohne manuelles SQL".

### F) Abhängigkeiten
- **Requires:** di2f-0006 (Tabelle + Prozedur — werden genutzt, nicht geändert), di2f-0003
  (`deploy.sh`), di2f-0004 (`db-deploy.yml`).
- **Verwandt:** di2f-0002 (Branch→Umgebung; `dev`-Branch → dev/int, `main` → test/prod — prägt, welche
  Stände getaggt sind: Prod-Releases tragen `v1.X.0`, dev/int meist untagged → `git_tag` NULL).
- **Keine** neuen DB-Objekte, **keine** Extensions, **kein** `etl`-Dynamic-SQL, **keine** RLS.

### Hinweis für `/backend`
Die Umsetzung ist **kein** DB-`/backend`, sondern **Skript-/Workflow-Arbeit**: Erweiterung von
`db/scripts/deploy.sh` (finaler, geguardeter Prozedur-Aufruf inkl. Tag-Ermittlung) und
`.github/workflows/db-deploy.yml` (Tags auf den Host fetchen). Tests laufen über die CI
(`deploy.sh all local` zeigt, dass `local` **nicht** schreibt) und einen Deploy in eine
Nicht-`local`-Umgebung (eine Zeile entsteht).

---

## Implementierung (Backend)

**Geänderte Bausteine (keine DB-Objekte):**
- [`db/scripts/deploy.sh`](../db/scripts/deploy.sh) — nach der Schema-Schleife ein
  **geguardeter Versionsschritt**: nur bei `SCHEMA=all` **und** `ENV != local`. Er validiert
  (`GIT_SHA` nicht leer; `APP_VERSION_*` numerisch — sonst `exit 1` → Deploy rot), ermittelt den
  `GIT_TAG` über `git describe --tags --exact-match HEAD` (kein Tag → leer → Prozedur schreibt NULL)
  und ruft `config.sp_ins_db_version(NULL, major, minor, build, git_commit, git_tag, environment)`.
- [`.github/workflows/db-deploy.yml`](../.github/workflows/db-deploy.yml) — `git fetch` um
  `--tags --force` erweitert, damit `git describe` auf dem Deploy-Host den Release-Tag sieht.

**Implementierungsdetails / Fallstricke:**
- **SQL über stdin, nicht `-c`:** `psql -c` interpoliert die `:var`-Variablen **nicht**
  (Syntaxfehler `at or near ":"`). Der Aufruf läuft daher über eine stdin-Heredoc; Textwerte werden
  mit `:'…'` injection-sicher gequotet (entspricht `%L`), `:major/:minor/:build` bleiben numerisch —
  keine String-Konkatenation von Eingaben.
- **`local`-Skip** verhindert, dass der `environment`-CHECK von `config.db_version` einen lokalen
  Deploy bricht.
- **Reihenfolge:** Der Aufruf steht **nach** der Schema-Schleife → bei einem Schema-Fehler bricht
  `set -e` vorher ab, es wird keine Zeile geschrieben (AK7).

**Smoke-Test (PostgreSQL 17, Container, gegen `di2f`):**
- Voller Write-Block (`env=dev`): genau eine Zeile, `release_version` generiert, untagged →
  `git_tag` NULL. ✅
- Tag gesetzt (`tag=v2.3.4`): landet in `git_tag`. ✅
- `deploy.sh all local`: grün, **keine** db_version-Zeile (local-Skip). ✅
- Guard (`all` + non-local) und Versions-Validierung (nicht-numerisch → Abbruch) geprüft. ✅
- `shellcheck --severity=warning db/scripts/deploy.sh`: sauber. ✅

**Folgeschritt-Hinweis fürs Deployen:** Da `config.db_version` erst seit di2f-0006 die neue Struktur
hat, gilt der dort dokumentierte Stub-Vorbehalt weiter (vor dem ersten Deploy einer Umgebung mit
altem Stand: `clean all` → `deploy all`). di2f-0007 ändert daran nichts — es fügt nur den
Versionsschritt hinzu.

---

## QA Test Results

**Getestet:** 2026-06-12 · **Tester:** `/qa` · **Verdict:** ✅ Production-Ready (keine Critical/High/Medium/Low-Bugs)

**Testaufbau:** PostgreSQL 17 (Container `di2f_dev_postgres`). Für ein faithful e2e wurde eine echte
**Nicht-`local`-Umgebung `int`** im Container via `create.sh int` gebootstrappt und nach dem Test mit
`drop.sh int` rückstandslos entfernt. Da der Postgres-Container **kein git** enthält (auf dem echten
Hetzner-Host löst git auf — siehe di2f-0006-Deploy-Log `git e78208f…`), wurde für die git-Ermittlung
ein **temporärer git-Shim** (`rev-parse`/`describe`) gesetzt und danach entfernt. Echte Exit-Codes
wurden ohne Pipe gemessen (Pipe maskiert sonst den Exit-Code).

### Akzeptanzkriterien (gegen das echte `deploy.sh`)

| AK | Inhalt | Ergebnis | Beleg |
|----|--------|----------|-------|
| 1 | erfolgreicher `all`-Deploy → genau eine Zeile | ✅ | `deploy.sh all int` → `REAL_EXIT=0`, +1 Zeile |
| 2 | Werte korrekt (major/minor/build, commit, env, `release_version`, `deployed_on`) | ✅ | Zeile: `1/0/0`, `release_version=1.0.0`, `git_commit=<sha>`, `environment=int`, `deployed_on` gesetzt |
| 3 | `git_tag` = Tag falls vorhanden, sonst NULL (untagged läuft durch) | ✅ | untagged → `git_tag` NULL; Shim-Tag `v9.9.9` → landet in `git_tag` |
| 4 | Einzelschema-Deploy schreibt **keine** Zeile | ✅ | `deploy.sh config int` → Zeilen 3→3 |
| 5 | `local`-Deploy schreibt **keine** Zeile | ✅ | `deploy.sh all local` → `di2f.db_version` bleibt 0 |
| 6 | Schreibfehler → Deploy rot, keine Teil-Zeile | ✅ | leerer `GIT_SHA` → `REAL_EXIT=1`, Zeilen 4→4 |
| 7 | Schema-Deploy-Fehler → gar keine Zeile | ✅ | strukturell: Versionsschritt steht **nach** der Schema-Schleife unter `set -e` → ein Schema-Fehler bricht vorher ab (real bezeugt durch den di2f-0006-Stub-Vorfall: Schema-Fehler → kein Schreiben) |
| 8 | Re-Deploy desselben Stands → weitere Zeile | ✅ | zweiter `deploy.sh all int` → Zeile id=2 (kein UNIQUE-Konflikt) |
| 9 | aktuelle Version = neueste Zeile je `environment` | ✅ | `max(id)` = jüngster Eintrag, korrekt |
| 10 | Versionsschritt idempotent wiederholbar, bricht Deploy nicht | ✅ | mehrere Läufe fehlerfrei (+1 je Lauf), Schema-Deploy unverändert erfolgreich |

### Edge Cases (alle ✅)
- **Untagged** (Normalfall dev/int): `git_tag` NULL, Deploy grün.
- **Getaggt**: Tag landet in `git_tag`.
- **Leerer/nicht ermittelbarer Commit-SHA**: harter Abbruch (`exit 1`), keine Zeile.
- **Nicht-numerische `APP_VERSION_*`**: Bash-Guard `exit 1` (in Backend-Smoke isoliert geprüft).
- **`local`** vs. **Einzelschema**: beide schreiben nicht (zwei getrennte Guard-Zweige).

### Feature-spezifische Security-Checks
- **Injection:** Der CALL nutzt `psql`-Quoting `:'sha'`/`:'tag'`/`:'env'` (= `%L`) für Textwerte,
  `:major/:minor/:build` numerisch — **keine** String-Konkatenation. Werte stammen ohnehin aus
  kontrollierten Quellen (`<env>.env`, git, ENV-Arg). ✅
- **SECURITY DEFINER:** keine neue Funktion; die genutzte Prozedur ist SECURITY INVOKER (di2f-0006). ✅
- **Rechte:** `deploy.sh` verbindet als Schema-Owner `di2_<env>_fw` (Eigentümer der Objekte) — die
  legitime Deploy-Identität, kein zusätzliches `GRANT`. ✅
- **Secrets/sensible Daten:** `git_commit`/`git_tag` sind keine Secrets; `DB_FW_PASSWORD` kommt aus
  GitHub-Secrets und wird **nicht** geloggt; die `>>> db_version: recording …`-Zeile enthält nur
  Version/Commit/Tag/Env. ✅

### Regression
- `deploy.sh all local` weiterhin grün; der bestehende Schema-Deploy-Pfad ist **unverändert** (der
  neue Block hängt **hinter** der Schema-Schleife). di2f-0006-Bausteine (`config.db_version` +
  `config.sp_ins_db_version`) werden nur genutzt, nicht verändert. ✅

### Kandidaten für nächsten `/security`-Run
- **Trust-Auth-Annahme im lokalen Container** (nur Test-Setup, nicht im Repo) — irrelevant für den
  echten Deploy; nicht im Scope.
- Übernahme aus di2f-0006: Config-Default-Privileges greifen nur bei Owner-Deploy — hier **bestätigt
  unkritisch**, da `deploy.sh` per Design als `…_fw`-Owner verbindet.

### Hinweis zu permanenten Tests
Der Write-Pfad lässt sich in der lokalen-only-CI (`deploy.sh all local` → schreibt bewusst nicht)
nicht automatisiert abdecken; er wurde **manuell e2e** gegen eine gebootstrappte `int`-Umgebung
verifiziert (Befehle oben dokumentiert). Die CI deckt weiterhin Idempotenz + `shellcheck` ab.

---

## Code Review

**Reviewer:** `/review` · **Datum:** 2026-06-12 · **Range:** Backend-Commit `82fab90`
(`db/scripts/deploy.sh`, `.github/workflows/db-deploy.yml`) · **Verdict:** ✅ **Approve**
(0 Blocker, 0 Major, 2 Minor)

### Spec ↔ Code (Akzeptanzkriterien im Diff lokalisiert)
| AK | Umsetzung im Diff (`db/scripts/deploy.sh`) |
|----|---------------------------------------------|
| 1 | Versionsblock **nach** der Schema-Schleife; schreibt eine Zeile via `CALL config.sp_ins_db_version` |
| 2 | `:major/:minor/:build` aus `APP_VERSION_*`, `:'sha'`=`GIT_SHA`, `:'env'`=`ENV` |
| 3 | `GIT_TAG` via `git describe --tags --exact-match` → leer ⇒ Prozedur schreibt NULL; `db-deploy.yml`: `git fetch --tags` |
| 4 | Guard `[ "$SCHEMA" = "all" ]` |
| 5 | Guard `[ "$ENV" != "local" ]` |
| 6 | leerer `GIT_SHA` / nicht-numerische `APP_VERSION_*` → `exit 1`; psql unter `ON_ERROR_STOP`+`set -e` |
| 7 | Block steht **hinter** dem `done` der Schema-Schleife → `set -e` bricht bei Schema-Fehler vorher ab |
| 8 | kein Skip-/UNIQUE-Pfad → jeder Lauf schreibt |

Datei-Scope passt exakt zur Spec (`deploy.sh` + `db-deploy.yml`), keine Fremddateien, keine
ungenannten Nebeneffekte; der bestehende Schema-Deploy-Pfad bleibt unverändert (rein additiv).

### Conventions & Qualität
- **Injection-sicher:** Textwerte über `:'sha'`/`:'tag'`/`:'env'` gequotet (= `%L`), Zahlen numerisch —
  **keine** String-Konkatenation (sql.md-Regel für Dynamic SQL eingehalten, obwohl hier nur ein
  statischer `CALL`). ✅
- **stdin-Heredoc statt `-c`:** korrekt (nur so interpoliert psql `:var`) und im Kommentar begründet. ✅
- **Schema-qualifiziert** (`config.sp_ins_db_version`), nichts in `public`, kein `SECURITY DEFINER`
  (keine neue Funktion). ✅
- **Fehlerbehandlung:** explizite, aussagekräftige Meldungen + `exit 1`; `GIT_TAG="$(… || echo '')"`
  verhindert, dass ein fehlender Tag unter `set -e` den Deploy bricht. ✅
- **Idempotenz/Determinismus:** Guards und Validierung deterministisch; Re-Run schreibt bewusst eine
  weitere Zeile (AK8). `shellcheck --severity=warning` sauber. ✅
- **Kommentar-Block** dokumentiert Guard, Werte, Fehlerpropagation und den `-c`-Fallstrick. ✅

### Security am Diff
Keine Secrets im Code (`DB_FW_PASSWORD` aus Env/GitHub-Secrets, nicht geloggt); `git_commit`/`git_tag`
sind keine Secrets; die `>>> db_version: recording …`-Logzeile enthält nur Version/Commit/Tag/Env. ✅

### Findings

**Blocker (0):** — **Major (0):** —

**Minor (2, beide optional) — ✅ behoben vor Deploy:**
1. **Fehlermeldungen nach stdout statt stderr** — [deploy.sh](../db/scripts/deploy.sh): **behoben** —
   **alle** `deploy.sh`-Fehler/Usage nach `>&2` geroutet (inkl. der bestehenden Usage-/
   `unknown environment`-/`DB_FW_PASSWORD`-Meldungen), Datei jetzt durchgängig konsistent.
   Verifiziert: `deploy.sh bogus local` → stdout leer, exit 1; `shellcheck` weiterhin sauber.
2. **`--force` beim Tag-Fetch** — [db-deploy.yml](../.github/workflows/db-deploy.yml): **behoben** —
   `--force` entfernt (`git fetch --tags origin <ref>`), Kommentar angepasst: ein verschobener
   Release-Tag soll laut auffallen statt still übernommen zu werden.

### Hinweise (kein Finding)
- **ENV-Werte** werden in `deploy.sh` nicht explizit auf `{dev,int,test,prod}` eingeschränkt — aktuell
  unkritisch: es existieren nur die fünf bekannten `*.env`-Dateien (sonst bricht `deploy.sh` bei der
  Datei-Prüfung ab), `local` wird übersprungen, und ein sonstiger Wert würde am `environment`-CHECK
  der Prozedur scheitern (Defense-in-Depth → Deploy rot, AK6).
- **Permanente Tests:** Der Write-Pfad ist in der local-only-CI nicht abbildbar (dokumentiert in der
  QA-Sektion); Abdeckung via manuellem e2e + CI-`shellcheck`/Idempotenz. Akzeptabel.

### Empfehlung
**Approve** — sauberer, rein additiver Diff; alle AKs im Code belegt; injection-sicher; `shellcheck`
grün. Die zwei Minors sind optionale Nits (einer davon ein pre-existing Projekt-Stil). Nächster
Schritt: `/deploy dev` (mit dem für `db_version` weiter geltenden Stub-Vorbehalt: `clean all` →
`deploy all`).

---

## Deployment

| Env | Datum | Branch | Commit | Status |
|-----|-------|--------|--------|--------|
| dev | 2026-06-12 | `dev` | `8b58b83` | ✅ ausgerollt (erste echte `db_version`-Zeile geschrieben) |
| int | 2026-06-12 | `dev` | `8b58b83` | ✅ ausgerollt |

- **Erster Live-Beweis:** Mit diesem Deploy entsteht in `dev`/`int` automatisch die erste
  `config.db_version`-Zeile (`release_version=1.0.0`, `git_commit=<deploy-SHA>`, `git_tag` NULL —
  branch-basiert/ungetaggt, `environment=dev`/`int`).
- **Versionsquelle:** `major/minor/build` stammen aus `db/config/<env>.env` (`APP_VERSION_*`, aktuell
  `1.0.0`); manuell zu pflegen (kein Auto-Bumping). `git_commit`/`git_tag` kommen automatisch aus dem
  deployten git-Stand.
- **Verbleibend:** `test` (Pre-Prod) und `prod` ausstehend. Dort liegt `config.db_version` noch als
  alter Stub → vor dem Deploy `clean all` → `deploy all` (di2f-0006-Stub-Vorbehalt). `prod` zusätzlich
  erst nach grünem `/security`-Gate; für `prod` den Release-Commit taggen (`v1.X.0`), damit `git_tag`
  gefüllt wird.
