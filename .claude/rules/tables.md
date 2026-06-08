# Rule: Tabellen (PostgreSQL 17)

Konventionen für Tabellen-Skripte im di2-framework. Je Tabelle **ein** Skript unter
`db/schemas/<schema>/tables/<Tabelle>.sql`.

## Benennung
- Schema-qualifiziert: `<schema>.<Tabelle>` (z. B. `log.component`).
- Tabellen- und Spaltennamen in `snake_case`.
- Primärschlüssel-Spalte: `<tabelle>_id` (oder `id`), als `bigint GENERATED ALWAYS AS IDENTITY`.

## Aufbau (Pflicht)
- Idempotent: `CREATE TABLE IF NOT EXISTS …`.
- Primärschlüssel explizit benennen: `CONSTRAINT pk_<tabelle> PRIMARY KEY (...)`.
- Fremdschlüssel: `CONSTRAINT fk_<tabelle>_<ref> FOREIGN KEY ...`.
- Datentypen: `text` statt `varchar(n)` ohne fachlichen Grund; `timestamptz` für Zeitstempel; `numeric` für Beträge.
- Audit-Spalten wo sinnvoll: `created_at timestamptz NOT NULL DEFAULT now()`, `created_by text`.
- Sinnvolle `NOT NULL`- und `CHECK`-Constraints.
- `COMMENT ON TABLE`/`COMMENT ON COLUMN` für fachliche Beschreibung.

## Template
```sql
-- <schema>.<tabelle> — <kurze Beschreibung>
CREATE TABLE IF NOT EXISTS <schema>.<tabelle> (
    <tabelle>_id  bigint GENERATED ALWAYS AS IDENTITY,
    -- fachliche Spalten ...
    created_at    timestamptz NOT NULL DEFAULT now(),
    created_by    text,
    CONSTRAINT pk_<tabelle> PRIMARY KEY (<tabelle>_id)
);

COMMENT ON TABLE <schema>.<tabelle> IS '<Zweck der Tabelle>';
```
