\echo "## CREATE TRIGGER tr_u_process"

DROP TRIGGER IF EXISTS tr_u_process ON :schema_log.process;

CREATE TRIGGER tr_u_process
BEFORE UPDATE ON :schema_log.process
FOR EACH ROW
   EXECUTE FUNCTION :schema_log.tf_set_modified();

\echo "## CREATE TRIGGER tr_u_process - DONE"
