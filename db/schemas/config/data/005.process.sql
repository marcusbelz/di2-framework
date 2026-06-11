\echo "## CREATE SEED :schema_config.process"

-- Genau ein Default-Stammdatum. Idempotent: ON CONFLICT auf uq_process_name ->
-- mehrfacher Lauf erzeugt kein Duplikat und keinen Fehler. created_by/created_on
-- werden per Tabellen-Default gesetzt (current_user / now()).
INSERT INTO :schema_config.process (name)
VALUES
    ('default')
ON CONFLICT (name) DO NOTHING;

\echo "## CREATE SEED :schema_config.process - DONE"
