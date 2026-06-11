# di2f-0004: GitHub-Actions-DB-Workflows & Secrets (4 Umgebungen)

- **Priorität:** P1
- **Status:** Deployed
- **Schema(s):** — (CI-CD / Deployment-Automation; betrifft alle vier Schemas über die Runner)

## Problem / Motivation
Das Repository hat noch keine `.github/workflows/`. Das DB-Setup, Deploy und Teardown sollen — **analog zum Parallelprojekt `di2`** — über manuell auslösbare GitHub-Actions-Workflows laufen, die per SSH auf den Hetzner-Server gehen und dort die Bash-Runner aus di2f-0003 ausführen. Dafür werden **Secrets für den DB-/Server-Zugriff** je Umgebung benötigt; der User soll bei der Anlage geführt werden.

Im Parallelprojekt ist nur das Schema `app` wählbar; hier müssen die **vier** Schemas (`config`, `etl`, `helper`, `log`) plus `all` auswählbar sein. Die Branch→Umgebung-Zuordnung folgt di2f-0002 (`dev`-Branch → dev/int, `main`-Branch → test/prod).

## User Stories
- Als **Deployer** möchte ich Deploy/Setup/Teardown über die GitHub-Actions-Oberfläche manuell auslösen (`workflow_dispatch`), damit ich Zeitpunkt und Ziel bewusst kontrolliere.
- Als **Deployer** möchte ich beim Deploy Schema (`config`/`etl`/`helper`/`log`/`all`) und Umgebung (`dev`/`int`/`test`/`prod`) auswählen, damit ich gezielt ausrolle.
- Als **Verantwortlicher** möchte ich, dass destruktive Workflows (clean/drop) eine getippte Bestätigung verlangen, damit nichts versehentlich gelöscht wird.
- Als **Sicherheitsbewusster** möchte ich DB-Zugangsdaten ausschließlich als GitHub-Secrets je Umgebung hinterlegen, damit keine Zugangsdaten im Repo stehen.
- Als **Einrichter** möchte ich eine geführte Checkliste, welche Secrets für welche Umgebung anzulegen sind, damit das Setup vollständig und reproduzierbar ist.

## Scope
Vier Workflows unter `.github/workflows/` (Vorlage: `di2/.github/workflows/db-*.yml`), alle `workflow_dispatch`, Job läuft mit `environment: <gewählte Umgebung>` (damit Environment-Secrets greifen):

- **`db-create.yml`** — Inputs: `environment`. Führt einmaliges DB-/Rollen-/User-Setup aus (`create.sh`).
- **`db-deploy.yml`** — Inputs: `schema` (choice: config | etl | helper | log | all), `environment` (choice: dev | int | test | prod). Führt `deploy.sh <schema> <env>` aus.
- **`db-clean.yml`** — Inputs: `schema`, `environment`, `confirm` (muss `clean` sein). Führt `clean.sh <schema> <env>` aus.
- **`db-drop.yml`** — Inputs: `environment`, `confirm` (muss `drop` sein). Führt `drop.sh <env>` aus.

Workflow-Mechanik (aus `di2` übernommen, angepasst):
- SSH via `appleboy/ssh-action`; Zielverzeichnis auf dem Server pro Umgebung (z. B. `…/di2-framework/<env>`).
- **Branch-Auflösung** gemäß di2f-0002: `test`/`prod` → `main`, `dev`/`int` → `dev`; der Server checkt vor dem Run den passenden Branch aus (`git fetch` + `git reset --hard origin/<branch>`).
- Destruktive Workflows (clean/drop) mit vorgelagertem Guard-Job, der die `confirm`-Eingabe prüft.
- DB-Passwörter und SSH-Zugang als `${{ secrets.* }}`.

**Secrets je Umgebung** (GitHub Environments `dev`/`int`/`test`/`prod`; da Hosting noch offen ist, vorsichtshalber **je Environment** anlegen — funktioniert sowohl bei gemeinsamem als auch bei getrenntem Host):
| Secret | Zweck |
|--------|-------|
| `HETZNER_SSH_HOST` | Ziel-Host für SSH |
| `HETZNER_SSH_USER` | SSH-Benutzer |
| `HETZNER_SSH_PRIVATE_KEY` | privater SSH-Schlüssel |
| `DB_ADMIN_PASSWORD_POSTGRES` | `postgres`-Superuser (create/clean/drop) |
| `DB_OWNER_PASSWORD` | DB-Owner `di2_<env>_owner` (create) |
| `DB_FW_PASSWORD` | Schema-Owner `di2_<env>_fw` (create + deploy) |
| `DB_SA_PASSWORD` | Service-Account `di2_<env>_sa` (create) |

- **Geführte Secret-Anlage:** eine reproduzierbare Checkliste / `gh secret set …`-Anleitung je Umgebung (durch den Assistenten begleitet, nach Spec-Freigabe).

## Nicht-Ziele
- **Keine** Bash-Runner — die sind di2f-0003 (werden hier nur aufgerufen).
- **Keine** automatischen Trigger bei Push/Merge — bewusst nur `workflow_dispatch` (vgl. di2f-0002).
- **Keine** App-/Docker-Deploys (die `deploy-<env>.yml` aus `di2` sind app-spezifisch und für das Framework irrelevant).
- **Keine** Branch-Protection-Konfiguration — die ist di2f-0002.
- **Keine** Ablage echter Secret-Werte im Repo — nur Namen/Doku.

## Datenmodell-Auswirkung
Keine.

## Protokollierungs-Integration
Keine direkte (siehe di2f-0003).

## Akzeptanzkriterien
1. Es existieren vier Workflows `db-create.yml`, `db-deploy.yml`, `db-clean.yml`, `db-drop.yml`, alle als `workflow_dispatch`.
2. `db-deploy` und `db-clean` bieten einen `schema`-Input mit den Optionen `config`, `etl`, `helper`, `log`, `all` sowie einen `environment`-Input mit `dev`, `int`, `test`, `prod`.
3. `db-create` und `db-drop` bieten einen `environment`-Input (dev/int/test/prod).
4. `db-clean` und `db-drop` verlangen eine getippte Bestätigung (`clean` bzw. `drop`); bei Abweichung bricht ein Guard-Job vor jeder destruktiven Aktion ab.
5. Jeder Workflow-Job läuft mit `environment: <gewählte Umgebung>`, sodass die Environment-Secrets der Umgebung gezogen werden.
6. Die ausgecheckte Branch auf dem Server folgt der Zuordnung aus di2f-0002: `test`/`prod` → `main`, `dev`/`int` → `dev`.
7. Die Workflows verbinden per SSH mit `HETZNER_SSH_HOST`/`HETZNER_SSH_USER`/`HETZNER_SSH_PRIVATE_KEY` und übergeben die DB-Passwörter als Umgebungsvariablen an die Bash-Runner.
8. Die benötigten Secrets sind dokumentiert und für **alle vier** Umgebungen gesetzt: `HETZNER_SSH_HOST`, `HETZNER_SSH_USER`, `HETZNER_SSH_PRIVATE_KEY`, `DB_ADMIN_PASSWORD_POSTGRES`, `DB_OWNER_PASSWORD`, `DB_FW_PASSWORD`, `DB_SA_PASSWORD`.
9. Es existiert eine geführte Checkliste/Anleitung zur Secret-Anlage je Umgebung.
10. Ein Deploy nach `test`/`prod` aus dem `dev`-Branch (bzw. `dev`/`int` aus `main`) ist durch die Branch-Auflösung/Guards ausgeschlossen.

## Edge Cases
- **Bestätigung falsch** (`confirm` ≠ `clean`/`drop`) → Guard-Job schlägt fehl, keine destruktive Aktion.
- **Fehlendes Secret** in einer Umgebung (z. B. `DB_FW_PASSWORD` nicht gesetzt) → Job schlägt mit klarer Meldung fehl, statt teilweise zu deployen.
- **`db-deploy` vor `db-create`** (DB/Rollen fehlen) → Deploy schlägt fehl; verständliche Fehlermeldung.
- **`schema=all`** → Workflow reicht `all` an `deploy.sh`/`clean.sh` durch; Reihenfolge liegt im Skript (di2f-0003).
- **Falscher „Use workflow from"-Branch** im Dispatch-Dialog relativ zur Zielumgebung → durch serverseitige Branch-Auflösung (di2f-0002) neutralisiert, sodass immer der korrekte Branch deployt wird.
- **Gemeinsamer vs. getrennter Hetzner-Host** noch offen → Secrets je Environment funktionieren in beiden Fällen; bei gemeinsamem Host sind die SSH-Werte je Umgebung identisch.
- **SSH-Port** wird als Workflow-Konfiguration (nicht Secret) gesetzt; abweichender Port pro Umgebung muss dokumentiert/konfigurierbar sein.

## Abhängigkeiten
- **Requires:** di2f-0003 (Bash-Runner — Workflows rufen `create/deploy/clean/drop.sh` auf).
- **Requires:** di2f-0002 (Branch→Umgebung-Zuordnung für die Branch-Auflösung).
- Relates: PRD-Roadmap „GitHub-Actions-Deployment (dev/int/test/prod)" (P1).
- Vorlage: `c:/sandbox/github/di2/.github/workflows/db-{deploy,clean,drop}.yml`.

---

## Tech Design (Solution Architect)

> **Views nötig: Nein.** CI/CD-Automation, keine DB-Objekte, kein Datenmodell. Nach Freigabe folgt die Umsetzung über `/backend` (Workflow-YAMLs unter `.github/workflows/`), **kein** `/frontend`.

### A) Einordnung
di2f-0004 ist die **ausführende Schicht**: vier GitHub-Actions-Workflows, die per SSH auf den Hetzner-Server gehen und dort die in **di2f-0003** gebauten Bash-Runner aufrufen. Die **Governance** (Branches, `main`-Ruleset, die vier Environments mit Branch-Policy) liefert **di2f-0002** und ist bereits aktiv. di2f-0004 fügt nichts an der DB-Logik hinzu — es orchestriert nur.

### B) Artefakt-Landschaft (flache Liste, keine Implementierung)
- `.github/workflows/db-create.yml` — einmaliges Setup je Umgebung (ruft `create.sh`).
- `.github/workflows/db-deploy.yml` — Schema-Objekte ausrollen (ruft `deploy.sh <schema> <env>`).
- `.github/workflows/db-clean.yml` — Schema-Objekte entfernen (ruft `clean.sh`), mit Bestätigung.
- `.github/workflows/db-drop.yml` — Datenbank droppen (ruft `drop.sh`), mit Bestätigung.
- **GitHub-Environment-Secrets** je `dev`/`int`/`test`/`prod` (Werte; keine Repo-Dateien).
- **Secret-Setup-Checkliste** (Doku/`gh`-Anleitung) — geführt, nach Freigabe.

### C) „Datenmodell" (Klartext) — Inputs & Secret-Routing
Kein DB-Datenmodell. Die relevanten „Daten" sind Workflow-Inputs und welches Secret an welchen Runner geht:

| Workflow | Inputs | Ruft (auf Server) | Benötigte Secrets (zusätzl. zu SSH) |
|----------|--------|-------------------|--------------------------------------|
| db-create | `environment` | `create.sh <env>` | `DB_ADMIN_PASSWORD_POSTGRES`, `DB_OWNER_PASSWORD`, `DB_FW_PASSWORD`, `DB_SA_PASSWORD` |
| db-deploy | `schema` (config/etl/helper/log/all), `environment` | `deploy.sh <schema> <env>` | `DB_FW_PASSWORD` |
| db-clean | `schema`, `environment`, `confirm=clean` | `clean.sh <schema> <env>` | `DB_FW_PASSWORD` |
| db-drop | `environment`, `confirm=drop` | `drop.sh <env>` | `DB_ADMIN_PASSWORD_POSTGRES` |

SSH-Secrets für **alle**: `HETZNER_SSH_HOST`, `HETZNER_SSH_USER`, `HETZNER_SSH_PRIVATE_KEY`.

### D) Schnittstellen (Klartext, nur Zweck)
- Jeder Workflow: **`workflow_dispatch`** (manuell), Job läuft mit **`environment: <gewählte Umgebung>`** → zieht die Environment-Secrets **und** unterliegt der Deployment-Branch-Policy aus di2f-0002.
- Destruktive Workflows (clean/drop): vorgelagerter **Guard-Job**, der die `confirm`-Eingabe prüft (`clean`/`drop`), sonst Abbruch vor jeder Aktion.
- SSH-Step (`appleboy/ssh-action`): verbindet zum Hetzner-Host und führt im umgebungs-spezifischen Checkout den passenden `db/scripts/*.sh`-Aufruf aus.

### E) Datenfluss & Branch-Durchsetzung
1. User startet Workflow manuell, wählt Umgebung (und ggf. Schema/Bestätigung).
2. **Native Branch-Sperre (di2f-0002):** GitHub lässt den Lauf nur zu, wenn er aus dem für die Umgebung erlaubten Branch kommt (`dev`/`int` ← `dev`, `test`/`prod` ← `main`) — sonst Abbruch **vor** dem Start. Es braucht **keinen** zusätzlichen Skript-Guard für die Branch-Regel.
3. SSH zum Server; der umgebungs-Checkout wird auf den auslösenden Branch gebracht (`git fetch` + `git reset --hard origin/<github.ref_name>`) — der ist durch Schritt 2 garantiert der richtige.
4. Der Bash-Runner (di2f-0003) läuft mit den als Umgebungsvariablen übergebenen Secrets; Erfolg/Fehler steht im Actions-Log.

### F) Tech-Entscheidungen (für PM begründet)
- **Workflows rufen die di2f-0003-Runner, statt SQL-Logik zu duplizieren:** eine einzige Quelle der Wahrheit; lokal (Docker) und in CI läuft exakt derselbe Code.
- **Native Environment-Branch-Policy statt Skript-Guard** (aus di2f-0002): die Branch→Umgebung-Regel ist nicht umgehbar per YAML-Tippfehler und greift vor Job-Start.
- **Bestätigungs-Guard nur für clean/drop:** destruktive Aktionen verlangen eine getippte Bestätigung — Schutz gegen Fehlklicks, ohne Routine-Deploys zu bremsen.
- **Secrets je GitHub-Environment** (nicht repo-weit): saubere Trennung der Umgebungen; funktioniert bei gemeinsamem **und** getrenntem Hetzner-Host (Hosting noch offen).
- **Least-Privilege-Routing:** db-deploy/clean bekommen nur `DB_FW_PASSWORD` (Schema-Owner), nur create/drop bekommen das Superuser-Passwort.

### G) Geführte Secret-Anlage (nach Freigabe)
Reproduzierbare Checkliste je Umgebung (`dev`/`int`/`test`/`prod`): die sieben Secrets als **Environment-Secrets** setzen — via GitHub-UI (Settings → Environments → Secrets) oder `gh secret set <NAME> --env <env>`. di2f-0004 liefert die Liste; der Assistent begleitet die Anlage Schritt für Schritt.

### H) Offene Build-Zeit-Parameter (in `/backend` zu fixieren)
- **Hetzner-Verzeichnislayout:** umgebungs-spezifischer Checkout-Pfad auf dem Server (z. B. `…/di2-framework/<env>`) — konkreter Basis-Pfad + SSH-User.
- **SSH-Port** (di2-Vorlage nutzte 2121) — als Workflow-Konstante; abweichender Port je Umgebung dokumentieren.
- **Hosting** (ein gemeinsamer Host vs. getrennte) — beeinflusst nur, ob die SSH-Secret-Werte je Umgebung identisch sind; das Design ist in beiden Fällen gleich.

### I) Abhängigkeiten (Technik)
- **Requires di2f-0003** (Runner) und **di2f-0002** (Environments/Branch-Policy, bereits live).
- Hetzner-Host mit `psql`-Client + ausgecheckter Repo-Kopie je Umgebung; SSH-Zugang.
- GitHub-Repo-Adminrechte für die Secret-Anlage.

---

## Backend-Umsetzung (Workflows & Schnittstellen)

**Artefakte** (`.github/workflows/`): `db-create.yml`, `db-deploy.yml`, `db-clean.yml`, `db-drop.yml`, `README.md` (Setup-Checkliste).

**Konfig-Entscheidung:** Nicht-sensible, server-/umgebungsspezifische Werte als **GitHub-Environment-Variablen** statt Hardcoding:
- `DEPLOY_PATH` (Pflicht je Environment) — absoluter Repo-Checkout-Pfad auf dem Host.
- `SSH_PORT` (optional, Default `2121`) — `${{ vars.SSH_PORT || 2121 }}`.

**Workflow-Schnittstellen:** alle `workflow_dispatch`, Job mit `environment: <gewählt>`.
- `db-create` (env) → `create.sh <env>`; Secrets: ADMIN/OWNER/FW/SA.
- `db-deploy` (schema, env) → `deploy.sh <schema> <env>`; Secret: FW.
- `db-clean` (schema, env, confirm=`clean`) → Guard-Job, dann `clean.sh`; Secret: FW.
- `db-drop` (env, confirm=`drop`) → Guard-Job, dann `drop.sh`; Secret: ADMIN.
- SSH-Step (`appleboy/ssh-action@v1.2.0`): `cd $DEPLOY_PATH` → `git fetch`/`reset --hard origin/<ref>` → Runner-Aufruf. DB-Passwörter via `envs:` in die Remote-Shell.

**Security-Details:** `confirm` wird **nicht** in den Skript-String interpoliert, sondern über `env: CONFIRM` verglichen (kein Shell-Injection-Risiko); `schema`/`environment` sind `choice`-Inputs (eingeschränkt). Branch→Umgebung nativ über die di2f-0002-Environments (kein Skript-Guard). Leerer `DEPLOY_PATH` → klarer Abbruch.

**Test-Stand:** YAML-Struktur + LF-Zeilenenden (`.gitattributes` `*.yml eol=lf`) geprüft. **Live verifiziert am 2026-06-11:** alle vier Workflows (`db-create`/`-deploy`/`-clean`/`-drop`) wurden über GitHub Actions in **allen vier Umgebungen** (`dev`/`int`/`test`/`prod`) erfolgreich ausgeführt. Betrieb auf einem gemeinsamen Hetzner-Host (SSH-User `fupi`, Port `2121`), Environment-Secrets/-Variablen je Umgebung gesetzt. Setup-Stolperstein zum Merken: eine versehentlich als *Secret* statt als *Variable* angelegte `DEPLOY_PATH` → der Guard schlägt fehl, weil `vars.` nur Variables liest.
