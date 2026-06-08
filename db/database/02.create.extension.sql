-- 02 — Extensions + public-Härtung (gegen die neue DB ausführen)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Härtung: niemand außer dem Owner darf Objekte im Schema public anlegen.
-- Die vier Framework-Schemas (config/etl/helper/log) werden separat erstellt.
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
