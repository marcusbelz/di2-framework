# SQL rules

- [SQL](#sql)
  - [Naming Conventions](#naming-conventions)
    - [Prefixes](#prefixes)
    - [Placeholder](#placeholder)
    - [Dollar Quoting](#dollar-quoting)
    - [Common](#common)
    - [Examples](#examples)
    - [Tabellarisches Alignment (Parameter, Variablen, JOINs)](#tabellarisches-alignment-parameter-variablen-joins)
  - [File Naming & Numbering](#file-naming--numbering)
  - [Single Responsibility](#single-responsibility)
  - [Fehler-Messages & `format()`](#fehler-messages--format)
  - [Foreign Keys](#foreign-keys)
  - [Layout & Formatierung (DDL/DML)](#layout--formatierung-ddldml)
  - [Structure Conventions](#structure-conventions)
    - [Stored Procedure](#stored-procedure)
    - [Stored Function](#stored-function)
    - [Trigger Function](#trigger-function)
    - [Trigger](#trigger)

# SQL

## Naming conventions

### Prefixes
| Object type        | prefix  | example                |
|--------------------|---------|------------------------|
| Stored Procedure   | `sp_`   | `sp_upd_table`         |
| Stored Function    | `fn_`   | `fn_is_null_or_empty`  |
| Trigger Function   | `tf_`   | `tf_upd_table`         |
| Trigger            | `tr_`   | `tr_iu_table`          |
| View               | `vw_`   | `vw_execution_duration`|

### Placeholder

#### `<entity>`  : Name of the main table that the procedure is dealing with

#### `<verb>`  :
  - `upd` = update
  - `ins` = insert
  - `del` = delete
  - `dup` = duplicate (copy a row to a new row, picking a new surrogate key — used for "save as" / "duplicate" UX flows; e.g. `sp_dup_project`)
  - `get` = select
  - `exe` = execute

#### `<type>`:
  - `i`   = insert
  - `u`   = update
  - `d`   = delete
  - `iud` = combination of types

### Dollar quoting
| Object type        | Dollar Quoting     |
|--------------------|--------------------|
| stored procedure   | `$procedure$`      |
| stored function    | `$function$`       |
| trigger function   | `$triggerfunction$`|
| trigger            | `$trigger$`        |

### Common
- ALWAYS **snake_case**
- Schema-Name in **DDL** (außerhalb von Dollar-Quoting): immer über die Variable, **nie** hartkodiert
  — gilt für `CREATE`/`DROP`/`ALTER`/`OWNER`, FK-`REFERENCES`, `\echo` usw.
  - **Framework:** die konkreten Schema-Variablen sind `:schema_config` / `:schema_etl` / `:schema_helper` / `:schema_log`, der Schema-Owner ist `:schema_owner` (siehe `db/config/*.env.sql`). In den Beispielen unten steht `:schema_name` **stellvertretend** für die jeweils konkrete Schema-Variable.
  - **Ausnahme — Prozedur-/Funktions-Body (Dollar-Quoting):** psql interpoliert `:schema_*` **nicht** innerhalb von `$procedure$…$procedure$` / `$function$…$function$` (Syntaxfehler `at or near ":"`). Objektreferenzen im Body werden daher **schema-qualifiziert hartkodiert** (`config.process`, `log.execution`). Das ist zulässig, weil die vier Schemanamen über **alle** Umgebungen fix sind (`db/config/*.env.sql` setzt sie konstant); einzig ein globales Schema-Rename erfordert ein `grep`-Replace der Bodies. Voll qualifizierte Body-Referenzen statt `SET search_path` — Letzteres nur, wenn unqualifizierte Namen unvermeidbar sind.
- ALWAYS use **singular** table names (`user`, `project`, `task` — never `users`, `projects`, `tasks`). Applies to the table name itself; foreign-key column names follow naturally (`user_id`, not `users_id`).
- ALWAYS suffix timestamp columns with **`_on`**, never `_at` (`created_on`, `modified_on`, `deleted_on`, `last_login_on`, `first_seen_on`). The TypeScript camelCase mapping uses the same suffix (`createdOn`, `lastLoginOn`).
- ALWAYS give each table a surrogate primary key column **`id bigserial NOT NULL`** with `CONSTRAINT pk_<table> PRIMARY KEY (id)`. Natural keys (composite or otherwise) become **`UNIQUE` constraints**, not the PK. Applies to all tables, including lookup / Stammdaten tables and existing tables — existing deployed tables are dropped + recreated rather than data-migrated. Where a row needs to carry an external identifier, it lives in its own `UNIQUE` column (e.g. `external_ref varchar UNIQUE NOT NULL`), separate from the surrogate `id`.
- ALWAYS store **the email address of the authenticated app user** in the audit columns `created_by` and `modified_by` — no `DEFAULT CURRENT_USER` (Datentyp/Länge: siehe `tables.md`). The application supplies the email explicitly, either via a stored-procedure parameter (`p_actor_email varchar(100)`) or via a per-request session variable (`SET LOCAL app.actor_email = '…'` + column `DEFAULT current_setting('app.actor_email', true)`). The architecture step decides per feature which mechanism. `CURRENT_USER` (PG role) is **not** an acceptable substitute — it would always be the connection role (`di2_<env>_rw`, …), useless for app-level audit.
- ALWAYS prefix stored-procedure and stored-function parameters with **`p_`** (e.g. `p_project_id`, `p_actor_email`) — distinguishes them from local variables (`l_` prefix). The mode keyword (`IN` / `OUT` / `INOUT`) carries the direction; do not encode mode in the name (use `p_result` not `p_out_result`).
- `RETURNS` clause on a separate line
- `LANGUAGE plpgsql` on a separate line
- indentation: **3 white spaces** within 
  - `BEGIN`/`END`
  - `IF`/`ELSE`/`END IF`
  - `SELECT`/`INTO`/`FROM`/`WHERE`/`GROUP BY`/`HAVING`
- indentation: **3 white spaces** after 
  - `FOR`

### Examples
- procedure names        : `sp_<verb>_<entity>` (e.g. `sp_upd_table`)
- function names         : `fn_<verb>_<name>`   (e.g. `fn_is_null_or_empty`)
- trigger function names : `tf_<entity>`        (e.g. `tf_table`)
- trigger names          : `tr_<type>_<entity>` (e.g. `tr_iud_table`)
- view names             : `vw_<name>`          (e.g. `vw_errors_by_table`)

### Tabellarisches Alignment (Parameter, Variablen, JOINs)

> Aus den gold-standard-Dateien vermessen. Spaltennummern sind 1-basiert ab Zeilenanfang. Grundeinrückung ist app-weit **3 Spaces** (siehe Common). Die Sub-Spalten (Name, Typ) richten sich tabellarisch an einer gemeinsamen Spalte aus = längster Bezeichner des Blocks + Abstand; längere Bezeichner laufen über (Overflow erlaubt, brechen das Alignment nur für ihre eigene Zeile).

**Prozedur-/Funktions-Parameter** (in der `( … )`-Signatur):

- `(` und `)` je auf eigener Zeile.
- Erstes Element **4 Spaces** Einrückung; Folgeelemente **3 Spaces + Leading-`,`** → das Modus-Keyword steht bei beiden in **Spalte 5**.
- Modus-Keyword (`IN` / `OUT` / `INOUT`) linksbündig, auf ein **6-Zeichen-Feld** gepolstert → Parametername ab **Spalte 11**.
- Parameter-Typ ausgerichtet in einer gemeinsamen Spalte = längster Parametername + Abstand (in der Referenz-Datei **Spalte 40**; bei kürzeren Signaturen entsprechend weiter links, Overflow bei längeren).

```sql
CREATE OR REPLACE PROCEDURE :schema_name.sp_example
(
    IN    p_source_table_id            bigint
   ,IN    p_actor_email                varchar
   ,INOUT p_result                     text
)
```

**Variablen-Deklarationen** (`DECLARE`-Block):

- **3 Spaces** Einrückung → Variablenname ab **Spalte 4**.
- Datentyp ausgerichtet in einer gemeinsamen Spalte = längster Variablenname + Abstand (Referenz-Datei **Spalte 30**).

```sql
DECLARE
   l_context                 varchar;
   l_session_actor           varchar;
   l_error_message           text;
```

**JOINs**:

- Immer voll qualifiziert: **`INNER JOIN`** statt nacktem `JOIN`; ebenso `LEFT JOIN` / `RIGHT JOIN` / `FULL JOIN` ausschreiben.
- **Tabellen-Aliase positionell** (`T01`, `T02`, `T03`, …) für **jede aliasierte Tabellen-Referenz** — JOIN, Single-Table-`FROM`, `UPDATE … FROM`, CTE-Korrelation, Subquery —, nummeriert in Reihenfolge des Auftretens **im jeweiligen Statement** (pro Statement neu ab `T01`). Unaliasierte Single-Table-Refs dürfen ohne Alias bleiben. **Warum positionell statt sprechend:** unterschiedlich lange Aliase (`pm`/`cp`/`sts`) brechen die tabellarische Ausrichtung der Feldnamen und werden unleserlich; gleichlange `T0n` halten die Spalten-Flucht. Sprechende Aliase verlieren bei vielen JOINs ohnehin ihre Aussagekraft.
- `ON` auf eigener Zeile, **unter dem `INNER`** ausgerichtet (gleiche Spalte wie `INNER JOIN` und die `FROM`-Tabelle).
- **Eine** Join-Bedingung: **2 Spaces** unter `ON` eingerückt — abweichend von der 3-Space-Grundeinrückung, weil `ON` nur 2 Zeichen breit ist und die Bedingung knapp dahinter fluchten soll.
- **Mehrere** Bedingungen: `AND`/`OR`-River wie im `WHERE` (führendes `AND`/`OR`, Bedingungen ausgerichtet, Vergleichs-`=` untereinander).

```sql
FROM
   :schema_log.component T01
   INNER JOIN :schema_log.execution T02
   ON
     T02.id = T01.execution_id
WHERE
       T01.execution_id = l_execution_id
   AND T02.status       = 'running'
```

## File Naming & Numbering

Jede DDL-Datei unter `db/schemas/<schema>/<objekttyp>/` trägt ein **3-stelliges Nummer-Prefix** vor dem Objekt-Namen, z. B. `003.sp_ins_execution.sql`. Das Prefix ist **kein globaler, fortlaufender Sequenz-Counter**, sondern ein **Tabellen-Gruppen-Indikator** (je Schema vergeben). Die Nummer ist orthogonal zu den Unterordnern: dieselbe `003` taucht in `tables/`, `procedures/`, `functions/`, `views/`, `trigger/` usw. auf — für jedes Objekt, das die Tabelle `003` beschreibt.

### Regel

- **Eine Tabelle = eine Nummer.** Alle DDL-Objekte, die zur selben Tabelle gehören (Tabelle selbst, ihre Policies, Trigger-Function, Trigger, Procedures, Data-Seed), tragen dasselbe Prefix.
- **Nummern werden in der Reihenfolge vergeben, in der Tabellen ins Schema kommen.** Einmal vergeben, niemals umverteilt — auch wenn eine Tabelle obsolet wird.
- **Disambiguation passiert über den Objekt-Namen-Suffix**, nicht über die Nummer. `003.sp_ins_project.sql` und `003.sp_upd_project.sql` haben bewusst dasselbe Prefix.

### Cross-Table-Objekte (Procedure / Function fasst mehrere Tabellen an)

Wähle das Prefix nach dieser Heuristik (in dieser Reihenfolge):

1. **Trigger-Funktion** → Prefix der Tabelle, an deren Trigger sie hängt. Beispiel: `tf_source_table_workflow_aggregate` liest aus `column_metadata` (007) und schreibt nach `source_table_selection` (006). Datei: `007.tf_source_table_workflow_aggregate.sql`, weil der Trigger `tr_iud_column_metadata_workflow_aggregate` auf `column_metadata` feuert.
2. **Procedure mit klarem Write-Target** → Prefix dieser Tabelle. Reads aus anderen Tabellen (Lookups, `FOR UPDATE`-Locks zur Defense-in-Depth) sind Begleit-Operationen und zählen nicht. Beispiel: `sp_recover_project_owner` lockt `project` (003) und schreibt nach `project_member` + `project_member_history` (004). Datei: `004.sp_recover_project_owner.sql`.
3. **Symmetrische Cross-Table-Operation** (gleichgewichtige Writes auf zwei unverwandte Tabellen) → **höhere** der beiden Gruppen-Nummern, damit beide Ziel-Tabellen beim `\ir`-Aufruf bereits existieren. In der Praxis selten — meistens lässt sich eine Tabelle als Driver identifizieren.

**Pflicht:** Der `--comment:`-Header der Datei nennt jede Cross-Table-Beziehung explizit, damit ein Suchender per `grep` und nicht nur per Prefix-Filter findet, was eine andere Tabelle anfasst.

### Warum diese Konvention (statt globaler Sequenz)

Bewusst **nicht** ein globaler `001., 002., 003., …`-Counter über alle Procedures hinweg. Die Tabellen-Gruppen-Variante hat drei konkrete Vorteile:

1. **Co-Location pro Tabelle.** `ls 007.*` zeigt alle Objekte einer Tabelle auf einen Blick — Driver für Reviews und Refactors.
2. **Keine Renummerier-Steuer.** Neue Procedure für `project_member`? Datei heißt `004.sp_neue_procedure.sql`, fertig — keine 20 anderen Dateien müssen umbenannt werden.
3. **Section-Ordering im Deploy-Runner (`db/scripts/`) löst Dependencies bereits.** Tables → Policies → Functions → Procedures → Triggers → Views → Data werden in separaten Blöcken geladen. Innerhalb eines Blocks ist die Reihenfolge meist egal (eine Procedure referenziert keine andere Procedure, nur Tabellen — die zu dem Zeitpunkt alle existieren).

### Single Source of Truth

Die Lade-Reihenfolge bestimmt der **Deploy-Runner** (`db/scripts/`): nach Sektion (Tables → Policies → Functions → Procedures → Triggers → Views → Data), innerhalb der Sektion nach Nummer. **Die Nummer ist Sortier-Helfer + Tabellen-Gruppen-Indikator, keine globale Sequenz.**

## Single Responsibility

- Each `CALL` statement delegates exactly **one** domain action to an `sp_` procedure
- One procedure = one responsibility (e.g. update status, set map access)

---

## Fehler-Messages & `format()`

Jede Message und jeder Error-Code, die an `RAISE EXCEPTION` (oder ein `RAISE WARNING`, das eine echte Message an den Client gibt) übergeben werden, werden **zuerst in separate Variablen gelegt** und erst dann ausgegeben. **Ausnahme:** diagnostische `RAISE NOTICE`-Traces (der `### procedure : %`-Eingangs-Trace und der `##### … SQLERRM`-Trace im `EXCEPTION`-Handler) bleiben einfaches Inline-`RAISE NOTICE` — sie sind Debug-Breadcrumbs, keine strukturierten Fehler-Messages. Hintergrund: keine hartkodierten Texte direkt am Funktions-/`RAISE`-Aufruf — der Code liest sich von oben nach unten (erst *was* geworfen wird, dann *dass* geworfen wird), und das `RAISE` bekommt nur noch Variablen.

### Regeln

- **Separate Variablen (PFLICHT):** `l_error_message text` für die Message und `l_error_code text` für den Error-Code (beide im DECLARE-Block). Kein Inline-Text am `RAISE`.
- **Message über `format($$…$$, v1, v2, …)`:** Dollar-Quoting (`$$…$$`) als Template-Delimiter — dadurch bleiben die Hochkommas um Text-Werte **einfach** (`'%2$s'` statt `''%2$s''`). Sicher im Procedure-Body, weil der mit `$procedure$…$procedure$` quotet; nur falls eine Message literal `$$` enthalten müsste, einen benannten Tag wie `$msg$…$msg$` verwenden (Randfall).
- **Nur indizierte Platzhalter:** `%1$s`, `%2$s`, `%3$s`, … — **niemals** der bare `%`. Gilt durchgängig, auch wenn jedes Argument nur einmal vorkommt; unverzichtbar, sobald ein Argument mehrfach in der Message steht (`%n$s` referenziert dasselbe Argument an mehreren Stellen, ohne es erneut zu übergeben).
- **Text-Werte in einfachen Hochkommas** in der Message (`'%2$s'`), damit String-Werte (Namen, E-Mails, Identifier) visuell abgegrenzt sind. **Numerische Werte** (`bigint`, `int`, …) ohne Hochkommas. **Ausnahme: der Komponenten-Prefix** (`l_component`, vorne als Label) wird **nicht** gequotet.
- **`RAISE EXCEPTION USING MESSAGE = …, ERRCODE = …;` einzeilig** — nimmt nur die Variablen entgegen, kein `'%'`-Platzhalter, kein Inline-String.
- **ERRCODE erhalten, nie erfinden:** den bestehenden ERRCODE exakt übernehmen. Hatte ein `RAISE EXCEPTION` im Original **keinen** ERRCODE, bleibt es ohne — `RAISE EXCEPTION USING MESSAGE = l_error_message;` (kein `l_error_code`, kein neu erfundener Code).

### Beispiel

```sql
DECLARE
   l_component       text;
   l_error_message   text;
   l_error_code      text;
   -- ...
BEGIN
   -- ...
   IF NOT l_can_edit THEN
      l_error_message := format($$%1$s: actor='%2$s' ist weder Owner noch Editor von Projekt id=%3$s$$, l_component, p_actor_email, l_project_id);
      l_error_code    := 'insufficient_privilege';

      RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
   END IF;
```

(`l_component` = Komponenten-Prefix → nicht gequotet; `p_actor_email` = Text-Wert → `'%2$s'`; `l_project_id` = numerisch → `%3$s` ohne Hochkommas.)

---

## Foreign Keys

- FK-Constraints benennen: `fk_<tabelle>_<spalte>`.
- **Ablage: als separate `ALTER TABLE … ADD CONSTRAINT` NACH der Tabelle** (nicht inline im
  `CREATE TABLE`), idempotent per `DROP CONSTRAINT IF EXISTS` + `ADD`, gruppiert unter
  `-- Foreign keys` — siehe [Layout](#create-table--spalten--constraints).
- `ON DELETE`-Verhalten bewusst wählen: `CASCADE` für abhängige Detail-Zeilen, `SET NULL` für
  optionale Referenzen, sonst Default (Restrict).
- Referenzierte Tabelle immer schema-qualifiziert über die Schema-Variable.
- Natural Keys werden `UNIQUE`-Constraints (nicht der PK — der ist immer `id bigserial`); ebenfalls
  als separates `ALTER TABLE … ADD CONSTRAINT` nach der Tabelle, gruppiert unter `-- Unique constraints`.
- Audit-Spalten `created_by` / `modified_by` (nur dort, wo fachlich genutzt — v. a. `config`):
  vom aufrufenden Prozess gesetzt — **nie** `CURRENT_USER` (das wäre nur die Verbindungsrolle,
  nicht der fachliche Akteur). Datentyp/Länge siehe `tables.md`.

Beispiel (`UNIQUE`/`FK` als separate `ALTER TABLE` nach der Tabelle — siehe [Layout](#create-table--spalten--constraints)):
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

---

## Layout & Formatierung (DDL/DML)

> Aus den gold-standard-Dateien abgeleitet. Ergänzt das [Tabellarische Alignment](#tabellarisches-alignment-parameter-variablen-joins) (Parameter/Variablen/JOINs) um die Datei- und Statement-Struktur. Grundeinrückung app-weit **3 Spaces**.

### Datei-Gerüst

- **Kopf:** erste Zeile `\echo "## CREATE <KIND> :schema_name.<name>"` (`<KIND>` = TABLE / PROCEDURE / FUNCTION / POLICIES / SEED / BACKFILL).
- **Fuß:** `\echo "## CREATE <KIND> :schema_name.<name> - DONE"` (ersetzt das alte leere `\echo ''`).
- **DROP:** `DROP …;`-Zeilen, dann eine Leerzeile, dann `CREATE OR REPLACE …`. (Trigger-Funktionen: kein DROP — siehe Structure conventions.)
- **OWNER:** `ALTER … OWNER TO :schema_owner;` direkt nach dem Objekt-Body (Tabellen: nach `);`; Procedures/Functions: nach `$…$;`).
- **Beschreibungs-Kommentare ans Datei-Ende** als Banner-Blöcke, nicht mehr inline über dem Objekt:
  - Trenner: `--` + 80 Bindestriche.
  - Pro Block `di2f-XXXX:` als Einstieg, Fließtext darunter auf die Spalte nach dem Label eingerückt.
  - Das alte `--comment:`-Prefix entfällt.

### Inline-Kommentar-Blöcke (Section-Kommentare)

Gruppierende Section-Kommentare im Skript-Body — z. B. `-- Unique constraints` / `-- Foreign keys`
nach der Tabelle sowie die `Get name` / `Check parameter` / `Workload`-Abschnitte im Procedure-Body —
werden **immer** als **3-zeiliger Banner-Block** geschrieben: Trennlinie · Label · Trennlinie. Die
**Trennlinie** ist `--`, **ein Leerzeichen**, dann **genau 80** `-`-Zeichen (Zeilenlänge 83). In
eingerückten Blöcken (Procedure-Body) steht die Grundeinrückung (3 Spaces) vor jeder der drei Zeilen.

```sql
-- --------------------------------------------------------------------------------
-- Unique constraints
-- --------------------------------------------------------------------------------
```

### Klammern auf eigener Zeile

`(` und `)` stehen je auf eigener Zeile bei: CREATE TABLE, Procedure-/Function-Signatur, INSERT-Spaltenliste, `VALUES`, CTE-Body, mehrzeiligen Subqueries (`EXISTS (` / `NOT EXISTS (`), Policy-`USING (` / `WITH CHECK (`.

**Ausnahme — triviale Konstanten-Bodies bleiben einzeilig:** `FOR UPDATE USING (false);`, `FOR DELETE USING (true);`, `WITH CHECK (true)`. Erst wenn der Body ein echter Ausdruck/Subquery ist, kommen `(`/`)` auf eigene Zeilen.

### CREATE TABLE — Spalten & Constraints

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
- **Reihenfolge nach `ALTER … OWNER`:** `-- Unique constraints` → `-- Foreign keys` → Indizes → `ENABLE`/`FORCE ROW LEVEL SECURITY` → `COMMENT`. `CREATE … INDEX` linearisiert (`CREATE [UNIQUE] INDEX IF NOT EXISTS <name> ON <table> (…) [WHERE …];`).

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

### SELECT / DML — vertikales Layout

- `SELECT` / `INTO` / `FROM` / `WHERE` / `GROUP BY` / `ORDER BY` je auf eigener Zeile auf Statement-Ebene.
- Listen (Select-Liste, `INTO`-Liste, Spaltenliste) darunter eingerückt mit Leading-Comma; erstes Element ein Space tiefer, damit es mit den Komma-Elementen fluchtet.
- `FROM`-Tabelle auf eigener eingerückter Zeile; JOINs siehe [Tabellarisches Alignment → JOINs](#tabellarisches-alignment-parameter-variablen-joins).
- `WHERE`: `AND`/`OR`-River (führendes `AND`/`OR`, Bedingungen ausgerichtet, `=` untereinander).
- Kurze Subqueries / Funktionsaufrufe dürfen einzeilig sein (`NOT EXISTS (SELECT 1 FROM … WHERE …)`, `l_x := app.fn_y(a, b, c);`).

```sql
SELECT
    is_active
   ,connection_id
INTO
    l_is_active
   ,l_connection_id
FROM
   app.source_table_selection
WHERE
   id = p_source_table_id;
```

### CTE

`WITH` auf eigener Zeile; CTE-Name mit `CTE_`-Prefix; `AS` dann `(` auf eigener Zeile.

```sql
WITH
CTE_effective_states AS
(
   SELECT
      ...
)
SELECT
   ...
FROM
   CTE_effective_states;
```

### INSERT / Seed

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

## Structure conventions

### Body-Struktur: Get name / Check parameter / Workload

> Jeder Procedure-/Function-Body gliedert sich in drei feste, je mit 80-Bindestrich-Banner eingeleitete Abschnitte. Die letzten beiden liegen in einem **eigenen `BEGIN … END;`-Sub-Block** — rein zur optischen Gruppierung und zum **Zuklappen** im Editor (Fokus auf einen Teil). Die Sub-Blöcke brauchen kein eigenes `DECLARE`/`EXCEPTION` (reine Gruppierungs-Blöcke), dürfen aber eins haben, wenn nötig.

1. **`Get name of function/procedure`** — `SET LOCAL lc_messages TO 'C'`, `GET DIAGNOSTICS … PG_CONTEXT`, `l_component := substring(…)` (+ optionaler `RAISE NOTICE`-Eingangs-Trace). Liegt direkt im äußeren `BEGIN` (kein Sub-Block).
   > **Grant-Voraussetzung (BUG-0337):** `lc_messages` ist ein **SUSET-GUC** — nur Superuser oder eine Rolle mit explizitem `GRANT SET ON PARAMETER lc_messages` darf ihn setzen. Da die Procedures mit **Caller-Rechten** laufen (kein `SECURITY DEFINER`), muss die Laufzeit-Rolle dieses Recht tragen, sonst wirft die allererste Body-Zeile `42501 permission denied to set parameter "lc_messages"`. Der Grant ist in `db/database/08.create.role.rw.sql` als **kommentierter Hinweis** hinterlegt — erst aktivieren (`GRANT SET ON PARAMETER lc_messages TO :role_rw;`), wenn diese Logging-Konvention tatsächlich übernommen wird.
2. **`Check parameter`** — `BEGIN … END;`-Sub-Block mit **allen Eingangs-/Guard-Checks am Anfang** (Parameter-Validierung, Actor-Context, Permission-Vorbedingungen). Verstoß → `RAISE` nach dem format()-Pattern.
3. **`Workload`** — `BEGIN … END;`-Sub-Block mit der eigentlichen Arbeit (Lookups, Mutationen, RETURN).

**Reihenfolge-Pflicht:** Guards stehen vor der Mutation — der `Check parameter`-Block kommt immer vor dem `Workload`-Block. Beim Umbau bestehender Procs darf die Reihenfolge sicherheitsrelevanter Checks (Permission!) **nie** hinter die Mutation rutschen.

**Umbau-Methode (kein Umsortieren):** Es gibt genau **eine Grenze** zwischen dem reinen Eingangs-Validierungs-Prefix und dem ersten Lookup-/Work-Statement. Die `BEGIN … END;`-Blöcke wrappen die bestehenden Statements **in-place** — Statements werden **nie** relativ zueinander verschoben. Sind Guards und Lookups interleaved (z. B. Permission-Check braucht ein zuvor gefetchtes `project_id`), liegt die Grenze nach dem letzten reinen Eingangs-Check; alle lookup-abhängigen Checks bleiben im `Workload`-Block. Lieber ein kleinerer `Check parameter`-Block als eine riskante Umsortierung.

**Leere Blöcke vermeiden:** ein `BEGIN END;` ohne Statement ist in PL/pgSQL ein Syntaxfehler — mindestens `NULL;` oder echte Statements.

Reine Validator-Functions ohne Fehler-`RAISE` (z. B. `fn_validate_*`, die nur Marker-Strings zurückgeben) lassen den `Get name`-Abschnitt weg; die `Check parameter`/`Workload`-Trennung ist dort optional.

### Stored Procedure
```sql
\echo "## CREATE PROCEDURE :schema_name.sp_upd_table_status"

DROP PROCEDURE IF EXISTS :schema_name.sp_upd_table_status(varchar, bigint);

CREATE OR REPLACE PROCEDURE :schema_name.sp_upd_table_status
(
    INOUT p_parameter1        varchar
   ,IN    p_parameter2        bigint
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   l_context                 varchar;
   l_component               varchar;
   l_source                  varchar(7);
   l_error_message           text;
   l_error_code              text;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   SET LOCAL lc_messages TO 'C';   -- erzwingt englische Server-Meldungen für diese Transaktion
   GET DIAGNOSTICS l_context = PG_CONTEXT;
   l_component := substring(l_context from 'function (.*?)\(');
   l_source    := 'plpgsql';

   RAISE NOTICE '### procedure : %', l_component;

   -- --------------------------------------------------------------------------------
   -- Check parameter
   -- --------------------------------------------------------------------------------
   BEGIN
      -- alle Eingangs-/Guard-Checks (Parameter-Validierung, Actor-Context, Permission).
      -- Verstoss -> Fehler über separate Variablen + format($$…$$):
      -- l_error_message := format($$%1$s: Beispiel-Fehler für id=%2$s$$, l_component, p_parameter2);
      -- l_error_code    := 'invalid_parameter_value';
      -- RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;
      NULL;
   END;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      -- eigentliche Arbeit (Lookups, Mutationen)
      NULL;
   END;

END;
$procedure$;

ALTER PROCEDURE :schema_name.sp_upd_table_status(varchar, bigint) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_name.sp_upd_table_status - DONE"
```

### Stored Function
```sql
\echo "## CREATE FUNCTION :schema_name.fn_is_null_or_empty"

DROP FUNCTION IF EXISTS :schema_name.fn_is_null_or_empty(varchar, bigint);

CREATE OR REPLACE FUNCTION :schema_name.fn_is_null_or_empty
(
    IN    p_parameter1        varchar
   ,IN    p_parameter2        bigint
)
RETURNS varchar
LANGUAGE plpgsql
AS $function$
DECLARE
   l_returnvalue             varchar;
BEGIN

   -- Logic

   RETURN l_returnvalue;

EXCEPTION WHEN others THEN
   RAISE NOTICE '##### %', SQLERRM;
   RETURN NULL::varchar;
END;
$function$;

ALTER FUNCTION :schema_name.fn_is_null_or_empty(varchar, bigint) OWNER TO :schema_owner;

\echo "## CREATE FUNCTION :schema_name.fn_is_null_or_empty - DONE"
```

---
### Trigger Function

> **Kein `DROP FUNCTION` für Trigger-Funktionen.** Trigger hängen an der Funktion; ein `DROP FUNCTION IF EXISTS` würde beim Re-Run mit `cannot drop function ... because other objects depend on it (trigger ...)` abbrechen. `CREATE OR REPLACE FUNCTION` allein ist trigger-safe, solange die Signatur stabil bleibt — bei Trigger-Funktionen mit `RETURNS TRIGGER` ohne Parameter ist sie das per Definition. Für **non-trigger** Stored Functions (siehe „Stored Function" oben) bleibt das `DROP FUNCTION IF EXISTS … (signatur);` + `CREATE OR REPLACE FUNCTION`-Pattern korrekt.

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

---

### Trigger
```sql
\echo "## CREATE TRIGGER tr_iud_table"

DROP TRIGGER IF EXISTS tr_iud_table ON :schema_name.log_execution;

CREATE TRIGGER tr_iud_table
BEFORE INSERT OR UPDATE OR DELETE ON :schema_name.log_execution
FOR EACH ROW
   EXECUTE PROCEDURE :schema_name.tf_table();

\echo "## CREATE TRIGGER tr_iud_table - DONE"
```

- Check `TG_OP` with `IF / ELSEIF / ELSE` — always cover all three branches
- `ELSE` → `RETURN NULL` (no implicit fall-through)
- On INSERT: pass `NEW.<column>`, `RETURN NEW`
- On DELETE: pass `OLD.<column>`, `RETURN OLD`
- Always pass `TG_OP` as the first argument to called procedures

---
