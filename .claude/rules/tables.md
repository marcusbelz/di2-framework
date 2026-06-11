# Rule: Tabellen (PostgreSQL 17)

> **Übergreifende SQL-Konventionen siehe [sql.md](sql.md) — vor jedem Skript lesen** (Naming
> snake_case/**singular**, PK `id bigserial` + `CONSTRAINT pk_<table>`, Natural Keys als `UNIQUE`,
> Timestamps mit Suffix **`_on`**, tabellarisches Alignment, Datei-Gerüst `\echo`-Kopf/Fuß +
> `OWNER TO`, File Naming & Numbering). **Bei Widerspruch gilt sql.md.** Die **tabellen-spezifischen**
> Regeln (CREATE-TABLE-Layout, Foreign Keys / Unique, Comments, INSERT/Seed) stehen **hier** in
> dieser Datei.
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
- **Datentypen (verbindlich — hier ist die maßgebliche Stelle):**
  - Zeichenspalten immer **`varchar`**, **nie `text`**. In PostgreSQL ist `varchar` (ohne Länge)
    intern identisch zu `text` (gleiche Speicherung/Performance); `varchar(n)` erzwingt zusätzlich
    eine Längenprüfung. Unbegrenzte Felder: `varchar` **ohne** Länge.
  - Audit-Spalten `created_by` / `modified_by` immer **`varchar(100)`**.
- **Audit-Spalten-Konvention (Default & Nullability):**
  - `created_on timestamptz NOT NULL DEFAULT now()`
  - `created_by varchar(100) NOT NULL DEFAULT current_user`
  - `modified_on timestamptz NULL` (kein Default)
  - `modified_by varchar(100) NULL` (kein Default)
  - `modified_on` / `modified_by` werden **nicht** per Default gesetzt, sondern bei jedem `UPDATE`
    durch den `BEFORE UPDATE`-Trigger `log.tf_set_modified()` (→ `now()` / `current_user`). Jede
    Tabelle mit `modified_*`-Spalten bekommt einen `tr_u_<tabelle>`-Trigger, der diese Funktion ruft.
- **Comments (`COMMENT ON TABLE` + `COMMENT ON COLUMN`):** Pflicht-Tabellenkommentar; Spaltenkommentare
  v. a. bei breiten Tabellen. Vollständige Regel inkl. Layout → Abschnitt
  [Comments (Tabelle & Spalten)](#comments-tabelle--spalten) unten.
- **RLS** auf sensiblen Tabellen aktivieren (v. a. `log.*`); Policies → [policies.md](policies.md).
- **Audit-Spalten:** die sql.md-Variante `created_by`/`modified_by` = E-Mail des App-Users ist
  app-geprägt — für Framework-Tabellen nur dort, wo fachlich sinnvoll (z. B. `config`).
  Log-Tabellen tragen ihre eigenen Zeit-/Status-Spalten der Protokollierung.

## CREATE TABLE — Spalten & Constraints

- Leading-Comma: erstes Element 4 Spaces, Folgeelemente `   ,` (3 + Komma).
- Tabellarische Spalten **Name | Typ | Nullability | Default**:
  - `NULL` ist vertikal ausgerichtet; das optionale `NOT ` sitzt in der 4-Zeichen-Spalte links davor (alle `NULL` fluchten, mit oder ohne `NOT`).
  - `DEFAULT <wert>` folgt direkt nach `NOT NULL` / `NULL`.
  - Overflow: Namen, die über die Namensspalte hinauslaufen, brechen das Alignment nur für ihre eigene Zeile.
- **Inline im `CREATE TABLE` (innerhalb der `( … )`): nur `PRIMARY KEY` und `CHECK`.**
  - **PK explizit als benannter Constraint** `CONSTRAINT pk_<table> PRIMARY KEY (…)` als **letztes** Element des Blocks — **nie** als Spalten-Inline (`id bigserial PRIMARY KEY`).
  - `CHECK`-Constraints (falls vorhanden) ebenfalls inline, durch Leerzeile abgesetzt; Ausdrücke untereinander ausgerichtet.
- **`UNIQUE` und `FOREIGN KEY` stehen NICHT im `CREATE TABLE`,** sondern als separate `ALTER TABLE`-Statements **nach** dem `ALTER … OWNER` — nach Familie gruppiert: erst alle `UNIQUE` unter `-- Unique constraints`, dann alle `FOREIGN KEY` unter `-- Foreign keys`.
  - **Idempotenz:** je Constraint `ALTER TABLE … DROP CONSTRAINT IF EXISTS <name>;` direkt gefolgt von `ALTER TABLE … ADD CONSTRAINT <name> …;` (PostgreSQL kennt kein `ADD CONSTRAINT IF NOT EXISTS`; ein `DO`-Guard scheidet aus, weil psql `:schema_*` im Dollar-Quoting nicht interpoliert). **Trade-off:** das Re-Add validiert FKs bzw. baut UNIQUE-Indizes bei **jedem** Deploy neu — bei sehr großen Tabellen bewusst einsetzen.
- Audit-Spalten unter `-- Audit`, durch Leerzeile abgesetzt.
- **Reihenfolge nach `ALTER … OWNER`:** `-- Unique constraints` → `-- Foreign keys` → Indizes → `ENABLE`/`FORCE ROW LEVEL SECURITY` → `-- Comments` (`COMMENT ON TABLE` + `COMMENT ON COLUMN`, siehe [Comments](#comments-tabelle--spalten)). `CREATE … INDEX` linearisiert (`CREATE [UNIQUE] INDEX IF NOT EXISTS <name> ON <table> (…) [WHERE …];`).

```sql
CREATE TABLE IF NOT EXISTS :schema_name.example
(
    id              bigserial     NOT NULL
   ,name            varchar(200)  NOT NULL
   ,parent_id       bigint            NULL
   ,is_active       boolean       NOT NULL DEFAULT true

   ,CONSTRAINT pk_example  PRIMARY KEY (id)

   ,CONSTRAINT chk_example_name  CHECK (length(trim(name)) > 0)
);
ALTER TABLE :schema_name.example OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Unique constraints
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_name.example DROP CONSTRAINT IF EXISTS uq_example_name;
ALTER TABLE :schema_name.example ADD  CONSTRAINT uq_example_name UNIQUE (name);

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_name.example DROP CONSTRAINT IF EXISTS fk_example_parent_id;
ALTER TABLE :schema_name.example ADD  CONSTRAINT fk_example_parent_id FOREIGN KEY (parent_id) REFERENCES :schema_name.example(id) ON DELETE CASCADE;
```

## Foreign Keys

- FK-Constraints benennen: `fk_<tabelle>_<spalte>`.
- **Ablage: als separate `ALTER TABLE … ADD CONSTRAINT` NACH der Tabelle** (nicht inline im
  `CREATE TABLE`), idempotent per `DROP CONSTRAINT IF EXISTS` + `ADD`, gruppiert unter
  `-- Foreign keys` — siehe [CREATE TABLE — Spalten & Constraints](#create-table--spalten--constraints).
- `ON DELETE`-Verhalten bewusst wählen: `CASCADE` für abhängige Detail-Zeilen, `SET NULL` für
  optionale Referenzen, sonst Default (Restrict).
- Referenzierte Tabelle immer schema-qualifiziert über die Schema-Variable.
- Natural Keys werden `UNIQUE`-Constraints (nicht der PK — der ist immer `id bigserial`); ebenfalls
  als separates `ALTER TABLE … ADD CONSTRAINT` nach der Tabelle, gruppiert unter `-- Unique constraints`.
- Audit-Spalten `created_by` / `modified_by` (nur dort, wo fachlich genutzt — v. a. `config`):
  vom aufrufenden Prozess gesetzt — **nie** `CURRENT_USER` (das wäre nur die Verbindungsrolle,
  nicht der fachliche Akteur). Datentyp/Länge siehe Datentypen oben.

Beispiel (`UNIQUE`/`FK` als separate `ALTER TABLE` nach der Tabelle — siehe [CREATE TABLE — Spalten & Constraints](#create-table--spalten--constraints)):
```sql
CREATE TABLE IF NOT EXISTS :schema_name.example
(
    id           bigserial     NOT NULL
   ,parent_id    bigint            NULL
   ,name         varchar(200)  NOT NULL
   ,created_on   timestamptz   NOT NULL DEFAULT now()
   ,created_by   varchar(100)  NOT NULL
   ,modified_on  timestamptz   NOT NULL DEFAULT now()
   ,modified_by  varchar(100)  NOT NULL

   ,CONSTRAINT pk_example  PRIMARY KEY (id)
);
ALTER TABLE :schema_name.example OWNER TO :schema_owner;

-- --------------------------------------------------------------------------------
-- Unique constraints
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_name.example DROP CONSTRAINT IF EXISTS uq_example_name;
ALTER TABLE :schema_name.example ADD  CONSTRAINT uq_example_name UNIQUE (name);

-- --------------------------------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------------------------------
ALTER TABLE :schema_name.example DROP CONSTRAINT IF EXISTS fk_example_parent_id;
ALTER TABLE :schema_name.example ADD  CONSTRAINT fk_example_parent_id FOREIGN KEY (parent_id) REFERENCES :schema_name.example(id) ON DELETE CASCADE;
```

## Comments (Tabelle & Spalten)

> Framework-lokal (Umfang **und** Layout), weil `COMMENT ON TABLE` / `COMMENT ON COLUMN`
> ausschließlich Tabellen betreffen — bewusste Ausnahme von „Layout steht in sql.md". Der
> `COMMENT`-Block steht **am Dateiende**, nach `-- Unique constraints` / `-- Foreign keys` /
> Indizes / RLS.

**Umfang (was kommentiert wird):**
- **`COMMENT ON TABLE` ist Pflicht** — fachliche Kurzbeschreibung der Tabelle.
- **`COMMENT ON COLUMN` für fachliche Spalten:** jede Spalte mit nicht-offensichtlicher Bedeutung.
  **Pflicht bei breiten Tabellen** (Faustregel ab ~8 fachlichen Spalten — z. B.
  `config.check_constraint`, `config.table_metadata`, `log.error`, `log.trace`). Knapp und fachlich;
  bei Codes/Flags die zulässigen Werte nennen (z. B. `error_type` → `E`/`W`/`I`).
- **Keine Spaltenkommentare nötig:** der Surrogat-PK `id` und die Audit-Spalten
  `created_on` / `created_by` / `modified_on` / `modified_by` (framework-weit einheitlich).
- **FK-Spalten:** optionaler Kurzhinweis auf Zieltabelle / Beziehung — v. a. in der Log-Kette
  `execution` → `component` → `trace`.

**Layout:**
- Gruppiert unter einem **`-- Comments`-Banner** (3-Zeilen-Banner wie `-- Unique constraints` /
  `-- Foreign keys`).
- **Reihenfolge:** erst `COMMENT ON TABLE`, dann die `COMMENT ON COLUMN` in der Spalten-Reihenfolge
  des `CREATE TABLE`.
- **Referenz-Start ausgerichtet:** `COMMENT ON TABLE ` mit 2 Spaces, `COMMENT ON COLUMN ` mit 1 Space,
  sodass Tabellen- und Spaltenreferenz in **derselben Spalte** beginnen.
- **`IS`-Klausel nicht** tabellarisch ausgerichtet (Referenzlängen variieren zu stark); Schema stets
  über die Variable, Beschreibungstext in einfachen Hochkommas (Umlaute/ß zulässig).

```sql
-- --------------------------------------------------------------------------------
-- Comments
-- --------------------------------------------------------------------------------
COMMENT ON TABLE  :schema_config.process IS 'Stammdaten: benannte Prozesse (Konfigurationsdaten).';
COMMENT ON COLUMN :schema_config.process.name IS 'Eindeutiger Prozessname (Natural Key, UNIQUE).';
```

## INSERT / Seed

- `INSERT INTO <table>` dann `(` Spaltenliste `)`, dann `VALUES` dann `(` Werteliste `)` — Parens auf eigenen Zeilen, Leading-Comma. (Kurze Spaltenliste darf einzeilig hinter `INSERT INTO <table>` stehen — siehe Seed-Beispiel.)
- Mehrzeilige Seed-`VALUES`: Tupel Leading-Comma, eines pro Zeile; Tupel-Elemente in Spalten ausgerichtet (String-Spalten gepolstert).
- `ON CONFLICT (...) DO UPDATE` → `SET` → Leading-Comma-Zuweisungen.

```sql
INSERT INTO :schema_name.example (slug, name, is_active, created_by, modified_by)
VALUES
    ('a', 'Alpha', true,  '<system>', '<system>')
   ,('b', 'Beta',  false, '<system>', '<system>')
ON CONFLICT (slug) DO UPDATE
SET
    name        = EXCLUDED.name
   ,is_active   = EXCLUDED.is_active
   ,modified_on = now();
```
