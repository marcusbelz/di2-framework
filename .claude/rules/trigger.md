# Rule: Trigger (PostgreSQL 17)

> **Maßgeblich sind die SQL-Code-Konventionen in [sql.md](sql.md) — vor jedem Skript lesen.**
> Trigger-Funktion **`tf_<entity>`** (`RETURNS TRIGGER`, **kein** `DROP FUNCTION` — nur
> `CREATE OR REPLACE`, Dollar-Quoting `$triggerfunction$`), Trigger **`tr_<type>_<entity>`**
> (`<type>` = `i`/`u`/`d`/`iud`), `TG_OP` mit `IF/ELSEIF/ELSE` (alle drei Zweige), `ELSE →
> RETURN NULL`, INSERT → `NEW`/`RETURN NEW`, DELETE → `OLD`/`RETURN OLD`. **Bei Widerspruch
> gilt sql.md.**
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
