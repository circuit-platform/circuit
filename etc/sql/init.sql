ALTER SYSTEM SET wal_level = logical;

CREATE DATABASE ${MAIN_SPACE};
\connect ${MAIN_SPACE};
CREATE SCHEMA private;

SET search_path TO public, private;