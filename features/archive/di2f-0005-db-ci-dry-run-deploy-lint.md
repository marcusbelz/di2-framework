# di2f-0005: DB-CI — Dry-Run-Deploy + Lint (GitHub Actions, Required-Gate)

- **Priorität:** P1
- **Status:** Deployed
- **Schema(s):** — (CI/CD / Qualitäts-Gate; kein DB-Schema betroffen)

## Problem / Motivation
Das Repository hat keine CI, die zum Projekttyp passt. Die aus dem Parallelprojekt bekannte App-CI „Lint & Build" (Node/Next: `npm lint` + `next build`) ist hier **sinnlos** — `di2-framework` ist ein reines PostgreSQL-Framework (SQL/PL-pgSQL + Bash + YAML), es gibt nichts zu „builden" und kein JS zu linten.

Sinnvoll ist eine **DB-passende CI**, die bei jedem Push/PR (1) die Lauffähigkeit der Deploy-Kette **echt** prüft (gegen ein wegwerfbares PostgreSQL) und (2) Skript-/SQL-Qualität lintet. Damit wird genau das automatisiert verifiziert, was bei di2f-0003 lokal nur einmalig im Container ging — auf jeder Änderung. Zusätzlich soll die CI als **Pflicht-Gate** vor Merges nach `main` greifen.

## User Stories
- Als **Entwickler** möchte ich, dass bei jedem PR automatisch ein Dry-Run-Deploy gegen ein frisches PostgreSQL läuft, damit kaputte SQL-/Runner-Änderungen vor dem Merge auffallen.
- Als **Entwickler** möchte ich `*.sh`- und `*.sql`-Lint in der CI, damit Stil-/Syntaxfehler früh und konsistent erkannt werden.
- Als **Release-Verantwortlicher** möchte ich, dass ein Merge nach `main` nur bei grüner CI möglich ist, damit nichts Defektes in den Produktions-Branch gelangt.
- Als **Team** möchten wir eine CI, die zum DB-Projekttyp passt (nicht die App-„Lint & Build"), damit die Prüfungen aussagekräftig sind.

## Scope
Betroffene Artefakte (keine DB-Objekte):

- **`.github/workflows/ci.yml`** — GitHub-Actions-Workflow mit zwei Aufgabenbereichen:
  - **Dry-Run-Deploy:** ein PostgreSQL-17 als Service hochfahren, dann `db/scripts/create.sh local` + `db/scripts/deploy.sh all local` gegen diese wegwerfbare DB ausführen (validiert Bootstrap + alle vier Schemas idempotent).
  - **Lint:** `shellcheck` über `db/scripts/*.sh`; `sqlfluff` (Dialekt PostgreSQL) über `db/schemas/**/*.sql` und `db/database/*.sql`, konfiguriert passend zum Styleguide (`.claude/rules/sql.md`).
- **Trigger:** `pull_request` nach `main` (Gate) und `push` auf `dev` (frühe Rückmeldung).
- **Required-Status-Check:** Erweiterung des di2f-0002-Rulesets `protect-main` um „Require status checks to pass" mit dem CI-Check als Pflicht (Merge nach `main` nur bei grün). *(Governance-Änderung an der bereits deployten di2f-0002 — als Teil dieses Features dokumentiert; di2f-0002 wird nicht „reopened".)*
- Optional: `sqlfluff`-Konfig (`.sqlfluff`) und ggf. eine kleine `shellcheck`-Direktive, falls nötig.

## Nicht-Ziele
- **Kein** Node/Next/„Lint & Build"-CI (App-spezifisch, hier irrelevant).
- **Kein** Deploy auf echte Umgebungen (dev/int/test/prod) — das ist di2f-0004; die CI nutzt nur eine ephemere DB im Runner.
- **Keine** neuen DB-Objekte; keine Änderung an den Runnern (di2f-0003) selbst (außer Bugfixes, falls die CI welche aufdeckt → eigener Bug).
- **Kein** Auto-Merge / keine Deploy-Automatik.

## Datenmodell-Auswirkung
Keine.

## Protokollierungs-Integration
Keine direkte (die CI deployt u. a. die `log`-Objekte in eine Wegwerf-DB, ist aber selbst kein Laufzeitpfad der Protokollierung).

## Akzeptanzkriterien
1. Es existiert `.github/workflows/ci.yml`, das bei `pull_request` nach `main` **und** bei `push` auf `dev` läuft.
2. Der Workflow startet ein PostgreSQL **17** (Service) und führt erfolgreich `create.sh local` aus (DB, vier Schemas, Rollen, User).
3. Im selben Lauf führt `deploy.sh all local` erfolgreich alle vier Schemas aus; ein erneuter `deploy.sh all local` im selben Lauf bleibt fehlerfrei (Idempotenz-Check).
4. `shellcheck` prüft `db/scripts/*.sh`; ein Shell-Fehler lässt den Job fehlschlagen.
5. `sqlfluff` (Dialekt postgres) prüft die SQL-Skripte; ein Lint-Fehler lässt den Job fehlschlagen. Die Konfig ist am Styleguide `sql.md` ausgerichtet (keine Fehlalarme gegen bestehende, konventionskonforme Skripte).
6. Ein PR mit einem absichtlich kaputten SQL-/Shell-Skript führt zu einem **roten** CI-Status.
7. Das Ruleset `protect-main` verlangt den CI-Check als Status-Check; ein Merge nach `main` ist bei rotem CI **nicht** möglich.
8. Bei grüner CI ist der Merge nach `main` (nach PR) möglich.
9. Die CI benötigt **keine** Secrets (rein ephemere DB im Runner; `local`-Passwörter sind hartkodiert `pw`).

## Edge Cases
- **Kaputtes SQL** (z. B. Syntaxfehler in einer Tabelle) → Dry-Run-Deploy bricht ab, Job rot.
- **Nicht-idempotentes Skript** (z. B. fehlendes `IF NOT EXISTS`) → zweiter `deploy all` im selben Lauf schlägt fehl → Job rot.
- **`sqlfluff` zu streng** → Fehlalarme gegen konventionskonforme Skripte; Konfig muss auf `sql.md` getrimmt sein (sonst Dauer-Rot).
- **CRLF in Skripten** → würde `bash`/`psql` im Linux-Runner brechen; durch `.gitattributes` (LF) bereits abgesichert, die CI deckt Regressionen auf.
- **Required-Check-Name ändert sich** (Workflow-/Job-Umbenennung) → der im Ruleset hinterlegte Check-Name muss mitgezogen werden, sonst gated er nichts mehr.
- **Lauf aus Fork-PR** (kein Schreibzugriff) → CI muss ohne Secrets auskommen (erfüllt, AC 9).

## Abhängigkeiten
- **Requires:** di2f-0003 (die Runner `create.sh`/`deploy.sh`, die die CI aufruft).
- **Relates/Touches:** di2f-0002 (Ruleset `protect-main` wird um den Required-Status-Check erweitert).
- Unabhängig von di2f-0004 (CI nutzt keine Environments/Secrets, sondern eine ephemere DB).

---

## Tech Design (Solution Architect)

> **Views nötig: Nein.** CI/CD-Qualitäts-Gate, keine DB-Objekte, kein Datenmodell. Nach Freigabe baut `/backend` die CI-Artefakte (`.github/workflows/ci.yml` + Lint-Konfig); **kein** `/frontend`.

### A) Einordnung
di2f-0005 ist die **Qualitätssicherungs-Schicht**: eine zum DB-Projekttyp passende CI, die bei jedem PR/Push die Deploy-Kette **echt** durchspielt und die Skripte lintet. Sie baut auf **di2f-0003** (die Runner `create.sh`/`deploy.sh`) auf und erweitert das **di2f-0002**-Ruleset um einen Pflicht-Status-Check. Anders als di2f-0004 nutzt sie **keine** Environments/Secrets — nur eine wegwerfbare DB im Runner.

### B) Artefakt-Landschaft (flache Liste, keine Implementierung)
- `.github/workflows/ci.yml` — CI-Workflow mit zwei Jobs: **Dry-Run-Deploy** und **Lint**.
- `.sqlfluff` — **konservative** sqlfluff-Konfig (Dialekt postgres, `:var`-Templater, mit dem Hausstil kollidierende Stil-/Layout-Regeln deaktiviert).
- ggf. kleine **Vorverarbeitung**, die psql-Meta-Kommando-Zeilen (`\echo`/`\set`/`\i`) vor dem sqlfluff-Lauf ausklammert (sonst Parse-Fehler an quasi jeder Datei).
- optional `.shellcheckrc` (nur falls Direktiven nötig).
- **Required-Status-Check** im Ruleset `protect-main` — eine **GitHub-Repo-Einstellung** (kein Datei-Artefakt), als Teil dieses Features dokumentiert; di2f-0002 wird **nicht** „reopened".

### C) „Daten" (Klartext) — CI-Trigger & Job-Struktur
Kein DB-Datenmodell. Die relevanten „Daten" sind Trigger und Jobs:

| Element | Inhalt | Zweck |
|---------|--------|-------|
| Trigger `pull_request` → `main` | — | Pflicht-Gate vor Merge nach `main` |
| Trigger `push` → `dev` | — | frühe Rückmeldung auf dem Arbeits-Branch |
| Job **dry-run-deploy** | PostgreSQL-17-Service; `create.sh local` → `deploy.sh all local` → `deploy.sh all local` (2.×) | Bootstrap + alle 4 Schemas + Idempotenz echt verifizieren |
| Job **lint** | `shellcheck` (Bash) + `sqlfluff` schlank (SQL) | Shell-/SQL-Syntax & -Stil im konservativen Rahmen |

Beide Jobs grün ⇒ CI grün. `local`-Creds sind hartkodiert `pw` ⇒ **keine Secrets** (auch aus Fork-PRs lauffähig).

### D) Schnittstellen (Klartext, nur Zweck)
- **`ci.yml`** — ein Workflow, getriggert durch `pull_request`(→main) und `push`(→dev); zwei **unabhängige** Jobs (laufen parallel).
- **dry-run-deploy-Job** — spult die echte Bootstrap-+Deploy-Kette gegen eine ephemere DB ab; **rot** bei jedem `psql`-Fehler oder wenn der zweite `deploy all` nicht idempotent durchläuft.
- **lint-Job** — `shellcheck` über `db/scripts/*.sh` (rot bei Shell-Fehler) + `sqlfluff` über die SQL-Skripte nach Meta-Command-Vorverarbeitung (rot bei echtem SQL-Parse-Fehler; **keine** Stil-Fehlalarme dank konservativer Konfig).
- **Required-Check (Governance)** — `protect-main` verlangt den/die CI-Job(s); Merge nach `main` nur bei grün.

### E) Datenfluss & Durchsetzung
1. PR nach `main` (oder Push auf `dev`) startet `ci.yml`.
2. **dry-run-deploy:** PG-17-Service hoch → `create.sh local` (DB, 4 Schemas, Rollen, User) → `deploy.sh all local` → erneut (Idempotenz). Der `postgres`-Service läuft mit Passwort `pw`, das der Job als `DB_ADMIN_PASSWORD_POSTGRES=pw` mitgibt — sonst hinge der non-interaktive Runner am Passwort-Prompt von `create.sh`.
3. **lint:** `shellcheck` + `sqlfluff` (Meta-Zeilen vorab raus, konservativer Regelsatz).
4. Beide Jobs grün → Status-Check grün → Merge erlaubt; die Branch-Durchsetzung selbst liegt im di2f-0002-Ruleset, nicht im Workflow.

### F) Tech-Entscheidungen (für PM begründet)
- **Dry-Run-Deploy als primäres SQL-Gate (statt Linter-Akrobatik):** Der echte `psql`-Lauf gegen echtes PostgreSQL 17 ist die aussagekräftigste Prüfung — er fängt Syntax **und** Semantik (FKs, Lade-Reihenfolge, Idempotenz), was ein Stil-Linter prinzipiell nicht kann.
- **`sqlfluff` bewusst schlank** (Entscheidung im Architektur-Schritt): Hausstil (Leading-Commas/Alignment) und psql-Meta-Kommandos kollidieren mit den sqlfluff-Defaults; ein voller Hausstil-Abgleich wäre Dauerpflege. Konservativer Regelsatz + Meta-Command-Vorverarbeitung erfüllt **AC 5** (kein Fehlalarm gegen konventionskonforme Skripte) und hält die CI grün-stabil. Die SQL-Korrektheit gated der Dry-Run, nicht der Linter.
- **`shellcheck` für Bash:** De-facto-Standard, fängt typische Shell-Fallen (Quoting, `set -e`-Lücken) günstig.
- **Ephemere DB, keine Secrets:** `local`-Creds `pw`; CI läuft auch aus Fork-PRs (AC 9 + Fork-Edge-Case).
- **Idempotenz-Check im selben Lauf** (zweiter `deploy all`): erzwingt die CLAUDE.md-Idempotenzregel maschinell.
- **Required-Check als Governance am Ruleset, nicht im YAML:** Branch-Schutz gehört ins `protect-main`-Ruleset (wie di2f-0002), nicht in den Workflow — und greift erst, **nachdem** der Check einmal gelaufen ist. Reihenfolge: `ci.yml` mergen/laufen lassen → dann den Check als „required" setzen.

### G) Abhängigkeiten
- **Requires di2f-0003** — die Runner `create.sh`/`deploy.sh`, die die CI aufruft.
- **Touches di2f-0002** — Ruleset `protect-main` wird um den Required-Status-Check erweitert (manuell/guided, kein Reopen).
- `.gitattributes` (LF) ist vorhanden — die CI deckt CRLF-Regressionen auf.
- **Unabhängig von di2f-0004** (keine Environments/Secrets).
- **GitHub-Repo-Adminrechte** für die Ruleset-Änderung.

### H) Offene Build-Zeit-Punkte (in `/backend` zu fixieren)
- Konkreter **sqlfluff-Regelsatz** + Form der **Meta-Command-Vorverarbeitung** (welche Zeilen raus, welcher Templater/`param_style`).
- **Stabile Job-/Check-Namen** (der im Ruleset hinterlegte Required-Check-Name muss exakt passen — Edge Case „Check-Name ändert sich").
- `shellcheck`-Severity/eventuelle Direktiven.

---

## Backend-Umsetzung (CI-Artefakte & Entscheidungen)

**Artefakte:**
- `.github/workflows/ci.yml` — zwei Jobs, getriggert durch `pull_request`→`main` und `push`→`dev`.
- `.github/sqlfluff-lint.sh` — Lint-Helfer: sanitiert die psql-Skripte (Meta-Kommandos raus, `:vars` → Platzhalter, `::`-Cast geschützt), lintet sanitierte Kopien.
- `.sqlfluff` — schlanke sqlfluff-Konfig.
- `.shellcheckrc` — `disable=SC1090`.
- `.gitattributes` — um `.sqlfluff`/`.shellcheckrc` (LF) ergänzt.

**Job `dry-run-deploy`** (primäres SQL-Gate): `postgres:17` als Service (`POSTGRES_PASSWORD=pw`, Healthcheck), `DB_ADMIN_PASSWORD_POSTGRES=pw` (kein Secret). Schritte: psql-Client sicherstellen → `create.sh local` → `deploy.sh all local` → `deploy.sh all local` (Idempotenz).

**Job `lint`:** `shellcheck --severity=warning db/scripts/*.sh .github/*.sh` + `pipx install 'sqlfluff>=3,<4'` → `bash .github/sqlfluff-lint.sh`.

**Lint-Entscheidungen (Build-Zeit, aus Tech-Design H):**
- **sqlfluff schlank:** `exclude_rules = layout, references.keywords, capitalisation.identifiers`. Begründung empirisch ermittelt — gegen die echten Dateien feuerten nur Layout-/Stil-Regeln (LT01/02/04/05, LT12/13) plus RF04 (`version`/`state` als Bezeichner) und CP02; **null** Parse-Fehler nach Sanitierung. Damit erfüllt AC 5 (kein Fehlalarm).
- **Eine Datei vom sqlfluff-Lint ausgenommen:** `db/database/08.create.role.rw.sql` (`CREATE ROLE … CONNECTION LIMIT -1` — valides PG, aber sqlfluff-Parser-Gap). Der Skip wird **geloggt**; Korrektheit gated der Dry-Run. (Abweichung von AC 5 „db/database/*.sql": eine begründete, transparente Ausnahme.)
- **shellcheck:** `SC1090` (dynamisches `source "$CONFIG"`) projektweit aus (`.shellcheckrc`); `--severity=warning` lässt das info-level `SC2162` (`read` ohne `-r` in den Runnern) **nicht** gaten. `SC2162` ist ein optionaler Mini-Follow-up an den di2f-0003-Runnern (eigener Bug, falls gewünscht) — hier bewusst nicht angefasst.

**Required-Check (Governance, AC 7):** Job-/Check-Namen **`dry-run-deploy`** und **`lint`**. Das di2f-0002-Ruleset `protect-main` wird um diese als „Require status checks to pass" erweitert — **manuell/guided** (kein Datei-Artefakt) und **erst, nachdem `ci.yml` einmal gelaufen ist** (GitHub bietet den Check-Namen sonst nicht an).

**Test-Stand (lokal via Docker validiert, 2026-06-11):**
- `sqlfluff` (3.x) gegen die sanitierten Skripte: **grün** — 26 Dateien gelintet, 1 dokumentiert übersprungen, 0 Verstöße.
- `shellcheck --severity=warning` über Runner + Helfer: **grün** (Exit 0).
- **Dry-Run gegen `postgres:17`:** `create.sh local` + `deploy.sh all local` + erneut (Idempotenz) **erfolgreich**; `has_table_privilege('di2f_rw','log.process','SELECT')` = `t` (Default-Privileges-Grant greift).
- **Live-Lauf in GitHub Actions** ✅ (2026-06-11): erster Push→`dev`-Lauf grün — beide Jobs (`dry-run-deploy`, `lint`) erfolgreich.

---

## QA Test Results (QA Engineer)

**Testumgebung:** lokal via Docker (`postgres:17`, `sqlfluff` 3.x, `koalaman/shellcheck`) gegen den **committeten** Stand (`git archive HEAD`, ohne di2f-0001-WIP); zusätzlich der **Live-Lauf** in GitHub Actions (Push→`dev`, 2026-06-11) grün. Negativ-Tests in ephemeren Containern mit Repo-Kopien (echtes Repo unberührt).

| AC | Ergebnis | Beleg |
|----|----------|-------|
| 1 — ci.yml, PR→main + push→dev | ✅ | Config korrekt; push→dev live grün |
| 2 — PG17-Service + `create.sh local` | ✅ | `create` EXIT=0 (live + lokal) |
| 3 — `deploy all` + Idempotenz (2.×) | ✅ | deploy#1/#2 EXIT=0 (committeter Stand) |
| 4 — shellcheck; Shell-Fehler → rot | ✅ | clean EXIT=0, kaputt EXIT=1 |
| 5 — sqlfluff; Fehler → rot; **keine** Fehlalarme | ✅ | kaputt EXIT=1, Baseline EXIT=0; `PG01`-Fehlalarm via **BUG-0002 behoben** + re-getestet (committeter HEAD mit Index → grün) |
| 6 — kaputtes SQL/Shell → rot | ✅ | sqlfluff=1, shellcheck=1, Dry-Run-Deploy EXIT=3 („syntax error") |
| 7 — Ruleset verlangt CI-Check; rot blockt Merge | ✅ | `protect-main` verlangt `dry-run-deploy` + `lint`; als „Required" sichtbar (2026-06-11) |
| 8 — grün → mergebar | ✅ | Required-Checks grün → Merge frei (folgt aus AC 7) |
| 9 — keine Secrets | ✅ | `ci.yml` ohne `secrets.*`; `permissions: contents: read`; local-Creds `pw` |

**Edge Cases:** kaputtes SQL → Dry-Run rot ✅ (EXIT 3); nicht-idempotent → 2. Deploy rot ✅ (EXIT 3, „already exists"); sqlfluff zu streng → **Fehlalarm gefunden** (PG01, s. Bug); CRLF durch `.gitattributes` (LF) abgesichert; Fork-PR ohne Secrets ✅ (`pull_request`, nicht `pull_request_target`).

**Gefundene Bugs:**
- **[Mittel] sqlfluff-Fehlalarm `PG01` (postgres.excessive_locks) auf konventionellem `CREATE INDEX`.** `.sqlfluff` `exclude_rules` enthält `PG01` nicht; die Regel verlangt `CONCURRENTLY` — die Hauskonvention (`sql.md`: `CREATE [UNIQUE] INDEX IF NOT EXISTS …` ohne CONCURRENTLY) nutzt das bewusst nicht (und im transaktionalen Deploy ist es nicht möglich). Folge: jede index-tragende Änderung färbt den `lint`-Job rot → blockiert Merges (verstößt gegen AC 5). **Repro:** eine Datei mit `CREATE INDEX … ON …;` unter `db/schemas/**` → `bash .github/sqlfluff-lint.sh` → `PG01`-FAIL. Aufgedeckt durch die di2f-0001-WIP (Index auf `execution`); der **committete/gepushte Stand ist noch grün**. **Fix:** `postgres.excessive_locks` (PG01) in `exclude_rules` aufnehmen → `/backend`. Kein View-Bug. → **Behoben** (Commit `1502212`: `.sqlfluff` += `postgres.excessive_locks`); `/qa`-Re-Test (2026-06-11) gegen committeten HEAD mit Index **grün**, kaputtes SQL weiter rot. Schließen via `/bug close BUG-0002`.

**Feature-spezifische Security-Checks (neue Fläche = die CI):**
- **Secrets:** keine — `ci.yml` referenziert keine `secrets.*`, `permissions: contents: read`, ephemere DB mit `pw`, fork-sicher (`pull_request`). ✅
- **Lint-Helfer:** `sqlfluff-lint.sh` schreibt nur nach `mktemp`, liest read-only; die sed-Sanitierung dient nur dem Linter (kein ausgeführtes SQL) → keine Injection-Relevanz. ✅
- Keine neuen Prozeduren/Funktionen/Policies/Rollen → kein Dynamic-SQL-/RLS-/SECURITY-DEFINER-Check nötig.

**Kandidaten für nächsten `/security`-Run:**
- Der `dry-run-deploy`-Job **führt PR-SQL real aus** (`create.sh`/`deploy.sh` gegen ephemere DB). Aus einem Fork-PR könnte bösartiges SQL (z. B. `COPY … TO PROGRAM`) Code auf dem Runner ausführen — Blast-Radius gering (keine Secrets, Wegwerf-Runner), aber relevant, falls je externe PRs akzeptiert werden.
- `SC2162` (`read` ohne `-r`) in den di2f-0003-Runnern — Mini-Robustheit.

**Regression:** di2f-0003-Runner durch den Dry-Run weiter grün (committeter Stand deployt + idempotent, RW-Grant `t`); di2f-0002/0004 unberührt (CI nutzt keine Environments/Secrets).

**Production-Ready: JA** (keine Critical/High; alle 9 AC erfüllt).
1. ✅ **BUG-0002 (Mittel) `PG01`-Fehlalarm** behoben, `/qa`-re-getestet (`1502212`) + geschlossen (`3390ec9`).
2. ✅ **AC 7/8** — Required-Check (`dry-run-deploy` + `lint`) im `protect-main`-Ruleset gesetzt, als „Required" sichtbar (2026-06-11).

---

## Code Review (Code Reviewer)

- **Reviewer:** Claude (`/review`) · **Datum:** 2026-06-11 · **Range:** di2f-0005-Artefakte bis `bc0222c`
- **Geprüfte Dateien:** `.github/workflows/ci.yml`, `.sqlfluff`, `.github/sqlfluff-lint.sh`, `.shellcheckrc`, `.gitattributes` (Δ).
- **Ergebnis: ✅ Approve** — 0 Blocker, 0 Major, 3 Minor.

**Spec ↔ Code:** alle 9 AC im Diff lokalisiert — AC 1 `ci.yml:8-12`; AC 2 `ci.yml:22-33,48-49`; AC 3 `ci.yml:51-55`; AC 4 `ci.yml:65-66`; AC 5 `ci.yml:68-72` + `.sqlfluff` + Helfer; AC 6 (ON_ERROR_STOP + Lint-Exit, QA-belegt); AC 7/8 Ruleset; AC 9 `ci.yml:14-15` (`permissions: contents: read`, keine `secrets.*`).

**Conventions:** `sql.md`-Objektregeln (Naming/Dollar-Quoting/Body-Struktur) **N/A** — keine DB-Objekte eingeführt. Erfüllt: `shellcheck`-clean (Runner + Helfer), YAML valide, LF via `.gitattributes`. Helfer sauber strukturiert (`set -euo pipefail`, `mktemp`+`trap`-Cleanup, geloggte Skips).

**Findings (alle Minor):**
1. **[Minor]** `ci.yml:69` — `pipx install 'sqlfluff>=3,<4'` ist floating innerhalb 3.x. Ein künftiges 3.x-Release könnte eine Regel verschärfen/ergänzen und den **Required**-Gate auf unbeteiligten PRs rot färben. Vorschlag: auf eine exakte Version pinnen (periodisch anheben) für reproduzierbare CI.
2. **[Minor]** `.github/sqlfluff-lint.sh:24-26` — die `SKIP`-Liste wirkt still, wenn ein Eintrag keinen Treffer mehr hat (Datei umbenannt / Parser-Gap behoben). Vorschlag: warnen, wenn ein `SKIP`-Pfad auf keine Datei matcht (Drift-Erkennung).
3. **[Minor / Security]** `ci.yml` `dry-run-deploy` **führt PR-SQL real aus** (`create.sh`/`deploy.sh` → `psql`). Bösartiges PR-SQL (`COPY … TO PROGRAM`) wäre RCE auf dem Runner. Mitigiert durch ephemeren Runner, keine Secrets, `contents: read`; akzeptabel für internes Team — bewusst zu entscheiden, falls je externe Fork-PRs gemergt werden.

**Kandidaten für nächsten `/security`-Run:** Finding #3 (Ausführung ungetrusteten PR-SQL im Runner).

**Hinweis zum Deploy-Pfad:** di2f-0005 deployt **keine** DB-Objekte → der klassische `/deploy dev` (SSH→Hetzner) ist nicht einschlägig. Das Feature ist auf `dev` bereits aktiv (Push→dev-CI) und wird für `main` durch Merge wirksam (gated durch seinen eigenen Required-Check).

**Follow-up (Fix-Loop, 2026-06-11):**
- **Minor #1 umgesetzt** — `ci.yml` pinnt `sqlfluff==3.5.0`. Der Pin deckte auf, dass 3.5.0 die Regel `PG01`/`postgres.excessive_locks` **nicht mehr** enthält (sqlfluff hat sie zwischen Minors entfernt — genau die Drift, die der Minor adressiert). Der BUG-0002-Exclude war in 3.5.0 ein ungültiger Verweis (`WARNING`) → aus `.sqlfluff` entfernt; `CREATE INDEX` lintet in 3.5.0 ohnehin grün. Kommentar in `.sqlfluff` dokumentiert das Wieder-Aufnehmen bei einem Versions-Bump.
- **Minor #2 umgesetzt** — `.github/sqlfluff-lint.sh` warnt jetzt, wenn ein `SKIP`-Eintrag keine Datei mehr trifft (Drift-Erkennung).
- **Minor #3 offen** — Ausführung ungetrusteten PR-SQL im `dry-run-deploy` bleibt `/security`-Kandidat (kein Code-Fix).

---

## Deployment

> di2f-0005 deployt **keine DB-Objekte** — der klassische `/deploy dev/int/test/prod`-Pfad
> (SSH→Hetzner) ist nicht einschlägig. „Go-Live" = die CI-Artefakte (`ci.yml` + Lint-Konfig) liegen
> auf `main`, und der Required-Status-Check ist im `protect-main`-Ruleset aktiv. Status damit **Deployed**.

| Artefakt / Gate | Stand | Datum |
|-----------------|-------|-------|
| `ci.yml` aktiv auf `dev` (Trigger `push`→`dev`) | ✅ erster Lauf grün | 2026-06-11 |
| `ci.yml` auf `main` (Trigger `pull_request`→`main`, Gate) | ✅ gemergt + aktiv | 2026-06-11 |
| Required-Check (`dry-run-deploy` + `lint`) im `protect-main`-Ruleset | ✅ als „Required" gesetzt | 2026-06-11 |

- Wirksam als **Pflicht-Gate**: jeder PR nach `main` muss beide CI-Jobs grün haben — zuletzt belegt
  durch den `dev`→`main`-PR #5 (di2f-0001-Prod-Bookkeeping), der durch genau diesen Check lief.
- Spätere Bestätigung beim laufenden Betrieb (2026-06-12): CI-Läufe auf den di2f-0001-Pushes grün
  (inkl. Lint-SKIP der Bootstrap-Preflight, Commit `25cf522`).
- Kein Release-Tag (CI-Tooling, kein Framework-Versionsstand).
