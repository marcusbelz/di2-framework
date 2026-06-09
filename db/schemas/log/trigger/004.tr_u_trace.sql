\echo "## CREATE TRIGGER tr_u_trace"

DROP TRIGGER IF EXISTS tr_u_trace ON :schema_log.trace;

CREATE TRIGGER tr_u_trace
BEFORE UPDATE ON :schema_log.trace
FOR EACH ROW
   EXECUTE FUNCTION :schema_log.tf_set_modified();

\echo "## CREATE TRIGGER tr_u_trace - DONE"
