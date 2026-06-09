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
