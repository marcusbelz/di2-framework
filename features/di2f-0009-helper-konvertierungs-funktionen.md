# di2f-0009: helper-Konvertierungs-Funktionen (Bit + Datum/Zeit, Portabilitäts-Layer)

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** helper

## Problem / Motivation
Beim Laden von Quelldaten müssen Roh-Strings robust in typisierte Werte gewandelt werden — ein
boolesches Flag aus `'J'`/`'N'`/`'1'`/`'0'`, und Datums-/Zeit-Strings aus **unterschiedlichen Formaten**
(US, ISO, deutsch, …) in echte `date`/`timestamp`-Werte. Die SQL-Server-Vorlage
(`example/sample05.db/dbo/functions`) löst das mit benannten Konvertierungs-Funktionen, die einen
**Format-Hinweis (Style)** entgegennehmen.

Damit das Framework über DBMS-Grenzen hinweg **gleiche Aufrufstellen** behält (siehe Portabilitäts-Ziel
in [di2f-0008](di2f-0008-helper-string-funktionen.md)), sollen diese Konvertierungen als benannte
`helper.fn_convert_*`-Funktionen in PostgreSQL bereitstehen — **so allgemeingültig wie möglich**, mit
**beibehaltenem `(wert, style)`-Interface**.

## User Stories
- Als **ETL-/Lade-Logik** möchte ich `helper.fn_convert_bit('J')` → `true` aufrufen, damit
  Ja/Nein-Flags aus Quellsystemen einheitlich zu `boolean` werden.
- Als **ETL-/Lade-Logik** möchte ich `helper.fn_convert_datetime(wert, style)` mit einem Format-Hinweis
  aufrufen, damit gemischte Datumsformate (z. B. `'17.08.2018'` mit Style `'DD.MM.YYYY'`) korrekt und
  **eindeutig** (Tag-zuerst vs. Monat-zuerst) geparst werden.
- Als **Lade-Prozess** möchte ich, dass ein unparsbarer Wert **NULL** liefert statt den Lauf
  abzubrechen, damit ein einzelner Datenfehler den Batch nicht killt (Datenfehler werden separat über
  `log.error` behandelt — nicht hier).
- Als **Portierer** möchte ich dasselbe Style-Interface wie in der Vorlage, damit die Aufrufe beim
  DBMS-Wechsel unverändert bleiben und nur die Funktion neu implementiert wird.

## Scope
Vier **reine** (seiteneffektfreie) Funktionen im Schema `helper`:

- **`helper.fn_convert_bit(p_value)` → boolean** — wandelt einen Text in `boolean`:
  `'1'`/`'J'`/`'TRUE'` → **true**; `'0'`/`'N'`/`'FALSE'`/`''` → **false**; `NULL` → **NULL**; sonst →
  **NULL**. Case-insensitiv, vorab getrimmt.
- **`helper.fn_convert_date(p_value, p_date_style)` → date** — parst einen Datums-/Zeit-String gemäß
  Style-Hinweis und liefert das **Datum** (Zeitanteil verworfen).
- **`helper.fn_convert_datetime(p_value, p_date_style)` → timestamp** — wie oben, liefert
  **Datum + Zeit**.
- **`helper.fn_convert_datetime2(p_value, p_date_style)` → timestamp(6)** — höchste in PostgreSQL
  verfügbare Sub-Sekunden-Präzision (Mikrosekunden); Gegenstück zu SQL-Server `datetime2`.

**Style-Interface (beibehalten):** Der zweite Parameter beschreibt das Eingabeformat über dieselben
Tokens wie die Vorlage, u. a. `YYYY.MM.DD`, `YYYY-MM-DD hh:mi:ss`, `YYYY-MM-DDThh:mi:ss.mmm`, `YYYYMMDD`,
`MM/DD/YYYY`, `MM-DD-YYYY`, `DD/MM/YYYY`, `DD.MM.YYYY`, `DD-MM-YYYY`, `DD MON YYYY`, `MON DD YYYY …`.
Der Style ist **case-insensitiv**. Er entscheidet v. a. die **Tag-/Monat-Reihenfolge** (z. B. `DD.MM.YYYY`
day-first vs. `MM/DD/YYYY` month-first).

## Nicht-Ziele
- **Keine** String-/Prädikat-Helfer (`fn_starts_with` etc.) — die sind **di2f-0008**.
- **Keine** vollständige Nachbildung der SQL-Server-`CONVERT`-Style-**Nummern** (`121`, `103`, …); es
  reichen die **benannten** Style-Tokens (die Nummern sind SQL-Server-intern). Mapping legt
  `/architecture` fest.
- **Kein** Werfen von Exceptions bei unparsbaren Werten — Rückgabe **NULL** (Datenfehler-Protokollierung
  ist Sache der aufrufenden Lade-Logik via `log.error`, nicht dieser Funktionen).
- **Keine** Zeitzonen-Konvertierung/`timestamptz` in dieser Iteration (lokale, zonenlose Werte wie die
  Vorlage; tz-Variante später möglich).

## Datenmodell-Auswirkung
- **Keine.** Reine Funktionen, keine Tabellen/Spalten/Constraints.

## Protokollierungs-Integration
- **Keine** direkte. Bewusst: unparsbare Eingaben → **NULL** (kein `RAISE`), damit der aufrufende
  Lade-Prozess entscheidet, ob/aus welchem Kontext ein `log.error` entsteht.

## Akzeptanzkriterien
> Werte aus den Testfällen der Vorlage abgeleitet.

1. **`fn_convert_bit`**: `'1'`→true, `'0'`→false, `'J'`→true, `'N'`→false, `'true'`→true,
   `'false'`→false, `''`→false, `' '`→false (Trim), `'X'`→**NULL**, `NULL`→**NULL**. Case-insensitiv
   (`'j'`=`'J'`).
2. **`fn_convert_datetime`** parst ISO/`YYYY`-Formate korrekt, z. B. `('2018-08-17 12:27:40',
   'YYYY-MM-DD hh:mi:ss')` → `2018-08-17 12:27:40`; `('20180817','YYYYMMDD')` → `2018-08-17 00:00:00`.
3. **Tag-/Monat-Reihenfolge** ist eindeutig: `('17.08.2018','DD.MM.YYYY')` → `2018-08-17` und
   `('08/17/2018','MM/DD/YYYY')` → `2018-08-17` (nicht vertauscht).
4. **`fn_convert_date`** liefert **nur das Datum** (Zeitanteil verworfen): `('2018-08-17 12:27:40',
   'YYYY-MM-DD hh:mi:ss')` → `2018-08-17`.
5. **`fn_convert_datetime2`** behält Sub-Sekunden: `('2018-08-17T12:27:40.654',
   'YYYY-MM-DDThh:mi:ss.mmm')` → `2018-08-17 12:27:40.654` (Mikrosekunden-genau).
6. **Unparsbarer Wert** (z. B. `('nonsense','YYYY-MM-DD')`) → **NULL** (keine Exception).
7. **`NULL`-Wert** → **NULL**; **unbekannter Style** → definiertes, dokumentiertes Verhalten
   (Vorschlag: bestmögliche/ISO-Parse, sonst **NULL** — finale Festlegung in `/architecture`, von
   `/qa` geprüft).
8. **Style case-insensitiv**: `'dd.mm.yyyy'` verhält sich wie `'DD.MM.YYYY'`.
9. Alle vier Funktionen sind **deterministisch** und ohne Seiteneffekte; Skripte mehrfach deploybar
   (`CREATE OR REPLACE`).
10. Eine **dokumentierte Liste der unterstützten Style-Tokens** liegt vor (in der Funktion und/oder
    Spec), inkl. des Verhaltens für nicht gelistete Styles.

## Edge Cases
- **`fn_convert_bit`** mit gemischter Schreibweise/Whitespace (`' j '`, `'TRUE'`, `'Wahr'?`) — nur die
  definierten Tokens (`1/0/J/N/TRUE/FALSE/''`) werden erkannt, alles andere → **NULL**. (Token-Liste in
  `/architecture` final, deutschsprachige Zusätze wie `'Ja'/'Nein'` optional erwägen.)
- **Mehrdeutige Datumswerte** (`'01/02/2018'`): das Ergebnis hängt **allein am Style** (DD/MM vs MM/DD) —
  kein Raten; ohne passenden Style ggf. NULL.
- **Unvollständige/abweichende Werte** zum Style (z. B. Style `'YYYY-MM-DD'`, Wert enthält Zeit) →
  bestmöglich parsen oder NULL — testbar festlegen.
- **Zweistelliges Jahr** (`'yy'`) / Mon-Namen (`'MON DD YYYY'`, `'Aug'`) — Erkennung gemäß Style;
  Monatsnamen englisch wie in der Vorlage.
- **Präzisions-Hinweis:** SQL-Server `datetime2(7)` (100 ns) → PostgreSQL `timestamp` ist
  Mikrosekunden (6 Stellen); der Unterschied ist dokumentiert und für die Framework-Zwecke
  ausreichend.

## Abhängigkeiten
- **Requires:** Schema `helper` + Owner (`db/database/`) — bereits vorhanden.
- **Unabhängig von di2f-0008** — keine gegenseitige Abhängigkeit; beide nur auf `helper`-Schema. Sinnvoll
  nach 0008, weil komplexer.
- **Künftige Nutzer:** ETL-/Lade-Logik (nutzt `table_metadata.date_style`, `null_handling`,
  `check_data` etc.) ruft diese Konvertierungen beim Laden auf.
