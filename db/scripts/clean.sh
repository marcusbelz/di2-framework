#!/bin/bash
# db/scripts/clean.sh — entfernt Schema-Objekte einer Umgebung (ohne DB-Drop).
#
# Droppt alle Objekte (Views, Tabellen, Funktionen, Prozeduren, Sequenzen) eines
# Schemas (oder 'all') per Introspektion — das Schema selbst BLEIBT bestehen,
# damit USAGE-Grant und Default Privileges für die RW-Rolle erhalten bleiben
# (kein Grant-Reapply nach einem anschließenden deploy.sh nötig).
# Verbindet als Framework-Schema-Owner di2_<env>_fw (Eigentümer der Objekte).
#
# Usage: bash db/scripts/clean.sh <schema> <env>
#   schema : config | etl | helper | log | all
#   env    : local | dev | int | test | prod   (default: local)
#
# Passwort: DB_FW_PASSWORD (nicht-local Pflicht; local -> 'pw').
set -e

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: clean.sh <schema> <env>"
  echo "  schema : config | etl | helper | log | all"
  echo "  env    : local | dev | int | test | prod   (default: local)"
  exit 1
fi

SCHEMA="$1"
ENV="${2:-local}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/../config/$ENV.env"
CLEAN_SQL="$SCRIPT_DIR/clean.schema.sql"

if [ ! -f "$CONFIG" ]; then
  echo "Error: unknown environment '$ENV' (no $CONFIG)"
  exit 1
fi

# Clean spiegelt die Deploy-Reihenfolge (helper->config->log->etl) -> umgekehrt.
CLEAN_ORDER=(etl log config helper)

case "$SCHEMA" in
  config|etl|helper|log) SCHEMAS=("$SCHEMA") ;;
  all)                   SCHEMAS=("${CLEAN_ORDER[@]}") ;;
  *) echo "Error: unknown schema '$SCHEMA' (expected: config | etl | helper | log | all)"; exit 1 ;;
esac

source "$CONFIG"

# Verbindung als Framework-Schema-Owner (fw); local -> 'pw'.
DB_FW_USER="${DB_FW_USER:-${DB_NAME}_fw}"
if [ "$ENV" = "local" ]; then
  DB_FW_PASSWORD="${DB_FW_PASSWORD:-pw}"
fi
if [ -z "$DB_FW_PASSWORD" ]; then
  echo "Error: DB_FW_PASSWORD must be set for env '$ENV'."
  exit 1
fi
export PGPASSWORD="$DB_FW_PASSWORD"

echo "--- cleaning schema(s): ${SCHEMAS[*]} | env: $ENV ($DB_NAME) as $DB_FW_USER ---"

for schema in "${SCHEMAS[@]}"; do
  echo ">>> clean schema: $schema"
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_FW_USER" -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -v "schema_target=$schema" \
    -f "$CLEAN_SQL"
done

echo "--- done ---"
