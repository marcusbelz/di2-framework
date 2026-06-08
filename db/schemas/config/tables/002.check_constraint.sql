\echo "## CREATE TABLE :schema_config.check_constraint"

CREATE TABLE IF NOT EXISTS :schema_config.check_constraint
(
    id                  bigserial       NOT NULL
   ,procedure_name      varchar(128)    NOT NULL
   ,error_type          char(1)         NOT NULL
   ,task                varchar(128)        NULL
   ,entity              varchar         NOT NULL
   ,step                varchar         NOT NULL
   ,schema_name         varchar(10)     NOT NULL
   ,table_name          varchar(128)    NOT NULL
   ,id1_field_name      varchar(128)    NOT NULL
   ,id2_field_name      varchar(128)        NULL
   ,id3_field_name      varchar(128)        NULL
   ,check_field_name    varchar(1000)   NOT NULL
   ,where_clause        varchar         NOT NULL
   ,max_occurance       integer            NULL
   ,message             varchar         NOT NULL
   ,description         varchar             NULL
   ,is_active           boolean         NOT NULL
   ,is_manual           boolean             NULL

   ,CONSTRAINT pk_check_constraint  PRIMARY KEY (id)
);
ALTER TABLE :schema_config.check_constraint OWNER TO :schema_owner;
COMMENT ON TABLE :schema_config.check_constraint IS 'Pruefregeln (Check Constraints), die beim Laden der Daten geprueft werden.';

\echo "## CREATE TABLE :schema_config.check_constraint - DONE"
