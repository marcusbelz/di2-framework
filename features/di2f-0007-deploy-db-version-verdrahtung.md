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
