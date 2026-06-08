# Rule: Prozeduren (PostgreSQL 17 / PL/pgSQL)

> **Maßgeblich sind die SQL-Code-Konventionen in [sql.md](sql.md) — vor jedem Skript lesen.**
> Naming `sp_<verb>_<entity>` (`upd`/`ins`/`del`/`get`/`exe`/`dup`), Parameter-Prefix `p_`,
> Variablen `l_`, Dollar-Quoting `$procedure$`, tabellarisches Alignment, Body-Struktur
> **Get name / Check parameter / Workload**, `format($$…$$, …)`-Fehlermeldungen über separate
> Variablen, Datei-Gerüst (`\echo`, `DROP … ; CREATE OR REPLACE …`, `OWNER TO`). **Bei
> Widerspruch gilt sql.md.**
>
> **Schema-Variablen:** `:schema_config`/`:schema_etl`/`:schema_helper`/`:schema_log` und
> `:schema_owner` statt `:schema_app_*`. Schema-Name **immer** als Variable, nie hartkodiert.

## Framework-spezifisch
- **Ablage:** je Prozedur ein Skript unter `db/schemas/<schema>/procedures/<NNN>.sp_<verb>_<entity>.sql`.
  `<NNN>` = Nummer der **Haupttabelle**, die die Prozedur beschreibt (Cross-Table-Heuristik s. sql.md).
- **Protokollierung integrieren:** Component am Start anlegen, am Ende auf Erfolg/Fehler
  aktualisieren; Trace analog; Datenfehler nach `log.error`; Status im `EXCEPTION`-Block
  deterministisch setzen.
- **Dynamic SQL** (Kernaufgabe `etl`): nur `format()` mit `%I`/`%L` bzw. parametrisiert via
  `USING` — niemals String-Konkatenation von Eingaben.
- **Hinweis lc_messages (BUG-0337 aus sql.md):** Nutzt die Logging-Konvention `SET LOCAL
  lc_messages TO 'C'` (Komponenten-Parsing aus `PG_CONTEXT`), braucht die Laufzeitrolle
  `GRANT SET ON PARAMETER lc_messages` — siehe Hinweis in `db/database/08.create.role.rw.sql`.
