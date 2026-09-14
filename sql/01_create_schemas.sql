-- ============================================================
-- E-Commerce Data Warehouse
-- 01 - Create Schemas
-- ============================================================

-- Raw layer: stores source data with minimal transformation
CREATE SCHEMA IF NOT EXISTS raw;

-- Staging layer: used for cleaning and intermediate transformations
CREATE SCHEMA IF NOT EXISTS staging;

-- Warehouse layer: dimensional model used for analytics
CREATE SCHEMA IF NOT EXISTS warehouse;