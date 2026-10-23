-- ============================================================
-- REPLACE THESE VALUES BEFORE RUNNING
-- ============================================================
-- Snowflake Account  : <your-account>.snowflakecomputing.com
-- Username           : <your-snowflake-username>
-- Role               : SYSADMIN  (or your admin role)
-- Warehouse          : COMPUTE_WH
-- ============================================================

-- Create the database and schemas
CREATE DATABASE IF NOT EXISTS HEALTHCARE_DB;
CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DB.RAW;        -- raw source tables
CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DB.ANALYTICS;  -- dbt output schema
