-- Migration 001: Initial schema creation
-- Created: 2024-01-01
-- Description: Create initial database schema with TimescaleDB

BEGIN;

-- Log migration start
INSERT INTO schema_migrations (version, description, applied_at) 
VALUES ('001', 'Initial schema creation', NOW());

-- The schema creation is handled by schema.sql
-- This migration file is for tracking purposes

COMMIT;