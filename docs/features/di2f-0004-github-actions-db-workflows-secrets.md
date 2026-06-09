# di2f-0004: GitHub-Actions-DB-Workflows & Secrets (4 Umgebungen)

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** — (CI-CD / Deployment-Automation; betrifft alle vier Schemas über die Runner)

## Problem / Motivation
Das Repository hat noch keine `.github/workflows/`. Das DB-Setup, Deploy und Teardown sollen — **analog zum Parallelprojekt `di2`** — über manuell auslösbare GitHub-Actions-Workflows laufen, die per SSH auf den Hetzner-Server gehen und dort die Bash-Runner aus di2f-0003 ausführen. Dafür werden **Secrets für den DB-/Server-Zugriff** je Umgebung benötigt; der User soll bei der Anlage geführt werden.

Im Parallelprojekt ist nur das Schema `app` wählbar; hier müssen die **vier** Schemas (`config`, `etl`, `helper`, `log`) plus `all` auswählbar sein. Die Branch→Umgebung-Zuordnung folgt di2f-0002 (`dev`-Branch → dev/test, `main`-Branch → int/prod).

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
- **Branch-Auflösung** gemäß di2f-0002: `int`/`prod` → `main`, `dev`/`test` → `dev`; der Server checkt vor dem Run den passenden Branch aus (`git fetch` + `git reset --hard origin/<branch>`).
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
6. Die ausgecheckte Branch auf dem Server folgt der Zuordnung aus di2f-0002: `int`/`prod` → `main`, `dev`/`test` → `dev`.
7. Die Workflows verbinden per SSH mit `HETZNER_SSH_HOST`/`HETZNER_SSH_USER`/`HETZNER_SSH_PRIVATE_KEY` und übergeben die DB-Passwörter als Umgebungsvariablen an die Bash-Runner.
8. Die benötigten Secrets sind dokumentiert und für **alle vier** Umgebungen gesetzt: `HETZNER_SSH_HOST`, `HETZNER_SSH_USER`, `HETZNER_SSH_PRIVATE_KEY`, `DB_ADMIN_PASSWORD_POSTGRES`, `DB_OWNER_PASSWORD`, `DB_FW_PASSWORD`, `DB_SA_PASSWORD`.
9. Es existiert eine geführte Checkliste/Anleitung zur Secret-Anlage je Umgebung.
10. Ein Deploy nach `int`/`prod` aus dem `dev`-Branch (bzw. `dev`/`test` aus `main`) ist durch die Branch-Auflösung/Guards ausgeschlossen.

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
