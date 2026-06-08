# Rule: Funktionen (PostgreSQL 17)

> **Maßgeblich sind die SQL-Code-Konventionen in [sql.md](sql.md) — vor jedem Skript lesen.**
> Naming `fn_<verb>_<name>`, Parameter-Prefix `p_`, Variablen `l_`, Dollar-Quoting `$function$`,
> `RETURNS`/`LANGUAGE` je eigene Zeile, tabellarisches Alignment, Datei-Gerüst (`\echo`,
> `DROP FUNCTION … (signatur); CREATE OR REPLACE …`, `OWNER TO`). **Bei Widerspruch gilt sql.md.**
>
> **Schema-Variablen:** `:schema_config`/`:schema_etl`/`:schema_helper`/`:schema_log` und
> `:schema_owner` statt `:schema_app_*`.

## Framework-spezifisch
- **Ablage:** je Funktion ein Skript unter `db/schemas/<schema>/functions/<NNN>.fn_<verb>_<name>.sql`.
  `<NNN>` = Nummer der Haupttabelle, auf die sich die Funktion bezieht (sql.md „File Naming & Numbering").
- **Volatilität korrekt setzen:** `IMMUTABLE` (reine Berechnung, z. B. `helper`-Konvertierungen),
  `STABLE` (nur lesend), `VOLATILE` (Seiteneffekte).
- Schreibvorgänge gehören in der Regel in **Prozeduren**, nicht in Funktionen.
- PL/Python (`plpython3u`) nur wo zwingend nötig.
