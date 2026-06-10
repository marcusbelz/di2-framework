# db/config

Umgebungsspezifische Konfiguration für Datenbankverbindungen und Objekt-Namen.

## Überblick

Jede Umgebung hat zwei zusammengehörige Config-Dateien:

| Environment | Shell-Config | psql-Variablen   |
|-------------|--------------|------------------|
| `local`     | `local.env`  | `local.env.sql`  |
| `dev`       | `dev.env`    | `dev.env.sql`    |
| `int`       | `int.env`    | `int.env.sql`    |
| `test`      | `test.env`   | `test.env.sql`   |
| `prod`      | `prod.env`   | `prod.env.sql`   |

## Datei-Paare

### `<ENV>.env`
Wird von den Bash-Skripten (`create.sh`, `drop.sh`, `deploy.sh`) geladen und setzt Verbindungsparameter als Shell-Variablen:

```bash
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres   # Bootstrap verbindet als Superuser
DB_NAME=di2_dev
```

| Variable | Beschreibung |
|----------|--------------|
| `DB_HOST` | PostgreSQL-Host. Alle Umgebungen (`dev`/`int`/`test`/`prod`) laufen auf dem Hetzner-Host mit lokalem Postgres → `localhost`; `local` ist die lokale Entwicklungsmaschine (ebenfalls `localhost`) |
| `DB_PORT` | PostgreSQL-Port |
| `DB_USER` | Verbindungs-User (Bootstrap: Superuser `postgres`) |
| `DB_NAME` | Ziel-Datenbank (`di2_<env>`) |

### `<ENV>.env.sql`
Wird von den psql-Skripten via `\i` geladen und setzt benannte Variablen für die Datenbankobjekte:

```sql
\set database_name   di2_dev
\set database_owner  di2_dev_owner
\set schema_owner    di2_dev_fw
\set schema_config   config
-- ...
```

| Variable | Beschreibung |
|----------|--------------|
| `database_name`  | Datenbankname `di2_<env>` |
| `database_owner` | DB-Owner-Rolle `di2_<env>_owner` |
| `schema_owner`   | Framework-Schema-Owner `di2_<env>_fw` (besitzt alle 4 Schemas) |
| `schema_config` / `schema_etl` / `schema_helper` / `schema_log` | Schema-Namen (fix: `config`/`etl`/`helper`/`log`) |
| `role_rw`        | RW-Gruppenrolle `di2_<env>_rw` |
| `user_sa`        | Service-Account `di2_<env>_sa` |

**Passwörter:** nur in `local.env.sql` hardcodiert (`pw`); für `dev`/`int`/`test`/`prod` zur Laufzeit via `-v` übergeben (`database_owner_password`, `schema_owner_password`, `user_sa_password`).
