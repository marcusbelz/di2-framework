#!/bin/bash
# db/scripts/deploy.sh — deployt Schema-Objekte einer Umgebung (idempotent).
#
# Lädt die Objekte eines Schemas (oder 'all') direkt aus der Verzeichnisstruktur
# db/schemas/<schema>/ — KEIN zentrales deploy.sql. Sektions-Reihenfolge:
#   tables -> policies -> functions -> procedures -> trigger -> views -> data
# Innerhalb einer Sektion: nach 3-stelligem Nummern-Prefix (Glob-Sortierung).
# Verbindet als Framework-Schema-Owner di2_<env>_fw, damit erzeugte Objekte dem
# fw-Owner gehören und über dessen Default Privileges automatisch an die
# RW-Rolle granted werden (kein separater Grant-Schritt nötig).
#
# Usage: bash db/scripts/deploy.sh <schema> <env>
#   schema : config | etl | helper | log | all
#   env    : local | dev | int | test | prod   (default: local)
#
# Passwort: DB_FW_PASSWORD (nicht-local Pflicht; local -> 'pw').
set -e

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: deploy.sh <schema> <env>"
  echo "  schema : config | etl | helper | log | all"
  echo "  env    : local | dev | int | test | prod   (default: local)"
  exit 1
fi

SCHEMA="$1"
ENV="${2:-local}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMAS_DIR="$SCRIPT_DIR/../schemas"
CONFIG="$SCRIPT_DIR/../config/$ENV.env"
ENV_SQL="$SCRIPT_DIR/../config/$ENV.env.sql"

if [ ! -f "$CONFIG" ]; then
  echo "Error: unknown environment '$ENV' (no $CONFIG)"
  exit 1
fi

# Abhängigkeitssichere Deploy-Reihenfolge bei 'all': fundamentlos -> aufbauend.
DEPLOY_ORDER=(helper config log etl)

case "$SCHEMA" in
  config|etl|helper|log) SCHEMAS=("$SCHEMA") ;;
  all)                   SCHEMAS=("${DEPLOY_ORDER[@]}") ;;
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

GIT_SHA="$(git -C "$SCRIPT_DIR/../.." rev-parse HEAD 2>/dev/null || echo '')"
APP_VERSION="${APP_VERSION_MAJOR:-0}.${APP_VERSION_MINOR:-0}.${APP_VERSION_BUILD:-0}"

# Sektions-Reihenfolge innerhalb eines Schemas.
SECTIONS=(tables policies functions procedures trigger views data)

echo "--- deploying schema(s): ${SCHEMAS[*]} | env: $ENV ($DB_NAME) as $DB_FW_USER ---"

for schema in "${SCHEMAS[@]}"; do
  echo ">>> schema: $schema (version $APP_VERSION, git ${GIT_SHA:-unknown})"

  files=()
  for section in "${SECTIONS[@]}"; do
    dir="$SCHEMAS_DIR/$schema/$section"
    [ -d "$dir" ] || continue
    for f in "$dir"/*.sql; do
      [ -e "$f" ] || continue
      files+=("$f")
    done
  done

  if [ "${#files[@]}" -eq 0 ]; then
    echo "    (no objects for schema '$schema' — skipping)"
    continue
  fi

  args=()
  for f in "${files[@]}"; do
    args+=(-f "$f")
  done

  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_FW_USER" -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -v "db_version=$APP_VERSION" \
    -v "git_sha=$GIT_SHA" \
    -f "$ENV_SQL" \
    "${args[@]}"
done

echo "--- done ---"
