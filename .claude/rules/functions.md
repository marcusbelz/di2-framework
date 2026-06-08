# Rule: Funktionen (PostgreSQL 17)

Konventionen für Funktionen. Je Funktion **ein** Skript unter
`db/schemas/<schema>/functions/fn<Name>.sql`.

## Benennung & Signatur
- Präfix `fn`, schema-qualifiziert: `<schema>.fn<Name>` (z. B. `helper.fn_convert_date`).
- Eingabeparameter `p_…`.
- Rückgabetyp explizit (`RETURNS <typ>` oder `RETURNS TABLE(...)`).

## Pflichten
- Idempotent: `CREATE OR REPLACE FUNCTION …`.
- **Volatilitäts-Klassifikation** korrekt setzen: `IMMUTABLE` (reine Berechnung, z. B. Datentyp-Konvertierung in `helper`), `STABLE` (nur lesend), `VOLATILE` (schreibend/Seiteneffekte).
- Lese-/Schreibfunktionen für `config` sauber trennen.
- Sprache: `plpgsql` oder `sql`; PL/Python nur, wo zwingend nötig (`plpython3u`) — dann Sicherheit beachten.
- Funktionen sollen **keine** Daten unkontrolliert ändern; Schreibvorgänge gehören in der Regel in Prozeduren.

## Template
```sql
-- <schema>.fn<Name> — <Beschreibung>
CREATE OR REPLACE FUNCTION <schema>.fn_<name>(
    p_input text
)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT /* Berechnung auf Basis von p_input */ p_input;
$$;
```
