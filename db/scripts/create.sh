#!/bin/bash
# db/scripts/create.sh — einmaliges DB-/Rollen-/User-Setup einer Umgebung.
#
# Baut Datenbank, Extensions, die vier Schemas (config/etl/helper/log), die
# RW-Gruppenrolle und die Login-User auf. Verbindet als postgres-Superuser.
# Bootstrap ist drop-and-recreate: bei Re-Setup zuerst drop.sh, dann create.sh.
#
# Usage: bash db/scripts/create.sh <env>
#   env : local | dev | int | test | prod   (default: local)
#
# Passwörter (nicht-local: Pflicht via Umgebungsvariablen; local: 'pw'):
#   DB_ADMIN_PASSWORD_POSTGRES  - postgres-Superuser (Connect)        -> Prompt, falls leer
#   DB_OWNER_PASSWORD           - DB-Owner   di2_<env>_owner (Skript 01)
#   DB_FW_PASSWORD              - Schema-Owner di2_<env>_fw   (Skript 03)
#   DB_SA_PASSWORD              - Service-Account di2_<env>_sa (Skript 09)
set -e

ENV="${1:-local}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_DIR="$SCRIPT_DIR/../database"
CONFIG="$SCRIPT_DIR/../config/$ENV.env"
ENV_SQL="$SCRIPT_DIR/../config/$ENV.env.sql"

if [ ! -f "$CONFIG" ]; then
  echo "Error: unknown environment '$ENV' (no $CONFIG)"
  exit 1
fi

source "$CONFIG"

# postgres-Superuser-Passwort (Prompt, falls nicht via Umgebungsvariable gesetzt)
if [ -z "$DB_ADMIN_PASSWORD_POSTGRES" ]; then
  read -s -p "Password for postgres superuser: " DB_ADMIN_PASSWORD_POSTGRES
  echo
fi
export PGPASSWORD="$DB_ADMIN_PASSWORD_POSTGRES"

# Rollen-Passwörter: local -> 'pw' (in $ENV.env.sql ohnehin gesetzt), sonst Pflicht.
if [ "$ENV" = "local" ]; then
  DB_OWNER_PASSWORD="${DB_OWNER_PASSWORD:-pw}"
  DB_FW_PASSWORD="${DB_FW_PASSWORD:-pw}"
  DB_SA_PASSWORD="${DB_SA_PASSWORD:-pw}"
else
  for v in DB_OWNER_PASSWORD DB_FW_PASSWORD DB_SA_PASSWORD; do
    if [ -z "${!v}" ]; then
      echo "Error: $v must be set for env '$ENV'."
      exit 1
    fi
  done
fi

echo "--- creating database: env $ENV ($DB_NAME) ---"

# Preflight: Bootstrap ist drop-and-recreate (siehe CLAUDE.md). Rollen sind
# cluster-global und ueberleben ein DROP DATABASE -> ein zweiter create.sh-Lauf
# ohne vorheriges drop.sh braeche sonst in Step 1 mit "role already exists" (42710)
# ab. Hier vorab ein klarer Hinweis statt des rohen psql-Fehlers. Exit-Code 3 =
# DB/Rollen existieren (RAISE unter ON_ERROR_STOP); 1/2 = echter Verbindungsfehler.
echo ">>> preflight: bestehende Datenbank / Rollen pruefen"
rc=0
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
  -v ON_ERROR_STOP=1 -X \
  -f "$ENV_SQL" \
  -f "$DB_DIR/00.preflight.create.sql" >/dev/null || rc=$?
if [ "$rc" -eq 3 ]; then
  echo
  echo "Error: Datenbank oder Rollen fuer env '$ENV' existieren bereits."
  echo "       Das Bootstrap-Setup ist drop-and-recreate (nicht idempotent)."
  echo "       Erst aufraeumen, dann neu anlegen:"
  echo "         bash db/scripts/drop.sh $ENV"
  echo "         bash db/scripts/create.sh $ENV"
  exit 1
elif [ "$rc" -ne 0 ]; then
  echo "Error: preflight psql failed (exit $rc) — Verbindung/Setup pruefen."
  exit "$rc"
fi

# Step 1: Datenbank + Owner-Rolle (gegen Maintenance-DB 'postgres')
echo ">>> step 1: database + owner"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
  -v ON_ERROR_STOP=1 \
  -v "database_owner_password=$DB_OWNER_PASSWORD" \
  -f "$ENV_SQL" \
  -f "$DB_DIR/01.create.database.sql"

# Step 2: Extensions, Schema-Owner, vier Schemas, RW-Rolle, Service-Account (neue DB)
echo ">>> step 2: extensions, schemas, roles, users"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
  -v ON_ERROR_STOP=1 \
  -v "schema_owner_password=$DB_FW_PASSWORD" \
  -v "user_sa_password=$DB_SA_PASSWORD" \
  -f "$ENV_SQL" \
  -f "$DB_DIR/02.create.extension.sql" \
  -f "$DB_DIR/03.create.user.fw.sql" \
  -f "$DB_DIR/04.create.schema.config.sql" \
  -f "$DB_DIR/05.create.schema.etl.sql" \
  -f "$DB_DIR/06.create.schema.helper.sql" \
  -f "$DB_DIR/07.create.schema.log.sql" \
  -f "$DB_DIR/08.create.role.rw.sql" \
  -f "$DB_DIR/09.create.user.sa.sql" \
  -f "$DB_DIR/10.grant.role.sa.sql"

echo "--- done ---"
