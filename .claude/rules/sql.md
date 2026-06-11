# SQL rules

> **Übergreifender** SQL-Styleguide (Naming, Alignment, File-Numbering, generische Layout-Prinzipien).
> Die **objekt-spezifischen** Regeln sind in die jeweiligen Objekt-Dateien ausgelagert — siehe
> [Objekt-spezifische Regeln (ausgelagert)](#objekt-spezifische-regeln-ausgelagert) am Ende.

- [SQL](#sql)
  - [Naming Conventions](#naming-conventions)
    - [Prefixes](#prefixes)
    - [Placeholder](#placeholder)
    - [Dollar Quoting](#dollar-quoting)
    - [Common](#common)
    - [Examples](#examples)
    - [Tabellarisches Alignment (Parameter, Variablen, JOINs)](#tabellarisches-alignment-parameter-variablen-joins)
  - [File Naming & Numbering](#file-naming--numbering)
  - [Layout & Formatierung (DDL/DML)](#layout--formatierung-ddldml)
- [Objekt-spezifische Regeln (ausgelagert)](#objekt-spezifische-regeln-ausgelagert)

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

**Gruppierung im `DECLARE`-Block:** Bei mehr als einer Handvoll Variablen werden die Deklarationen
unter **3-zeiligen Banner-Sub-Headern** nach Rolle gruppiert (gleiche Banner-Form wie die
Section-Kommentare, siehe [Inline-Kommentar-Blöcke](#inline-kommentar-blöcke-section-kommentare)) —
feste Reihenfolge, leere Gruppen entfallen:

1. `-- Common` — Infrastruktur-Variablen (`l_component`, ggf. `l_context` / `l_source`).
2. `-- Error Handling` — `l_error_message`, `l_error_code`.
3. `-- Workload` — die fachlichen Arbeits-Variablen (Lookups, Zwischenergebnisse).

Die Gruppen spiegeln die Body-Abschnitte
([Get name / Check parameter / Workload](procedures.md#body-struktur-get-name--check-parameter--workload)) wider.

```sql
DECLARE
   -- --------------------------------------------------------------------------------
   -- Common
   -- --------------------------------------------------------------------------------
   l_component               varchar;

   -- --------------------------------------------------------------------------------
   -- Error Handling
   -- --------------------------------------------------------------------------------
   l_error_message           text;
   l_error_code              text;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   l_name                    varchar;
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

## Layout & Formatierung (DDL/DML)

> Aus den gold-standard-Dateien abgeleitet. Ergänzt das [Tabellarische Alignment](#tabellarisches-alignment-parameter-variablen-joins) (Parameter/Variablen/JOINs) um die Datei- und Statement-Struktur. Grundeinrückung app-weit **3 Spaces**.

### Datei-Gerüst

- **Kopf:** erste Zeile `\echo "## CREATE <KIND> :schema_name.<name>"` (`<KIND>` = TABLE / PROCEDURE / FUNCTION / POLICIES / SEED / BACKFILL).
- **Fuß:** `\echo "## CREATE <KIND> :schema_name.<name> - DONE"` (ersetzt das alte leere `\echo ''`).
- **DROP:** `DROP …;`-Zeilen, dann eine Leerzeile, dann `CREATE OR REPLACE …`. (Trigger-Funktionen: kein DROP — siehe [trigger.md](trigger.md).)
- **Parameter-Block:** bei Procedures/Functions **mit Parametern** zwischen `DROP …;` und `CREATE OR REPLACE …` der `-- Parameter`-Dokublock — siehe [Parameter-Dokumentation in procedures.md](procedures.md#parameter-dokumentation-inline-block-vor-create).
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

# Objekt-spezifische Regeln (ausgelagert)

sql.md ist der **übergreifende** Styleguide (Naming, Alignment, File-Numbering, generische
Layout-Prinzipien). Die **objekt-spezifischen** Regeln stehen in den jeweiligen Objekt-Dateien —
dort nachschlagen, je nachdem was gebaut wird. Jede Objekt-Datei verweist für das Übergreifende
zurück auf sql.md; **bei Widerspruch gilt sql.md.**

| Objekttyp | Regel-Datei | enthält u. a. |
|---|---|---|
| Tabellen | [tables.md](tables.md) | CREATE-TABLE-Layout, Foreign Keys / Unique, Comments (Tabelle & Spalten), INSERT/Seed, Datentypen, Audit-Spalten, RLS |
| Prozeduren | [procedures.md](procedures.md) | Parameter-Reihenfolge (ID zuerst), Parameter-Dokumentation, Body-Struktur, Fehler-Messages & `format()`, Single Responsibility, Procedure-Skelett |
| Funktionen | [functions.md](functions.md) | Function-Skelett, Volatilität; geteilte Body-Regeln via Verweis auf procedures.md |
| Trigger | [trigger.md](trigger.md) | Trigger-/Trigger-Function-Skelett, `TG_OP`-Logik |
| Views | [views.md](views.md) | View-Konventionen |
| Policies / RLS | [policies.md](policies.md) | Row-Level-Security-Policies |
