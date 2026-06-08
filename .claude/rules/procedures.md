# Rule: Prozeduren (PostgreSQL 17 / PL/pgSQL)

Konventionen für Prozeduren. Je Prozedur **ein** Skript unter
`db/schemas/<schema>/procedures/sp<Name>.sql`.

## Benennung & Signatur
- Präfix `sp`, schema-qualifiziert: `<schema>.sp<Name>` (z. B. `etl.sp_load_data`).
- Parameter mit Modus und Präfix: `IN p_…`, `OUT …`, `INOUT io_…`.
- `LANGUAGE plpgsql`.

## Pflichten
- Idempotent: `CREATE OR REPLACE PROCEDURE …`.
- **Dynamic SQL** (Kernaufgabe von `etl`): immer mit `format()` + `%I`/`%L` bzw. parametrisiert via `USING` — niemals String-Konkatenation von Eingaben (SQL-Injection).
- **Protokollierung**: Komponentenebene (`log`-Prozeduren) am Anfang anlegen, am Ende auf Erfolg/Fehler aktualisieren; Datenfehler in `log.error`.
- **Fehlerbehandlung**: `EXCEPTION WHEN OTHERS THEN` → Fehler protokollieren, Status setzen, sinnvoll weiterreichen (`RAISE`).
- Mengenbasiert statt Cursor, wo möglich.

## Template
```sql
-- <schema>.sp<Name> — <Beschreibung>
CREATE OR REPLACE PROCEDURE <schema>.sp_<name>(
    IN p_param_1 text
    -- weitere Parameter ...
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_component_id bigint;
BEGIN
    -- log: Komponente starten
    -- ... fachliche Logik (Dynamic SQL via format()/USING) ...
    -- log: Komponente erfolgreich
EXCEPTION
    WHEN OTHERS THEN
        -- log: Komponente fehlerhaft + log.error
        RAISE;
END;
$$;
```
