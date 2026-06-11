# di2f-0001: Finalisierung der Tabelle `config.process` (Umzug aus `log`)

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** config (primär) · log (Strukturanpassung: FK + Renumbering)

## Problem / Motivation
Die Tabelle `process` (Stammdaten der protokollierten Prozesse) existiert bisher im Schema `log`
(`log/tables/001.process.sql`), hat aber weder Zugriffs-Prozeduren noch Stammdaten noch Tests.

Inhaltlich sind **Prozesse Konfigurationsdaten** — sie gehören damit ins Schema `config`, nicht in
`log` (dort liegen die *Protokoll-Einträge*, nicht ihre Stammdaten). Dieses Feature **verlegt
`process` nach `config`** und „finalisiert" die Tabelle dort: Insert-/Update-/Delete-Prozeduren,
ein Default-Seed und ein Testskript. Die Protokoll-Tabelle `log.execution` referenziert die Prozesse
weiterhin — künftig **schemaübergreifend** über `process_id → config.process(id)`. Da `process` das
Schema `log` verlässt, werden die verbliebenen `log`-Tabellen wieder ab `001` durchnummeriert.

## User Stories
- Als **aufrufender Prozess/Job** möchte ich einen Prozess über `config.sp_ins_process` anlegen,
  damit ich anschließend Executions (`log.execution`) darauf referenzieren kann.
- Als **Administrator** möchte ich den Namen eines Prozesses über `config.sp_upd_process`
  korrigieren, ohne den Datensatz neu anlegen zu müssen.
- Als **Administrator** möchte ich einen nicht mehr benötigten Prozess über `config.sp_del_process`
  entfernen, aber davor geschützt werden, einen noch von Executions referenzierten Prozess zu löschen.
- Als **Entwickler** möchte ich, dass eine frisch deployte DB einen Default-Prozess enthält
  (`name = 'default'`), damit Executions sofort gegen einen gültigen Prozess laufen können.
- Als **Entwickler/QA** möchte ich ein psql-Testskript, das die drei Prozeduren und das Seeding
  automatisiert prüft — und damit zugleich die Test-Konvention für `db/tests/` etabliert.

## Scope
Betroffene Objekte (je mit Zweck):

**Strukturumzug (config ⇄ log):**
- **`config.process`** — Tabelle zieht von `log/tables/001.process.sql` nach
  `config/tables/005.process.sql` (config hat bereits 001–004 belegt); ergänzt um
  `UNIQUE (name)`. Spalten/PK/Audit bleiben unverändert.
- **`config.tf_set_modified()` + `config.tr_u_process`** — config-eigener modified-Trigger für
  `process` (config wird **vor** `log` deployt → darf `log.tf_set_modified()` nicht referenzieren).
- **`log.execution`** — FK `fk_execution_process_id` zeigt künftig auf **`config.process(id)`**
  (schemaübergreifend); Datei-Renumbering von `log/tables/002.execution.sql` → `001.execution.sql`.
- **`log`-Renumbering** — die verbliebenen `log`-Tabellen + Trigger wieder ab `001`
  (execution=001, component=002, trace=003, error=004, import_file=005, export_file=006; Trigger
  analog). Rein mechanisch, kein Verhaltensänderung.

**Finalisierung `config.process` (CRUD / Seed / Test):**
- **`config.sp_ins_process`** — legt einen neuen Prozess an, gibt die neue `id` an den Aufrufer zurück.
- **`config.sp_upd_process`** — ändert den Namen eines bestehenden Prozesses.
- **`config.sp_del_process`** — löscht einen Prozess; weist referenzierte Prozesse ab.
- **Seed** `config/data/005.process.sql` — fügt **einen** Default-Datensatz (`name = 'default'`)
  idempotent ein.
- **Test** `db/tests/…` — reines psql + Assertions (DO/`ASSERT`), prüft Prozeduren + Seeding gegen
  eine frisch deployte DB; legt das Test-Format für das Projekt fest.

## Nicht-Ziele
- **Keine Datenmigration:** `log`/`config` sind noch nicht in prod deployt — der Umzug erfolgt per
  Drop-and-Recreate der Skripte (kein `ALTER`/Daten-Transfer).
- **Kein Soft-Delete** (keine `deleted_on`-Spalte) — Delete ist physisch.
- **Keine Force-Delete-Option** — ein von Executions referenzierter Prozess bleibt hart geschützt.
- **Keine eigene Framework-Protokollierung** in den Prozeduren (kein Execution/Component/Trace) —
  Stammdaten-CRUD; Fehler nur via `RAISE`.
- **Kein `p_actor_email`-Parameter** — Audit über `current_user` (Default + `tr_u_process`-Trigger),
  bewusste Abweichung für diese framework-interne Stammdaten-Tabelle.
- **Kein Bulk-/CSV-Import** — der Seed ist statisch (genau der Default-Datensatz).
- **Keine Views** (separates Feature).

## Datenmodell-Auswirkung
- **`process` wechselt das Schema:** `log.process` → `config.process` (Tabellengruppe `005` in
  config). Struktur unverändert: `id bigserial` PK, `name varchar(100) NOT NULL`, Audit-Spalten.
- **Neuer Constraint** `uq_process_name UNIQUE (name)` auf `config.process`.
- **Schemaübergreifender FK** `fk_execution_process_id`: `log.execution.process_id` →
  `config.process(id)` (Default `ON DELETE RESTRICT` als Backstop zum Pre-Check in `sp_del_process`).
- **Audit:** `created_on`/`created_by` mit Default (`now()` / `current_user`);
  `modified_on`/`modified_by` per `config.tr_u_process` (→ `config.tf_set_modified()`).
- **`log`-Tabellen + Trigger** werden neu nummeriert (ab `001`); keine strukturelle Änderung an
  execution/component/trace/error/import_file/export_file außer der execution-FK.

## Protokollierungs-Integration
Bewusst **schlank**: Die Prozeduren schreiben **keine** Execution/Component/Trace-Einträge
(Vermeidung zirkulären Loggings auf der Konfigurations-/Log-Infrastruktur). Fehler werden über
`RAISE EXCEPTION` mit `format()`-Meldung (separate Variablen, sql.md-Pattern) gemeldet; der
`EXCEPTION`-Pfad gibt eine deterministische, verständliche Meldung zurück.

## Akzeptanzkriterien

**Struktur (Umzug + Renumbering):**
1. Die Tabelle `process` liegt im Schema **`config`** (`config/tables/005.process.sql`) und nicht
   mehr in `log`; `log/tables/*process*.sql` existiert nicht mehr.
2. `config.process` besitzt den Constraint `uq_process_name UNIQUE (name)`.
3. `log.execution` besitzt den FK `fk_execution_process_id` auf **`config.process(id)`**
   (schemaübergreifend).
4. Die verbliebenen `log`-Tabellen sind ab `001` durchnummeriert
   (execution=001, component=002, trace=003, error=004, import_file=005, export_file=006), die
   zugehörigen Trigger entsprechend; ein vollständiger `bash db/scripts/deploy.sh all <env>` läuft
   ohne Fehler durch.
5. `config.process` wird bei jedem `UPDATE` durch `config.tr_u_process` gepflegt
   (`modified_on`/`modified_by` gesetzt); der Trigger referenziert **keine** `log`-Objekte.

**CRUD `config.process`:**
6. `sp_ins_process` legt mit gültigem Namen einen neuen Prozess an, setzt `created_on`/`created_by`
   per Default und gibt die neue `id` an den Aufrufer zurück.
7. `sp_ins_process` lehnt einen bereits existierenden Namen mit einer **verständlichen** Meldung ab
   (kein roher Constraint-Fehler an den Client).
8. `sp_ins_process` lehnt `NULL` oder einen (nach `trim`) leeren Namen mit Meldung ab.
9. `sp_upd_process` ändert den Namen eines existierenden Prozesses; `modified_on`/`modified_by`
   werden durch `config.tr_u_process` automatisch gesetzt; ein Update auf den **identischen**
   (unveränderten) Namen ist erlaubt (No-op, kein Fehler).
10. `sp_upd_process` lehnt ab, wenn die `id` nicht existiert.
11. `sp_upd_process` lehnt ab, wenn der neue Name bereits von einem **anderen** Prozess verwendet wird.
12. `sp_del_process` löscht einen Prozess, der von **keiner** Execution referenziert wird.
13. `sp_del_process` weist das Löschen mit verständlicher Meldung (inkl. Anzahl referenzierender
    Executions) ab, wenn der Prozess referenziert wird; der Datensatz bleibt erhalten.
14. `sp_del_process` lehnt ab, wenn die `id` nicht existiert.

**Seed & Test:**
15. `config/data/005.process.sql` legt **genau einen** Datensatz mit `name = 'default'` an und ist
    **idempotent** (mehrfacher Lauf erzeugt keine Duplikate, keinen Fehler).
16. Das Testskript unter `db/tests/` ist ein **reines psql-Skript mit Assertions** (DO-Blöcke /
    `ASSERT`, keine Extension), deckt AK 6–15 ab und läuft gegen eine frisch deployte DB grün; es
    dient als Vorlage/Konvention für künftige `db/tests/`-Skripte.

## Edge Cases
- Doppelter Name bei Insert **und** bei Update (Kollision mit anderem Prozess).
- `NULL` / leerer / nur-Whitespace-Name.
- Update auf den **identischen** Namen (muss erlaubt sein, kein Selbst-Kollisions-Fehler).
- Delete eines von Executions **referenzierten** Prozesses (Pre-Check + FK-Backstop).
- Update/Delete mit **nicht existierender** `id`.
- Name länger als 100 Zeichen (übersteigt `varchar(100)`).
- Nebenläufige Inserts desselben Namens — der `UNIQUE`-Constraint schützt; der zweite Aufruf erhält
  den definierten Fehler.
- **Cross-Schema-FK / Deploy-Reihenfolge:** Ein `deploy.sh log <env>` **ohne** vorher deploytes
  `config` lässt die FK-Erstellung auf `config.process` mit klarer Meldung scheitern; der volle
  `deploy.sh all` (helper→config→log) ordnet das korrekt.
- **Teardown/Clean:** `config` allein leeren/droppen, während `log.execution` noch referenziert,
  schlägt durch den FK fehl → Abräum-Reihenfolge muss `log` vor `config` berücksichtigen
  (bzw. DB-Drop).
- Seed mehrfach deployt → bleibt bei genau einem `default`-Datensatz.

## Abhängigkeiten
- Requires: Schema `config` wird **vor** `log` deployt — durch die Runner-Reihenfolge
  `helper → config → log → etl` ([db/scripts/deploy.sh:40](../db/scripts/deploy.sh#L40)) erfüllt.
- Requires: Tabelle `log.execution` (für den Referenz-Check in `sp_del_process` und den Test).
- Requires: `config.tf_set_modified()` (neu in diesem Feature) für `config.tr_u_process`.
- Relates: di2f-0005 (DB-CI) — das psql-Testskript kann dort als Smoke-/Lint-Schritt aufgegriffen werden.

---

## Tech Design (Solution Architect)

> **Views nötig: Nein.** di2f-0001 ist reines Backend — Tabellenumzug, drei CRUD-Prozeduren, ein
> Seed und ein Testskript. Es gibt nichts auszuwerten/zu monitoren. Nach `/backend` folgt **kein**
> `/frontend`.

### A) Einordnung
Prozesse sind **Konfigurations-Stammdaten**, keine Protokoll-Einträge. Das Feature verschiebt die
`process`-Tabelle deshalb aus `log` nach `config` und macht sie dort „benutzbar": kontrolliertes
Anlegen/Ändern/Löschen über Prozeduren, ein Default-Stammdatum und ein automatisierter Test. Die
Protokoll-Tabelle `log.execution` zeigt weiterhin auf einen Prozess — nun schemaübergreifend.

### B) Objekt-Landschaft (flache Liste, keine Implementierung)

**Schema `config` (neu/zugezogen):**
- `config.process` *(Tabelle)* — Stammdaten benannter Prozesse; zieht aus `log`, erhält `UNIQUE(name)`.
- `config.tf_set_modified()` *(Trigger-Funktion, NEU)* — setzt `modified_on`/`modified_by` bei jedem
  UPDATE; erste Trigger-Funktion in `config`, wiederverwendbar für künftige config-Tabellen.
- `config.tr_u_process` *(Trigger)* — feuert `tf_set_modified()` bei UPDATE auf `process`.
- `config.sp_ins_process` *(Prozedur)* — legt einen Prozess an, gibt die neue `id` zurück.
- `config.sp_upd_process` *(Prozedur)* — benennt einen Prozess um.
- `config.sp_del_process` *(Prozedur)* — löscht einen Prozess; schützt referenzierte Prozesse.
- `config/data/005.process.sql` *(Seed)* — ein Default-Datensatz (`name = 'default'`).

**Schema `log` (Strukturanpassung, kein neues Verhalten):**
- `log.execution` — FK `process_id` zeigt künftig auf `config.process(id)`; Datei-Renumber `002 → 001`.
- `log.component` / `trace` / `error` / `import_file` / `export_file` — reines Datei-Renumber.
- log-Trigger — Renumber; `log/.../tr_u_process` **entfällt** (zieht nach config).
- `log/tables/…process.sql` **entfällt** (zieht nach config).

**`db/tests/`:**
- erstes psql-Testskript (Assertions) — etabliert die Test-Konvention.

### C) Datenmodell (Klartext)
Ein **Prozess** hat:
- eine eindeutige `id` (technischer Schlüssel),
- einen **eindeutigen Namen** (max. 100 Zeichen),
- Audit: *wer/wann angelegt* (`created_on`/`created_by`), *wer/wann zuletzt geändert*
  (`modified_on`/`modified_by`).

Gespeichert in **`config.process`**. Beziehung: **viele** `log.execution`-Einträge verweisen über
`process_id` auf **einen** `config.process`. Ausgeliefertes Stammdatum: **genau ein** Prozess
`default`.

### D) Schnittstellen (Klartext, nur Zweck — kein Code)
- `config.sp_ins_process(name) → neue id` — legt einen Prozess an; lehnt **leeren** und **doppelten**
  Namen mit klarer Meldung ab.
- `config.sp_upd_process(id, neuer_name)` — benennt um; **identischer** Name = No-op (kein Fehler);
  **doppelter** Name oder **fehlende** `id` = klare Meldung.
- `config.sp_del_process(id)` — löscht; **referenzierter** Prozess = Abweisung **mit Anzahl** der
  Executions (Datensatz bleibt); **fehlende** `id` = Meldung.

Audit-Akteur kommt aus `current_user` (kein `p_actor_email`-Parameter) — bewusste Abweichung für diese
framework-interne Stammdaten-Tabelle.

### E) Datenfluss & Protokollierung
- **Anlegen:** Aufrufer → `sp_ins_process` → neue Zeile in `config.process` → `id` zurück → später
  `log.execution` mit diesem `process_id`.
- **Ändern:** `sp_upd_process` → UPDATE → Trigger `tr_u_process` setzt `modified_on`/`modified_by`.
- **Löschen:** `sp_del_process` zählt zuerst die referenzierenden `log.execution`-Zeilen;
  > 0 → Abweisung mit Anzahl (Datensatz bleibt), = 0 → DELETE. Der FK (`RESTRICT`) wirkt als
  Backstop bei Direktzugriff.

**Bewusst keine** Execution/Component/Trace/Error-Protokollierung in diesen Prozeduren — sonst würde
die Stammdaten-/Infrastruktur sich selbst protokollieren (zirkulär). Fehler werden ausschließlich
über `RAISE` mit `format()`-Meldung (separate Variablen, sql.md-Pattern) gemeldet.

### F) Tech-Entscheidungen (für PM begründet)
1. **`process` nach `config`:** Prozesse sind Konfigurations-Stammdaten; `log` enthält nur die
   *Einträge* einer Ausführung. Der Umzug schärft die Schema-Semantik.
2. **Schemaübergreifender FK statt Duplizieren:** Es gibt **eine** Wahrheit für Prozesse;
   `execution` verweist direkt darauf. Möglich, weil `config` **vor** `log` deployt wird.
3. **Eigene `config.tf_set_modified()` statt Wiederverwendung von `log`:** Die Deploy-Reihenfolge
   (config zuerst) verbietet einen Verweis auf ein `log`-Objekt; zugleich bleibt `config`
   selbst-konsistent und der Trigger für weitere config-Tabellen nutzbar.
4. **Pre-Check + FK-Backstop beim Löschen:** freundliche Meldung *mit Anzahl* statt rohem
   FK-Fehler; der FK schützt zusätzlich bei direktem Zugriff an den Prozeduren vorbei.
5. **Schlanke Prozeduren ohne `lc_messages`/Komponenten-Logging:** kein `GRANT SET ON PARAMETER`
   nötig (BUG-0337); passt zur Entscheidung „keine Framework-Protokollierung".
6. **`log`-Renumber ab 001:** rein strukturell/kosmetisch — hält die Tabellen-Gruppennummern nach
   dem Wegzug von `process` lückenlos.
7. **Test als reines psql + `ASSERT`:** keine Extension-Abhängigkeit, läuft in jeder Umgebung und in
   der DB-CI (di2f-0005).

### G) Abhängigkeiten (Technik)
- **Deploy-Reihenfolge** `helper → config → log → etl` ([db/scripts/deploy.sh:40](../db/scripts/deploy.sh#L40))
  — config vor log; erfüllt.
- **`log.execution`** muss existieren (Referenz-Check in `sp_del_process` + Test).
- **Laufzeitrolle (RW):** braucht `USAGE` auf **beiden** Schemas (`config`, `log`), `SELECT` auf
  `log.execution` (Cross-Schema-Read im Löschpfad) und DML auf `config.process` — im bestehenden
  Grant-Modell (fw-Owner Default Privileges) abgedeckt; im `/backend` verifizieren.
- **Keine** Extensions, **kein** `etl`/Dynamic SQL, **keine** Views.

---

## Backend (implementiert)

> Stand `/backend`. Smoke-Test gegen PostgreSQL 17 (Docker): `deploy.sh all local` (idempotent,
> 2× fehlerfrei) + `db/tests/config/005.process.sql` → **AK 6–15 grün**, Default-Seed-Anzahl
> bleibt 1.

### Implementierte Schnittstellen
- `config.sp_ins_process(IN p_name varchar, INOUT p_id bigint)` — legt Prozess an, liefert neue `id`
  über `INOUT p_id`. Fehler: `invalid_parameter_value` (Name NULL/leer), `unique_violation`
  (Name existiert).
- `config.sp_upd_process(IN p_id bigint, IN p_name varchar)` — benennt um; identischer Name = No-op.
  Fehler: `invalid_parameter_value` (`p_id` NULL / Name leer), `no_data_found` (id unbekannt),
  `unique_violation` (Name von anderem Prozess belegt).
- `config.sp_del_process(IN p_id bigint)` — löscht; Pre-Check zählt `log.execution`. Fehler:
  `invalid_parameter_value` (`p_id` NULL), `no_data_found` (id unbekannt), `foreign_key_violation`
  (referenziert — Meldung **mit Anzahl**; FK als Race-Backstop).
- `config.tf_set_modified()` + Trigger `config.tr_u_process` — setzen `modified_on`/`modified_by`.
- Seed `config.process`: ein Datensatz `name = 'default'` (`ON CONFLICT (name) DO NOTHING`).
- Index `ix_execution_process_id` auf `log.execution (process_id)` (FK-Spalte + Delete-Count).

### Konventions-Entscheidungen (Framework-Setzung)
- **Body-Schema-Referenzen hardcoded qualifiziert:** psql interpoliert `:schema_*` **nicht** in
  Dollar-Quoting (empirisch bestätigt: `ERROR: syntax error at or near ":"`). Entscheidung (User):
  der Prozedur-Body referenziert **explizit qualifiziert** (`config.process` / `log.execution`); die
  DDL-Teile (CREATE/DROP/OWNER) bleiben `:schema_*`-Variablen (Single Source of Truth für Ablage).
  Vertretbar, weil die vier Schemanamen über **alle** Umgebungen fix sind — nur ein globaler
  Schema-Rename wäre ein grep-replace. **Erste Prozeduren im Framework → setzt die Konvention.**
- **Schlanke Procs:** `l_component` als Literal gesetzt (kein `lc_messages`/`PG_CONTEXT`), daher kein
  `GRANT SET ON PARAMETER lc_messages` nötig (BUG-0337).
- **Constraint-Layout (sql.md erweitert):** PK inline (explizit benannt, am Ende des `CREATE TABLE`);
  `UNIQUE`/`FK` als separate idempotente `ALTER TABLE … DROP CONSTRAINT IF EXISTS … ; ADD CONSTRAINT
  …` nach `ALTER … OWNER`, gruppiert. Repo-weit auf alle config/log-Tabellen angewendet.

---

## QA Test Results

**Getestet:** 2026-06-11 · **Umgebung:** PostgreSQL 17 (Docker, wegwerfbar) · **Runner:**
`deploy.sh all local` (2× idempotent) + `db/tests/config/005.process.sql` (psql + `ASSERT`,
transaktional mit `ROLLBACK`). Test zusätzlich **als Laufzeitrolle** `di2f_sa` (erbt `di2f_rw`,
nicht Owner) ausgeführt → bestanden.

### Akzeptanzkriterien

| # | Kriterium | Ergebnis | Beleg |
|---|-----------|----------|-------|
| 1 | `process` in `config`, nicht mehr in `log` | ✅ | Katalog: `config.process` existiert, `log.process` nicht |
| 2 | `uq_process_name UNIQUE (name)` | ✅ | Katalog + AK 7/11 (unique_violation) |
| 3 | FK `fk_execution_process_id` → `config.process(id)` | ✅ | Katalog (`confrelid` = config.process) + AK 13 |
| 4 | `log`-Tabellen ab 001 neu nummeriert, `deploy.sh all` grün | ✅ | Dateisystem (`ls`) + Deploy rc=0 |
| 5 | `config.tr_u_process` pflegt `modified_*`, ohne `log`-Bezug | ✅ | Katalog + AK 9 (modified_on gesetzt) |
| 6 | `sp_ins_process`: anlegen, `id` zurück, created-Defaults | ✅ | Test |
| 7 | `sp_ins_process`: doppelter Name abgewiesen | ✅ | Test (unique_violation) |
| 8 | `sp_ins_process`: NULL/leer/Whitespace abgewiesen | ✅ | Test (invalid_parameter_value) |
| 9 | `sp_upd_process`: umbenennen, `modified_*` via Trigger, identisch = No-op | ✅ | Test |
| 10 | `sp_upd_process`: nicht existierende `id` abgewiesen | ✅ | Test (no_data_found) |
| 11 | `sp_upd_process`: fremder Name abgewiesen | ✅ | Test (unique_violation) |
| 12 | `sp_del_process`: nicht referenzierten Prozess löschen | ✅ | Test |
| 13 | `sp_del_process`: referenzierten abweisen (mit Anzahl), Datensatz bleibt | ✅ | Test (foreign_key_violation) |
| 14 | `sp_del_process`: nicht existierende `id` abgewiesen | ✅ | Test (no_data_found) |
| 15 | Seed: genau ein `default`, idempotent | ✅ | Test + Deploy 2× → Anzahl bleibt 1 |
| 16 | psql-Testskript deckt AK ab, frisch deployt grün | ✅ | Skript erweitert (AK 1–3,5 strukturell + 6–15 + Edge) |

### Edge Cases
- Doppelter Name (ins/upd), NULL/leer/Whitespace, identischer Name (No-op), Delete referenziert,
  Update/Delete unbekannte `id`: alle ✅ (siehe AK 7–14).
- **Name > 100 Zeichen:** ✅ — wirft `string_data_right_truncation` (22001), **kein** stiller Cut
  (definierter, sicherer Fehler; keine AK fordert eine freundliche Meldung).
- **Nebenläufige Inserts gleichen Namens:** durch `uq_process_name` + `EXCEPTION WHEN
  unique_violation` abgesichert (funktional über AK 7 belegt; echte Parallelität nicht im
  Single-Session-Skript reproduzierbar).
- **Idempotenz:** Deploy 2× rc=0, keine `ERROR:`/`FATAL`, Seed bleibt bei 1.

### Protokollierungs-Integration
Spec-konform **schlank**: die Prozeduren schreiben **keine** Execution/Component/Trace/Error-Einträge
(kein Dynamic SQL, keine Inserts nach `log.*`; `sp_del_process` **liest** nur `log.execution`).
Fehler ausschließlich über `RAISE` mit `format()`-Meldung.

### Feature-spezifische Security-Funde
- **`SECURITY INVOKER`** (kein `SECURITY DEFINER`) bei allen drei Prozeduren → keine
  Privilege-Escalation. ✅ (Katalog: `prosecdef = f`)
- **Kein Dynamic SQL** (kein `EXECUTE`) → keine Injection-Fläche; `format()` erzeugt nur
  Fehler-Meldungstext (indizierte Platzhalter), wird nicht als SQL ausgeführt. ✅
- **Least-Privilege verifiziert:** Test als `di2f_sa`/`di2f_rw` (Nicht-Owner) grün — inkl.
  Cross-Schema-`SELECT` auf `log.execution` im Löschpfad mit Standard-Grants. ✅
- **Niedrig/Info — FK `ON DELETE`:** `confdeltype = 'a'` (NO ACTION). Die Spec sprach von
  „RESTRICT"; funktional identisch (Löschen referenzierter Prozesse wird abgewiesen). Optional
  explizites `ON DELETE RESTRICT` für Klarheit.

### Kandidaten für nächsten `/security`-Run
- **Cross-Schema-Grant-Modell:** `di2f_rw` braucht `USAGE` auf `config`+`log`, `SELECT` auf
  `log.execution`, `EXECUTE` auf `config`-Routinen. In QA mit manuellen Grants belegt; das **reale
  `db/database/`-Bootstrap** (laut CLAUDE.md noch nicht auf die vier Schemas umgebaut) muss diese
  Grants vergeben — **bei `/deploy dev` verifizieren**.
- **Audit über `current_user`** (Verbindungsrolle) statt App-Akteur — bewusste Spec-Entscheidung für
  framework-interne Stammdaten; projektweite Bewertung der Audit-Konvention für `config`.
- **BUG-0002** (sqlfluff PG01-Fehlalarm auf `CREATE INDEX`) — Lint-Konfig, kein SQL-Fehler.

### Production-Ready-Entscheidung
**READY.** Keine Critical/High/Medium-Bugs. AK 1–16 + Edge Cases bestanden, idempotent,
least-privilege verifiziert. Offene Punkte sind **Verifikations-/Konfig-Aufgaben** (Cross-Schema-
Grants im realen Bootstrap → spätestens `/deploy dev`), keine Code-Defekte.

---

## Code Review

- **Reviewer:** `/review` (Claude) · **Datum:** 2026-06-11
- **Commit-Range (di2f-0001):** `c72697d` (Spec) · `6232176` (Tech Design) · `a4c3f8f` (Backend +
  Konvention) · `518090e` (Banner-Stil + sql.md-Regel) · `0e659ea` (QA). di2f-0005-Commits sind
  zwischengeschoben und **nicht** Teil dieses Reviews.
- **Diff-Scope:** `config.process` (Tabelle/Trigger/Procedures/Seed), `log`-Renumber + FK, `db/tests/`,
  `.claude/rules/sql.md` (Konvention), Tracking. Keine fremden Dateien.

### Spec ↔ Code
AK 1–16 im Code lokalisiert und durch `/qa` belegt (Tabelle/Constraints/FK/Trigger/Procedures/Seed/
Test). Keine ungenannten Nebeneffekte; Datei-Scope passt zum Feature.

### Konventionen (`sql.md` u. a.)
- Naming (`sp_`/`tf_`/`tr_`, snake_case, singular), Dollar-Quoting (`$procedure$`/`$triggerfunction$`),
  DROP-vor-CREATE, `OWNER TO`, `\echo`-Kopf/Fuß: ✅
- `format($$…$$, …)`-Fehler über separate Variablen, indizierte `%n$s`, Quoting-Regeln: ✅
- Body-Struktur Get name / Check parameter / Workload, tabellarisches Alignment: ✅
- Neue Constraint-Konvention (PK inline; UNIQUE/FK als idempotente `ALTER`; Banner-Kommentare): ✅
- Idempotenz aller `db/`-Skripte (Deploy 2× rc=0): ✅

### Findings

**Blocker:** keine.

**Major:**
1. **`sql.md`-Selbstwiderspruch** — [sql.md:63](../.claude/rules/sql.md#L63) sagt „ALWAYS use a
   parameter or variable for the schema name — **NEVER hard code schema names**", aber die
   Procedure-Bodies referenzieren bewusst hardcodiert `config.process` / `log.execution` (z. B.
   [005.sp_del_process.sql](../db/schemas/config/procedures/005.sp_del_process.sql)). Der Code ist
   **korrekt** (psql interpoliert `:schema_*` nicht in Dollar-Quoting — empirisch belegt), aber die
   maßgebliche Regel muss eine **Ausnahme dokumentieren**: DDL nutzt `:schema_*`; im
   dollar-gequoteten Body wird schema-qualifiziert hardcodiert. Sonst führt die autoritative Regel
   künftige `/backend`/`/review` in die Irre. **Fix: doc-only in `sql.md`, kein Re-QA.**
   → **BEHOBEN:** [sql.md:63 ff.](../.claude/rules/sql.md#L63) um die Body-Ausnahme (Dollar-Quoting)
   ergänzt; DDL bleibt `:schema_*`, Body schema-qualifiziert hartkodiert.

**Minor:**
2. **Lean Get-name-Variante undokumentiert** — die Procedures setzen `l_component` als Literal und
   lassen `SET LOCAL lc_messages` + `GET DIAGNOSTICS PG_CONTEXT` aus (begründet: kein
   Komponenten-Logging → kein `GRANT SET ON PARAMETER`, BUG-0337). Sinnvoll, aber in
   `sql.md`/`procedures.md` nicht als zulässige Variante erwähnt. → kurz dokumentieren. (Das Literal
   enthält zudem den Schemanamen `config.` — selbes Thema wie Major #1.)
3. **FK ohne explizites `ON DELETE`** — [001.execution.sql](../db/schemas/log/tables/001.execution.sql):
   `confdeltype = NO ACTION`; Spec-Text nennt „RESTRICT". Funktional gleich (referenzierte Deletes
   abgewiesen, AK 13 ✅). → optional explizit `ON DELETE RESTRICT`.

**Info / Kandidaten für `/security`:**
4. Natürliche zusammengesetzte PKs in `config.configuration` / `db_version` / `table_metadata`
   widersprechen `sql.md` („PK immer `id bigserial`") — **vorbestehend**, außerhalb di2f-0001
   (nur `table_metadata`-UNIQUE wurde verschoben). Systemisch → eigener Konvention-/`/security`-Task.
5. Cross-Schema-Grants für `di2f_rw` — in QA-Sandbox belegt; reales `db/database/`-Bootstrap muss sie
   vergeben (bei `/deploy dev` verifizieren).
6. BUG-0002 (sqlfluff PG01-Fehlalarm auf `CREATE INDEX`) — Lint-Konfig.

### Deploy-Tauglichkeit
Skripte am richtigen Ort; `deploy.sh`-Sektions-/Nummern-Reihenfolge löst Dependencies (config vor log
→ Cross-Schema-FK); idempotent verifiziert. ✅

### Empfehlung
**Approve with Comments** — keine Blocker. Ein Major (`sql.md`-Doku-Widerspruch; doc-only, vor
Merge empfohlen, damit die Konventionen kohärent bleiben), Minors optional/Follow-up. di2f-0001-Code
ist korrekt, `/qa`-READY, idempotent, least-privilege verifiziert.
