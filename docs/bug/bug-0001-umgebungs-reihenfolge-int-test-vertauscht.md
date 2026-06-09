# BUG-0001: Branch→Umgebung-Zuordnung: int und test vertauscht
- **Bereich:** CI/CD-Governance — GitHub-Environments (`int`, `test`), [di2f-0002 (archiviert)](../../features/archive/di2f-0002-git-branch-und-deploy-strategie.md), [di2f-0004](../../features/di2f-0004-github-actions-db-workflows-secrets.md), [.github/workflows/](../../.github/workflows/), [help-Skill](../../.claude/skills/help/SKILL.md)
- **Status:** ❌ Offen
- **Schweregrad:** Mittel
- **Quelle:** manual

**Beschreibung:** Die gewünschte Promotion-Reihenfolge der Umgebungen ist **dev → int → test → prod** (Development, Integration, Test, Production) — konsistent zum Parallelprojekt. Aktuell ordnet das Framework die Branches als `dev`-Branch → (`dev`, `test`) und `main`-Branch → (`int`, `prod`) zu. Entlang der Branches gelesen ergibt das die Reihenfolge `dev, test, int, prod` — **`int` und `test` sind also relativ zur Soll-Reihenfolge vertauscht**. Erwartet: eine monotone Aufteilung, bei der die frühen Stufen (dev, int) aus `dev` und die Release-Stufen (test, prod) aus `main` kommen. **Kein** Rename von `test` nach UAT (bewusst verworfen).

**Root Cause:** In di2f-0002 wurde bei der Anforderungsklärung die Zuordnung „dev+test ← dev, int+prod ← main" gewählt. Diese Gruppierung ist nicht monoton zur Reihenfolge dev < int < test < prod: `int` (Stufe 2) hängt an `main`, `test` (Stufe 3) an `dev`. Dadurch wirkt die Promotion-Reihenfolge vertauscht.

**Betroffene Datei(en):**
- GitHub-Environment-Deployment-Branch-Policies (extern, kein Repo-File): `int` aktuell `main` → soll `dev`; `test` aktuell `dev` → soll `main`. (`dev`→`dev`, `prod`→`main` bleiben.)
- [features/archive/di2f-0002-git-branch-und-deploy-strategie.md](../../features/archive/di2f-0002-git-branch-und-deploy-strategie.md) — Mapping-Tabelle (Scope), AC 7/8, Tech Design (B/C/E + Umsetzungs-Schritte), QA Test Results.
- [features/di2f-0004-github-actions-db-workflows-secrets.md](../../features/di2f-0004-github-actions-db-workflows-secrets.md) Zeilen ~10, 29, 65, 69, 122 (Branch-Auflösung/-Sperre-Texte).
- [.github/workflows/db-create.yml](../../.github/workflows/db-create.yml), [db-deploy.yml](../../.github/workflows/db-deploy.yml), [db-clean.yml](../../.github/workflows/db-clean.yml), [db-drop.yml](../../.github/workflows/db-drop.yml) — Kopf-Kommentare „(dev/test <- dev, int/prod <- main)".
- [.github/workflows/README.md](../../.github/workflows/README.md) Zeilen ~15, 17 — Branch→Umgebung-Beschreibung.
- [.claude/skills/help/SKILL.md](../../.claude/skills/help/SKILL.md) Zeilen ~92, 116 — „speist int/prod" bzw. „dev/test → dev, int/prod → main".

**Reproduktion:**
1. di2f-0002-Spec / GitHub-Environments ansehen: `int` ← `main`, `test` ← `dev`.
2. Umgebungen entlang der Branches lesen (`dev`-Branch zuerst): dev, test, int, prod.
3. Mit Soll-Reihenfolge dev → int → test → prod vergleichen → `int`/`test` vertauscht.

**Fix:** Branch→Umgebung-Zuordnung auf **`dev`-Branch → (`dev`, `int`)** und **`main`-Branch → (`test`, `prod`)** umstellen.
- GitHub-Environments: Deployment-Branch von `int` auf `dev`, von `test` auf `main` ändern (manuell in GitHub; `dev`/`prod` bleiben).
- Doku angleichen: di2f-0002 (archiviert), di2f-0004-Spec, workflows-Kommentare + README, help-Skill — überall die neue Gruppierung und die Reihenfolge dev → int → test → prod.
- Workflow-YAMLs funktional voraussichtlich unberührt (nutzen `github.ref_name` + native Environment-Policy; `options:`-Reihenfolge ist bereits `[dev, int, test, prod]`).
- Reihenfolge/Zuordnung final mit dem Parallelprojekt abgleichen (Konsistenz über beide Repos ist das Ziel).
- Routing: `/backend BUG-0001` (Doku/Workflow-Texte) + manuelle GitHub-Environment-Anpassung durch den User.
