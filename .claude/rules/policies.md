# Rule: Policies / Row Level Security (PostgreSQL 17)

Konventionen für RLS-Policies. Je Policy **ein** Skript unter
`db/schemas/<schema>/policies/<policy>.sql` (Framework primär im Schema `log`).

## Benennung
- Sprechender Policy-Name: `<tabelle>_<zweck>_<befehl>` (z. B. `error_select_own`).

## Pflichten
- RLS aktiv schalten: `ALTER TABLE <schema>.<tabelle> ENABLE ROW LEVEL SECURITY;`
  (für besonders sensible Tabellen zusätzlich `FORCE ROW LEVEL SECURITY`).
- Policy je Befehl getrennt: `FOR SELECT|INSERT|UPDATE|DELETE`.
- Rollen explizit: `TO <rolle>`; kein pauschales `PUBLIC` ohne Begründung.
- `USING` (Sichtbarkeit) und `WITH CHECK` (Schreibbedingung) bewusst und vollständig setzen.
- Least Privilege: Default-Deny; nur das Nötige erlauben.
- Idempotenz: vor `CREATE POLICY` ggf. `DROP POLICY IF EXISTS`.

## Template
```sql
-- RLS für <schema>.<tabelle>
ALTER TABLE <schema>.<tabelle> ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS <tabelle>_select_own ON <schema>.<tabelle>;
CREATE POLICY <tabelle>_select_own
    ON <schema>.<tabelle>
    FOR SELECT
    TO <rolle>
    USING ( /* Sichtbarkeitsbedingung */ true );
```
