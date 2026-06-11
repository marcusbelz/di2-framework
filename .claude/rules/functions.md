# Rule: Funktionen (PostgreSQL 17)

> **Übergreifende SQL-Konventionen siehe [sql.md](sql.md) — vor jedem Skript lesen** (Naming
> `fn_<verb>_<name>`, Parameter-Prefix `p_`, Variablen `l_`, Dollar-Quoting `$function$`,
> `RETURNS`/`LANGUAGE` je eigene Zeile, tabellarisches Alignment, Datei-Gerüst `\echo`/`DROP
> FUNCTION … (signatur)`/`CREATE OR REPLACE`/`OWNER TO`). **Bei Widerspruch gilt sql.md.**
>
> **Geteilte PL/pgSQL-Body-Regeln** (gelten für Functions identisch wie für Procedures) stehen in
> [procedures.md](procedures.md):
> [Parameter-Reihenfolge](procedures.md#parameter-reihenfolge-id-zuerst) ·
> [Parameter-Dokumentation](procedures.md#parameter-dokumentation-inline-block-vor-create) ·
> [Body-Struktur](procedures.md#body-struktur-get-name--check-parameter--workload) ·
> [Fehler-Messages & `format()`](procedures.md#fehler-messages--format).
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

## Skelett (Stored Function)

> Reine Validator-Functions ohne Fehler-`RAISE` lassen den `Get name`-Abschnitt der
> [Body-Struktur](procedures.md#body-struktur-get-name--check-parameter--workload) weg; die
> `Check parameter`/`Workload`-Trennung ist dort optional. Der `-- Parameter`-Block ist
> auch bei Functions mit Parametern Pflicht.

```sql
\echo "## CREATE FUNCTION :schema_name.fn_is_null_or_empty"

DROP FUNCTION IF EXISTS :schema_name.fn_is_null_or_empty(varchar, bigint);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_parameter1        varchar
--       <Bedeutung von p_parameter1>
--    p_parameter2        bigint
--       <Bedeutung von p_parameter2>
-- --------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION :schema_name.fn_is_null_or_empty
(
    IN    p_parameter1        varchar
   ,IN    p_parameter2        bigint
)
RETURNS varchar
LANGUAGE plpgsql
AS $function$
DECLARE
   l_returnvalue             varchar;
BEGIN

   -- Logic

   RETURN l_returnvalue;

EXCEPTION WHEN others THEN
   RAISE NOTICE '##### %', SQLERRM;
   RETURN NULL::varchar;
END;
$function$;

ALTER FUNCTION :schema_name.fn_is_null_or_empty(varchar, bigint) OWNER TO :schema_owner;

\echo "## CREATE FUNCTION :schema_name.fn_is_null_or_empty - DONE"
```
