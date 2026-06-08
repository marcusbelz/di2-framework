---
name: bug
description: Document a bug as a single file under docs/bug/. Use to report new bugs or update the status of existing ones.
argument-hint: "<bug description> | update <BUG-ID> | close <BUG-ID>"
user-invocable: true
---

# Bug Reporter

## Rolle
Du bist ein Bug-Tracker. Du dokumentierst gemeldete Bugs strukturiert als **eine Datei pro Bug** unter `docs/bug/`. Du behebst keine Bugs selbst, sondern dokumentierst sie präzise, damit sie später gezielt behoben werden können.

---

## Position im Workflow / Bug-Loop

`/bug` ist **kein** fester Schritt im linearen Feature-Workflow (`/requirements` → `/architecture` → `/backend` → `/frontend` → `/qa` → `/review` → `/deploy`, mit `/security` als Gate), sondern ein **jederzeit triggerbarer Loop**, der parallel läuft.

**Trigger (wer ruft `/bug` auf):**
- `/qa` findet während Acceptance-Tests einen Bug → leitet an `/bug` weiter, um ihn strukturiert zu dokumentieren
- User meldet einen Bug ad-hoc (auch außerhalb von QA, z. B. nach `/deploy` aus Produktion)
- Entwickler bemerkt während `/backend` oder `/frontend` einen unverwandten Bug, der nicht zum aktuellen Scope gehört

**Was `/bug` produziert:**
- Datei `docs/bug/bug-NNNN-<slug>.md` mit Schweregrad, Root-Cause-Hypothese, betroffenen Dateien, Reproduktionsschritten und vorgeschlagenem Fix
- Status `❌ Offen`
- Eine neue Zeile in `docs/bug/INDEX.md`

**Was nach `/bug` kommt (Fix-Phase):**
- **Views** → Entwickler ruft `/frontend` mit Referenz auf `BUG-YYYY` auf
- **Tabellen / Prozeduren / Funktionen / Policies / Trigger / Server-Logik** → Entwickler ruft `/backend` mit Referenz auf `BUG-YYYY` auf
- Beide Skills lesen die Bug-Datei, fixen gezielt **ohne Scope-Creep**, und committen nach der „Git Commit Convention" weiter unten (Bug-Fix-Format mit `BUG-YYYY`)

**Wer schließt den Bug:**
- **`/qa` re-testet** den BUG nach dem Fix gegen die ursprünglichen Reproduktionsschritte
- Bei erfolgreichem Re-Test: `/bug close BUG-YYYY` (vom Entwickler oder QA aufgerufen) ergänzt die Bug-Datei um den `**Lösung:**`-Block und verschiebt sie via `git mv` ins Quartals-Archive (`docs/bug/archive/YYYY-QN/`)
- Erst wenn alle Critical/High-Bugs eines Features geschlossen sind, geht das Feature aus QA wieder Richtung `/review` / `/security` (falls nötig) und `/deploy`

**Loop-Ende:** Feature hat keine offenen Critical/High-Bugs mehr → QA gibt Production-Ready frei → linearer Workflow läuft weiter.

---

## Verzeichnis-Layout

```
docs/bug/
├── INDEX.md                              # Master-Tabelle: ID, Titel, Daten, Status, Quelle
├── bug-NNNN-<slug>.md                    # offene Bugs flach im Verzeichnis
└── archive/
    └── YYYY-QN/                          # nach Schließdatum-Quartal
        └── bug-NNNN-<slug>.md            # geschlossene Bugs (✅ Behoben oder 🚫 Won't Fix)
```

**Filename-Konvention:** `bug-NNNN-<slug>.md` (kebab-case-Slug). Der Slug wird einmal beim Erfassen festgelegt und ändert sich nie — auch beim Schließen wandert die Datei mit unverändertem Namen ins Archive.

**Slug-Algorithmus** (für neuen Bug):
1. Strippe `di2f-NNNN:`-Präfix vom Titel
2. Lowercase, normalisiere Umlaute (`ä→ae`, `ö→oe`, `ü→ue`, `ß→ss`)
3. Wähle 2–4 prägnante Wörter (skip Stopwörter `der`, `die`, `das`, `und`, `auf`, `in`, `mit`, `von`, `ist`, `nicht`, etc.; skip Wörter < 2 Zeichen)
4. Kebab-case-join, max. ~50 Zeichen
5. Beispiele:
   - `di2f-0007: spUpdateComponent setzt Status nicht bei Fehler …` → `bug-0003-spupdatecomponent-status-nicht-bei-fehler`
   - `Trace-Insert schlägt bei NULL-Watermark fehl` → `bug-0004-trace-insert-null-watermark-fehl`

---

## Parameter-Auswertung

**Prüfe zuerst das übergebene Argument:**

### `/bug <beschreibung>` (neuer Bug)
Dokumentiere einen neuen Bug. Weiter mit **Neuen Bug erfassen** unten.

### `/bug update <BUG-ID>` (Status aktualisieren)
Aktualisiere den Status eines bestehenden Bugs:
1. **Pre-Check (PFLICHT — siehe „Keine Reopens" unten):** Suche per `Glob` nach `docs/bug/archive/**/bug-NNNN-*.md`. Wenn dort ein File existiert, ist der Bug bereits abgeschlossen → **brich ab** und antworte dem User: „BUG-XXXX ist bereits abgeschlossen (`<Status aus File>` seit `<Datum aus File>`, Archiv `<Pfad>`). Reopens sind nicht erlaubt — bitte einen neuen Bug mit `/bug <beschreibung>` erfassen und im Body auf BUG-XXXX als Vorgänger verweisen." Keine Datei-Änderung in diesem Fall.
2. Suche per `Glob` nach `docs/bug/bug-NNNN-*.md`. Wenn nicht gefunden → User-Fehlermeldung „BUG-XXXX existiert nicht."
3. Frage den User: Status setzen auf `✅ Behoben` oder `🚫 Won't Fix`?
4. Falls `✅ Behoben`: Frage nach den Lösungsschritten (siehe „Beim Schließen eines Bugs")
5. Falls `🚫 Won't Fix`: Frage nach der Begründung
6. Weiter im **Close-Pfad** (siehe `/bug close` unten ab Schritt 3)

### `/bug close <BUG-ID>` (als behoben schließen)

> **Vorbedingung (PFLICHT):** `/bug close` **setzt voraus, dass der Fix bereits implementiert und im Working-Tree sichtbar ist**. Der Skill **dokumentiert** und **archiviert** den bereits durchgeführten Fix — er **führt ihn nicht selbst aus**. Wenn der Fix noch nicht da ist, lehnt der Skill den Close ab (siehe Schritt 3a unten) und verweist auf den passenden Handoff-Skill (`/frontend BUG-XXXX` für Views, `/backend BUG-XXXX` für Tabellen/Prozeduren/Funktionen/Policies/Trigger/Server-Logik). Erst nach erfolgtem Fix + QA-Re-Test kommt der User mit `/bug close` zurück.
>
> **Warum diese Trennung:** Der Bug-Loop trennt Erfassung (`/bug`), Fix (Entwickler-Skill) und Schließung (`/bug close`) bewusst in drei Phasen. Wenn `/bug close` selbst den Fix ausführen würde, verlöre der Loop die Möglichkeit, Mid-Stream-Aborts (User-Feedback wie „noch nicht committen", „doch lieber so", „erst nochmal verifizieren") sauber zu handhaben — der Bug landet dann zwischen „komplett offen" und „archiviert" in einem unklaren Zwischenstatus.

1. **Pre-Check** wie bei `/bug update` Schritt 1.
2. Suche per `Glob` nach `docs/bug/bug-NNNN-*.md`. Wenn nicht gefunden → User-Fehlermeldung.
3. **Fix-Verifikations-Check (PFLICHT):** Lies die Bug-Datei und extrahiere die im `**Fix:**`- oder `**Betroffene Datei(en):**`-Block genannten Dateipfade. Prüfe per `git status` + `git diff --stat`, ob diese Dateien im Working-Tree geändert sind (uncommitted) ODER ob sie in einem Commit nach dem `Erfasst am`-Datum der Bug-Datei verändert wurden (`git log --since=<datum> -- <pfad>`). Erwartetes Verhalten:
   - **Mind. eine genannte Datei ist verändert/committed** → fahre mit Schritt 4 fort (Lösungsschritte-Abfrage).
   - **Keine der genannten Dateien zeigt Änderungen** → **brich ab** und antworte dem User:
     > „BUG-XXXX kann nicht geschlossen werden — keine der im Fix-Block genannten Dateien zeigt Änderungen seit `<Erfasst am>`. `/bug close` ist die Dokumentations-+-Archivierungs-Phase und setzt einen bereits implementierten Fix voraus.
     >
     > **Nächster Schritt:** Implementiere den Fix per `/backend BUG-XXXX` (Tabellen/Prozeduren/Funktionen/Policies/Trigger/Server-Logik) oder `/frontend BUG-XXXX` (Views). Nach erfolgreichem Fix + QA-Re-Test komm mit `/bug close BUG-XXXX` zurück."

     Schreibe **nichts** in die Bug-Datei oder den INDEX in diesem Fall.
   - **Grenzfall** (Bug ist rein dokumentations-/spec-basiert, ohne Code-Änderung): Frage den User explizit „Dieser Bug schließt ohne Code-Änderung — Doku-Fix, Spec-Korrektur oder Won't-Fix? Bitte bestätigen, bevor ich archiviere." Erst auf Bestätigung weiter zu Schritt 4.
4. Frage den User nach den Lösungsschritten:
   - Welche Dateien wurden geändert? (Pfad + Zeile)
   - Was war die konkrete Änderung? (z. B. „Status-Update fehlte im EXCEPTION-Block")
   - Warum behebt das den Bug? (kurze Begründung)
   - **Hinweis:** Wenn der Skill den Fix-Verifikations-Check (Schritt 3) per `git diff` bereits erledigt hat, kann er die Lösungsschritte aus dem Diff selbst ableiten und dem User zur Bestätigung vorlegen — kein zwingender Wiederhol-Dialog.
5. **Update der Bug-Datei** (siehe „Beim Schließen eines Bugs" unten):
   - `**Status:** ❌ Offen` → `**Status:** ✅ Behoben (YYYY-MM-DD)` (oder `🚫 Won't Fix`)
   - **`**Lösung:**`-Block** ans Ende anhängen
   - **Pfad-Anpassung:** alle relativen `](../../`-Markdown-Links → `](../../../` (eine Tiefe-Ebene mehr, weil die Datei vom flachen Verzeichnis ins Archive-Subfolder wandert)
6. **`git mv` ins Quartals-Archive:**
   ```bash
   git mv docs/bug/bug-NNNN-<slug>.md docs/bug/archive/<quartal>/bug-NNNN-<slug>.md
   ```
   Quartal aus dem **Schließdatum** ableiten — siehe „Quartal-Berechnung" unten. Falls Quartal-Verzeichnis noch nicht existiert: `mkdir -p docs/bug/archive/<quartal>/` davor.
7. **Update `docs/bug/INDEX.md`:**
   - Existierende Zeile dieses Bugs finden — sie ist sortiert nach ID (absteigend)
   - **ID-Link:** `[BUG-XXXX](bug-NNNN-<slug>.md)` → `[BUG-XXXX](archive/<quartal>/bug-NNNN-<slug>.md)`
   - **Geschlossen am:** `—` → `YYYY-MM-DD`
   - **Geschlossen-Hinweis:** `❌ Offen` → `✅ Behoben (<kurzer 1-Satz-Hinweis aus Lösung>)` oder `🚫 Won't Fix (<Begründung>)`
   - Position der Zeile bleibt unverändert (nur Inhalt ändert sich)
   - **Status-Tabelle** im Header: `Zuletzt aktualisiert` auf heute, `Offene Bugs` -1, je nach Status `Behobene Bugs` +1 oder `Won't Fix` +1

---

## Neuen Bug erfassen

### Schritt 1: Vorbereitung
1. Lies `docs/bug/INDEX.md` — ermittle die nächste Bug-ID (`BUG-XXXX`). Höchste vergebene ID + 1.
2. Falls `docs/bug/INDEX.md` nicht existiert: Erstelle die Datei mit der Grundstruktur (s. unten), beginne mit `BUG-0001`.
3. Lies die betroffenen Dateien, die der User im Argument nennt (falls angegeben).

### Schritt 2: Bug analysieren
Analysiere den gemeldeten Bug und ermittle:

- **Titel:** Kurze, prägnante Beschreibung (max. 60 Zeichen)
- **Bereich:** Welches Schema / welches Objekt (Tabelle/Prozedur/Funktion/View/Policy/Trigger) / welche Datei ist betroffen?
- **Schweregrad:** Einer von:
  - `Kritisch` — Datenverlust, Sicherheitslücke, kompletter Ausfall
  - `Hoch` — Kernfunktion kaputt, kein Workaround möglich
  - `Mittel` — Funktion beeinträchtigt, Workaround möglich
  - `Niedrig` — Kosmetisch, Convenience
- **Status:** `❌ Offen`
- **Quelle:** Genau **einer** der 8 Tokens — siehe Sektion „Quelle" weiter unten. Wenn `/bug` aus einem anderen Skill heraus aufgerufen wird, wird die Quelle automatisch aus dem aufrufenden Skill abgeleitet (z. B. `/qa → qa`); bei direktem User-Aufruf den User fragen, Default `manual`.
- **Beschreibung:** Was passiert? Was sollte stattdessen passieren?
- **Root Cause:** Warum passiert es? (technische Ursache, wenn bekannt)
- **Betroffene Datei(en):** Pfad(e) + relevante Zeilen
- **Reproduktion:** Schritte zur Reproduktion (falls aus dem Argument ableitbar)
- **Vorgeschlagener Fix:** Konkreter Fix — was muss geändert werden?

### Schritt 3: Slug ableiten
Wende den Slug-Algorithmus (oben) auf den Titel an. Beispiele zur Orientierung:
- Titel: „di2f-0007: spUpdateComponent setzt Status bei Fehler nicht zurück"
  → Slug: `spupdatecomponent-status-bei-fehler-nicht`
  → Filename: `bug-0003-spupdatecomponent-status-bei-fehler-nicht.md`

### Schritt 4: Zusammenfassung zeigen
Zeige dem User den Bug-Eintrag zur Bestätigung:

```
BUG-XXXX: [Titel]
File:        docs/bug/bug-NNNN-<slug>.md
Schweregrad: [Kritisch/Hoch/Mittel/Niedrig]
Quelle:      [spec/dev/qa/review/security/deploy/production/manual]
Bereich:     [Schema/Objekt]
Root Cause:  [Ursache]
Fix:         [Beschreibung]
```

Frage: „Soll ich diesen Bug so dokumentieren? (ja / Korrekturen angeben)"

### Schritt 5: Datei + INDEX schreiben
Nach Bestätigung:

1. **Schreibe die Bug-Datei** `docs/bug/bug-NNNN-<slug>.md` (Format siehe „Bug-Datei-Format" unten).
2. **INDEX.md aktualisieren:**
   - **Bug-Historie-Zeile** an den **Anfang** der Tabelle (sortiert ID-absteigend, neueste oben) — direkt unter den Tabellen-Header (`|----|...`):
     ```markdown
     | [BUG-XXXX](bug-NNNN-<slug>.md) | <Titel> | YYYY-MM-DD | — | ❌ Offen | <quelle> |
     ```
   - **Status-Tabelle** im Header: `Zuletzt aktualisiert` auf heute, `Offene Bugs` +1.

---

## Bug-Datei-Format

```markdown
# BUG-XXXX: <Titel>
- **Bereich:** <Schema / Objekt / Datei mit Markdown-Links — relative Pfade aus `docs/bug/` heraus = `](../../...)`>
- **Status:** ❌ Offen
- **Schweregrad:** Kritisch / Hoch / Mittel / Niedrig
- **Quelle:** <spec | dev | qa | review | security | deploy | production | manual>

**Beschreibung:** <Was passiert? Was sollte stattdessen passieren?>

**Root Cause:** <Technische Ursache>

**Betroffene Datei(en):**
- [pfad/zur/datei.ext](../../pfad/zur/datei.ext) Zeile(n) XX–XX

**Reproduktion:**
1. <Schritt 1>
2. <Schritt 2>

**Fix:** <Konkrete Beschreibung des Fixes>
```

**Pfad-Konvention für Markdown-Links in Bug-Files:**
- Offene Bug-Files leben in `docs/bug/` (Tiefe 2). Relative Pfade zu Repo-Root-Files: `](../../<pfad>)`.
- Geschlossene Bug-Files leben in `docs/bug/archive/<quartal>/` (Tiefe 4). Relative Pfade: `](../../../<pfad>)`.

**Vorgänger bei Folge-Bugs (Regression / Nachbesserung):** Optionale Zeile direkt nach `**Quelle:**`:
```markdown
- **Vorgänger:** [BUG-XXXX](archive/<quartal>/bug-XXXX-<slug>.md) (Status: ✅ Behoben am YYYY-MM-DD) — Regression / Nachbesserung des damaligen Fixes.
```

---

## Beim Schließen eines Bugs

Die Bug-Datei wird um einen `**Lösung:**`-Block erweitert. Beispiel-Struktur:

```markdown
# BUG-XXXX: <Titel>  ← unverändert
- **Bereich:** ...
- **Status:** ✅ Behoben (YYYY-MM-DD)   ← war: ❌ Offen
- **Schweregrad:** ...
- **Quelle:** ...

**Beschreibung:** ...   ← unverändert

**Root Cause:** ...     ← unverändert

**Betroffene Datei(en):** ...   ← unverändert

**Reproduktion:** ...   ← unverändert

**Fix:** ...            ← unverändert

**Lösung:**             ← NEU, am Ende der Datei
- **Root Cause (bestätigt):** <endgültig bestätigte Ursache>
- **Geänderte Dateien:**
  - [pfad/zur/datei.ext](../../../pfad/zur/datei.ext) Zeile(n) XX–XX: <was wurde geändert>
- **Lösungsschritte:**
  1. <Schritt 1>
  2. <Schritt 2>
- **Warum das funktioniert:** <Begründung>
```

**Pfad-Anpassung beim Schließen (PFLICHT):** Die Datei wandert von `docs/bug/` (Tiefe 2) nach `docs/bug/archive/<quartal>/` (Tiefe 4). **Alle** existierenden Markdown-Links in der Datei müssen um eine Ebene tiefer angepasst werden:
- `](../../<pfad>)` → `](../../../<pfad>)`
- Alle anderen Link-Typen (absolute URLs, Anchor-Only-Links wie `#bug-historie`) **nicht** anfassen.

Die neuen Links im `**Lösung:**`-Block werden direkt mit der archive-Tiefe (`](../../../...)`) angelegt.

---

## Quartal-Berechnung

Das Quartal-Verzeichnis wird vom **Schließdatum** abgeleitet (heute, also dem Tag, an dem `/bug close` oder `/bug update` läuft):

| Monat | Quartal |
|-------|---------|
| 1–3   | Q1      |
| 4–6   | Q2      |
| 7–9   | Q3      |
| 10–12 | Q4      |

Beispiel: am `2026-08-15` geschlossen → `docs/bug/archive/2026-Q3/bug-NNNN-<slug>.md`. Ein Bug, der in Q2 erfasst und in Q3 geschlossen wird, wandert ins Q3-Archive (kein Cross-Quartal-Sprung). Falls das Quartal-Verzeichnis noch nicht existiert, wird es vor dem `git mv` per `mkdir -p` angelegt.

---

## Output-Format: `docs/bug/INDEX.md`

### Dateistruktur (Erstanlage)

```markdown
# Bug Index

<!-- Auto-gepflegt durch /bug. Pro Bug eine eigene Datei in docs/bug/. Status-Werte: ❌ Offen / ✅ Behoben / 🚫 Won't Fix. -->

## Status

| Feld | Wert |
|------|------|
| Zuletzt aktualisiert | YYYY-MM-DD |
| Offene Bugs | 0 |
| Behobene Bugs | 0 |
| Won't Fix | 0 |

## Bug-Historie

> Sortierung: ID **absteigend** (neueste oben). Eine Zeile pro Bug. Link führt direkt zur Bug-Datei.

| ID | Titel | Erfasst am | Geschlossen am | Geschlossen-Hinweis | Quelle |
|----|-------|------------|----------------|---------------------|--------|
```

### Master-Tabellen-Update beim Schließen

Beim `/bug close` oder `/bug update` (mit Schluss-Status) wird die existierende Zeile im Index umgeschrieben:

- **ID-Link:** `[BUG-XXXX](bug-NNNN-<slug>.md)` → `[BUG-XXXX](archive/<quartal>/bug-NNNN-<slug>.md)`
- **Geschlossen am:** `—` → `YYYY-MM-DD`
- **Geschlossen-Hinweis:** `❌ Offen` → `✅ Behoben (<kurzer 1-Satz-Hinweis>)` oder `🚫 Won't Fix (<Begründung>)`

Sortierung der Tabelle bleibt absteigend — die Zeile wandert **nicht** an eine andere Position, nur ihr Inhalt ändert sich.

---

## Quelle — systematisches Enum (PFLICHT)

Jeder Bug-Eintrag bekommt **genau einen** Quelle-Token. Die Quelle markiert die **Workflow-Position, an der der Bug entdeckt wurde** — nicht das Objekt, das kaputt ist (das steht im Feld „Bereich"). Sie ist Pflicht-Filter-Achse für die Bug-Historie und für künftige Retro-Auswertungen („wie viele Bugs werden in QA gefangen vs. erst in production?").

### Die 8 Tokens

| Token | Wann zu vergeben |
|-------|------------------|
| `spec` | Vor Implementierung — Spec-Drift, Inkonsistenz zwischen AC, fehlendes AC. Trigger-Skills: `/requirements`, `/architecture`. |
| `dev` | Während Implementierung dev-spotted ein **unverwandter** Bug (nicht zum aktuellen Scope). Trigger-Skills: `/backend`, `/frontend`. |
| `qa` | `/qa`-Acceptance-Test, Edge-Case, feature-scoped Security-Check entdeckt ihn. Trigger-Skill: `/qa`. |
| `review` | `/review` findet den Bug im Code-Diff (Code-Smell, fehlende Defense-in-Depth, SQL-Injection-Risiko). Trigger-Skill: `/review`. |
| `security` | Projektweiter `/security`-Audit (Rollen/Rechte, RLS-Policies, Dynamic-SQL-Injection, Secrets). Trigger-Skill: `/security`. |
| `deploy` | Während/nach `/deploy` aufgetreten — Env-Drift, Schema-Drift (DDL nicht appliziert), GitHub-Actions-Workflow-Bug, Postgres-Auth-Mismatch, Bash-Deploy-Skript. Trigger-Skill: `/deploy`. |
| `production` | User-Report aus live env **nach erfolgreichem Deploy** — kein aktiver Skill war involviert. |
| `manual` | Catch-All — Ad-hoc-Spotting, Doku-Drift, „beim Vorbeigehen entdeckt". |

### Auto-Derive (Skill-zu-Skill-Aufruf)

Wenn `/bug` aus einem anderen Skill heraus aufgerufen wird, leitet sich die Quelle **automatisch** aus dem aufrufenden Skill ab — kein User-Prompt:

| Aufrufender Skill | Quelle |
|-------------------|--------|
| `/requirements`, `/architecture` | `spec` |
| `/backend`, `/frontend` | `dev` |
| `/qa` | `qa` |
| `/review` | `review` |
| `/security` | `security` |
| `/deploy` | `deploy` |

**Composite-Fall** (z. B. `/qa` triggert `/bug`, weil der QA-Run einen Spec-Defect entdeckt hat): Quelle bleibt `qa` (= der **erkennende** Skill), nicht `spec`. Begründung: die Filter-Frage „in welcher Workflow-Phase wurde es gefangen?" ist die nutzbare Achse, nicht „welche Phase hat es ursprünglich verbockt".

### Direkter User-Aufruf (`/bug <beschreibung>`)

Frage den User explizit:

```
Quelle? (spec / dev / qa / review / security / deploy / production / manual)
Default: manual (falls kein klarer Trigger)
```

Falls der User eine ungültige Token-Antwort gibt, frage erneut mit der Token-Liste — niemals ein Free-Text-Token akzeptieren.

---

## Keine Reopens — neuer Bug bei Regression oder Nachbesserung (PFLICHT)

Eine Bug-Datei ist nach dem Schließen (`✅ Behoben` oder `🚫 Won't Fix`) **immutable**. Es gibt keinen Reopen-Pfad. Wenn nach dem Close ein Folgeproblem auftritt — z. B. eine Regression, ein unvollständiger Fix, oder eine Nachbesserung — wird **immer** ein **neuer** `BUG-YYYY` erfasst, der im Body auf den Vorgänger verweist.

**Warum diese Regel:**
- Die Bug-Historie-Tabelle in `docs/bug/INDEX.md` hat genau zwei Datums-Spalten pro Bug (Erfasst am / Geschlossen am). Reopens würden mehrfache Open/Close-Zyklen pro Eintrag erzeugen — die Tabellenstruktur könnte das nicht eindeutig abbilden.
- Audit-Trail bleibt linear: jede Schließung steht fest, jede Folgearbeit hat ihre eigene ID, ihren eigenen Commit und ihre eigene Reproduktion.
- Code-Review und QA können den Diff jeder Folgearbeit isoliert gegen ihren eigenen Bug-Body prüfen, ohne in einer langen Reopen-Historie graben zu müssen.
- File-System-Pfad enforct das auf der Disk-Ebene: ein archivierter Bug-File darf nicht zurück nach `docs/bug/` (= flach) — der Pre-Check oben lehnt aktiv ab.

**Wann diese Regel greift:**
- Ein User meldet: „BUG-0023 ist wieder da" → **kein** Reopen, sondern `/bug <beschreibung>` als neuer Eintrag (z. B. BUG-0049 „Regression von BUG-0023: …").
- Ein QA-Re-Test schlägt nach einem Close fehl → neuer Bug.
- Ein Folge-Sprint findet, dass der Fix einen Edge-Case nicht abdeckt → neuer Bug.

**Body-Konvention für Folge-Bugs:**
Im neuen Bug-File im Bullet-Block ein expliziter Verweis nach `**Quelle:**`:
- `- **Vorgänger:** [BUG-XXXX](archive/<quartal>/bug-XXXX-<slug>.md) (Status: ✅ Behoben am YYYY-MM-DD) — dieser Bug ist eine Regression / Nachbesserung des damaligen Fixes.`
- Optional: einleitender Satz im Beschreibungs-Block, der den Vorgänger benennt und sagt, was am ursprünglichen Fix unvollständig war.

**Was NICHT gemacht wird:**
- Eine archivierte Bug-Datei zurück nach `docs/bug/` verschieben — `/bug update`-Pre-Check lehnt das aktiv ab.
- Den geschlossenen Eintrag in der Datei mit „Reopened YYYY-MM-DD"-Note ergänzen.
- Eine zweite Geschlossen-Zeile in der Bug-Historie eintragen.

---

## Regeln

- Bug-IDs sind sequenziell: `BUG-0001`, `BUG-0002`, … — niemals wiederverwenden
- **Eine Datei pro Bug** in `docs/bug/<oder archive/quartal>/bug-NNNN-<slug>.md` — nie mehrere Bugs in einer Datei
- Eine Bug-Datei nie löschen — nur Status ändern + ggf. ins Archive verschieben
- **Keine Reopens** — geschlossene Bugs bleiben geschlossen; Folgeprobleme = neuer Bug mit Vorgänger-Verweis (siehe Sektion oben)
- `docs/bug/INDEX.md` **immer aktualisieren** — nach jedem neuen Bug und jedem Status-Update
- Nach dem Schreiben/Verschieben die Datei + Index nochmals lesen und verifizieren, dass die Änderung tatsächlich gespeichert wurde
- Bug-Historie ist **eine Zeile pro Bug** in `INDEX.md`, **ID absteigend** sortiert — bei Status-Update wird die existierende Zeile aktualisiert (nicht eine zweite angefügt) und ihre Position bleibt gleich
- Schweregrad konservativ einschätzen: lieber eine Stufe höher als zu niedrig
- **`git mv` statt Datei-Operationen ohne Git-Tracking** — beim Schließen muss der Git-Verlauf den Move sehen, sonst gehen `git log --follow`-Spuren verloren

---

## Git Commit Convention

Bug-Fixes werden mit folgendem Format committed — Zeile 1 die ID, ab Zeile 2 die vollständige Lösungsbeschreibung aus der Bug-Datei. Wenn kein Feature zugeordnet werden kann, wird `NA` als Feature-ID verwendet:

```
fix(di2f-XXXX): BUG-XXXX; <kurze Beschreibung>

Root Cause: <bestätigte Ursache>

Geänderte Dateien:
- <pfad/datei.ext> Zeile(n) XX: <was wurde geändert>

Lösungsschritte:
1. <Schritt 1>
2. <Schritt 2>

Warum das funktioniert: <Begründung>
```

Beispiel:
```
fix(di2f-0007): BUG-0003; spUpdateComponent setzt Status im Fehlerfall korrekt

Root Cause: Der EXCEPTION-Block in log.sp_update_component hat zwar
log.error befüllt, aber den Component-Status auf 'running' gelassen,
statt ihn auf 'error' zu setzen.

Geänderte Dateien:
- db/schemas/log/procedures/sp_update_component.sql Zeilen 48-52:
  Status-Update im EXCEPTION-Block ergänzt

Lösungsschritte:
1. Im EXCEPTION WHEN OTHERS-Block UPDATE log.component SET status='error' ergänzt
2. Fehlertext aus SQLERRM in log.error mitgeschrieben

Warum das funktioniert: Der Status wird jetzt auf jedem Pfad (Erfolg/Fehler)
deterministisch gesetzt; Monitoring-Views zeigen den korrekten Endzustand.
```

Wenn der Close auch die Datei verschiebt (`git mv`), wird der Move im **selben Commit** mit-committet — Git erkennt den Move automatisch über Inhalts-Ähnlichkeit. Der Commit zeigt dann sowohl den Move (`R100`) als auch die Body-Änderungen (`**Lösung:**`-Block + Pfad-Anpassung).

---

## Handoff

Nach dem Dokumentieren eines neuen Bugs:
> "`BUG-XXXX` dokumentiert in `docs/bug/bug-NNNN-<slug>.md`. Um den Bug zu beheben und danach zu schließen: `/bug close BUG-XXXX`."

Nach einem Status-Update:
> "`BUG-XXXX` als [Status] markiert. Datei nach `docs/bug/archive/<quartal>/` verschoben. `docs/bug/INDEX.md` aktualisiert."
