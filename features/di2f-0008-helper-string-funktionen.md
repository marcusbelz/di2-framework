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
