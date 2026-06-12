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
