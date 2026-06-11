# Rule: Prozeduren (PostgreSQL 17 / PL/pgSQL)

> **Übergreifende SQL-Konventionen siehe [sql.md](sql.md) — vor jedem Skript lesen** (Naming
> `sp_<verb>_<entity>`, Parameter-Prefix `p_`, Variablen `l_`, Dollar-Quoting `$procedure$`,
> tabellarisches Alignment, Datei-Gerüst `\echo`/`DROP`/`CREATE OR REPLACE`/`OWNER TO`, File
> Naming & Numbering). **Bei Widerspruch gilt sql.md.** Die **procedure-spezifischen** Regeln
> (Parameter-Reihenfolge, Parameter-Dokumentation, Body-Struktur, Fehler-Messages, Single
> Responsibility, Skelett) stehen **hier** in dieser Datei.
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

## Parameter-Reihenfolge (ID zuerst)

> Aus den `config.process`-Procedures (`sp_ins_process` / `sp_upd_process` / `sp_del_process`) abgeleitet.

Spricht eine Procedure/Function einen **Datensatz über seinen Identifier** an (`p_id` — allgemein
der Primärschlüssel/Identifier des betroffenen Datensatzes) und nimmt **zusätzlich Attribut-Parameter**
entgegen (Name, Text-/Namensfeld, …), dann gilt für die Reihenfolge in der Signatur:

- **Der Identifier-Parameter steht IMMER an erster Stelle**, danach folgen die Attribut-Felder — in
  der Reihenfolge, in der die zugehörige Tabelle den Datensatz erst **identifiziert** und dann
  **beschreibt**. Das spiegelt die Statement-Logik der Procedures wider: `WHERE id = p_id`
  identifiziert zuerst die Zeile, danach werden die Attribut-Spalten gelesen/gesetzt (vgl. die
  `SELECT … WHERE id = p_id`, `UPDATE … WHERE id = p_id`, `DELETE … WHERE id = p_id` in
  `sp_upd_process` / `sp_del_process`).
- Gilt für alle Verben: `del`/`get` haben oft nur `p_id`; `upd` hat `p_id` + Attribute; **`ins`**
  führt die `id` als `INOUT` (Rückgabe des neu vergebenen Surrogate-Keys) — sie steht trotzdem
  **vor** den Attribut-Feldern. Die Regel „Identifier zuerst" hat hier Vorrang vor der sonst
  üblichen Reihung „Inputs vor Outputs".
- Mehrere Identifier (Composite-/Cross-Table-Keys): alle Identifier-Parameter zuerst (in Reihenfolge
  ihrer Identifikations-Tiefe), danach die Attribut-Felder.

```sql
-- richtig: Identifier (p_id) vor Attribut (p_name) — auch wenn p_id beim INSERT INOUT ist
CREATE OR REPLACE PROCEDURE :schema_config.sp_ins_process
(
    INOUT p_id          bigint
   ,IN    p_name        varchar
)
```

## Parameter-Dokumentation (Inline-Block vor `CREATE`)

> Aus den `config.process`-Procedures abgeleitet. **Pflicht für jede Procedure/Function mit
> Parametern** — die nackte Signatur reicht nicht, besonders bei langen Parameterlisten.

**Zwischen `DROP …;` und `CREATE OR REPLACE …`** steht ein Kommentar-Block, der jeden Parameter
dokumentiert. Er ist als Banner-Block aufgebaut: 3-zeiliger `-- Parameter`-Header, die Einträge,
abgeschlossen durch **eine weitere Trennlinie direkt vor `CREATE`**.

- **Header/Footer:** dieselbe Banner-Trennlinie wie sonst (`--` + Leerzeichen + 80 `-`); Label `Parameter`.
- **Pro Parameter zwei Zeilen:**
  - **Zeile 1 — Name + Typ:** `--` + **4 Spaces** (= 3 Zeichen Einrückung ab dem Kommentar-Prefix
    `-- `), dann `<p_name>`, dann die Ausrichtungs-Spaces + `<typ>`. Name und Typ werden **1:1 aus
    der Signatur übernommen** (ab dem Parameter-Namen kopiert) — Modus-Keyword (`IN`/`INOUT`) und
    Leading-Comma entfallen; die Typen fluchten dadurch untereinander wie in der Signatur.
  - **Zeile 2 — Beschreibung:** `--` + **7 Spaces** (= 3 Zeichen weiter eingerückt als der Name),
    dann der Beschreibungstext (fachliche Bedeutung des Parameters).
- Reihenfolge der Einträge = Reihenfolge der Signatur (also Identifier zuerst, siehe
  [Parameter-Reihenfolge](#parameter-reihenfolge-id-zuerst)).

```sql
-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_id          bigint
--       Identifier des betroffenen Prozess-Datensatzes
--    p_name        varchar
--       Name des Prozesses
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE :schema_config.sp_upd_process
(
    IN    p_id          bigint
   ,IN    p_name        varchar
)
```

## Body-Struktur: Get name / Check parameter / Workload

> Jeder Procedure-/Function-Body gliedert sich in drei feste, je mit 80-Bindestrich-Banner eingeleitete Abschnitte. Die letzten beiden liegen in einem **eigenen `BEGIN … END;`-Sub-Block** — rein zur optischen Gruppierung und zum **Zuklappen** im Editor (Fokus auf einen Teil). Die Sub-Blöcke brauchen kein eigenes `DECLARE`/`EXCEPTION` (reine Gruppierungs-Blöcke), dürfen aber eins haben, wenn nötig.

1. **`Get name of function/procedure`** — `SET LOCAL lc_messages TO 'C'`, `GET DIAGNOSTICS … PG_CONTEXT`, `l_component := substring(…)` (+ optionaler `RAISE NOTICE`-Eingangs-Trace). Liegt direkt im äußeren `BEGIN` (kein Sub-Block).
   > **Grant-Voraussetzung (BUG-0337):** `lc_messages` ist ein **SUSET-GUC** — nur Superuser oder eine Rolle mit explizitem `GRANT SET ON PARAMETER lc_messages` darf ihn setzen. Da die Procedures mit **Caller-Rechten** laufen (kein `SECURITY DEFINER`), muss die Laufzeit-Rolle dieses Recht tragen, sonst wirft die allererste Body-Zeile `42501 permission denied to set parameter "lc_messages"`. Der Grant ist in `db/database/08.create.role.rw.sql` als **kommentierter Hinweis** hinterlegt — erst aktivieren (`GRANT SET ON PARAMETER lc_messages TO :role_rw;`), wenn diese Logging-Konvention tatsächlich übernommen wird.
2. **`Check parameter`** — `BEGIN … END;`-Sub-Block mit **allen Eingangs-/Guard-Checks am Anfang** (Parameter-Validierung, Actor-Context, Permission-Vorbedingungen). Verstoß → `RAISE` nach dem format()-Pattern.
3. **`Workload`** — `BEGIN … END;`-Sub-Block mit der eigentlichen Arbeit (Lookups, Mutationen, RETURN).

**Reihenfolge-Pflicht:** Guards stehen vor der Mutation — der `Check parameter`-Block kommt immer vor dem `Workload`-Block. Beim Umbau bestehender Procs darf die Reihenfolge sicherheitsrelevanter Checks (Permission!) **nie** hinter die Mutation rutschen.

**Umbau-Methode (kein Umsortieren):** Es gibt genau **eine Grenze** zwischen dem reinen Eingangs-Validierungs-Prefix und dem ersten Lookup-/Work-Statement. Die `BEGIN … END;`-Blöcke wrappen die bestehenden Statements **in-place** — Statements werden **nie** relativ zueinander verschoben. Sind Guards und Lookups interleaved (z. B. Permission-Check braucht ein zuvor gefetchtes `project_id`), liegt die Grenze nach dem letzten reinen Eingangs-Check; alle lookup-abhängigen Checks bleiben im `Workload`-Block. Lieber ein kleinerer `Check parameter`-Block als eine riskante Umsortierung.

**Leere Blöcke vermeiden:** ein `BEGIN END;` ohne Statement ist in PL/pgSQL ein Syntaxfehler — mindestens `NULL;` oder echte Statements.

Reine Validator-Functions ohne Fehler-`RAISE` (z. B. `fn_validate_*`, die nur Marker-Strings zurückgeben) lassen den `Get name`-Abschnitt weg; die `Check parameter`/`Workload`-Trennung ist dort optional.

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

## Single Responsibility

- Each `CALL` statement delegates exactly **one** domain action to an `sp_` procedure
- One procedure = one responsibility (e.g. update status, set map access)

## Skelett (Stored Procedure)

```sql
\echo "## CREATE PROCEDURE :schema_name.sp_upd_table_status"

DROP PROCEDURE IF EXISTS :schema_name.sp_upd_table_status(varchar, bigint);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_parameter1        varchar
--       <Bedeutung von p_parameter1>
--    p_parameter2        bigint
--       <Bedeutung von p_parameter2>
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE :schema_name.sp_upd_table_status
(
    INOUT p_parameter1        varchar
   ,IN    p_parameter2        bigint
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   -- --------------------------------------------------------------------------------
   -- Common
   -- --------------------------------------------------------------------------------
   l_context                 varchar;
   l_component               varchar;
   l_source                  varchar(7);

   -- --------------------------------------------------------------------------------
   -- Error Handling
   -- --------------------------------------------------------------------------------
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
