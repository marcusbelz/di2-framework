\echo "## CREATE TRIGGER tr_u_process"

DROP TRIGGER IF EXISTS tr_u_process ON :schema_config.process;

CREATE TRIGGER tr_u_process
BEFORE UPDATE ON :schema_config.process
FOR EACH ROW
   EXECUTE FUNCTION :schema_config.tf_set_modified();

\echo "## CREATE TRIGGER tr_u_process - DONE"
