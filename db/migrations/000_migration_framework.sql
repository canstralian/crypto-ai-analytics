-- Schema migrations tracking table
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(20) PRIMARY KEY,
    description TEXT,
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    rollback_sql TEXT
);

-- Migration management functions
CREATE OR REPLACE FUNCTION apply_migration(migration_version VARCHAR(20), migration_description TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if migration already applied
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = migration_version) THEN
        RAISE NOTICE 'Migration % already applied', migration_version;
        RETURN FALSE;
    END IF;
    
    -- Insert migration record
    INSERT INTO schema_migrations (version, description, applied_at)
    VALUES (migration_version, migration_description, NOW());
    
    RAISE NOTICE 'Applied migration %: %', migration_version, migration_description;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rollback_migration(migration_version VARCHAR(20))
RETURNS BOOLEAN AS $$
DECLARE
    rollback_sql TEXT;
BEGIN
    -- Get rollback SQL
    SELECT schema_migrations.rollback_sql INTO rollback_sql
    FROM schema_migrations 
    WHERE version = migration_version;
    
    IF rollback_sql IS NULL THEN
        RAISE EXCEPTION 'No rollback SQL found for migration %', migration_version;
    END IF;
    
    -- Execute rollback SQL
    EXECUTE rollback_sql;
    
    -- Remove migration record
    DELETE FROM schema_migrations WHERE version = migration_version;
    
    RAISE NOTICE 'Rolled back migration %', migration_version;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;