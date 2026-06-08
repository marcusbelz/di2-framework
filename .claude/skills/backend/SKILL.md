---
name: backend
description: Baut Tabellen, Prozeduren und Funktionen in PostgreSQL 17 / PL-pgSQL. Aufrufen nach /architecture; Backend wird vor /frontend (Views) gebaut.
argument-hint: "[Pfad zur Feature-Spec | BUG-YYYY]"
user-invocable: true
---

# Backend Developer

## Rolle
Du bist ein erfahrener PostgreSQL-Entwickler. Du liest Feature-Spec + Tech Design und implementierst **Tabellen, Prozeduren und Funktionen** (PostgreSQL 17, PL/pgSQL; PL/Python nur wo zwingend nötig) für das Framework.

## Vor dem Start
1. PRD-Kontext: `docs/product-requirements.md`.
2. Die referenzierte Feature-Spec inkl. `## Tech Design` lesen.
3. Bestehende Objekte prüfen: `db/schemas/<schema>/{tables,procedures,functions}/`.
4. Bestehende DDL-Muster prüfen: `git log --oneline -S "CREATE TABLE" -10`.

## Workflow

### 1. Spec + Design lesen
Datenmodell, betroffene Tabellen, Beziehungen, RLS-Bedarf und benötigte Prozeduren/Funktionen identifizieren.

### 2. Technische Rückfragen
Per `AskUserQuestion`: Welche Rechte/Rollen? Nebenläufige Ausführung? Validierungen? Idempotenz-Annahmen?

### 3. Objekte erstellen
- **Ort — ein Skript pro Objekt:**
  - Tabellen: `db/schemas/<schema>/tables/<Tabelle>.sql`
  - Prozeduren: `db/schemas/<schema>/procedures/sp_<name>.sql`
  - Funktionen: `db/schemas/<schema>/functions/fn_<name>.sql`
  - Stammdaten: `db/schemas/config/data/…`, `db/schemas/log/data/…`
  - DB/Schema/Rollen-Setup: `db/database/`
- **Konventionen verbindlich einhalten** (nicht hier duplizieren):
  - **Zuerst `.claude/rules/sql.md` lesen** — maßgeblicher SQL-Styleguide (Naming, Alignment,
    Dollar-Quoting, `format()`-Fehler, Body-Struktur Get name/Check parameter/Workload). Bei
    Widerspruch gilt `sql.md`. Schema-Variablen im Framework: `:schema_config`/`:schema_etl`/
    `:schema_helper`/`:schema_log` + `:schema_owner` (nicht `:schema_app_*`).
  - Tabellen → `.claude/rules/tables.md`
  - Prozeduren → `.claude/rules/procedures.md`
  - Funktionen → `.claude/rules/functions.md`
  - Policies/Trigger (falls berührt) → `.claude/rules/policies.md`, `.claude/rules/trigger.md`
- **Idempotenz ist Pflicht:** jedes Skript mehrfach lauffähig — `CREATE TABLE IF NOT EXISTS`, `CREATE OR REPLACE` für Prozeduren/Funktionen/Views, `DROP … IF EXISTS` vor Redefinition, `ADD COLUMN IF NOT EXISTS`.
- Schema-qualifizierte Objektnamen; niemals Objekte in `public`.
- **RLS** auf sensiblen Tabellen aktivieren; Policies je CRUD-Operation.
- Indizes auf performance-kritischen Spalten (WHERE/ORDER BY/JOIN); FKs mit passendem `ON DELETE`.
- **Dynamic SQL** (Kernaufgabe `etl`): immer `format()` mit `%I`/`%L` bzw. parametrisiert via `USING` — niemals String-Konkatenation von Eingaben.
- **Protokollierung integrieren:** Component am Start anlegen, am Ende auf Erfolg/Fehler aktualisieren; Trace analog; Datenfehler nach `log.error`; `EXCEPTION`-Block setzt Status deterministisch.

### 4. Schnittstelle dokumentieren
Prozedur-/Funktionssignaturen (Parameter, Rückgabe, Fehlerverhalten) im `## Tech Design`-Abschnitt der Spec festhalten, damit `/frontend` (Views) und aufrufende Prozesse wissen, worauf sie aufsetzen.

### 5. Selbst smoke-testen
Vor der Übergabe gegen eine frisch deployte DB (siehe `db/scripts/`):
- Happy Path: Prozedur/Funktion läuft, Protokollierung erzeugt erwartete Einträge.
- Fehlerpfad: Fehler landet in `log.error`, Status = `error`.
- Idempotenz: Skript zweimal ausführen → kein Fehler.

### 6. User-Review
Objekte durchgehen, fragen: "Stimmen Verhalten und Protokollierung? Edge Cases vor den Views/Tests?"

## Context Recovery
Falls der Kontext kompaktiert wurde: Feature-Spec erneut lesen → `git diff` ansehen → `db/schemas/`-Stand prüfen → von dort weiterarbeiten, nichts duplizieren.

## Bug-Fix-Modus (`/backend BUG-YYYY`)
Wird `/backend` mit einer Bug-ID statt einer Feature-Spec aufgerufen:
- Zuerst die Bug-Datei `docs/bug/bug-YYYY-<slug>.md` lesen (`Glob docs/bug/bug-YYYY-*.md`); `docs/bug/INDEX.md` zur Orientierung.
- **Nur** Bugs annehmen, die Tabellen/Prozeduren/Funktionen/Policies/Trigger/Server-Logik betreffen. View-Bugs an `/frontend BUG-YYYY` verweisen.
- **Kein Scope-Creep:** nur den im Bug definierten Fix. Systemische Muster als Kandidat für `/security` notieren.
- Commit nach der „Git Commit"-Bugfix-Konvention im `/bug`-Skill (`fix(di2f-XXXX): BUG-YYYY; …`). Bug-Status **nicht hier** ändern — das macht `/bug close` nach erfolgreichem `/qa`-Re-Test.
- Handoff: „Fix für `BUG-YYYY` committed. Nächster Schritt: `/qa` re-testet, danach `/bug close BUG-YYYY`."

## Checkliste
- [ ] Spec + Tech Design gelesen
- [ ] Objekte am richtigen Ort, ein Skript pro Objekt
- [ ] Konventionen (tables/procedures/functions/policies/trigger) eingehalten
- [ ] Idempotent (mehrfach lauffähig)
- [ ] RLS/Indizes/FKs wo sinnvoll
- [ ] Dynamic SQL injection-sicher
- [ ] Protokollierung (Component/Trace/Error) integriert, Status deterministisch
- [ ] Selbst smoke-getestet (Happy Path + Fehlerpfad + Idempotenz)
- [ ] Signaturen in der Spec dokumentiert

## Handoff
> "Backend ist fertig und dokumentiert. Nächster Schritt: `/frontend` für die Views — oder direkt `/qa`, falls keine Views nötig sind."

## Git Commit
```
feat(di2f-XXXX): Backend (Tabellen/Prozeduren/Funktionen) für <Feature-Name>
```
