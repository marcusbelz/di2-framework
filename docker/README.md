# docker/ — Lokales DB-Deployment im Container

Isolierte **PostgreSQL-17**-Instanz (postgis-Image) für lokale Entwicklung und Tests.
Bindet das Git-Repo in den Container ein und führt dort die Bash-Runner aus
`db/scripts/` (Feature di2f-0003) aus — also dasselbe `create`/`deploy`/`clean`/`drop`
wie später auf Hetzner, nur lokal.

## Dateien

| Datei                        | Zweck                                                            |
|------------------------------|------------------------------------------------------------------|
| `docker.di2f.yml`            | Compose-Definition (Service `postgres`, Volume, Netzwerk)        |
| `docker.di2f.dev.env`        | Konkrete Werte für die Umgebung **dev** (lokal, **nicht** ins Repo) |
| `docker.di2f.dev.env.example`| Vorlage zum Kopieren nach `docker.di2f.dev.env`                  |
| `docker.di2f.dev.md`         | Zusatz-Kommandos (Bash im Container, `docker cp`, Volume)        |

## Voraussetzungen

- Docker Desktop (WSL2-Backend). Das Laufwerk mit dem Repo (z. B. `C:`) muss in
  Docker Desktop unter *Settings → Resources → File sharing* freigegeben sein.
- Das Repo liegt lokal ausgecheckt vor.

## 1. Konfiguration

`docker.di2f.dev.env` setzen (aus `*.example` kopiert):

```
COMPOSE_PROJECT_NAME=di2f_dev
CONTAINER_NAME=di2f_dev_postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres          # postgres-Superuser im Container
POSTGRES_DB=postgres
POSTGRES_HOST_PORT=5556             # Host-Port; Container-intern bleibt 5432
GIT_REPO_PATH=C:/sandbox/github/di2-framework   # Pfad zum Repo (Forward-Slashes, mit Laufwerk)
```

> `GIT_REPO_PATH` wird per Bind-Mount unter **`/di2-framework`** im Container eingehängt.
> `POSTGRES_HOST_PORT` (5556) ist nur für Zugriff vom Host relevant — die Runner
> laufen **im** Container gegen `localhost:5432` (so wie in `db/config/local.env`).

## 2. Container starten

```bash
docker compose -f docker/docker.di2f.yml --env-file docker/docker.di2f.dev.env up -d
# Status / Healthcheck:
docker inspect --format '{{.State.Health.Status}}' di2f_dev_postgres
```

## 3. DB-Deployment im Container

Die Runner laufen **im** Container (dort sind `psql` und der Server vorhanden).
Der `postgres`-Superuser-Connect braucht `DB_ADMIN_PASSWORD_POSTGRES` = `POSTGRES_PASSWORD`;
die Rollen-Passwörter sind für `local` hartkodiert (`pw`, siehe `db/config/local.env.sql`).

```bash
# Einmaliges Setup: DB, 4 Schemas, Rollen, User
docker exec -e DB_ADMIN_PASSWORD_POSTGRES=postgres di2f_dev_postgres \
  bash /di2-framework/db/scripts/create.sh local

# Objekte ausrollen (Schema: config | etl | helper | log | all)
docker exec di2f_dev_postgres \
  bash /di2-framework/db/scripts/deploy.sh all local

# Objekte eines Schemas entfernen (Schema bleibt bestehen)
docker exec di2f_dev_postgres \
  bash /di2-framework/db/scripts/clean.sh log local

# Komplette DB + Rollen entfernen
docker exec -e DB_ADMIN_PASSWORD_POSTGRES=postgres di2f_dev_postgres \
  bash /di2-framework/db/scripts/drop.sh local
```

## 4. Verifikation (Beispiele)

```bash
# Tabellen je Schema
docker exec -e PGPASSWORD=postgres di2f_dev_postgres \
  psql -U postgres -d di2_local -c \
  "SELECT table_schema, count(*) FROM information_schema.tables
   WHERE table_schema IN ('config','etl','helper','log') GROUP BY 1 ORDER BY 1;"

# Greift der automatische Grant an die RW-Rolle? (sollte 't' sein)
docker exec -e PGPASSWORD=postgres di2f_dev_postgres \
  psql -U postgres -d di2_local -At -c \
  "SELECT has_table_privilege('di2_local_rw','log.process','SELECT');"
```

## 5. Teardown

```bash
# Container + Volume + Netzwerk entfernen (Daten weg)
docker compose -f docker/docker.di2f.yml --env-file docker/docker.di2f.dev.env down -v
```

## Hinweise

- **Idempotenz:** `deploy.sh` ist wiederholbar (`CREATE OR REPLACE` / `IF NOT EXISTS`).
- **Grants:** `deploy.sh` verbindet als Schema-Owner `di2_local_fw`; über dessen
  Default Privileges (`db/database/08.create.role.rw.sql`) werden neue Objekte
  automatisch an `di2_local_rw` granted — nach `clean`+Re-Deploy **kein** Grant-Reapply nötig.
- **Andere Umgebungen** (`dev`/`int`/`test`/`prod`) laufen nicht lokal über dieses
  Compose, sondern via GitHub Actions → Hetzner (Feature di2f-0004).
