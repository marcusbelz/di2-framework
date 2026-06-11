-- 00 — Preflight: stellt sicher, dass weder Datenbank noch Rollen bereits existieren.
--
-- Bootstrap ist drop-and-recreate (siehe CLAUDE.md): Rollen sind cluster-global und
-- ueberleben ein DROP DATABASE. Ein zweiter create.sh-Lauf ohne vorheriges drop.sh
-- braeche sonst in 01.create.database.sql mit "role already exists" (42710) ab.
-- Dieser Preflight stoppt vorher kontrolliert via RAISE -> psql liefert unter
-- ON_ERROR_STOP Exit-Code 3; create.sh faengt diesen Code ab und verweist auf drop.sh.
--
-- Gegen die Maintenance-DB 'postgres' ausfuehren, nach Laden von <env>.env.sql.

SELECT EXISTS (SELECT 1 FROM pg_database WHERE datname  =  :'database_name')
    OR EXISTS (SELECT 1 FROM pg_roles    WHERE rolname IN (:'database_owner', :'schema_owner', :'role_rw', :'user_sa'))
       AS di2_already_exists
\gset

\if :di2_already_exists
   DO $$
   BEGIN
      RAISE EXCEPTION 'di2-framework preflight: Datenbank oder Rollen existieren bereits — erst drop.sh ausfuehren';
   END
   $$;
\endif
