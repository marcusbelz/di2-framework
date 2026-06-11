# di2f-0005: DB-CI — Dry-Run-Deploy + Lint (GitHub Actions, Required-Gate)

- **Priorität:** P1
- **Status:** Geplant
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
