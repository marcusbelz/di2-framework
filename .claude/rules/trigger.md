# Rule: Trigger (PostgreSQL 17)

> **Übergreifende SQL-Konventionen siehe [sql.md](sql.md) — vor jedem Skript lesen** (Naming,
> tabellarisches Alignment, Datei-Gerüst, File Naming & Numbering). **Bei Widerspruch gilt sql.md.**
> Trigger-Funktion **`tf_<entity>`** (`RETURNS TRIGGER`, **kein** `DROP FUNCTION` — nur
> `CREATE OR REPLACE`, Dollar-Quoting `$triggerfunction$`), Trigger **`tr_<type>_<entity>`**
> (`<type>` = `i`/`u`/`d`/`iud`). Die **Trigger-/Trigger-Function-Skelette** und die `TG_OP`-Logik
> stehen **hier** in dieser Datei.
>
> **Schema-Variablen:** `:schema_config`/`:schema_etl`/`:schema_helper`/`:schema_log` und
> `:schema_owner` statt `:schema_app_*`.

## Framework-spezifisch
- **Ablage:** je Trigger ein Skript unter `db/schemas/<schema>/trigger/<NNN>.<tf|tr>_<...>.sql`
  (Trigger-Funktion + Trigger-Definition). `<NNN>` = Nummer der Tabelle, an deren Trigger die
  Funktion hängt (Cross-Table-Heuristik s. sql.md).
- Schlank halten: keine schwere Geschäftslogik, keine unkontrollierten Seiteneffekte, keine
  Endlos-/Rekursionsschleifen.
- `SECURITY DEFINER` nur mit Begründung **und** gesetztem `search_path`.

## Trigger-Logik (`TG_OP`)
- Check `TG_OP` with `IF / ELSEIF / ELSE` — always cover all three branches
- `ELSE` → `RETURN NULL` (no implicit fall-through)
- On INSERT: pass `NEW.<column>`, `RETURN NEW`
- On DELETE: pass `OLD.<column>`, `RETURN OLD`
- Always pass `TG_OP` as the first argument to called procedures

## Skelett (Trigger Function)

> **Kein `DROP FUNCTION` für Trigger-Funktionen.** Trigger hängen an der Funktion; ein `DROP FUNCTION IF EXISTS` würde beim Re-Run mit `cannot drop function ... because other objects depend on it (trigger ...)` abbrechen. `CREATE OR REPLACE FUNCTION` allein ist trigger-safe, solange die Signatur stabil bleibt — bei Trigger-Funktionen mit `RETURNS TRIGGER` ohne Parameter ist sie das per Definition. Für **non-trigger** Stored Functions (siehe [functions.md](functions.md)) bleibt das `DROP FUNCTION IF EXISTS … (signatur);` + `CREATE OR REPLACE FUNCTION`-Pattern korrekt.

```sql
\echo "## CREATE FUNCTION :schema_name.tf_table()"

CREATE OR REPLACE FUNCTION :schema_name.tf_table()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $triggerfunction$
BEGIN

   -- Logic

END;
$triggerfunction$;

ALTER FUNCTION :schema_name.tf_table() OWNER TO :schema_owner;

\echo "## CREATE FUNCTION :schema_name.tf_table() - DONE"
```

## Skelett (Trigger)

```sql
\echo "## CREATE TRIGGER tr_iud_table"

DROP TRIGGER IF EXISTS tr_iud_table ON :schema_name.log_execution;

CREATE TRIGGER tr_iud_table
BEFORE INSERT OR UPDATE OR DELETE ON :schema_name.log_execution
FOR EACH ROW
   EXECUTE PROCEDURE :schema_name.tf_table();

\echo "## CREATE TRIGGER tr_iud_table - DONE"
```
