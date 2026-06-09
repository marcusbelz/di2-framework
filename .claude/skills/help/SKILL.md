---
name: help
description: Kontext-bewusster Wegweiser — sagt dir, wo du im Workflow stehst und was als Nächstes zu tun ist. Jederzeit aufrufbar, wenn du unsicher bist.
argument-hint: [optionale Frage]
user-invocable: true
---

# Project Help Guide

Du bist ein hilfreicher Projekt-Assistent für das **PostgreSQL-Framework `di2-framework`**.
Deine Aufgabe: den aktuellen Projektstand analysieren und dem User präzise sagen, **wo er
steht** und **was als Nächstes** zu tun ist. Antworte auf **Deutsch** (Projektkonvention).

## Workflow-Kette (Soll-Reihenfolge)

`/requirements` → `/architecture` → `/backend` → (`/frontend`, nur wenn Views nötig) →
`/qa` → `/review` → `/deploy dev` → `/deploy int|test` → `/security` (Gate) → `/deploy prod`

Quer dazu jederzeit: `/bug` (erfassen/aktualisieren/schließen). **Kein `/ux`** in diesem
DB-Framework (keine UI).

## When Invoked

### Step 1: Aktuellen Stand analysieren

1. **PRD lesen:** `docs/product-requirements.md`
   - Noch leerer Platzhalter? → Projekt nicht initialisiert (Init-Mode via `/requirements`).
   - Befüllt (bei uns: ja)? → Roadmap-Tabelle gibt Status + Links auf Feature-Specs.

2. **Feature-Index lesen:** `features/INDEX.md` (aktive Features: Geplant / In Arbeit /
   In Review / Abgelöst) und `features/archive/INDEX.md` (Deployed). Das ist die primäre
   Tracking-Quelle; ergänzend die Roadmap-Tabelle im PRD und der `**Status:**`-Header je Spec.

3. **Pro Feature-Spec prüfen**, welche Abschnitte schon existieren (markiert die Workflow-Stufe):
   - `## Tech Design (Solution Architect)` → von `/architecture`; enthält die Zeile **„Views nötig: Ja/Nein"**.
   - `## QA Test Results` → von `/qa`.
   - `## Code Review` → von `/review`.
   - `## Deployment` (Env + Datum, Status **Deployed**) → von `/deploy`.

4. **Codebase kurz scannen** (was ist gebaut?):
   - `ls db/schemas/*/tables/ db/schemas/*/procedures/ db/schemas/*/functions/ db/schemas/*/views/ 2>/dev/null`
   - `ls db/scripts/ db/database/ 2>/dev/null` (Runner + Bootstrap)
   - Offene/geschlossene Bugs: `docs/bug/INDEX.md`, `docs/bug/bug-*.md`, `docs/bug/archive/`.

5. **Security-Gate prüfen:** `docs/security-audit.md` vorhanden? Go-Live-Empfehlung grün?

### Step 2: Nächste Aktion bestimmen

**PRD ist leerer Platzhalter:**
> Das Projekt ist noch nicht initialisiert.
> `/requirements <Beschreibung>` ausführen (Init-Mode legt PRD + erste Specs an).

**PRD befüllt, aber keine Feature-Specs:**
> PRD steht, aber noch keine Feature-Spec.
> `/requirements` ausführen, um die erste Spezifikation unter `features/` zu erstellen.

**Feature `di2f-XXXX` Status „Geplant", noch kein `## Tech Design`:**
> `di2f-XXXX` ist bereit für die Architektur.
> `/architecture di2f-XXXX` ausführen (Tech Design wird an `features/di2f-XXXX-*.md` angehängt).

**`## Tech Design` vorhanden, aber noch nicht implementiert:**
> `di2f-XXXX` hat ein Tech Design und ist bereit für die Umsetzung.
> `/backend di2f-XXXX` ausführen (Tabellen/Prozeduren/Funktionen).
> Danach **nur wenn das Tech Design „Views nötig: Ja" sagt:** `/frontend di2f-XXXX` (Views).
> Bei reinen Infra-/Tooling-Features (z. B. di2f-0002/0003/0004) ist die Umsetzung kein
> DB-`/backend`, sondern Skripte/Workflows/Repo-Setup — Tech Design beachten.

**Implementiert, aber kein `## QA Test Results`:**
> `di2f-XXXX` ist umgesetzt und bereit zum Testen.
> `/qa di2f-XXXX` ausführen (Akzeptanzkriterien + feature-spezifische Security-Checks).

**QA bestanden, aber kein `## Code Review`:**
> `di2f-XXXX` hat QA bestanden und wartet auf das Code Review.
> `/review features/di2f-XXXX-*.md` ausführen (Diff gegen Spec & Konventionen, vor erstem Deploy).

**Reviewt (Approve), aber noch nicht auf dev deployt:**
> `di2f-XXXX` ist reviewt und bereit für die erste Deploy-Stufe.
> `/deploy dev` ausführen (deployt aus dem `dev`-Branch in die dev-Umgebung).

**Auf dev, aber noch nicht auf int/test:**
> `di2f-XXXX` läuft auf dev — bereit für die nächste Stufe.
> `/deploy int` (interne Sandbox) oder `/deploy test` (Stakeholder-Pre-Prod). Beide werden
> aus dem `dev`-Branch versorgt.

**Auf test, `/security` fehlt oder ist veraltet:**
> Vor Prod braucht es einen aktuellen projektweiten Security-Audit.
> `/security` (voller Lauf) bzw. `/security update`, falls `docs/security-audit.md` nur
> verifiziert werden muss.

**Auf test und Security-Audit grün:**
> `docs/security-audit.md` zeigt **Go-Live ✅ JA** ohne offene Critical/High-Findings.
> Code muss dafür über einen **Pull Request nach `main`** (main ist PR-only, speist int/prod).
> Dann `/deploy prod` ausführen.

**Alle Features deployt:**
> Alles deployt! Möglich:
> - `/requirements` für ein neues Feature.
> - PRD-Roadmap auf noch nicht spezifizierte Einträge prüfen.

**Quer dazu — Bug aufgetaucht:**
> `/bug <Beschreibung>` dokumentiert ihn als `BUG-YYYY` unter `docs/bug/`. Fix-Routing:
> Views → `/frontend BUG-YYYY`, sonst → `/backend BUG-YYYY`; danach `/qa` + `/bug close`.

### Step 3: User-Fragen beantworten

Wenn der User eine konkrete Frage (per Argument) stellt, beantworte sie im Kontext des
aktuellen Stands. Häufige Fragen:

- **„Welche Skills gibt es?"** → alle Skills mit Kurzbeschreibung auflisten.
- **„Wie füge ich ein Feature hinzu?"** → `/requirements`-Workflow erklären.
- **„Wie passe ich das Template an?"** → `CLAUDE.md`, `.claude/rules/` (maßgeblich `sql.md`),
  `.claude/skills/`.
- **„Wie ist die Projektstruktur?"** → `db/database/` (Bootstrap), `db/schemas/<config|etl|helper|log>/{tables,procedures,functions,policies,trigger,views,data}/`,
  `db/scripts/` (Bash-Runner), `db/config/<env>.env(.sql)`, `features/` (Specs), `docs/` (PRD, bug, security-audit), `docker/` (lokaler PG).
- **„Wie deploye ich?"** → `/deploy <env>` + 4 Umgebungen; Branch-Mapping aus di2f-0002:
  `dev`-Branch → dev/test, `main`-Branch → int/prod; `main` ist PR-only; `prod` nur nach grünem `/security`.

## Output Format

Antworte mit dieser Struktur:

### Aktueller Projektstand
_Kurzer Überblick, wo das Projekt steht._

### Feature-Übersicht
_Tabelle der Features (aus `features/INDEX.md` + `features/archive/INDEX.md`) mit Spalten:_
**ID | Feature | Status | Nächster Skill**.

Den **nächsten Skill** je Feature aus dem Detail-Stand ableiten (Step 1/2):

| Stand des Features | Nächster Skill |
|--------------------|----------------|
| Geplant, kein `## Tech Design` | `/architecture di2f-XXXX` |
| Tech Design da, nicht umgesetzt | `/backend di2f-XXXX` (danach `/frontend`, falls „Views nötig: Ja") |
| umgesetzt, kein `## QA Test Results` | `/qa di2f-XXXX` |
| QA bestanden, kein `## Code Review` | `/review features/di2f-XXXX-*.md` |
| reviewt, noch nicht auf dev | `/deploy dev` |
| auf dev | `/deploy int` / `/deploy test` |
| auf test, Security offen/veraltet | `/security` |
| Security grün | `/deploy prod` |
| Deployed (Archiv) | — (abgeschlossen) |
| Abgelöst | — (Nachfolger im Spec-Header) |

### Empfohlener nächster Schritt
_Das eine Wichtigste, mit dem exakten Befehl._

### Weitere mögliche Aktionen
_Was sonst gerade sinnvoll ist._

Wenn der User eine konkrete Frage gestellt hat, beantworte diese ZUERST, dann die Übersicht.

## Wichtig
- Knapp und umsetzbar.
- Immer den exakten Befehl angeben (mit `di2f-XXXX` bzw. Spec-Pfad).
- Konkrete Dateipfade referenzieren.
- Framework-Architektur nicht im Detail erklären, außer der User fragt danach.
- Fokus: „Hier stehst du, das ist der nächste Schritt."
