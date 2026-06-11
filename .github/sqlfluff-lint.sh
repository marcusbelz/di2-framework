#!/usr/bin/env bash
# .github/sqlfluff-lint.sh — CI-Helfer (di2f-0005): lintet die psql-SQL-Skripte.
#
# Die Skripte unter db/schemas/ und db/database/ sind KEIN reines SQL: sie nutzen
# psql-Meta-Kommandos (\echo, \set, \i) und :variablen. sqlfluff parst das nicht.
# Daher werden sanitierte Kopien gelintet:
#   0) Cast-Operator :: schuetzen (sonst zerlegt Schritt 3 ihn).
#   1) Zeilen, die mit einem psql-Meta-Kommando (Backslash) beginnen, entfernen.
#   2) psql-Variablen durch Platzhalter ersetzen:
#        :'name'  -> 'x'      (String-Literal)
#        :"name"  -> ph_id    (Identifier)
#        :name    -> ph_name  (Identifier, z. B. :schema_log.execution -> ph_schema_log.execution)
#
# Die SQL-Korrektheit selbst gated der echte Dry-Run-Deploy (siehe ci.yml). Dieser
# Lint prueft Parsebarkeit/Syntax mit einem schlanken, hausstil-konformen Regelsatz
# (.sqlfluff) — Stil-/Layout-Regeln, die mit .claude/rules/sql.md kollidieren, sind aus.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Dateien mit Konstrukten, die sqlfluffs Postgres-Dialekt (noch) nicht parst, obwohl
# sie valides PostgreSQL sind. Korrektheit gated der Dry-Run-Deploy, nicht der Lint.
SKIP=(
   "db/database/00.preflight.create.sql" # DO $$ ... END $$ (anonymer Block, RAISE EXCEPTION) -> sqlfluff PRS-Gap
   "db/database/08.create.role.rw.sql"   # CREATE ROLE ... CONNECTION LIMIT -1  -> sqlfluff PRS-Gap
)

is_skipped() {
   local needle="$1" s
   for s in "${SKIP[@]}"; do
      [ "$s" = "$needle" ] && return 0
   done
   return 1
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

shopt -s globstar nullglob

# Drift-Check (Review-Minor): warnen, falls ein SKIP-Eintrag keine Datei mehr trifft
# (Datei umbenannt oder sqlfluff-Parser-Gap behoben -> Eintrag aus SKIP entfernen).
for s in "${SKIP[@]}"; do
   [ -f "$s" ] || echo "WARN: SKIP-Eintrag '${s}' trifft auf keine Datei (Drift?)."
done

n=0
for f in db/schemas/**/*.sql db/database/*.sql; do
   if is_skipped "$f"; then
      echo "    (skip lint: ${f} — sqlfluff-Parser-Gap; Korrektheit via Dry-Run-Deploy)"
      continue
   fi
   dest="$TMP/${f//\//__}"
   sed -E \
      -e 's/::/@@CAST@@/g' \
      -e '/^[[:space:]]*\\/d' \
      -e "s/:'[A-Za-z_][A-Za-z0-9_]*'/'x'/g" \
      -e 's/:"[A-Za-z_][A-Za-z0-9_]*"/ph_id/g' \
      -e 's/:([A-Za-z_][A-Za-z0-9_]*)/ph_\1/g' \
      -e 's/@@CAST@@/::/g' \
      "$f" > "$dest"
   n=$((n + 1))
done

if [ "$n" -eq 0 ]; then
   echo "WARN: keine SQL-Dateien gefunden — nichts zu linten."
   exit 0
fi

echo ">>> sqlfluff: linte ${n} sanitierte SQL-Datei(en)"
sqlfluff lint --config "${ROOT}/.sqlfluff" "${TMP}"
