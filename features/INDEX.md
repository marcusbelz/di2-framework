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
| di2f-0006 | DB-Versionierung (`config.db_version` Historie) | In Review | [di2f-0006-config-db-version.md](di2f-0006-config-db-version.md) | 2026-06-12 |
| di2f-0007 | Deploy schreibt db_version-Zeile (deploy.sh + Workflows verdrahten) | In Review | [di2f-0007-deploy-db-version-verdrahtung.md](di2f-0007-deploy-db-version-verdrahtung.md) | 2026-06-12 |
| di2f-0008 | helper-String-/Prädikat-Funktionen (starts_with, ends_with, is_null_or_empty, split) | In Review | [di2f-0008-helper-string-funktionen.md](di2f-0008-helper-string-funktionen.md) | 2026-06-12 |
| di2f-0009 | helper-Konvertierungs-Funktionen (convert_bit, convert_date/datetime/datetime2) | Geplant | [di2f-0009-helper-konvertierungs-funktionen.md](di2f-0009-helper-konvertierungs-funktionen.md) | 2026-06-12 |

<!-- Add features above this line -->

## Archiv (Deployed)

Abgeschlossene, live deployte Features stehen unter [archive/](archive/) und sind in
[archive/INDEX.md](archive/INDEX.md) gelistet. Erreicht ein Feature den Status `Deployed`,
wandert seine Spec via `git mv` nach `features/archive/` und die Zeile aus der Tabelle oben
in die Archiv-Tabelle.

## Nächste freie ID: di2f-0010
