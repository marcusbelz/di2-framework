# db/scripts — Bash-Runner (Linux)

Reproduzierbares DB-Setup, Deploy und Teardown der vier Schemas (`config`, `etl`,
`helper`, `log`). Ausführung unter Linux/Bash mit `psql`-Client. Feature: di2f-0003.

## Skripte

| Skript                       | Zweck                                                              | Verbindet als |
|------------------------------|--------------------------------------------------------------------|---------------|
| `create.sh <env>`            | Einmaliges Setup: DB, Extensions, 4 Schemas, Rollen, User          | `postgres`    |
| `deploy.sh <schema> <env>`   | Schema-Objekte idempotent ausrollen (`<schema>` = config/etl/helper/log/**all**) | Schema-Owner `fw` |
| `clean.sh <schema> <env>`    | Schema-Objekte entfernen (Schema bleibt; kein DB-Drop)             | Schema-Owner `fw` |
| `drop.sh <env>`              | Komplette Datenbank + Rollen entfernen                             | `postgres`    |
| `clean.schema.sql`           | Helfer für `clean.sh` (droppt Objekte per Introspektion)           | —             |

`<env>` ∈ `local | dev | int | test | prod` (Default `local`).

## Lade-Logik (deploy.sh)

Pro Schema werden die Sektionsordner in fester Reihenfolge geladen, darin nach
3-stelligem Nummern-Prefix:

```
tables → policies → functions → procedures → trigger → views → data
```

Es gibt **kein** zentrales `deploy.sql` — die Verzeichnisstruktur + Nummerierung
ist die Wahrheit. Bei `all` werden die Schemas abhängigkeitssicher deployt
(`helper → config → log → etl`); `clean all` läuft exakt umgekehrt.

## Passwörter

- **`local`:** hardcodiert `pw` (in `db/config/local.env.sql`).
- **Sonst:** über Umgebungsvariablen — `DB_ADMIN_PASSWORD_POSTGRES` (Superuser,
  Connect), `DB_OWNER_PASSWORD`, `DB_FW_PASSWORD`, `DB_SA_PASSWORD`. Nie in Dateien.
  Werden in der CI (di2f-0004) als GitHub-Environment-Secrets bereitgestellt.

## Typischer Ablauf

```bash
bash db/scripts/create.sh local        # 1x: DB/Rollen/Schemas anlegen
bash db/scripts/deploy.sh all local    # Objekte ausrollen (wiederholbar)
bash db/scripts/clean.sh  log local    # nur log-Objekte entfernen
bash db/scripts/drop.sh   local        # alles abräumen (Reset)
```
