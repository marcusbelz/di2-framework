# GitHub-Actions-Workflows — DB-Deployment (di2f-0004)

Manuelle (`workflow_dispatch`) Workflows, die per SSH auf den Hetzner-Host gehen und dort
die Bash-Runner aus `db/scripts/` (di2f-0003) ausführen.

| Workflow | Zweck | Inputs |
|----------|-------|--------|
| `db-create.yml` | Einmaliges DB-/Rollen-/User-Setup | environment |
| `db-deploy.yml` | Schema-Objekte ausrollen | schema (config/etl/helper/log/all), environment |
| `db-clean.yml`  | Schema-Objekte entfernen (DB bleibt) | schema, environment, confirm=`clean` |
| `db-drop.yml`   | Datenbank + Rollen entfernen | environment, confirm=`drop` |

## Branch → Umgebung
Nativ über die GitHub-Environment-Deployment-Branches (di2f-0002):
`dev`/`test` ← Branch `dev`, `int`/`prod` ← Branch `main`. Läufe aus dem falschen Branch
werden von GitHub **vor** dem Start blockiert. Beim Dispatch „Use workflow from" passend wählen
(prod/int → `main`, dev/test → `dev`).

## Setup je Environment (`dev`, `int`, `test`, `prod`)

GitHub → Settings → Environments → `<env>`.

**Secrets** (Settings → Environments → `<env>` → Environment secrets):

| Secret | Zweck |
|--------|-------|
| `HETZNER_SSH_HOST` | SSH-Host |
| `HETZNER_SSH_USER` | SSH-Benutzer |
| `HETZNER_SSH_PRIVATE_KEY` | privater SSH-Schlüssel |
| `DB_ADMIN_PASSWORD_POSTGRES` | postgres-Superuser (create/drop) |
| `DB_OWNER_PASSWORD` | DB-Owner `di2_<env>_owner` (create) |
| `DB_FW_PASSWORD` | Schema-Owner `di2_<env>_fw` (create + deploy/clean) |
| `DB_SA_PASSWORD` | Service-Account `di2_<env>_sa` (create) |

**Variables** (Environment variables — nicht sensibel):

| Variable | Zweck | Beispiel |
|----------|-------|----------|
| `DEPLOY_PATH` | absoluter Pfad des Repo-Checkouts dieser Umgebung auf dem Host | `/home/<user>/di2-framework/dev` |
| `SSH_PORT` | SSH-Port (optional; Default `2121`) | `2121` |

### Per `gh` (Beispiel `dev`)
```bash
gh secret   set HETZNER_SSH_HOST          --env dev
gh secret   set HETZNER_SSH_USER          --env dev
gh secret   set HETZNER_SSH_PRIVATE_KEY   --env dev < key.pem
gh secret   set DB_ADMIN_PASSWORD_POSTGRES --env dev
gh secret   set DB_OWNER_PASSWORD         --env dev
gh secret   set DB_FW_PASSWORD            --env dev
gh secret   set DB_SA_PASSWORD            --env dev
gh variable set DEPLOY_PATH               --env dev --body "/home/<user>/di2-framework/dev"
gh variable set SSH_PORT                  --env dev --body "2121"
```

## Server-Voraussetzung
Pro Umgebung muss unter `DEPLOY_PATH` eine Checkout-Kopie des Repos liegen (einmalig
`git clone`). Die Workflows holen den passenden Branch per `git fetch` + `git reset --hard`.
