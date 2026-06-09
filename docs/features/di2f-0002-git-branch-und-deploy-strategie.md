# di2f-0002: Git-Branch- & Deployment-Strategie (dev/int/test/prod)

- **Priorität:** P1
- **Status:** Geplant
- **Schema(s):** — (Infrastruktur / CI-CD / Repo-Governance; kein DB-Schema betroffen)

## Problem / Motivation
Das Repository hat aktuell nur den Branch `main` (lokal + `origin/main`) und keine GitHub-Actions-Workflows. Die Roadmap nennt „GitHub-Actions-Deployment (dev/int/test/prod)" als P1, aber es fehlt eine verbindliche Festlegung, **aus welchem Branch welche Umgebung versorgt wird** und **wie der `main`-Branch (Quelle der produktiven Umgebung) gegen unkontrollierte Änderungen geschützt ist**.

Ziel: eine nachvollziehbare, reproduzierbare Branch→Umgebung-Zuordnung mit klarem Schutz des produktionsnahen Branches, damit Code nur kontrolliert (über Pull Request) in den `main`-Branch und damit nach int/prod gelangt.

## User Stories
- Als **Entwickler** möchte ich den aktuellen Stand in einem `dev`-Branch halten, damit ich auf `dev` schnell iterieren kann, ohne `main` zu berühren.
- Als **Release-Verantwortlicher** möchte ich, dass Code ausschließlich über einen Pull Request in `main` gelangt, damit jede produktionsrelevante Änderung reviewbar und nachvollziehbar ist.
- Als **Deployer** möchte ich eine Umgebung (dev/int/test/prod) gezielt und manuell deployen, damit ich den Zeitpunkt kontrolliere und Promotion bewusst auslöse.
- Als **Deployer** möchte ich, dass dev/test nur aus `dev` und int/prod nur aus `main` deploybar sind, damit keine Umgebung versehentlich aus dem falschen Branch versorgt wird.
- Als **Team** möchten wir verhindern, dass jemand direkt auf `main` pusht, damit der produktive Stand stabil und geschützt bleibt.

## Scope
Betroffene Artefakte (keine DB-Objekte):

- **Branch `dev`** — neu, aus dem aktuellen `main`-HEAD erzeugt und nach `origin` gepusht; dauerhafter Integrations-/Arbeitsbranch.
- **Branch `main`** — bleibt produktionsnaher Branch; erhält eine Branch-Protection-Regel.
- **Branch-Protection-Regel auf `main`** — Direkt-Push gesperrt; Änderungen ausschließlich über Pull Request (Merge).
- **GitHub-Actions-Deploy-Workflow** — manuell auslösbar (`workflow_dispatch`) mit Umgebungs-Parameter (`dev`/`int`/`test`/`prod`); enthält einen **Branch-Guard**, der die zulässige Branch→Umgebung-Zuordnung erzwingt.
- **Branch→Umgebung-Zuordnung** (verbindlich dokumentiert):
  | Branch | Umgebungen      |
  |--------|-----------------|
  | `dev`  | `dev`, `test`   |
  | `main` | `int`, `prod`   |
- **GitHub Environments / Secrets-Trennung** — pro Umgebung (dev/int/test/prod) eigene Deploy-Secrets (SSH, DB-Passwörter); nutzt die bestehenden `db/config/<env>.env(.sql)`.

## Nicht-Ziele
- **Kein** automatisches Deployment bei Push/Merge — Deployment bleibt manuell (`workflow_dispatch` / `/deploy`).
- **Kein** Pflicht-Review-Approval und **keine** erzwungenen Status-Checks auf `main` in dieser Iteration (nur „PR statt Direkt-Push"). Kann später nachgezogen werden.
- **Kein** Schutz des `dev`-Branches — `dev` bleibt offen für Direkt-Push.
- **Keine** Aufnahme von `local` als deploybare GitHub-Umgebung (`local` bleibt reine Entwickler-Maschine).
- **Keine** Änderung an DB-Objekten, Schemas oder der 3-Ebenen-Protokollierung.
- **Kein** Aufbau der eigentlichen Deploy-Schritte (SSH→Hetzner, Bash-Runner-Aufruf) im Detail — das ist Teil des bestehenden Deploy-Features / `/deploy`; hier wird nur der Branch-/Umgebungs-Rahmen festgelegt.

## Datenmodell-Auswirkung
Keine. Reine Repo-/CI-Governance; keine Tabellen, Spalten oder Constraints betroffen.

## Protokollierungs-Integration
Keine (Execution/Component/Trace/Error unberührt — dieses Feature betrifft nicht den DB-Laufzeitpfad).

## Akzeptanzkriterien
1. Auf `origin` existiert ein Branch `dev`, dessen HEAD dem `main`-HEAD zum Zeitpunkt der Erstellung entspricht.
2. `main` existiert weiterhin und ist der Default-/Produktions-Branch.
3. Ein direkter `git push` auf `main` (ohne PR) wird von GitHub abgelehnt.
4. Ein Merge in `main` ist ausschließlich über einen Pull Request möglich.
5. Direkter Push auf `dev` ist weiterhin erlaubt (kein Schutz auf `dev`).
6. Es existiert ein GitHub-Actions-Deploy-Workflow, der **manuell** (über `workflow_dispatch`) mit einem Umgebungs-Parameter aus der Menge {`dev`, `int`, `test`, `prod`} gestartet werden kann.
7. Ein Deploy nach `dev` oder `test`, der von einem anderen Branch als `dev` ausgelöst wird, wird durch den Branch-Guard abgebrochen (fehlschlagender Job, kein Deployment).
8. Ein Deploy nach `int` oder `prod`, der von einem anderen Branch als `main` ausgelöst wird, wird durch den Branch-Guard abgebrochen.
9. `local` ist **nicht** als deploybare Umgebung im Workflow auswählbar.
10. Jede der vier Umgebungen verwendet ihre eigenen Deploy-Secrets/Config (`db/config/<env>.env(.sql)`); ein Deploy zieht die Config der gewählten Umgebung.

## Edge Cases
- **Direkt-Push auf `main`** → abgelehnt; Nutzer muss einen PR öffnen.
- **Deploy `prod` aus `dev`-Branch ausgelöst** → Branch-Guard bricht ab (int/prod nur aus `main`).
- **Deploy `dev` aus `main`-Branch ausgelöst** → Branch-Guard bricht ab (dev/test nur aus `dev`).
- **Hotfix für prod nötig** → muss als Branch von `main` erstellt und per PR nach `main` gemergt werden; danach Deploy `int`/`prod` aus `main` (kein Umweg über `dev`).
- **`dev`-Branch wird gelöscht/neu erstellt** → zulässig (offen), darf den `main`-Schutz und die Workflow-Guards nicht beeinflussen.
- **Force-Push auf `dev`** → erlaubt (kein Schutz); auf `main` durch PR-Pflicht faktisch ausgeschlossen.
- **Falsche/fehlende Secrets für eine Umgebung** → Deploy-Job schlägt mit klarer Meldung fehl, statt teilweise zu deployen.
- **Branch `dev` und `main` divergieren** (Feature in `dev`, Hotfix in `main`) → bewusst zulässig; Synchronisation (z. B. `main`→`dev` zurückmergen) liegt im Team-Prozess, nicht im Workflow.

## Abhängigkeiten
- Relates: Roadmap-Eintrag „GitHub-Actions-Deployment (dev/int/test/prod)" (P1) und Skill `/deploy`.
- Nutzt: bestehende Umgebungs-Configs `db/config/<env>.env` / `<env>.env.sql` und die Bash-Runner unter `db/scripts/`.
- Keine Abhängigkeit zu di2f-0001 (log.process).
