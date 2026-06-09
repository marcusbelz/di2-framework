# di2f-0001: Finalisierung der Tabelle `log.process`

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** log

## Problem / Motivation
Die Tabelle `log.process` (Stammdaten der protokollierten Prozesse) existiert bereits, hat aber
weder Zugriffs-Prozeduren noch Stammdaten noch Tests. Damit Anwendungen Prozesse kontrolliert
anlegen, ändern und entfernen können — und damit `log.execution` über `process_id` auf gültige
Prozesse verweist — wird die Tabelle mit Insert-/Update-/Delete-Prozeduren, einem Seed-Skript und
einem Testskript „finalisiert".

## User Stories
- Als **aufrufender Prozess/Job** möchte ich einen Prozess über `sp_ins_process` anlegen, damit ich
  anschließend Executions darauf referenzieren kann.
- Als **Administrator** möchte ich den Namen eines Prozesses über `sp_upd_process` korrigieren,
  ohne den Datensatz neu anlegen zu müssen.
- Als **Administrator** möchte ich einen nicht mehr benötigten Prozess über `sp_del_process`
  entfernen, aber davor geschützt werden, einen noch referenzierten Prozess zu löschen.
- Als **Entwickler** möchte ich Standard-Prozesse per Deployment-Skript bereitgestellt bekommen,
  damit eine frisch deployte DB sofort sinnvolle Stammdaten enthält.
- Als **Entwickler/QA** möchte ich ein Testskript, das die drei Prozeduren und das Seeding
  automatisiert prüft.

## Scope
Betroffene Objekte (je mit Zweck):
- **`log.process`** (bestehende Tabelle) — ergänzt um `UNIQUE (name)`.
- **`log.sp_ins_process`** — legt einen neuen Prozess an, gibt die neue `id` zurück.
- **`log.sp_upd_process`** — ändert den Namen eines bestehenden Prozesses.
- **`log.sp_del_process`** — löscht einen Prozess; weist referenzierte Prozesse ab.
- **Seed** `db/schemas/log/data/001.process.sql` — fügt die Prozess-Stammdaten idempotent ein.
- **Test** `db/tests/…` — prüft Prozeduren + Seeding gegen eine frisch deployte DB.

## Nicht-Ziele
- **Kein Soft-Delete** (keine `deleted_on`-Spalte) — Delete ist physisch.
- **Keine eigene Framework-Protokollierung** in den Prozeduren (kein Execution/Component/Trace) —
  Stammdaten-CRUD auf der Log-Infrastruktur selbst; Fehler nur via `RAISE`.
- **Kein `p_actor_email`-Parameter** — Audit über `current_user` (Default + `tr_u_process`-Trigger).
- **Kein Bulk-/CSV-Import** — der Seed ist eine statische Stammdaten-Liste.
- **Keine Views** (separates Feature).

## Datenmodell-Auswirkung
- `log.process`: neuer Constraint **`uq_process_name UNIQUE (name)`**. Sonst keine Struktur­änderung
  (Spalten/PK/FK bleiben).
- Audit unverändert: `created_on`/`created_by` mit Default (`now()` / `current_user`),
  `modified_on`/`modified_by` per `tr_u_process`-Trigger.

## Protokollierungs-Integration
Bewusst **schlank**: Die Prozeduren schreiben **keine** Execution/Component/Trace-Einträge
(Vermeidung zirkulären Loggings auf der Log-Infrastruktur). Fehler werden über
`RAISE EXCEPTION` mit `format()`-Meldung (separate Variablen, sql.md-Pattern) gemeldet; der
`EXCEPTION`-Pfad gibt eine deterministische, verständliche Meldung zurück.

## Akzeptanzkriterien
1. `log.process` besitzt den Constraint `uq_process_name UNIQUE (name)`.
2. `sp_ins_process` legt mit gültigem Namen einen neuen Prozess an, setzt `created_on`/`created_by`
   per Default und gibt die neue `id` zurück.
3. `sp_ins_process` lehnt einen bereits existierenden Namen mit einer **verständlichen** Meldung ab
   (kein roher Constraint-Fehler an den Client).
4. `sp_ins_process` lehnt `NULL` oder einen (nach `trim`) leeren Namen mit Meldung ab.
5. `sp_upd_process` ändert den Namen eines existierenden Prozesses; `modified_on`/`modified_by`
   werden durch `tr_u_process` automatisch gesetzt.
6. `sp_upd_process` lehnt ab, wenn die `id` nicht existiert.
7. `sp_upd_process` lehnt ab, wenn der neue Name bereits von einem **anderen** Prozess verwendet
   wird; der Update auf den **gleichen** (unveränderten) Namen ist erlaubt (No-op, kein Fehler).
8. `sp_del_process` löscht einen Prozess, der von **keiner** Execution referenziert wird.
9. `sp_del_process` weist das Löschen mit verständlicher Meldung (inkl. Anzahl referenzierender
   Executions) ab, wenn der Prozess referenziert wird; der Datensatz bleibt erhalten.
10. `sp_del_process` lehnt ab, wenn die `id` nicht existiert.
11. `db/schemas/log/data/001.process.sql` fügt die definierten Prozess-Stammdaten ein und ist
    **idempotent** (mehrfacher Lauf erzeugt keine Duplikate, keinen Fehler).
12. Das Testskript unter `db/tests/` deckt AK 2–11 ab und läuft gegen eine frisch deployte DB grün.

## Edge Cases
- Doppelter Name bei Insert **und** bei Update (Kollision mit anderem Prozess).
- `NULL` / leerer / nur-Whitespace-Name.
- Update auf den **identischen** Namen (muss erlaubt sein, kein Selbst-Kollisions-Fehler).
- Delete eines von Executions **referenzierten** Prozesses.
- Update/Delete mit **nicht existierender** `id`.
- Name länger als 100 Zeichen (übersteigt `varchar(100)`).
- Nebenläufige Inserts desselben Namens — der `UNIQUE`-Constraint schützt; der zweite Aufruf
  erhält den definierten Fehler.

## Abhängigkeiten
- Requires: Tabelle `log.process` + Trigger `tr_u_process` (vorhanden).
- Requires: Tabelle `log.execution` (für den Referenz-Check in `sp_del_process` und den Test).
