# Rule: Tabellen (PostgreSQL 17)

> **Maßgeblich sind die SQL-Code-Konventionen in [sql.md](sql.md) — vor jedem Skript lesen.**
> Naming (snake_case, **singular**, PK `id bigserial` + `CONSTRAINT pk_<table>`, Natural Keys
> als `UNIQUE`, Timestamps mit Suffix **`_on`**), Layout/Alignment (Leading-Comma, Spalten
> Name|Typ|Nullability|Default), Datei-Gerüst (`\echo`-Kopf/Fuß, `OWNER TO`) und FK-Regeln
> stehen dort. **Bei Widerspruch gilt sql.md.**
>
> **Schema-Variablen:** im Framework `:schema_config` / `:schema_etl` / `:schema_helper` /
> `:schema_log` und `:schema_owner` verwenden — **nicht** `:schema_app_*` aus den sql.md-Beispielen
> (siehe `db/config/*.env.sql`).

## Framework-spezifisch
- **Ablage:** je Tabelle ein Skript unter `db/schemas/<schema>/tables/<NNN>.<tabelle>.sql`.
  `<NNN>` = 3-stellige **Tabellen-Gruppennummer** (je Schema fortlaufend in Erstellungs-Reihenfolge
  vergeben, nie neu verteilt). Diese Nummer tragen alle Objekte dieser Tabelle (siehe sql.md
  „File Naming & Numbering").
- **Idempotenz:** `CREATE TABLE IF NOT EXISTS …`.
- **RLS** auf sensiblen Tabellen aktivieren (v. a. `log.*`); Policies → [policies.md](policies.md).
- **Audit-Spalten:** die sql.md-Variante `created_by`/`modified_by` = E-Mail des App-Users ist
  app-geprägt — für Framework-Tabellen nur dort, wo fachlich sinnvoll (z. B. `config`).
  Log-Tabellen tragen ihre eigenen Zeit-/Status-Spalten der Protokollierung.
