# Rule: Trigger (PostgreSQL 17)

Konventionen für Trigger. Je Trigger **ein** Skript unter
`db/schemas/<schema>/trigger/<trigger>.sql`. Ein Trigger besteht aus einer
**Trigger-Funktion** (`RETURNS trigger`) und der **Trigger-Definition**.

## Benennung
- Trigger-Funktion: `<schema>.fn_trg_<tabelle>_<zweck>`.
- Trigger: `trg_<tabelle>_<zweck>` (z. B. `trg_component_set_audit`).

## Pflichten
- Idempotenz: `CREATE OR REPLACE FUNCTION` + `DROP TRIGGER IF EXISTS` vor `CREATE TRIGGER`.
- Zeitpunkt/Ereignis bewusst wählen (`BEFORE`/`AFTER`, `INSERT`/`UPDATE`/`DELETE`), `FOR EACH ROW` vs. `FOR EACH STATEMENT`.
- Trigger-Funktion gibt korrektes `NEW`/`OLD`/`NULL` zurück.
- Schlank halten: keine schwere Geschäftslogik, keine unkontrollierten Seiteneffekte; keine Privilege-Escalation (`SECURITY DEFINER` nur mit Begründung und gesetztem `search_path`).
- Endlos-/Rekursionsschleifen vermeiden.
- Zweck im Skript kommentieren.

## Template
```sql
-- Trigger-Funktion: setzt Audit-Spalten auf <schema>.<tabelle>
CREATE OR REPLACE FUNCTION <schema>.fn_trg_<tabelle>_set_audit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.created_at := COALESCE(NEW.created_at, now());
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_<tabelle>_set_audit ON <schema>.<tabelle>;
CREATE TRIGGER trg_<tabelle>_set_audit
    BEFORE INSERT ON <schema>.<tabelle>
    FOR EACH ROW
    EXECUTE FUNCTION <schema>.fn_trg_<tabelle>_set_audit();
```
