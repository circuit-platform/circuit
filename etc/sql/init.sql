ALTER SYSTEM SET wal_level = logical;

CREATE DATABASE circuit;
\connect circuit;
CREATE SCHEMA private;

SET search_path TO public, private;