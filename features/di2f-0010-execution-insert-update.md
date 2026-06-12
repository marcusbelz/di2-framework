# di2f-0010: Prozessprotokollierung `log.execution` — Insert/Update-Prozeduren

- **Priorität:** P0 (MVP)
- **Status:** In Arbeit (Backend implementiert, QA ausstehend)
- **Schema(s):** log (primär) · liest config (`process`, `db_version`)

## Problem / Motivation
Die Tabelle `log.execution` (Prozessebene der dreistufigen Protokollierung) existiert seit di2f-0001
inkl. FK auf `config.process` und Audit-Trigger — hat aber **keine Zugriffs-Prozeduren**. Ein
aufrufender Prozess kann derzeit keinen Lauf protokollieren.

`log.execution` protokolliert **einen langlaufenden Prozess mit genau einem Datensatz**: wann er
gestartet ist, wann er beendet wurde, und sein Status ist zu jedem Zeitpunkt abfragbar. Über die
beiden Delta-Spalten trägt der Datensatz zusätzlich das **inkrementelle Ladefenster** (von wann bis
wann Daten zu laden sind). Dieses Feature liefert die Prozeduren, um einen Lauf **anzulegen**
(Start + Delta-Ermittlung) und sein Ergebnis **fortzuschreiben** (Status/Erfolg/Ende) — inklusive
der Validierung der zulässigen Status/Erfolg-Kombinationen und der lückenlosen Delta-Fortschreibung.

## User Stories
- Als **aufrufender Prozess/Job** möchte ich zu Beginn meines Laufs einen Execution-Datensatz über
  `log.sp_ins_execution` anlegen und dessen `id` zurückbekommen, damit ich ihn am Ende fortschreiben
  und Component/Trace darauf referenzieren kann.
- Als **aufrufender Prozess** möchte ich, dass beim Anlegen automatisch das **Delta-Ladefenster**
  aus dem letzten erfolgreichen Lauf ermittelt wird, damit ich lückenlos und ohne eigene Berechnung
  inkrementell laden kann.
- Als **aufrufender Prozess** möchte ich meinen Lauf am Ende mit einer **semantischen Kurz-Prozedur**
  (`…_success` / `…_error` / `…_warning` / `…_information`) abschließen, ohne State und Success von
  Hand setzen (und falsch kombinieren) zu können.
- Als **Framework-Betreiber** möchte ich, dass ungültige Status/Erfolg-Kombinationen (z. B. `error`
  mit `success = true`) **abgewiesen** werden, damit die Protokolldaten konsistent und auswertbar
  bleiben.
- Als **Monitoring/Auswertung** möchte ich, dass jeder Lauf die ausführende **Framework-Version**
  trägt, damit nachvollziehbar ist, welcher Stand lief.

## Scope
Neue Objekte unter `db/schemas/log/procedures/` (Tabellengruppe `001` = `execution`):

- **`log.sp_ins_execution(INOUT p_id, IN p_process_id, IN p_machine, IN p_instance)`** — legt einen
  Lauf an: setzt Start, initialen Status, Delta-Fenster, ausführenden User und Version; gibt die neue
  `id` zurück.
- **`log.sp_upd_execution(IN p_id, IN p_state, IN p_success)`** — generische Fortschreibung: prüft
  Status/Erfolg-Kombinatorik und schreibt Status, Erfolg und Ende; Single Source of Truth der
  Validierung.
- **`log.sp_upd_execution_error(IN p_id)`** — Convenience: setzt `error` / `false`.
- **`log.sp_upd_execution_success(IN p_id)`** — Convenience: setzt `success` / `true`.
- **`log.sp_upd_execution_warning(IN p_id, IN p_success)`** — Convenience: setzt `warning`, Erfolg frei.
- **`log.sp_upd_execution_information(IN p_id, IN p_success)`** — Convenience: setzt `information`,
  Erfolg frei.

Die vier Convenience-Prozeduren **delegieren** per `CALL` an `sp_upd_execution` (eine
Validierungsstelle).

## Nicht-Ziele
- **Keine Tabellen-/Strukturänderung** an `log.execution` — Tabelle, FK und Audit-Trigger stammen aus
  di2f-0001 und bleiben unverändert (etwaige `CHECK`-Constraints sind ein separater Folge-Vorschlag).
- **Keine Component-/Trace-/Error-Protokollierung** durch diese Prozeduren — sie sind die
  Prozessebene selbst; sie protokollieren sich nicht über die unteren Ebenen (kein zirkuläres
  Logging). Fehler nur via `RAISE` mit `format()`-Meldung.
- **Kein Delta-Parameter** — das Delta-Fenster wird **berechnet**, nicht übergeben (Abweichung von
  der SQL-Server-Vorlage, die `DeltaStart`/`DeltaEnd` als Parameter nahm).
- **Kein `p_actor_email`** — `user_name` trägt den DB-Verbindungsuser (`current_user`), analog zur
  framework-internen Audit-Konvention; nicht den fachlichen App-Akteur.
- **Keine Views/Monitoring** — Auswertung ist ein separates `log`-Views-Feature.
- **Kein Update von `start_on` / `process_id` / Delta / `user_name` / `machine` / `instance` /
  `version`** — diese Felder sind nach dem Insert unveränderlich.

## Datenmodell-Auswirkung
Keine. Es werden ausschließlich Prozeduren angelegt; `log.execution` (Spalten, PK, FK
`fk_execution_process_id → config.process(id)`, Index, Audit-Trigger `tr_u_execution` →
`log.tf_set_modified()`) bleibt unverändert. Gelesen wird zusätzlich `config.db_version`
(Spalte `release_version`) und `config.process` (Existenzprüfung).

**Status-Wertebereich** (`state`): `processing`, `error`, `warning`, `information`, `success`.
**Zulässige `(state, success)`-Kombinationen:**

| state | success |
|-------|---------|
| processing | `false` |
| error | `false` |
| success | `true` |
| warning | `false` oder `true` |
| information | `false` oder `true` |

Ungültig ist damit genau: `success = true` bei `processing`/`error`, und `success = false` bei
`state = 'success'`.

## Protokollierungs-Integration
Diese Prozeduren **sind** die Prozessebene (Execution). Sie schreiben selbst keine
Component-/Trace-/Error-Einträge und nutzen kein `lc_messages`/Komponenten-Parsing (schlankes Muster,
kein `GRANT SET ON PARAMETER`, BUG-0337). Die untere Logging-Kette (Component/Trace) referenziert
später die hier erzeugte `execution.id`.

## Akzeptanzkriterien

**Anlegen (`sp_ins_execution`):**
1. Mit gültiger `p_process_id` wird genau ein `log.execution`-Datensatz angelegt und dessen `id` über
   `INOUT p_id` zurückgegeben.
2. `p_process_id` ist Pflicht: `NULL` wird mit verständlicher Meldung abgewiesen.
3. Eine `p_process_id`, die **nicht** in `config.process` existiert, wird **vor** dem Insert mit
   verständlicher Meldung abgewiesen (nicht als roher FK-Fehler).
4. Beim Anlegen gilt: `start_on = now()`, `end_on = NULL`, `state = 'processing'`, `success = false`.
5. `delta_end` ist gleich `start_on` (derselbe Zeitstempel).
6. `delta_start` ist gleich dem `delta_end` des **aktuellsten erfolgreichen** Laufs **desselben**
   `process_id`; „erfolgreich" = `state IN ('success','warning') AND success = true`.
7. Existiert für den Prozess **kein** erfolgreicher Vorlauf, ist `delta_start = NULL`
   (Erstlauf / Vollladung).
8. `version` wird mit der `release_version` (`major.minor.build`) der **jüngsten** Zeile aus
   `config.db_version` befüllt (kein Eintrag vorhanden → `version = NULL`).
9. `user_name` = `current_user`; `machine` = `p_machine`; `instance` = `p_instance` (beide dürfen
   `NULL` sein).

**Fortschreiben (`sp_upd_execution`):**
10. `p_id`, `p_state`, `p_success` sind Pflicht: `NULL` bzw. leerer `p_state` werden mit Meldung
    abgewiesen.
11. Ein `p_state` außerhalb des erlaubten Wertebereichs wird mit Meldung abgewiesen.
12. Eine **ungültige** `(state, success)`-Kombination (siehe Tabelle) wird mit Meldung abgewiesen
    (z. B. `state = 'error'` mit `success = true`).
13. Bei gültigen Eingaben werden **ausschließlich** `state`, `success` und `end_on` (= `now()`)
    geschrieben; `process_id`, `start_on`, `delta_start`, `delta_end`, `user_name`, `machine`,
    `instance`, `version` bleiben unverändert.
14. `modified_on` / `modified_by` werden **nicht** von der Prozedur, sondern durch den Trigger
    `tr_u_execution` gesetzt.
15. Ein `p_id`, der nicht existiert, wird mit verständlicher Meldung abgewiesen.

**Convenience-Wrapper:**
16. `sp_upd_execution_error(p_id)` setzt `error`/`false`, `sp_upd_execution_success(p_id)` setzt
    `success`/`true` — jeweils ohne `p_success`-Parameter.
17. `sp_upd_execution_warning(p_id, p_success)` und `sp_upd_execution_information(p_id, p_success)`
    setzen den jeweiligen Status mit frei wählbarem `p_success`; jede ungültige Kombination wird über
    die delegierte Validierung abgewiesen.
18. Alle vier Wrapper delegieren an `sp_upd_execution` (keine eigene, abweichende Schreiblogik).

## Edge Cases
- **Ungültige Kombination** (`success = true` bei `error`/`processing`; `success = false` bei
  `success`) → Exception.
- **Unbekannter Status** (`p_state` nicht im Wertebereich) → Exception.
- **Erstlauf** eines Prozesses ohne erfolgreichen Vorlauf → `delta_start = NULL`.
- **Fehlgeschlagener Vorlauf rückt das Delta-Wasserzeichen nicht vor:** ist der jüngste Lauf
  `error` (oder `warning`/`information` mit `success = false`), nimmt der Folgelauf das `delta_end`
  des **davorliegenden** erfolgreichen Laufs → das Fenster bleibt lückenlos / kein Datenverlust.
- **`information` + `success = true`** ist eine gültige Kombination, zählt aber **nicht** als
  erfolgreicher Lauf für das Delta-Wasserzeichen.
- **`config.db_version` leer** (frische DB ohne Deploy-Eintrag) → `version = NULL`, kein Fehler.
- **Nicht existierende `p_id`** beim Update → Exception (kein stilles No-op).
- **Mehrere parallele Läufe desselben Prozesses:** das Wasserzeichen basiert auf dem jüngsten
  erfolgreichen Datensatz; gleichzeitige Inserts können dasselbe Fenster ableiten (bewusst — die
  Prozessebene serialisiert keine Läufe; Orchestrierung ist Non-Goal des Frameworks).

## Abhängigkeiten
- Requires: **di2f-0001** — Tabelle `log.execution` inkl. FK `fk_execution_process_id` auf
  `config.process(id)` und Audit-Trigger `tr_u_execution` → `log.tf_set_modified()`.
- Requires: **di2f-0006** — `config.db_version` (Spalte `release_version`) für die Versions-Ableitung.
- Requires: Laufzeitrolle mit `USAGE` auf `config` + `log`, `SELECT` auf `config.process` /
  `config.db_version`, DML auf `log.execution` (im Bootstrap-Grant-Modell abgedeckt; bei `/deploy dev`
  verifizieren).
- Relates: künftige Component-/Trace-Prozeduren referenzieren die hier erzeugte `execution.id`;
  Log-Views (Monitoring) setzen auf `log.execution` auf.

---

## QA Test Results

**Getestet:** 2026-06-12 · **Umgebung:** PostgreSQL 17 (Docker-Container `di2f_dev_postgres`,
lokal, wegwerfbar) · **Runner:** `deploy.sh log local` (Procedures angelegt, danach **2×**
idempotent → `--- done ---`, kein `ERROR`/`FATAL`) + `db/tests/log/001.execution.sql` (reines psql +
`ASSERT`, transaktional mit `ROLLBACK` → keine Testdaten zurück). Funktionaltest als Owner `di2f_fw`;
zusätzlich **Least-Privilege-Smoke als Laufzeitrolle `di2f_sa`** (erbt `di2f_rw`, nicht Owner).

### Test-Design-Hinweis
`now()` ist innerhalb **einer** Transaktion konstant → die natürliche Flow-Logik (Erstlauf →
`delta_start = NULL`; Folgelauf → `delta_start = delta_end` des Vorlaufs) wird so geprüft (Block 1),
der **Wasserzeichen-Selektor** (welcher Vorlauf gewinnt, Ausschluss von `information+true` /
`warning+false` / `error`) deterministisch über **Sentinel-Fixtures** mit distinkten
`start_on`/`delta_end` (Block 3).

### Akzeptanzkriterien

| # | Kriterium | Ergebnis | Beleg |
|---|-----------|----------|-------|
| 1 | `sp_ins_execution` legt genau eine Zeile an, liefert `id` | ✅ | Block 1 |
| 2 | `process_id = NULL` abgewiesen | ✅ | Block 1 (`invalid_parameter_value`) |
| 3 | nicht existierender `process_id` abgewiesen (vor Insert) | ✅ | Block 1 (`foreign_key_violation`) |
| 4 | Insert: `start_on=now`, `end_on=NULL`, `state='processing'`, `success=false` | ✅ | Block 1 |
| 5 | `delta_end = start_on` | ✅ | Block 1 |
| 6 | Folgelauf: `delta_start = delta_end` des letzten erfolgreichen Laufs | ✅ | Block 1 |
| 7 | Erstlauf: `delta_start = NULL` | ✅ | Block 1 |
| 8 | `version = release_version` der jüngsten `config.db_version`-Zeile; leer → `NULL` | ✅ | Block 4 (`9.9.9` future-dated + leere Tabelle) |
| 9 | `user_name=current_user`, `machine`/`instance` aus Parametern | ✅ | Block 1 |
| 10 | Update: `p_id`/`p_state`(leer)/`p_success` NULL abgewiesen | ✅ | Block 2 (`invalid_parameter_value`, 4 Fälle) |
| 11 | Update: unbekannter `state` abgewiesen | ✅ | Block 2 |
| 12 | ungültige `(state,success)`-Kombi abgewiesen; alle 7 gültigen werfen nicht | ✅ | Block 2 (`processing/true`,`error/true`,`success/false` abgewiesen) |
| 13 | Update ändert nur `state`/`success`/`end_on`; übrige Felder unverändert | ✅ | Block 2 (8 Immutable-Felder via `IS NOT DISTINCT FROM`) |
| 14 | `modified_on`/`modified_by` durch Trigger gesetzt | ✅ | Block 2 |
| 15 | Update auf nicht existierende `id` abgewiesen | ✅ | Block 2 (`no_data_found`) |
| 16 | `_error`→`error/false`, `_success`→`success/true` (je `end_on` gesetzt) | ✅ | Block 2 |
| 17 | `_warning(p_success)` / `_information(p_success)` setzen Status + freien Erfolg | ✅ | Block 2 (je `false` und `true`) |
| 18 | Wrapper delegieren an `sp_upd_execution` (Validierung greift) | ✅ | Block 2 (Wrapper-Effekt = generischer Call) |

### Edge Cases
- **Wasserzeichen-Selektor (Block 3):** Fixtures `success/true`(2024-01), `warning/true`(2024-02),
  `information/true`(2024-03), `warning/false`(2024-04), `error/false`(2024-05) → neuer Lauf zieht
  `delta_start = 2024-02-01` (jüngster **qualifizierender** = `warning/true`). Beweist Ausschluss von
  `information+true`, `warning+false`, `error` trotz jüngerer Zeitstempel. ✅
- **Nur nicht-qualifizierende Vorläufe** (`error`, `information+true`) → `delta_start = NULL`. ✅
- **Leere `config.db_version`** → `version = NULL`, kein Fehler. ✅
- **Alle 7 gültigen `(state,success)`-Kombinationen** ausführbar ohne Wurf. ✅
- **Idempotenz:** Deploy `log` 2× rc=0, keine `ERROR`. ✅

### Protokollierungs-Integration
Spec-konform: Die Prozeduren **sind** die Prozessebene und schreiben **keine**
Component/Trace/Error-Einträge (kein Dynamic SQL, keine Inserts nach `log.component`/`trace`/`error`).
Gelesen werden `config.process` (Existenzprüfung) und `config.db_version` (Version). `modified_*`
kommt ausschließlich vom Trigger `tr_u_execution`.

### Feature-spezifische Security-Funde
- **Kein Dynamic SQL** (kein `EXECUTE`) → keine Injection-Fläche; `p_state` wird gegen eine
  Allowlist validiert und nur als **Wert** (nie als Identifier) verwendet. ✅
- **`SECURITY INVOKER`** (kein `SECURITY DEFINER`) → keine Privilege-Escalation; Body-Referenzen
  schema-qualifiziert hartkodiert → kein `search_path`-Hijack. ✅
- **Least-Privilege verifiziert:** `di2f_sa` (Nicht-Owner) führt `sp_ins_execution` +
  `sp_upd_execution_warning` inkl. Cross-Schema-Read (`config.process`/`config.db_version`) mit
  Standard-Grants aus — **kein** `permission denied`. ✅
- **Keine PII/Secrets** in Fehlermeldungen — nur numerische Surrogat-Keys + allowlistete `state`. ✅

### Kandidaten für nächsten `/security`-Run
- **Cross-Schema-Grant-Modell** (`di2f_rw`: `USAGE` auf `config`+`log`, `SELECT` auf
  `config.process`/`config.db_version`, DML auf `log.execution`) — lokal als `di2f_sa` belegt; bei
  `/deploy dev` gegen das reale Bootstrap verifizieren (systemisch, gilt feature-übergreifend).
- **Optionaler `CHECK`-Constraint** auf `log.execution(state)` bzw. die volle `(state,success)`-
  Kombinatorik als DB-seitige Absicherung gegen Out-of-band-Writes (der Delta-Filter ist
  case-sensitiv und verlässt sich auf die Normalisierung im Schreibpfad) — Defense-in-depth, kein
  Defekt.

### Regression
Der Re-Deploy von `log` rollt alle log-Tabellen/Trigger idempotent neu aus (fehlerfrei); der Test
nutzt `config.sp_ins_process` (di2f-0001) intensiv → gemeinsam genutzte config-CRUD bleibt grün.

### Production-Ready-Entscheidung
**READY.** Keine Critical/High/Medium-Bugs. AK 1–18 + alle Edge Cases bestanden, idempotent,
least-privilege verifiziert. Offene Punkte sind Verifikations-/Defense-in-depth-Kandidaten für
`/security`, keine Code-Defekte.

---

## Code Review

- **Reviewer:** `/review` (Claude) · **Datum:** 2026-06-12
- **Commit-Range (di2f-0010):** `99e5daf` (Backend + Spec) · `2650ab2` (QA-Testskript). Base
  `f1c5240`. Die übrigen Dateien in `main…HEAD` (113) gehören zu di2f-0001…0009 (eigenständig
  review't/deployt) — **nicht** Teil dieses Reviews.
- **Diff-Scope:** 6 Prozeduren unter `db/schemas/log/procedures/001.*`, Testskript
  `db/tests/log/001.execution.sql`, Spec + INDEX/PRD-Tracking. Keine fremden Dateien, keine
  Strukturänderung an `log.execution`.

### Spec ↔ Code
Jedes Akzeptanzkriterium im Diff lokalisiert und durch `/qa` belegt:

| AK | Ort im Code |
|----|-------------|
| 1,4,5 | [001.sp_ins_execution.sql:114-142](../db/schemas/log/procedures/001.sp_ins_execution.sql#L114) (`INSERT … RETURNING`; `start_on=l_start`, `end_on=NULL`, `delta_end=l_start`, `state='processing'`, `success=false`) |
| 2,3 | [001.sp_ins_execution.sql:57-73](../db/schemas/log/procedures/001.sp_ins_execution.sql#L57) (NULL-Guard + `NOT EXISTS config.process` → `foreign_key_violation`) |
| 6,7 | [001.sp_ins_execution.sql:87-100](../db/schemas/log/procedures/001.sp_ins_execution.sql#L87) (Wasserzeichen-`SELECT`, `state IN (success,warning) AND success`, `LIMIT 1` → NULL bei Erstlauf) |
| 8 | [001.sp_ins_execution.sql:103-112](../db/schemas/log/procedures/001.sp_ins_execution.sql#L103) (`release_version`, `ORDER BY deployed_on DESC, id DESC`) |
| 9 | [001.sp_ins_execution.sql:135-137](../db/schemas/log/procedures/001.sp_ins_execution.sql#L135) (`current_user`, `p_machine`, `p_instance`) |
| 10,11,12 | [001.sp_upd_execution.sql:51-101](../db/schemas/log/procedures/001.sp_upd_execution.sql#L51) (NULL/leer-Guards, Allowlist, Kombinatorik-`IF`) |
| 13,15 | [001.sp_upd_execution.sql:110-125](../db/schemas/log/procedures/001.sp_upd_execution.sql#L110) (`UPDATE` nur state/success/end_on; `IF NOT FOUND` → `no_data_found`) |
| 14 | Trigger `tr_u_execution` (di2f-0001) — Update fasst `modified_*` nicht an |
| 16,17,18 | `001.sp_upd_execution_{error,success,warning,information}.sql` (delegieren per `CALL`) |

Kein ungenannter Nebeneffekt; Datei-Scope passt exakt zum Feature.

### Konventionen (`sql.md`, `procedures.md`)
- Naming (`sp_<verb>_<entity>`, snake_case), Dollar-Quoting `$procedure$`, DROP-vor-CREATE mit voller
  Signatur, `OWNER TO :schema_owner`, `\echo`-Kopf/Fuß: ✅
- `:schema_log`/`:schema_owner` in DDL, Body schema-qualifiziert hartkodiert (`log.execution`,
  `config.process`, `config.db_version`) — sql.md-Body-Ausnahme korrekt angewandt: ✅
- `format($$…$$, …)` mit indizierten `%n$s`, Text in Hochkommas / Numerik+Boolean ohne,
  `RAISE EXCEPTION USING` einzeilig, gültige ERRCODE-Condition-Names
  (`invalid_parameter_value`/`foreign_key_violation`/`no_data_found`): ✅
- Body-Struktur Get name / Check parameter / Workload, DECLARE-Banner-Gruppierung
  (Common/Error Handling/Workload), Parameter-Reihenfolge „Identifier zuerst" (`INOUT p_id` vorn),
  Parameter-Doku-Block, tabellarisches Alignment: ✅
- Schlanke Get-name-Variante (Literal statt `lc_messages`/`PG_CONTEXT`) — etablierte Konvention aus
  di2f-0001: ✅

### Findings

**Blocker:** keine. **Major:** keine.

**Minor / Info:**
1. **Lean-Wrapper-Struktur** — die vier Wrapper
   ([001.sp_upd_execution_error.sql](../db/schemas/log/procedures/001.sp_upd_execution_error.sql) u. a.)
   bestehen aus `Get name` + `Workload`(CALL) **ohne** `Check parameter`-Block. Zulässig, da reine
   Delegatoren (Validierung vollständig in `sp_upd_execution`); konsistent mit der „optionalen
   Check/Workload-Trennung" aus procedures.md. Kein Defekt — als bewusste Setzung notiert.
2. **`end_on = now()` auch bei generischem Update auf `processing`** —
   [001.sp_upd_execution.sql:114](../db/schemas/log/procedures/001.sp_upd_execution.sql#L114) finalisiert
   `end_on` bei **jedem** Update, auch für die (gültige) Kombination `processing/false`. Spec-konform
   (User: „Update setzt end_on"); die Wrapper sind terminal. Falls je ein **nicht-terminales**
   Fortschritts-Update gebraucht wird, müsste `end_on` konditional werden. Info, kein Defekt.
3. **Defense-in-depth `CHECK`-Constraint** — der Wasserzeichen-Filter
   ([001.sp_ins_execution.sql:96](../db/schemas/log/procedures/001.sp_ins_execution.sql#L96)) ist
   case-sensitiv und verlässt sich auf die `lower(trim())`-Normalisierung im Schreibpfad
   ([001.sp_upd_execution.sql:79](../db/schemas/log/procedures/001.sp_upd_execution.sql#L79)). Ein
   `CHECK`-Constraint auf `log.execution(state)` bzw. die volle `(state,success)`-Kombinatorik würde
   die Invariante DB-seitig garantieren (gegen Out-of-band-Writes). Optional → `/security`-Kandidat.
4. **Index für Wasserzeichen-Query (perf)** — die Watermark-`SELECT` filtert `process_id`
   (Index `ix_execution_process_id` vorhanden) + `state`/`success` und sortiert nach `start_on`. Bei
   sehr großen `execution`-Tabellen wäre ein partieller Index
   `(process_id, start_on DESC) WHERE success AND state IN (…)` günstiger. Im Single-Tenant-/
   Niedrigvolumen-Kontext unkritisch → Follow-up/`/security`-Perf-Notiz.

### Security-Smells am Diff
Kein Dynamic SQL (kein `EXECUTE`); `p_state` allowlist-validiert und nur als Wert genutzt; kein
`SECURITY DEFINER` (INVOKER); Body schema-qualifiziert → kein `search_path`-Hijack; keine Secrets;
Fehlermeldungen nur mit numerischen IDs + allowlisteten States. ✅

### Deploy-Tauglichkeit
Skripte am richtigen Ort (`db/schemas/log/procedures/`, Präfix `001` = Tabelle `execution`);
Sektions-Reihenfolge (procedures nach tables/functions) löst Dependencies; idempotent
(`DROP … IF EXISTS` + `CREATE OR REPLACE`, Deploy 2× rc=0 in QA). ✅

### Empfehlung
**Approve** — keine Blocker, keine Major; vier Minor/Info (Lean-Wrapper als bewusste Setzung,
`end_on`-Semantik spec-konform, optionaler `CHECK`-Constraint + Perf-Index als `/security`-/
Follow-up-Kandidaten). di2f-0010-Code ist korrekt, `/qa`-READY, idempotent, least-privilege
verifiziert. Nächster Schritt: `/deploy dev`.
