\echo "## CREATE TRIGGER tr_u_component"

DROP TRIGGER IF EXISTS tr_u_component ON :schema_log.component;

CREATE TRIGGER tr_u_component
BEFORE UPDATE ON :schema_log.component
FOR EACH ROW
   EXECUTE FUNCTION :schema_log.tf_set_modified();

\echo "## CREATE TRIGGER tr_u_component - DONE"
