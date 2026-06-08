---
name: frontend
description: Baut die lesende Sicht-Schicht des Frameworks – Views (z. B. Monitoring-/Auswertungs-Views im Schema log). Aufrufen nach /backend, damit Views auf realen Tabellen aufsetzen.
argument-hint: "[Pfad zur Feature-Spec | BUG-YYYY]"
user-invocable: true
---

# Frontend Developer (Views)

## Rolle
In diesem DB-Framework ist „Frontend" die **lesende Sicht-Schicht**: **Views**. Du liest Feature-Spec + Tech Design und implementierst Views (Monitoring/Reporting/Auswertung) auf den bestehenden Tabellen.

## Vor dem Start
1. PRD-Kontext: `docs/product-requirements.md`.
2. Die referenzierte Feature-Spec inkl. `## Tech Design` lesen (welche Auswertung wird gebraucht?).
3. Bestehende Views/Tabellen prüfen: `db/schemas/<schema>/views/`, `db/schemas/<schema>/tables/`.

## Workflow

### 1. Spec + Design lesen
Verstehen, welche Kennzahlen/Sichten gefragt sind und auf welchen Tabellen sie aufsetzen.

### 2. Anforderungen klären (falls offen)
Per `AskUserQuestion`: Welche Spalten/Aggregationen? Pro Ebene (Execution/Component/Trace) oder übergreifend? Materialized View nötig (teure Aggregation)?

### 3. Views implementieren
- **Konventionen verbindlich**: `.claude/rules/views.md`.
- Je View ein Skript: `db/schemas/<schema>/views/v_<name>.sql` (Log-Views: `db/schemas/log/views/`).
- Präfix `v`; idempotent (`CREATE OR REPLACE VIEW`); nur lesend, keine Seiteneffekte.
- Spalten explizit benennen/aliasieren (kein `SELECT *` in dauerhaften Views); schema-qualifizierte Quellen.
- Bei teuren Aggregationen `MATERIALIZED VIEW` erwägen und Refresh-Strategie dokumentieren.
- `COMMENT ON VIEW` mit fachlicher Beschreibung.

### 4. User-Review
Views gegen eine deployte DB prüfen (plausible Ergebnisse?). Fragen: "Stimmen die Auswertungen?"

## Context Recovery
Falls der Kontext kompaktiert wurde: Spec erneut lesen → `git diff` → `db/schemas/**/views/`-Stand prüfen → weiter, nichts duplizieren.

## Bug-Fix-Modus (`/frontend BUG-YYYY`)
Wird `/frontend` mit einer Bug-ID aufgerufen:
- Zuerst die Bug-Datei `docs/bug/bug-YYYY-<slug>.md` lesen (`Glob docs/bug/bug-YYYY-*.md`); `docs/bug/INDEX.md` zur Orientierung.
- **Nur** View-/Auswertungs-Bugs annehmen. Tabellen-/Prozedur-/Funktions-/Logik-Bugs an `/backend BUG-YYYY` verweisen.
- **Kein Scope-Creep:** nur die genannten Objekte/Symptome anfassen.
- Commit nach der „Git Commit"-Bugfix-Konvention im `/bug`-Skill. Bug-Status **nicht hier** ändern — das macht `/bug close` nach erfolgreichem `/qa`-Re-Test.
- Handoff: „Fix für `BUG-YYYY` committed. Nächster Schritt: `/qa` re-testet, danach `/bug close BUG-YYYY`."

## Sanity-Check vor der Übergabe
- Keine `SELECT *`-Reste in dauerhaften Views.
- Quellen schema-qualifiziert, keine Abhängigkeit auf nicht existierende Objekte.
- Materialized Views: Refresh-Strategie dokumentiert.

## Checkliste
- [ ] Spec + Tech Design gelesen
- [ ] Views am richtigen Ort, ein Skript pro View, Präfix `v`
- [ ] `.claude/rules/views.md` eingehalten
- [ ] Idempotent, nur lesend, Spalten explizit
- [ ] `COMMENT ON VIEW` gesetzt
- [ ] Gegen deployte DB plausibilisiert

## Handoff
> "Views sind fertig. Nächster Schritt: `/qa`, um das Feature gegen seine Akzeptanzkriterien zu testen."

## Git Commit
```
feat(di2f-XXXX): Views für <Feature-Name>
```
