\echo "## CREATE TRIGGER tr_u_execution"

DROP TRIGGER IF EXISTS tr_u_execution ON :schema_log.execution;

CREATE TRIGGER tr_u_execution
BEFORE UPDATE ON :schema_log.execution
FOR EACH ROW
   EXECUTE FUNCTION :schema_log.tf_set_modified();

\echo "## CREATE TRIGGER tr_u_execution - DONE"
