# Rule: Policies / Row Level Security (PostgreSQL 17)

> **Maßgeblich sind die SQL-Code-Konventionen in [sql.md](sql.md) — vor jedem Skript lesen.**
> Layout (`USING (` / `WITH CHECK (` mit Klammern auf eigener Zeile bei echten Ausdrücken,
> triviale Konstanten-Bodies einzeilig), Datei-Gerüst und Alignment stehen dort.
> **Bei Widerspruch gilt sql.md.**
>
> **Schema-Variablen:** `:schema_config`/`:schema_etl`/`:schema_helper`/`:schema_log` und
> `:schema_owner` statt `:schema_app_*`.

## Framework-spezifisch
- **Ablage:** Skript unter `db/schemas/<schema>/policies/<NNN>.<tabelle>_policies.sql`
  (Framework primär `log`). `<NNN>` = Nummer der Tabelle, deren Policies hier definiert werden.
- RLS aktivieren: `ALTER TABLE … ENABLE ROW LEVEL SECURITY;` (sensible Tabellen zusätzlich
  `FORCE ROW LEVEL SECURITY`).
- Policy **je Befehl** (`FOR SELECT|INSERT|UPDATE|DELETE`); Rollen explizit (`TO :role_rw` …),
  kein pauschales `PUBLIC`.
- `USING` (Sichtbarkeit) und `WITH CHECK` (Schreibbedingung) vollständig setzen; Default-Deny.
- Idempotenz: `DROP POLICY IF EXISTS …` vor `CREATE POLICY`.
