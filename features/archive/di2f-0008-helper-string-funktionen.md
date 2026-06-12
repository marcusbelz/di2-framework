# di2f-0008: helper-String-/Prädikat-Funktionen (Portabilitäts-Layer)

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** helper

## Problem / Motivation
Das Framework wird auf PostgreSQL gebaut, soll aber **leicht auf ein anderes DBMS portierbar** sein
(z. B. SQL Server). Mehrere String-/Prüf-Operationen, die Framework-Prozeduren brauchen, existieren in
PostgreSQL zwar teilweise nativ (`starts_with`, `string_to_table`, …), in anderen Systemen aber **nicht**
(z. B. kein `startswith` in SQL Server). Damit die Aufrufstellen über DBMS-Grenzen hinweg **gleich**
bleiben, soll das Framework durchgängig benannte `helper.fn_*`-Funktionen verwenden — der DBMS-Wechsel
erfordert dann nur eine Neu-Implementierung **dieses Layers**, nicht jeder Aufrufstelle.

Dieses Feature portiert die String-/Prädikat-Helfer aus der SQL-Server-Vorlage
(`example/sample05.db/dbo/functions`) nach `helper` — so **allgemeingültig wie möglich**.

## User Stories
- Als **Framework-Entwickler** möchte ich `helper.fn_is_null_or_empty(...)` statt DBMS-spezifischer
  Idiome aufrufen, damit derselbe Prozedur-Code auf PostgreSQL **und** einem Zielsystem läuft.
- Als **ETL-/Lade-Logik** möchte ich Eingaben mit `fn_starts_with` / `fn_ends_with` prüfen (case-
  sensitiv, optional getrimmt), damit Präfix-/Suffix-Regeln einheitlich und vorhersagbar sind.
- Als **Verarbeitungs-Prozedur** möchte ich eine getrennte Liste mit `fn_split` in Zeilen zerlegen,
  damit ich Mengen statt Strings verarbeite — unabhängig vom DBMS.
- Als **Portierer** möchte ich eine kleine, klar umrissene Funktionsmenge mit dokumentiertem Verhalten,
  damit ich sie im Zielsystem 1:1 nachbauen kann.

## Scope
Vier **reine** (seiteneffektfreie) Funktionen im Schema `helper`, Rückgabe **`boolean`** für die
Prädikate:

- **`helper.fn_is_null_or_empty(p_input, p_trim)` → boolean** — true, wenn der Wert NULL **oder** leer
  ist; `p_trim` schaltet ein Trimmen vor der Leer-Prüfung ein.
- **`helper.fn_starts_with(p_input, p_pattern, p_trim)` → boolean** — true, wenn `p_input` mit
  `p_pattern` **beginnt**. **Case-sensitiv**, `p_pattern` als **literaler** String (kein Wildcard);
  `p_trim` trimmt `p_input` vorab.
- **`helper.fn_ends_with(p_input, p_pattern, p_trim)` → boolean** — analog für **endet mit**.
- **`helper.fn_split(p_value, p_separator)` → Menge von Textwerten** — zerlegt `p_value` am
  Trennzeichen `p_separator` (ein Zeichen) und liefert die Elemente als Zeilen.

## Nicht-Ziele
- **Keine** Konvertierungs-Funktionen (`fn_convert_*`) — die sind **di2f-0009**.
- **Keine** Locale-/Collation-Konfiguration, keine case-insensitive Varianten (bewusst case-sensitiv
  wie die Vorlage; eine ci-Variante kann später folgen).
- **Keine** Wildcard-/Regex-Semantik in `fn_starts_with`/`fn_ends_with` (literaler Vergleich; behebt
  bewusst die latente LIKE-Pattern-Eigenheit der SQL-Server-Vorlage).
- **Kein** Mehrzeichen-/Regex-Trennzeichen in `fn_split` in dieser Iteration (ein Zeichen wie die
  Vorlage; Generalisierung später möglich).

## Datenmodell-Auswirkung
- **Keine.** Reine Funktionen, keine Tabellen/Spalten/Constraints. Erste Objekte im Schema `helper`.

## Protokollierungs-Integration
- **Keine.** Reine Berechnungsfunktionen ohne Execution/Component/Trace/Error-Bezug. Sie werfen keine
  Fehler für „normale" Eingaben, sondern liefern definierte Ergebnisse (s. Akzeptanzkriterien).

## Akzeptanzkriterien
> Werte aus den Testfällen der SQL-Server-Vorlage abgeleitet (Rückgabe als `boolean`).

1. **`fn_is_null_or_empty`**: `(NULL,false)`=**true**, `(NULL,true)`=**true**, `('',false)`=**true**,
   `('',true)`=**true**, `(' ',false)`=**false**, `(' ',true)`=**true**, `('  ',false)`=**false**,
   `('  ',true)`=**true**, `(' X ',false)`=**false**, `(' X ',true)`=**false**.
2. **`fn_starts_with`** ist **case-sensitiv**: `(' abcde ','a',false)`=**false**,
   `(' abcde ','a',true)`=**true**, `(' abcde ','ab',true)`=**true**, `(' abcde ','Ab',true)`=**false**.
3. **`fn_ends_with`** ist **case-sensitiv**: `(' abcde ','e',false)`=**false**,
   `(' abcde ','e',true)`=**true**, `(' abcde ','de',true)`=**true**, `(' abcde ','De',true)`=**false**.
4. **NULL-Eingaben** bei `fn_starts_with`/`fn_ends_with`: ist `p_input` **oder** `p_pattern` NULL →
   **false** (keine Exception).
5. **Leeres Pattern**: `fn_starts_with(x,'',…)` und `fn_ends_with(x,'',…)` mit nicht-NULL `x` → **true**
   (jeder String beginnt/endet mit dem Leerstring).
6. **`fn_split`** liefert je Element eine Zeile: `('A,B,C', ',')` → **3 Zeilen** `A`,`B`,`C`.
7. **`fn_split`** bei `NULL`- oder Leer-Eingabe (`p_value` NULL oder `''`) → **0 Zeilen** (keine
   Exception).
8. **`fn_split`** mit aufeinanderfolgenden Trennzeichen behält **innere Leer-Elemente**: `('A,,C', ',')`
   → 3 Zeilen `A`,``,`C`.
9. Trennzeichen-Verhalten bei **abschließendem** Trennzeichen (`'A,B,C,'`) ist **festgelegt und
   dokumentiert** und in beide Richtungen testbar (siehe Edge Cases — finale Festlegung in
   `/architecture`).
10. Alle vier Funktionen sind **deterministisch** (gleiche Eingabe → gleiche Ausgabe) und ohne
    Seiteneffekte; mehrfaches Deploy der Skripte ist idempotent (`CREATE OR REPLACE`).

## Edge Cases
- **`p_trim`-Semantik**: getrimmt wird **beidseitig** (führend + nachfolgend) vor Leer-/Präfix-/
  Suffix-Prüfung. Ohne Trim zählt Whitespace als Inhalt (`fn_is_null_or_empty(' ',false)`=false).
- **Abschließendes Trennzeichen** `fn_split('A,B,C,', ',')`: erzeugt es ein **leeres** Schluss-Element
  (`A,B,C,''`) oder nicht (`A,B,C`)? Standard-Split-Semantik (PG `string_to_table`) erzeugt das leere
  Element; die SQL-Server-Vorlage **verwarf** es. **Empfehlung:** das leere Schluss-Element behalten
  (vorhersagbarer/allgemeingültiger) — `/architecture` legt verbindlich fest, `/qa` prüft genau diesen
  Fall.
- **NULL als Pattern/Trennzeichen**: definierte, dokumentierte Reaktion statt Exception
  (`starts_with`/`ends_with` → false; `fn_split` mit NULL-Separator → `/architecture` definiert,
  Vorschlag: leere Menge oder Fehler — testbar machen).
- **Mehrbyte-/Unicode-Eingaben** (Umlaute, ß): Längen-/Trim-/Präfix-Logik arbeitet **zeichen-**, nicht
  bytebasiert.
- **Pattern länger als Input**: `fn_starts_with('ab','abc',…)` → false (keine Exception).

## Abhängigkeiten
- **Requires:** Schema `helper` + Owner (`db/database/`) — bereits vorhanden (heute leer).
- **Unabhängig von di2f-0009** (Konvertierungs-Helfer) — beide brauchen nur das `helper`-Schema; keine
  gegenseitige Abhängigkeit. Empfohlene Reihenfolge: 0008 (einfacher) vor 0009.
- **Künftige Nutzer:** die noch zu bauende ETL-/Lade-Logik und Prüf-Prozeduren rufen diese Helfer.

---

## Tech Design (Solution Architect)

### Views nötig: **Nein**
Reine Berechnungsfunktionen ohne lesende Sicht. → Nach `/backend` **kein** `/frontend`.

### A) Objekt-Landschaft (vier Funktionen, keine Tabellen)
Erste Objekte im bislang leeren Schema `helper`. Keine Tabelle, kein Trigger, keine View, kein
`etl`-Dynamic-SQL.
```
- helper.fn_is_null_or_empty(p_input, p_trim)          — true, wenn Wert NULL oder leer (optional getrimmt)
- helper.fn_starts_with(p_input, p_pattern, p_trim)    — true, wenn Wert mit Muster BEGINNT (literal, case-sensitiv)
- helper.fn_ends_with(p_input, p_pattern, p_trim)      — true, wenn Wert mit Muster ENDET   (literal, case-sensitiv)
- helper.fn_split(p_value, p_separator)                — zerlegt Wert am Trennzeichen in eine Zeilenmenge
```

### B) Datenmodell (Klartext)
**Keines.** Es wird nichts gespeichert. Alle vier Funktionen berechnen ihr Ergebnis allein aus den
Eingabeparametern (zustandslos). `fn_split` **liefert** eine Ergebnismenge (eine Spalte je Element),
**schreibt** aber nichts.

### C) Schnittstellen (Zweck, kein Code)
```
- helper.fn_is_null_or_empty(p_input, p_trim)        -> boolean   (true = NULL oder leer)
- helper.fn_starts_with(p_input, p_pattern, p_trim)  -> boolean   (true = beginnt mit Muster)
- helper.fn_ends_with(p_input, p_pattern, p_trim)    -> boolean   (true = endet mit Muster)
- helper.fn_split(p_value, p_separator)              -> Menge aus Textwerten (eine Spalte 'value')
```
- Texteingaben als `varchar` (Framework-Konvention; nicht `text`). `p_trim` als `boolean`.
  `p_separator` ist **ein** Zeichen.
- `p_input`/`p_pattern` zuerst der zu prüfende Wert, dann das Muster, dann der `p_trim`-Schalter —
  entspricht der Lesart „prüfe Wert gegen Muster".

### D) Datenfluss & Protokollierung
- **Kein** Datenfluss durch die Log-Kette. Die Funktionen sind Bausteine, die **andere** Komponenten
  (künftige ETL-/Lade-/Prüf-Logik) in ihren Ausdrücken aufrufen.
- **Keine** Protokollierung, **keine** Exceptions im Normalbetrieb: Grenzfälle liefern definierte
  Ergebnisse (false / 0 Zeilen), damit ein aufrufender Lade-Lauf nie an einem Helfer abbricht.

### E) Tech-Entscheidungen (für PM begründet)
1. **Dünne Wrapper um PostgreSQL-Bordmittel statt Neu-Erfindung.** Wo PostgreSQL ein passendes
   Bordmittel hat (Präfix-/Suffix-Vergleich, Trennen), nutzt die Funktion es **intern** — der Wert
   liegt im **stabilen, benannten Aufruf** (`helper.fn_*`), nicht im Algorithmus. *Warum:* korrekt &
   schnell, und genau diese benannte Naht macht die spätere Portierung billig (nur der Layer wird im
   Zielsystem neu gebaut).
2. **`boolean`-Rückgabe** (laut Spec) statt 0/1. *Warum:* direkt in `WHERE`/`IF` nutzbar, PG-idiomatisch.
3. **Literaler Vergleich** in `starts_with`/`ends_with` (Muster ist ein **gewöhnlicher String**, kein
   Wildcard/Regex). *Warum:* behebt die latente LIKE-Pattern-Eigenheit der SQL-Server-Vorlage; ein
   Muster mit `%`/`_` wird buchstäblich verglichen — vorhersagbar.
4. **Case-sensitiv** (wie die Vorlage). *Warum:* Konsistenz mit dem Original; eine case-insensitive
   Variante kann später als eigene Funktion folgen, statt hier ein Verhalten zu überladen.
5. **`fn_split`: abschließendes Trennzeichen erzeugt ein leeres Schluss-Element** (`'A,B,C,'` →
   `A`,`B`,`C`,``). *Warum:* entspricht der Standard-Split-Semantik (vorhersagbar, verlustfrei); die
   Vorlage verwarf es — die hier gewählte Regel ist die allgemeingültigere. Innere Leer-Elemente
   bleiben ebenfalls erhalten (`'A,,C'` → `A`,``,`C`).
6. **Null-sicher, ohne Überraschungen:** `NULL`/leerer `p_value` → **0 Zeilen**; `NULL`/leeres
   `p_separator` → **eine Zeile = der gesamte Wert** (kein Split). *Warum:* PostgreSQL würde bei einem
   `NULL`-Trennzeichen den String in **Einzelzeichen** zerlegen — diese Überraschung wird bewusst
   abgefangen.
7. **Volatilität `IMMUTABLE`** (reine Berechnung, kein DB-Zugriff). *Warum:* erlaubt dem Planer
   Inlining/Konstanten-Faltung und Nutzung in Index-Ausdrücken.
8. **Datei-Nummerierung sequenziell im `helper`-Schema** (`001.`…`004.`), da es **keine Tabelle** zum
   Anker gibt — die sql.md-Regel „Nummer der Haupttabelle" greift im tabellenlosen `helper` nicht.
   di2f-0009 setzt die Nummerierung fort (`005.`…). *(Kleiner Konventions-Zusatz — Vorschlag, das als
   Ein-Zeiler in `functions.md`/`sql.md` nachzuziehen; nicht Teil dieses Deploys.)*

### F) Abhängigkeiten
- **Requires:** Schema `helper` + Owner (`db/database/`) — vorhanden. Owner `:schema_owner`; aufrufbar
  durch die Laufzeitrolle (`:role_rw`).
- **Unabhängig von di2f-0009**; **keine** Extensions, **kein** `etl`, **keine** RLS/Tabellen.

### Hinweis für `/backend`
Vier `CREATE OR REPLACE FUNCTION`-Skripte unter `db/schemas/helper/functions/` (`001.`…`004.`),
`IMMUTABLE`, `OWNER TO :schema_owner`. Reine Validator-Functions ohne Fehler-`RAISE` (Skelett-Variante
aus `functions.md` ohne `Get name`-Block). Smoke-Test gegen die Akzeptanzkriterien-Wertetabellen
(direkt aus den Vorlage-Testfällen).

---

## Implementierung (Backend)

**Objekte** (erste Objekte im `helper`-Schema, alle `IMMUTABLE`, Owner `:schema_owner`):
- [`001.fn_is_null_or_empty.sql`](../db/schemas/helper/functions/001.fn_is_null_or_empty.sql)
- [`002.fn_starts_with.sql`](../db/schemas/helper/functions/002.fn_starts_with.sql)
- [`003.fn_ends_with.sql`](../db/schemas/helper/functions/003.fn_ends_with.sql)
- [`004.fn_split.sql`](../db/schemas/helper/functions/004.fn_split.sql)

**Implementierte Signaturen:**
```
helper.fn_is_null_or_empty(p_input varchar, p_trim boolean)                  -> boolean
helper.fn_starts_with     (p_input varchar, p_pattern varchar, p_trim boolean) -> boolean
helper.fn_ends_with       (p_input varchar, p_pattern varchar, p_trim boolean) -> boolean
helper.fn_split           (p_value varchar, p_separator varchar)              -> TABLE (value varchar)
```

**Umsetzung / Details:**
- `fn_starts_with` nutzt das PG-Bordmittel `starts_with()` (literal, case-sensitiv). `fn_ends_with`
  hat kein Bordmittel → literaler Suffix-Vergleich via `right(wert, char_length(muster)) = muster`.
- `fn_is_null_or_empty`: NULL → true; `p_trim` → `btrim()` vor `char_length(...) = 0`.
- `fn_split` (`RETURNS TABLE(value varchar)`): NULL/leerer Wert → 0 Zeilen; NULL/leeres Trennzeichen →
  eine Zeile = ganzer Wert (fängt PGs NULL-Delimiter-Verhalten ab); sonst `string_to_table()` (innere
  **und** abschliessende Leer-Elemente bleiben erhalten).
- Kein `EXCEPTION`-Block: die Funktionen haben keinen Fehlerpfad (reine, null-sichere Logik).
- `p_trim` als `boolean`; `NULL`-`p_trim` wird wie „nicht trimmen" behandelt.

**Smoke-Test (PostgreSQL 17, Container, gegen `helper` in `di2f`):**
- Alle Akzeptanzkriterien AK1–AK9 als `ASSERT`-Block grün (Wertetabellen direkt aus den
  Vorlage-Testfällen), inkl. Design-Fälle: abschliessendes Trennzeichen → leeres Schluss-Element;
  NULL/leeres Trennzeichen → ganzer Wert. ✅
- Unicode/Umlaute zeichen-basiert korrekt (`fn_ends_with('grüße','ße')`=true). ✅
- Volatilität `IMMUTABLE`, Owner `…_fw` (Catalog geprüft). ✅
- Doppelter Deploy fehlerfrei (`CREATE OR REPLACE`). ✅

---

## QA Test Results

**Getestet:** 2026-06-12 · **Tester:** `/qa` · **Verdict:** ✅ Production-Ready (0 Bugs)

**Testaufbau:** PostgreSQL 17 (Container), Funktionen im `helper`-Schema deployt. Neues **permanentes
Testskript** [db/tests/helper/001.string_funktionen.sql](../db/tests/helper/001.string_funktionen.sql)
(psql/`ASSERT`, Konvention wie `config/005.process.sql`), Wertetabellen aus den SQL-Server-Vorlage-Testfällen.

### Akzeptanzkriterien
| AK | Inhalt | Ergebnis |
|----|--------|----------|
| 1 | `fn_is_null_or_empty` (NULL/leer/Whitespace × trim) | ✅ alle 10 Wertepaare |
| 2 | `fn_starts_with` case-sensitiv, literal | ✅ inkl. `Ab`→false |
| 3 | `fn_ends_with` case-sensitiv, literal | ✅ inkl. `De`→false |
| 4 | NULL-Input/-Pattern → false (keine Exception) | ✅ |
| 5 | leeres Pattern → true | ✅ |
| 6 | `fn_split('A,B,C',',')` → 3 Zeilen `A`,`B`,`C` | ✅ |
| 7 | NULL/leerer Wert → 0 Zeilen | ✅ |
| 8 | innere Leer-Elemente bleiben (`A,,C`) | ✅ |
| 9 | abschliessendes Trennzeichen → leeres Schluss-Element (`A,B,C,`→4) | ✅ |
| 10 | deterministisch + idempotenter Deploy | ✅ (doppelter Deploy, `CREATE OR REPLACE`) |

### Edge Cases (alle ✅)
- `p_trim = NULL` → wie „nicht trimmen" behandelt.
- **Tab wird NICHT getrimmt** (`btrim` entfernt nur Leerzeichen — wie die SQL-Server-Vorlage; bewusst,
  kein Bug).
- Pattern länger als Wert → false (keine Exception).
- NULL/leeres Trennzeichen → ganzer Wert als eine Zeile; nur-Trennzeichen (`','`) → zwei leere Elemente.
- Unicode/Umlaute zeichen-basiert.

### Feature-spezifische Security-Checks
- **Injection:** kein Dynamic SQL; `fn_split` nutzt `string_to_table` (parametrisiert) — keine Fläche. ✅
- **SECURITY DEFINER:** nein (alle 4 `prosecdef = false`, INVOKER) — keine Privilege-Escalation. ✅
- **Rechte:** unter der DML-Rolle `di2f_rw` ausführbar (USAGE auf `helper` + EXECUTE vorhanden);
  Funktionen owned by `…_fw`. ✅
- **Sensible Daten / RLS:** N/A (reine Funktionen, keine Tabellen, keine Logs). ✅

### Hinweise (informativ, keine Bugs)
- **Mehrzeichen-Trennzeichen** wird in `fn_split` nicht abgelehnt und wirkt als Mehrzeichen-Delimiter
  (`string_to_table`-Verhalten) — über den dokumentierten Ein-Zeichen-Vertrag hinaus **toleranter**,
  nicht falsch. Falls strikte Ein-Zeichen-Prüfung gewünscht ist: spätere Verschärfung.

### Kandidaten für nächsten `/security`-Run
- **Default-`EXECUTE`-auf-Funktionen:** PostgreSQL grantet `EXECUTE` neuer Funktionen an `PUBLIC`; der
  Bootstrap `REVOKE`t das nicht. Für zustandslose Helfer risikoarm (Zugriff wird über `USAGE` auf das
  `helper`-Schema gegated), aber die projektweite Funktions-Grant-Policy sollte `/security` prüfen
  (gleiches Thema wie die Config-Default-Privileges-Notiz).

### Regression
- di2f-0006/0007 (`config.db_version`, Deploy-Verdrahtung) unberührt — `helper`-Funktionen sind
  isoliert (eigenes Schema, keine geteilten Objekte). `deploy.sh all local` weiterhin grün. ✅

---

## Code Review

**Reviewer:** `/review` · **Datum:** 2026-06-12 · **Range:** Backend-Commit `d463e3a`
(`db/schemas/helper/functions/001.`–`004.`) · **Verdict:** ✅ **Approve** (0 Blocker, 0 Major, 1 Minor)

### Spec ↔ Code (Akzeptanzkriterien im Code lokalisiert)
| AK | Umsetzung |
|----|-----------|
| 1 | [001.fn_is_null_or_empty.sql](../db/schemas/helper/functions/001.fn_is_null_or_empty.sql) — NULL→true, optional `btrim`, `char_length=0` |
| 2 | [002.fn_starts_with.sql](../db/schemas/helper/functions/002.fn_starts_with.sql) — `starts_with()` (literal, case-sensitiv) |
| 3 | [003.fn_ends_with.sql](../db/schemas/helper/functions/003.fn_ends_with.sql) — `right(wert, char_length(muster)) = muster` |
| 4/5 | NULL-Input→false, leeres Muster→true (in 002/003) |
| 6–9 | [004.fn_split.sql](../db/schemas/helper/functions/004.fn_split.sql) — `string_to_table`, null-sichere Guards, Leer-Elemente erhalten |
| 10 | alle `CREATE OR REPLACE` + `DROP … IF EXISTS`, deterministisch |

Datei-Scope passt exakt (4 Funktionen + Spec), keine Fremddateien, keine ungenannten Nebeneffekte.

### Conventions & Qualität (sql.md + functions.md)
- Naming `fn_<name>` snake_case, Schema durchgängig über `:schema_helper`, `OWNER TO :schema_owner`,
  nichts in `public`. ✅
- Datei-Gerüst: `\echo`-Kopf/Fuß, `DROP FUNCTION IF EXISTS (signatur)` → `CREATE OR REPLACE`,
  `-- Parameter`-Dokublock, Beschreibungs-Banner am Dateiende. ✅
- `RETURNS`/`LANGUAGE`/`IMMUTABLE` je eigene Zeile, `$function$`-Quoting, tabellarisches Alignment,
  `T01`-Positionsalias in `fn_split`. ✅
- **Idempotenz** + **IMMUTABLE** (vom QA-Catalog bestätigt). ✅
- **Validator-Stil ohne `EXCEPTION`-Block** (reine, null-sichere Logik ohne Fehlerpfad) — von
  `functions.md` für Validator-Functions ausdrücklich gedeckt; bewusst und korrekt.

### Security am Diff
- **Kein Dynamic SQL**; `fn_split` nutzt `string_to_table` (Werte als Datenargument, keine
  Konkatenation). Keine Injection-Fläche. ✅
- **Kein `SECURITY DEFINER`** (INVOKER, vom QA bestätigt); keine Secrets; Body referenziert nur
  `pg_catalog`-Bordmittel (`starts_with`/`right`/`btrim`/`string_to_table`) — search_path-unabhängig. ✅

### Findings
**Blocker (0):** — **Major (0):** —

**Minor (1, optional):**
1. **`fn_split` validiert das Trennzeichen nicht auf ein Zeichen** —
   [004.fn_split.sql](../db/schemas/helper/functions/004.fn_split.sql): ein Mehrzeichen-`p_separator`
   wirkt als Mehrzeichen-Delimiter (`string_to_table`). Das ist **toleranter** als der dokumentierte
   Ein-Zeichen-Vertrag, nicht falsch (QA bestätigt). *Optional:* falls strikt gewünscht, im Backend
   auf `char_length = 1` prüfen — sonst Vertrag in der Spec auf „beliebiger Trenn-String" weiten.
   Niedrige Prio.

### Hinweise (kein Finding)
- **`/security`-Kandidat:** Default-`EXECUTE`-auf-Funktionen an `PUBLIC` (Bootstrap revoke't nicht) —
  projektweit, siehe QA-Sektion.

### Empfehlung
**Approve** — konventionskonforme, isolierte, injection-sichere Funktionen; alle AKs im Code belegt;
IMMUTABLE bestätigt. Der eine Minor ist optional. Nächster Schritt: `/deploy dev` (gemeinsam mit
di2f-0009 möglich — beide ins `helper`-Schema, kein Stub-Vorbehalt).

---

## Deployment

| Env | Datum | Branch | Commit | Status |
|-----|-------|--------|--------|--------|
| dev | 2026-06-12 | `dev` | `a0f7455` | ✅ ausgerollt |
| int | 2026-06-12 | `dev` | `a0f7455` | ✅ ausgerollt |

- **Erste Objekte im `helper`-Schema** live (zusammen mit di2f-0009 deployt). Kein Stub-Vorbehalt —
  nur neue Funktionen, keine Strukturänderung; normaler `deploy.sh helper`/`all` ohne `clean`.
- **Verbleibend:** `test`/`prod` ausstehend; `prod` erst nach grünem `/security`-Gate.
- Offener Review-Minor (`fn_split`-Trennzeichen nicht auf ein Zeichen validiert) weiterhin
  nicht-blockierend offen.
