# Database Setup

Einmalige Setup-Skripte, die die Datenbank `di2_<env>`, die vier Framework-Schemas
(`config`, `etl`, `helper`, `log`) und alle PostgreSQL-Rollen erstellen.

## Inhalt
- [Environments](#environments)
- [Datenbank-Überblick](#datenbank-überblick)
- [Rollen-Überblick](#rollen-überblick)
- [Ausführung](#ausführung)
- [Skript-Dateien](#skript-dateien)
- [Hinweise](#hinweise)

## Environments

| ENV     | Config                       | Ziel                    | Passwörter        |
|---------|------------------------------|-------------------------|-------------------|
| `local` | `db/config/local.env(.sql)`  | lokale Maschine (Docker)| hardcodiert `pw`  |
| `dev`   | `db/config/dev.env(.sql)`    | lokale Entwicklung      | Env-Variablen     |
| `int`   | `db/config/int.env(.sql)`    | lokale Integration      | Env-Variablen     |
| `test`  | `db/config/test.env(.sql)`   | Hetzner test            | Env-Variablen     |
| `prod`  | `db/config/prod.env(.sql)`   | Hetzner production      | Env-Variablen     |

Default ist `local`. Namen (DB, Rollen) stammen aus der jeweiligen `*.env.sql`.

## Datenbank-Überblick

```
di2_<env> (Datenbank)
├── public   — Schema public (NIEMALS Objekte hier anlegen; CREATE für PUBLIC entzogen)
├── config   — Konfiguration der Anwendung
├── etl      — generische Dynamic-SQL-Prozeduren
├── helper   — Hilfsfunktionen (Konvertierung u. a.)
└── log       — Prozessprotokollierung (Execution/Component/Trace) + Error
```

Alle vier Schemas gehören dem **Framework-Schema-Owner** `di2_<env>_fw`.

## Rollen-Überblick

```
postgres (Superuser)
└── di2_<env>_owner   — Datenbank-Owner, LOGIN, für DDL/Bootstrap
└── di2_<env>_fw      — Framework-Schema-Owner, LOGIN, besitzt alle 4 Schemas, legt Objekte an
└── di2_<env>_rw      — Gruppenrolle, NOLOGIN, DML über alle 4 Schemas
└── di2_<env>_sa      — Service-Account, LOGIN, INHERIT, erbt _rw
```

- **`_owner`** — Eigentümer der Datenbank, führt Migrationen aus. Passwort via `-v` (Hetzner) bzw. Env-Datei (local).
- **`_fw`** — Schema-Owner der vier Schemas; erstellt Tabellen/Prozeduren/Funktionen/Views. Default-Privileges machen künftige Objekte automatisch für `_rw` erreichbar.
- **`_rw`** — Gruppenrolle (kein Login): `CONNECT`, `USAGE` auf den Schemas, `SELECT/INSERT/UPDATE/DELETE` auf Tabellen, `USAGE` auf Sequenzen, `EXECUTE` auf Routinen. **Kein** `CREATE` (Objekte legt nur `_fw` an).
- **`_sa`** — Anwendungs-Service-Account (LOGIN, INHERIT); erhält `_rw` über `10.grant.role.sa.sql`. `search_path`: `config, etl, helper, log, public`.

## Ausführung

> Bash-Runner unter `db/scripts/` (`create.sh`, `drop.sh`, `deploy.sh`) sind noch zu erstellen.
> **Bootstrap (create/drop) verbindet als Superuser `postgres`** — er legt die Owner-Rolle erst an.

### Local (Docker)
Passwörter sind als `pw` vorkonfiguriert — keine Vorbereitung nötig.
```bash
bash db/scripts/create.sh local   # Datenbank erstellen
bash db/scripts/drop.sh   local   # Datenbank entfernen
```

### Hetzner (dev / int / test / prod)
Vor dem Lauf alle Passwörter als Env-Variablen setzen:
```bash
export DB_ADMIN_PASSWORD_POSTGRES="<pw>"   # postgres Superuser
export DB_OWNER_PASSWORD="<pw>"            # di2_<env>_owner
export DB_FW_PASSWORD="<pw>"               # di2_<env>_fw (Schema-Owner)
export DB_SA_PASSWORD="<pw>"               # di2_<env>_sa (Service-Account)

bash db/scripts/create.sh dev
bash db/scripts/drop.sh   dev
```

## Skript-Dateien

| Datei | Beschreibung |
|-------|--------------|
| `01.create.database.sql`        | Datenbank + Owner-Rolle (gegen Maintenance-DB `postgres`) |
| `02.create.extension.sql`       | Extension `pgcrypto`; `CREATE` auf `public` für PUBLIC entzogen |
| `03.create.user.fw.sql`         | Framework-Schema-Owner `di2_<env>_fw` |
| `04.create.schema.config.sql`   | Schema `config` |
| `05.create.schema.etl.sql`      | Schema `etl` |
| `06.create.schema.helper.sql`   | Schema `helper` |
| `07.create.schema.log.sql`      | Schema `log` |
| `08.create.role.rw.sql`         | RW-Gruppenrolle + Grants/Default-Privileges über alle 4 Schemas |
| `09.create.user.sa.sql`         | Service-Account `di2_<env>_sa` |
| `10.grant.role.sa.sql`          | `_rw` an `_sa` granten |
| `99.drop.database.sql`          | Datenbank, Rollen und Logins entfernen |

## Hinweise

- Die **Bootstrap-Skripte sind drop-and-recreate**, nicht idempotent — bei erneutem Lauf erst `drop`, dann `create`. (Die Schema-**Objekte** unter `db/schemas/` sind dagegen idempotent.)
- Auf Hetzner Passwörter **nie** in Dateien — immer via `-v` auf der Kommandozeile.
- `01` läuft gegen die Maintenance-DB `postgres`, `02`–`10` gegen die neue Datenbank.
