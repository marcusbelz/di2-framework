---
name: deploy
description: Deployt das DB-Framework in eine der vier Hetzner-Umgebungen (dev, int, test, prod) via GitHub Actions. Der Prod-Pfad ist strikt und verlangt ein grünes /security-Ergebnis.
argument-hint: "<dev|int|test|prod>"
user-invocable: true
---

# DevOps Engineer

## Rolle
Du deployst das PostgreSQL-Framework in ein Multi-Environment-Setup auf Hetzner (GitHub Actions → SSH → Hetzner). Deploy ist **kein** einzelner Schritt — Stände fließen durch **dev → int → test → prod**, jede Stufe mit eigener Vorbedingung.

> **Infra-Konfiguration (TODO bei Erstaufsetzung):** konkrete VPS-Adresse, Pfade pro Env, Postgres-Container/-Instanz, Datenbanknamen und GitHub-Actions-Workflow-Namen werden beim Aufsetzen der Deployment-Struktur festgelegt und hier sowie in `CLAUDE.md` ergänzt. Bis dahin Platzhalter `<…>` verwenden.

## Argument-Auswertung (Pflicht zuerst)
Erlaubt sind genau `dev`, `int`, `test`, `prod`.
- **Kein Argument:** explizit nachfragen — nicht raten:
  > "Bitte Ziel angeben: `/deploy dev`, `/deploy int`, `/deploy test` oder `/deploy prod`."
- **Ungültiges Argument:** Fehler + erlaubte Werte, abbrechen.

## Environments im Überblick
| Env | Zweck | Vorbedingung |
|-----|-------|--------------|
| dev | Integrationstest auf VPS, schnelle Loops | `/qa` durch, keine Critical/High offen |
| int | interner Demo-/Probierstand | `/review` durch |
| test | Pre-Prod, Stakeholder-Abnahme | `/review` durch |
| prod | Live | `/security` aktuell und grün (s. u.) |

## Vor jedem Deploy (alle Envs)
1. PRD/betroffene Feature-Specs lesen — passt der Status zur Ziel-Umgebung?
2. Sanity-Checks lokal:
   - [ ] Deployment-Skripte unter `db/scripts/` laufen lokal/gegen Test-DB durch (idempotent).
   - [ ] Alle Änderungen committet und gepusht.
   - [ ] Keine Secrets im Diff.
3. Erforderlichen Branch prüfen (`dev` für dev/int/test, `main` für prod) — GitHub Actions verweigert sonst.

## `/deploy dev`
**Wann:** sobald `/qa` freigegeben hat (keine Critical/High offen).
**Vorbedingungen:** QA-Sektion "passed"; Branch `dev` enthält den Commit.
**Ausführung:** GitHub → Actions → Workflow „Deploy - dev" → „Use workflow from: dev" → „Run workflow". Der Workflow spielt das Framework per `db/scripts/` in die dev-DB ein (idempotenter Re-Deploy).
**Verifikation:** Workflow grün; Schemas/Objekte vorhanden (`\dn`, `\dt log.*`); Smoke-Test (ein Prozess protokolliert korrekt in Execution/Component/Trace).
**Bookkeeping:** Deploy-Sektion in der Feature-Spec (Datum, Commit-SHA, Env=dev); `features/INDEX.md`-Status auf **In Review** setzen.
**Nächster Schritt:** `/review`, danach `/deploy int` oder `/deploy test`.

## `/deploy int`
**Wann:** nach `/review`. **Vorbedingung:** Findings adressiert/akzeptiert; Branch `dev`.
**Ausführung:** Workflow „Deploy - int" von `dev`. **Verifikation:** Workflow grün; Smoke-Test; keine Fehler im Deploy-Log.

## `/deploy test`
**Wann:** nach `/review`; Pre-Prod für Abnahme (prod-gleicher Stand gegen Test-DB).
**Ausführung:** Workflow „Deploy - test" von `dev`. **Verifikation:** Workflow grün; Acceptance-Walkthrough dokumentiert.
**Hinweis:** letzte Stufe vor prod — danach `/security` als Gate.

## `/deploy prod` (strenger Pfad)
**Wann:** **nur** nach erfolgreichem `/security`-Audit. Release-Schritt, nicht pro Feature.

### Pflicht-Gate vor Ausführung
1. **`docs/security-audit.md` lesen.** Existiert nicht → STOP:
   > "`docs/security-audit.md` existiert nicht. Vor `/deploy prod` muss `/security` einmal vollständig laufen."
2. **Datum:** Header `Zuletzt geprüft` älter als 30 Tage **oder** seitdem security-relevante Commits → STOP:
   > "Letzter Security-Audit ist veraltet ([Datum]). Bitte `/security update` oder `/security` laufen lassen."
3. **Findings:** sobald **eine** Critical/High-Finding `❌ Offen` ist → STOP:
   > "Offene Critical/High-Findings: [Titel]. Prod-Deploy blockiert. Zuerst beheben, dann `/security update`."
4. **Go-Live-Empfehlung:** Header muss `✅ JA` zeigen; sonst STOP.
5. **Branch-Check:** Stand muss auf `main` sein.
6. Erst wenn alle Gates passieren: explizit bestätigen lassen — *"Prod-Deploy starten? (yes/no)"*.

### Ausführung
GitHub → Actions → „Deploy - prod" → „Use workflow from: main" → „Run workflow".

### Verifikation
- [ ] Workflow grün
- [ ] Schemas/Objekte in prod vorhanden und aktuell
- [ ] Ende-zu-Ende-Smoke-Test eines protokollierten Prozesses
- [ ] Keine Fehler im Deploy-Log

### Bookkeeping
- Feature-Spec(s): Deployment-Sektion (Env=prod, Datum), Status **Deployed**; PRD-Roadmap aktualisieren.
- **Archivierung (`features/INDEX.md`):** Spec via `git mv features/di2f-XXXX-*.md features/archive/` verschieben; die Zeile aus „Features (aktiv)" entfernen und mit Status **Deployed** in `features/archive/INDEX.md` eintragen. Spec-Links in Specs/PRD, die auf die verschobene Datei zeigen, auf den `archive/`-Pfad anpassen.
- Git-Tag: `git tag -a v1.X.0 -m "Prod release YYYY-MM-DD"`, `git push origin v1.X.0`.
- `docs/security-audit.md` Audit-Historie: Zeile "Deploy prod YYYY-MM-DD" anhängen.

### Rollback
Letzten erfolgreichen Stand erneut deployen (alter Commit auf `main`) oder Hotfix auf `main` mergen und neu deployen. Auslöser per `/bug` unter `docs/bug/` dokumentieren.

## Common Issues
- **„Enforce workflow source branch" failed:** dev/int/test brauchen Branch `dev`, prod braucht `main`.
- **Schema fehlt nach Deploy:** prüfen, ob die `db/scripts/`-Deployment-Skripte wirklich gegen das Ziel-Env liefen (idempotenter Re-Run).
- **Env-Vars/Secrets fehlen:** pro GitHub-Environment hinterlegt? Verbindungsdaten korrekt?

## Git Commit (Deploy-Bookkeeping)
```
deploy(di2f-XXXX): <Feature> nach <env> ausgerollt

- Env: <env>
- Commit: <sha>
- Datum: YYYY-MM-DD
```
