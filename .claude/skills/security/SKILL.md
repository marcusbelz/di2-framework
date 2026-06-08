---
name: security
description: Projektweiter Security-Audit des DB-Frameworks (Rollen/Rechte, RLS-Policies, Dynamic-SQL-Injection, SECURITY DEFINER/search_path, Secrets, sensible Daten in Logs, Deployment/CI). Vor Go-Live und nach größeren Änderungen ausführen.
argument-hint: "[optional: 'update' | Fokus z. B. 'roles' | 'rls' | 'dynsql']"
user-invocable: true
---

# Security Engineer

## Rolle
Du führst einen **projektweiten** Security-Audit des PostgreSQL-Frameworks durch — unabhängig von einzelnen Features. Du **findest und dokumentierst** Schwachstellen priorisiert. Du **behebst nichts selbst**.

## Scope-Abgrenzung — vor dem Start lesen
**Dies ist nicht `/qa`.** `/qa` testet die neue Fläche eines einzelnen Features. `/security` ist der **projektweite Gate vor Prod-Deploy** — über das gesamte `db/`-Verzeichnis, dafür in die Tiefe.

- **In Scope:** Rollen & Rechte (Least Privilege) über alle Schemas; RLS-Policies aller sensiblen Tabellen; Dynamic SQL im ganzen `etl`-Schema; `SECURITY DEFINER`-Funktionen & `search_path`; Secret-Scanning im ganzen Repo; sensible Daten in `log.trace`/`log.error`; PostgreSQL-Härtung (`public`-Schema-Rechte, Extensions wie `plpython3u`); Deployment-/CI-Sicherheit (GitHub Actions, `db/scripts/`).
- **Nicht in Scope:** funktionales Testen oder die Validierung eines einzelnen neuen Objekts — das macht `/qa`.

### Wann `/security` triggert
1. **Vor jedem Prod-Deploy**, wenn seit dem letzten Audit security-relevante Änderungen gemerged wurden → voller Audit oder `/security update`.
2. **Nach größeren Änderungen** (neues Rollenmodell, neue `etl`-Dynamic-SQL-Prozedur, neue Extension, geänderte RLS).
3. **Quartalsweise** als Routine.
4. Auf expliziten User-Wunsch.

Nicht nach jedem Feature — das verwässert den Gate-Charakter.

---

## Parameter-Auswertung

### `/security update`
Kein neuer Audit. Nur `docs/security-audit.md` aktualisieren: bestehende Datei lesen → betroffenen Code prüfen → je Finding Status aktualisieren (`❌ Offen` → `✅ Behoben (YYYY-MM-DD)` / `⚠️ Teilweise`) → `Zuletzt geprüft` + Go-Live-Empfehlung aktualisieren → zurückschreiben → Zusammenfassung zeigen. Existiert die Datei nicht: auf vollen `/security`-Lauf verweisen.

### `/security [fokus]` (z. B. `roles`, `rls`, `dynsql`)
Voller Audit, aber nur für den genannten Bereich; Ergebnis trotzdem in `docs/security-audit.md` (nur den geprüften Abschnitt aktualisieren).

### `/security` (kein Argument)
Vollständiger Audit aller Bereiche unten.

---

## Vorbereitung
1. PRD lesen: `docs/product-requirements.md` (Datensensitivität, Rollen).
2. Alle Objekt-Skripte scannen: `db/schemas/**/`, `db/database/`.
3. Rollen/Grants finden: `Grep -n "GRANT|REVOKE|CREATE ROLE|ALTER ROLE" db/`.
4. RLS finden: `Grep -n "ROW LEVEL SECURITY|CREATE POLICY|FORCE ROW" db/`.
5. Dynamic SQL finden: `Grep -n "EXECUTE|format\(|quote_ident|quote_literal" db/`.
6. `SECURITY DEFINER` finden: `Grep -n "SECURITY DEFINER|search_path" db/`.

---

## Audit-Bereiche

### 1. Rollen & Rechte (Least Privilege)
- [ ] Eigene Rollen je Aufgabe (Owner/Deploy vs. App-/Lese-Rolle)? Keine produktive Nutzung von Superuser.
- [ ] `GRANT`s minimal — keine pauschalen Rechte an `PUBLIC`.
- [ ] `public`-Schema gehärtet (`REVOKE CREATE ON SCHEMA public FROM PUBLIC`)?
- [ ] Objekt-Owner korrekt; keine Objekte in `public`.

### 2. Row Level Security & Policies
- [ ] RLS auf allen sensiblen Tabellen aktiviert (besonders `log.*`)? Ggf. `FORCE ROW LEVEL SECURITY`.
- [ ] Policy je Befehl (SELECT/INSERT/UPDATE/DELETE), Rollen explizit, `USING` + `WITH CHECK` vollständig.
- [ ] Default-Deny; keine umgehbare Policy. Siehe `.claude/rules/policies.md`.

### 3. Dynamic SQL Injection (Schema `etl`)
- [ ] Identifier via `%I`/`quote_ident`, Literale via `%L`/`quote_literal` bzw. `USING`-Parameter.
- [ ] **Keine** String-Konkatenation von Eingaben in `EXECUTE`.
- [ ] Eingaben (Tabellen-/Spaltennamen) gegen Whitelist/Katalog validiert, wo möglich.

### 4. SECURITY DEFINER & search_path
- [ ] `SECURITY DEFINER` nur mit Begründung; explizit gesetzter `search_path` (z. B. `SET search_path = pg_catalog, <schema>`).
- [ ] Keine Privilege-Escalation über veränderbaren `search_path`.

### 5. Secrets & Konfiguration
- [ ] Keine Klartext-Secrets in `config`-Daten, Skripten oder `db/`-Dateien.
- [ ] Keine hardcodierten Verbindungsdaten/Passwörter; nur über Env/GitHub-Secrets.
- [ ] `.gitignore` deckt lokale Env-/Secret-Dateien ab: `Grep -nE "\.env|secret|key" .gitignore`.

### 6. Sensible Daten in Logs
- [ ] `log.trace`/`log.error` enthalten keine Klartext-Passwörter/PII/Tokens.
- [ ] Fehlertexte (`SQLERRM`) geben keine Secrets/DB-Internals an Endnutzer weiter.

### 7. PostgreSQL-Härtung & Extensions
- [ ] Untrusted-Extensions (`plpython3u`) nur wo zwingend nötig; Funktionen, die sie nutzen, geprüft.
- [ ] Keine unnötigen Extensions/Superuser-Funktionen exponiert.
- [ ] Verbindungs-/`ssl`-Anforderungen für Prod definiert.

### 8. Deployment & CI/CD
- [ ] GitHub-Actions-Secrets via `${{ secrets.NAME }}`, kein `echo $SECRET`.
- [ ] `db/scripts/` geben keine Secrets aus; Deploy-User minimal berechtigt (kein root).
- [ ] Workflows triggern nur auf `main`/`dev` (kein Wildcard).
- [ ] `Glob .github/workflows/*.yml` durchsehen.

---

## DB-Risiko-Kurzcheck
Je Kategorie Status setzen (✅ Abgedeckt / ⚠️ Teilweise / ❌ Offen):

| # | Kategorie | Prüfpunkte |
|---|-----------|-----------|
| D1 | Broken Access Control | RLS aktiv? Rechte minimal? Keine Objekte in `public`? |
| D2 | SQL Injection | Dynamic SQL parametrisiert (`%I`/`%L`/`USING`)? |
| D3 | Privilege Escalation | `SECURITY DEFINER` + fixer `search_path`? Owner korrekt? |
| D4 | Sensitive Data Exposure | Keine Secrets/PII in `trace`/`error`/Fehlertexten? |
| D5 | Secrets Management | Keine hardcodierten Secrets; `.gitignore` deckt ab? |
| D6 | Insecure Config | `public` gehärtet? Extensions minimal? `ssl` für Prod? |
| D7 | CI/CD Integrity | Actions-Secrets sauber, Deploy-User minimal? |
| D8 | Logging Failures | Fehler protokolliert ohne sensible Daten? |

---

## Output-Format

### Schritt 1: Zusammenfassung in der Konversation
```
Security Audit — Ergebnis
Datum: [heute]
Geprüfte Bereiche: [Liste]

Kritisch: N | Hoch: N | Mittel: N | Niedrig: N
Bereit für Go-Live: JA / NEIN
```
Danach Findings nach Priorität, je: **Schwachstelle**, **Wo** (Datei:Zeile/Bereich), **Status** ❌ Offen, **Risiko**, **Fix** (mit SQL-Beispiel wo möglich). Plus DB-Risiko-Tabelle.

### Schritt 2: Ergebnis in `docs/security-audit.md` schreiben
Falls vorhanden: erst lesen, dann vollständig überschreiben (Audit-Historie **anfügen**, nicht überschreiben).

```markdown
# Security Audit

<!-- Wird von /security automatisch aktualisiert. Nicht manuell bearbeiten. -->

## Status

| Feld | Wert |
|------|------|
| Zuletzt geprüft | YYYY-MM-DD |
| Geprüfte Bereiche | Alle / [Bereich] |
| Go-Live-Empfehlung | ✅ JA / ❌ NEIN |
| Kritische Findings | N offen / N behoben |
| Hohe Findings | N offen / N behoben |

## Findings

### Kritisch
#### [Titel]
- **Bereich:** [z. B. "3. Dynamic SQL Injection"]
- **Wo:** [Datei:Zeile]
- **Status:** ❌ Offen | ✅ Behoben (YYYY-MM-DD) | ⚠️ Teilweise
- **Risiko:** [Beschreibung]
- **Fix:** [Beschreibung + SQL-Snippet]

### Hoch
[gleiche Struktur]

### Mittel
[gleiche Struktur]

### Niedrig / Informational
[Kurzliste mit Status]

### Abgedeckt ✅
[Was bereits korrekt ist]

## DB-Risiko-Kurzcheck

| # | Kategorie | Status | Anmerkung |
|---|-----------|--------|-----------|
| D1 | Broken Access Control | ✅/⚠️/❌ | |
| D2 | SQL Injection | ✅/⚠️/❌ | |
| D3 | Privilege Escalation | ✅/⚠️/❌ | |
| D4 | Sensitive Data Exposure | ✅/⚠️/❌ | |
| D5 | Secrets Management | ✅/⚠️/❌ | |
| D6 | Insecure Config | ✅/⚠️/❌ | |
| D7 | CI/CD Integrity | ✅/⚠️/❌ | |
| D8 | Logging Failures | ✅/⚠️/❌ | |

## Audit-Historie

| Datum | Bereiche | Kritisch | Hoch | Go-Live |
|-------|---------|----------|------|---------|
| YYYY-MM-DD | Alle | N | N | ❌/✅ |
```

## Wichtige Regeln
- **Nichts reparieren** — nur dokumentieren und priorisieren.
- Konservativ einschätzen (lieber zu hoch). SQL-Fix-Beispiele erwünscht.
- Nicht überprüfbare Bereiche explizit vermerken.
- Am Ende immer klare **Go-Live: JA/NEIN**-Empfehlung; `docs/security-audit.md` **immer schreiben**.

## Handoff
> "Security-Audit abgeschlossen. [N] kritische, [N] hohe Findings. Ergebnis in `docs/security-audit.md`.
>
> **Wenn Critical/High offen:** `/backend` (oder `/frontend`) zum Beheben, danach `/security update`.
> **Wenn grün** (`Go-Live: ✅ JA`, keine offenen Critical/High): nächster Schritt `/deploy prod` — der Deploy-Skill liest dieses File als Gate."
