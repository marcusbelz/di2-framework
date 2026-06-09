#!/bin/bash
# db/scripts/drop.sh — droppt die komplette Datenbank + Rollen einer Umgebung.
#
# Führt db/database/99.drop.database.sql gegen die Maintenance-DB 'postgres' aus
# (trennt Verbindungen, DROP DATABASE, DROP der Rollen/User). Alle DROPs sind
# IF EXISTS -> wiederholt lauffähig. Verbindet als postgres-Superuser.
#
# Usage: bash db/scripts/drop.sh <env>
#   env : local | dev | int | test | prod   (default: local)
#
# Passwort: DB_ADMIN_PASSWORD_POSTGRES (Prompt, falls leer).
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

if [ -z "$DB_ADMIN_PASSWORD_POSTGRES" ]; then
  read -s -p "Password for postgres superuser: " DB_ADMIN_PASSWORD_POSTGRES
  echo
fi
export PGPASSWORD="$DB_ADMIN_PASSWORD_POSTGRES"

echo "--- dropping database: env $ENV ($DB_NAME) ---"

psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
  -v ON_ERROR_STOP=1 \
  -f "$ENV_SQL" \
  -f "$DB_DIR/99.drop.database.sql"

echo "--- done ---"
