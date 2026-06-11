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
