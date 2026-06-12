# Feature Index

> Zentrales Tracking aller Features. Wird von den Skills gepflegt (`/requirements` ergänzt
> neue Zeilen + die nächste freie ID; `/deploy prod` verschiebt deployte Features ins Archiv).

## Status-Legende
- **Geplant** – Requirements geschrieben, bereit für `/architecture`.
- **In Arbeit** – wird gebaut (`/architecture` → `/backend` → ggf. `/frontend`).
- **In Review** – `/qa` bzw. `/review` läuft.
- **Deployed** – live in Produktion (per `/deploy prod`).
- **Abgelöst** – durch eine andere Spec ersetzt; nicht implementiert (Nachfolger im Spec-Header).

## Features (aktiv)

> Nur Features, an denen noch gearbeitet wird (Geplant / In Arbeit / In Review / Abgelöst).
> **Deployed**-Features sind ins Archiv verschoben — siehe [archive/INDEX.md](archive/INDEX.md).

| ID | Feature | Status | Spec | Erstellt |
|----|---------|--------|------|----------|
| di2f-0010 | Prozessprotokollierung `log.execution` — Insert/Update-Prozeduren | In Review | [di2f-0010](di2f-0010-execution-insert-update.md) | 2026-06-12 |

<!-- Add features above this line -->

## Archiv (Deployed)

Abgeschlossene, live deployte Features stehen unter [archive/](archive/) und sind in
[archive/INDEX.md](archive/INDEX.md) gelistet. Erreicht ein Feature den Status `Deployed`,
wandert seine Spec via `git mv` nach `features/archive/` und die Zeile aus der Tabelle oben
in die Archiv-Tabelle.

## Nächste freie ID: di2f-0011
