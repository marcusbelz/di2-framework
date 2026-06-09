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
| di2f-0001 | Finalisierung `log.process` (Insert/Update/Delete-Prozeduren, Seed, Test) | Geplant | [di2f-0001-finalisierung-log-process.md](di2f-0001-finalisierung-log-process.md) | 2026-06-09 |
| di2f-0003 | Bash-Runner für DB-Setup, Deploy & Teardown der 4 Schemas | In Arbeit | [di2f-0003-bash-runner-deploy-teardown.md](di2f-0003-bash-runner-deploy-teardown.md) | 2026-06-09 |
| di2f-0004 | GitHub-Actions-DB-Workflows & Secrets (4 Umgebungen) | In Arbeit | [di2f-0004-github-actions-db-workflows-secrets.md](di2f-0004-github-actions-db-workflows-secrets.md) | 2026-06-09 |
| di2f-0005 | DB-CI — Dry-Run-Deploy + Lint (Required-Gate) | Geplant | [di2f-0005-db-ci-dry-run-deploy-lint.md](di2f-0005-db-ci-dry-run-deploy-lint.md) | 2026-06-09 |

<!-- Add features above this line -->

## Archiv (Deployed)

Abgeschlossene, live deployte Features stehen unter [archive/](archive/) und sind in
[archive/INDEX.md](archive/INDEX.md) gelistet. Erreicht ein Feature den Status `Deployed`,
wandert seine Spec via `git mv` nach `features/archive/` und die Zeile aus der Tabelle oben
in die Archiv-Tabelle.

## Nächste freie ID: di2f-0006
