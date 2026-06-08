# Rule: Views (PostgreSQL 17)

> **Maßgeblich sind die SQL-Code-Konventionen in [sql.md](sql.md) — vor jedem Skript lesen.**
> Naming **`vw_<name>`**, snake_case, vertikales SELECT/FROM/WHERE-Layout, JOIN-Alignment
> (`T01`/`T02`…), Datei-Gerüst (`\echo`, `OWNER TO`). **Bei Widerspruch gilt sql.md.**
>
> **Schema-Variablen:** `:schema_config`/`:schema_etl`/`:schema_helper`/`:schema_log` und
> `:schema_owner` statt `:schema_app_*`.

## Framework-spezifisch
- **Ablage:** je View ein Skript unter `db/schemas/<schema>/views/<NNN>.vw_<name>.sql`
  (Log-Views: `db/schemas/log/views/`). `<NNN>` = Nummer der zugrunde liegenden Haupttabelle.
- Idempotent (`CREATE OR REPLACE VIEW`), **nur lesend**, Spalten explizit benennen/aliasieren
  (kein `SELECT *` in dauerhaften Views).
- Teure Aggregationen ggf. `MATERIALIZED VIEW` + dokumentierte Refresh-Strategie.
- `COMMENT ON VIEW` mit fachlicher Beschreibung.
