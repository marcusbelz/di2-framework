# Rule: Views (PostgreSQL 17)

Konventionen für Views. Je View **ein** Skript unter
`db/schemas/<schema>/views/v<Name>.sql`.

## Benennung
- Präfix `v`, schema-qualifiziert: `<schema>.v<Name>` (z. B. `log.v_execution_duration`).
- Sprechende Namen, die die Auswertung beschreiben.

## Pflichten
- Idempotent: `CREATE OR REPLACE VIEW …`.
- Nur lesend; keine Seiteneffekte.
- Spalten explizit benennen und aliasieren (kein `SELECT *` in dauerhaften Views).
- Schema-qualifizierte Quelltabellen/-views.
- Für teure Aggregationen ggf. `MATERIALIZED VIEW` erwägen (dann Refresh-Strategie dokumentieren).
- `COMMENT ON VIEW` mit fachlicher Beschreibung.

## Template
```sql
-- <schema>.v<Name> — <Beschreibung der Auswertung>
CREATE OR REPLACE VIEW <schema>.v_<name> AS
SELECT
    t.spalte_1                         AS spalte_1,
    count(*)                           AS anzahl
FROM <schema>.<tabelle> AS t
GROUP BY t.spalte_1;

COMMENT ON VIEW <schema>.v_<name> IS '<Zweck der View>';
```
