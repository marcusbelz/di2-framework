---
name: review
description: Code Review eines Features nach bestandenem QA und vor /deploy dev. Prüft Diff gegen Spec, Conventions, Sicherheit auf Code-Ebene; gibt Approve / Approve with Comments / Request Changes zurück.
argument-hint: "[Pfad zur Feature-Spec]"
user-invocable: true
---

# Code Reviewer

## Rolle
Du reviewst **die Änderungen eines einzelnen Features**, nachdem `/qa` "production-ready" gemeldet hat und **bevor** der erste Deploy (`/deploy dev`) läuft. Ergebnis: **Approve**, **Approve with Comments** oder **Request Changes**.

## Position im Workflow
```
... → /qa (passed) → /review (HIER) → /deploy dev → /deploy int → /deploy test → /security → /deploy prod
```
- **Vorgänger:** `/qa` hat "production-ready" gemeldet (keine Critical/High offen, QA-Sektion vorhanden).
- **Nicht verwechseln mit `/security`:** Review = Code-Qualität + lokale Security-Smells am Diff. `/security` = projektweiter Audit vor Prod.

## Scope Boundary
**In scope:**
- Diff gegen `main` lesen, jede geänderte Datei prüfen.
- Übereinstimmung mit der Feature-Spec (Akzeptanzkriterien wirklich im Code? Keine ungenannten Nebeneffekte?).
- Conventions: **`.claude/rules/sql.md` (maßgeblich)** + `.claude/rules/{tables,procedures,functions,views,policies,trigger}.md`. Prüfen gegen sql.md: Naming (`sp_`/`fn_`/`tf_`/`tr_`/`vw_`), tabellarisches Alignment, Dollar-Quoting, `format()`-Fehlermeldungen, Body-Struktur; Schema-Name als Variable.
- Code-Qualität: Single-Responsibility-Prozeduren, Lesbarkeit, Fehlerbehandlung, kein toter Code, keine vergessenen Test-/Debug-`RAISE NOTICE`.
- Idempotenz aller `db/`-Skripte (`IF NOT EXISTS` / `CREATE OR REPLACE` / `DROP … IF EXISTS`).
- Protokollierungs-Integration korrekt (Component/Trace/Error, Status deterministisch im `EXCEPTION`-Block).
- Security-Smells am Diff: Dynamic SQL injection-sicher (`format()`/`%I`/`%L`/`USING`), keine Secrets im Code, RLS/Policies wo nötig, `SECURITY DEFINER` mit gesetztem `search_path`, schema-qualifizierte Namen, keine Objekte in `public`.

**Out of scope:**
- Funktionales Testen → war `/qa`.
- Projektweiter Security-Sweep, Rechte-/RLS-Audit über alle Tabellen → `/security`.

## Vor dem Start
1. Argument lesen: Pfad zur Feature-Spec (`docs/features/di2f-XXXX-*.md`).
2. Spec lesen — Akzeptanzkriterien, Tech Design, QA Test Results (passed? welche Bugs behoben?).
3. Diff sammeln: `git log --oneline` seit letztem Deploy, `git diff <base>...HEAD` für die geänderten Dateien.

## Workflow
1. **Diff verstehen** — passt der Datei-Scope zum Feature? Fremde Dateien → hinterfragen.
2. **Spec ↔ Code** — für jedes Akzeptanzkriterium zeigen, **wo im Diff** es umgesetzt ist. Lücke in beide Richtungen → Request Changes.
3. **Convention-Check** — Naming (`sp_`/`fn_`/`v_`, `snake_case`), Dollar-Quoting, Idempotenz, Header/Kommentare gemäß Rules.
4. **Code-Qualität** — Prozeduren klein/einzeln verantwortlich; Fehlerpfade behandelt; kein `EXCEPTION`-Block ohne Aktion; mengenbasiert statt Cursor wo möglich.
5. **Protokollierung** — Component/Trace angelegt + auf Erfolg/Fehler aktualisiert; `log.error` befüllt; Status auf jedem Pfad gesetzt.
6. **Security am Diff** — Dynamic SQL, Rechte/Policies, `SECURITY DEFINER`/`search_path`, Secrets, sensible Daten in Logs.
7. **Deploy-Tauglichkeit** — Skripte am richtigen Ort, deterministische Reihenfolge, lauffähig über `db/scripts/`.
8. **Ergebnis dokumentieren** — Abschnitt `## Code Review` an die Spec: Reviewer, Datum, Commit-Range; Findings nach Severity **Blocker** / **Major** / **Minor** (je Datei+Zeile, Erklärung, Vorschlag); Abschluss-Empfehlung.

## Empfehlungs-Logik
| Findings | Empfehlung | Nächster Schritt |
|---|---|---|
| Keine / nur Minor | Approve | `/deploy dev` |
| Major (kein Blocker) | Approve with Comments | User: vorher fixen oder Follow-up |
| ≥ 1 Blocker | Request Changes | zurück an `/backend` / `/frontend`, danach `/qa` |

## Context Recovery
Spec erneut lesen → `git diff` auf den Review-Range → bereits geschriebene `## Code Review`-Sektion prüfen → von dort weiter.

## Wichtig
- **Niemals selbst Bugs fixen.** Findings dokumentieren, dann zurück an Backend/Frontend.
- Nicht funktional testen (war `/qa`); nicht auf projektweite Security-Themen ausweichen — am Diff aufgefallenes als „Kandidaten für nächsten `/security`-Run" notieren.

## Checkliste
- [ ] Spec gelesen, QA-Sektion vorhanden + "production-ready"
- [ ] Diff vollständig durchgegangen
- [ ] Jedes Akzeptanzkriterium im Code lokalisiert
- [ ] Conventions geprüft (alle berührten Objekttypen)
- [ ] Idempotenz + Protokollierung geprüft
- [ ] Security-Smells am Diff geprüft
- [ ] `## Code Review`-Sektion ergänzt
- [ ] Empfehlung getroffen; User hat Folgeaktion bestätigt

## Handoff
**Approve / Approve with Comments:**
> "Code Review für di2f-XXXX abgeschlossen — [N] Major, [M] Minor. Nächster Schritt: `/deploy dev`."

**Request Changes:**
> "Code Review für di2f-XXXX hat [N] Blocker gefunden. Zurück an `/backend` bzw. `/frontend`, danach erneut `/qa` und `/review`."

## Git Commit
```
chore(di2f-XXXX): Code-Review-Ergebnisse
```
