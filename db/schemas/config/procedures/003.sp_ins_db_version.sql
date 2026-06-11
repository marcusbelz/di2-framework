\echo "## CREATE PROCEDURE :schema_config.sp_ins_db_version"

DROP PROCEDURE IF EXISTS :schema_config.sp_ins_db_version(bigint, int, int, int, varchar, varchar, varchar);

-- --------------------------------------------------------------------------------
-- Parameter
-- --------------------------------------------------------------------------------
--    p_id             bigint
--       db_version-id assigned to the newly inserted row (INOUT, returned to caller)
--    p_major          int
--       Hauptversion (major) der Release-Version
--    p_minor          int
--       Nebenversion (minor) der Release-Version
--    p_build          int
--       Build-Nummer der Release-Version
--    p_git_commit     varchar
--       Commit-SHA des deployten Git-Stands
--    p_git_tag        varchar
--       Git-Release-Tag des Stands (optional; leer/NULL erlaubt)
--    p_environment    varchar
--       Zielumgebung des Deploys (dev/int/test/prod)
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE :schema_config.sp_ins_db_version
(
    INOUT p_id             bigint
   ,IN    p_major          int
   ,IN    p_minor          int
   ,IN    p_build          int
   ,IN    p_git_commit     varchar
   ,IN    p_git_tag        varchar
   ,IN    p_environment    varchar
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
   -- --------------------------------------------------------------------------------
   -- Common
   -- --------------------------------------------------------------------------------
   l_component               varchar;

   -- --------------------------------------------------------------------------------
   -- Error Handling
   -- --------------------------------------------------------------------------------
   l_error_message           text;
   l_error_code              text;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   l_git_commit              varchar;
   l_git_tag                 varchar;
   l_environment             varchar;
BEGIN
   -- --------------------------------------------------------------------------------
   -- Get name of function/procedure
   -- --------------------------------------------------------------------------------
   -- schlank: kein lc_messages/PG_CONTEXT (keine Komponenten-Protokollierung; BUG-0337)
   l_component := 'config.sp_ins_db_version';

   RAISE NOTICE '### procedure : %', l_component;

   -- --------------------------------------------------------------------------------
   -- Check parameter
   -- --------------------------------------------------------------------------------
   BEGIN
      IF p_major IS NULL OR p_minor IS NULL OR p_build IS NULL THEN

         l_error_message := format($$%1$s: Versionsnummer (major/minor/build) darf nicht leer sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      IF p_major < 0 OR p_minor < 0 OR p_build < 0 THEN

         l_error_message := format($$%1$s: Versionsnummer darf nicht negativ sein (major=%2$s, minor=%3$s, build=%4$s)$$, l_component, p_major, p_minor, p_build);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      IF p_git_commit IS NULL OR length(trim(p_git_commit)) = 0 THEN

         l_error_message := format($$%1$s: Git-Commit darf nicht leer sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      IF p_environment IS NULL OR length(trim(p_environment)) = 0 THEN

         l_error_message := format($$%1$s: Umgebung darf nicht leer sein$$, l_component);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;

      IF trim(p_environment) NOT IN ('dev', 'int', 'test', 'prod') THEN

         l_error_message := format($$%1$s: ungültige Umgebung '%2$s' (erlaubt: dev, int, test, prod)$$, l_component, p_environment);
         l_error_code    := 'invalid_parameter_value';

         RAISE EXCEPTION USING MESSAGE = l_error_message, ERRCODE = l_error_code;

      END IF;
   END;

   -- --------------------------------------------------------------------------------
   -- Workload
   -- --------------------------------------------------------------------------------
   BEGIN
      l_git_commit  := trim(p_git_commit);
      l_git_tag     := NULLIF(trim(p_git_tag), '');
      l_environment := trim(p_environment);

      INSERT INTO config.db_version (major, minor, build, git_commit, git_tag, environment)
      VALUES
      (
          p_major
         ,p_minor
         ,p_build
         ,l_git_commit
         ,l_git_tag
         ,l_environment
      )
      RETURNING id INTO p_id;

   END;

END;
$procedure$;

ALTER PROCEDURE :schema_config.sp_ins_db_version(bigint, int, int, int, varchar, varchar, varchar) OWNER TO :schema_owner;

\echo "## CREATE PROCEDURE :schema_config.sp_ins_db_version - DONE"
