-- ============================================================
-- REPLACE THESE VALUES BEFORE RUNNING
-- ============================================================
-- Snowflake Account  : <your-account>.snowflakecomputing.com
-- Username           : <your-snowflake-username>
-- Role               : SYSADMIN  (or your admin role)
-- Warehouse          : COMPUTE_WH
-- ============================================================

-- Run this after 3-5 dbt job runs to simulate a regression
-- This triples the APPOINTMENTS and CLAIMS volume suddenly

-- ============================================================
-- Add 20,000 more appointments
-- ============================================================
INSERT INTO HEALTHCARE_DB.RAW.APPOINTMENTS
SELECT
    SEQ4() + 10001 AS APPOINTMENT_ID,
    UNIFORM(1, 2000, RANDOM()) AS PATIENT_ID,
    UNIFORM(1, 100, RANDOM()) AS PROVIDER_ID,
    DATEADD(day, -UNIFORM(0, 60, RANDOM()), CURRENT_DATE()) AS APPOINTMENT_DATE,
    TIMEADD('minute', UNIFORM(480, 1020, RANDOM()), '00:00:00'::TIME) AS APPOINTMENT_TIME,
    CASE MOD(SEQ4(), 9)
        WHEN 0 THEN 'Routine Checkup'   WHEN 1 THEN 'Follow-up'
        WHEN 2 THEN 'Emergency'         WHEN 3 THEN 'Consultation'
        WHEN 4 THEN 'Procedure'         WHEN 5 THEN 'Lab Review'
        WHEN 6 THEN 'Vaccination'       WHEN 7 THEN 'Mental Health'
        ELSE 'Physical Therapy'
    END AS APPOINTMENT_TYPE,
    CASE
        WHEN UNIFORM(1,100,RANDOM()) <= 65 THEN 'completed'
        WHEN UNIFORM(1,100,RANDOM()) <= 80 THEN 'scheduled'
        WHEN UNIFORM(1,100,RANDOM()) <= 90 THEN 'cancelled'
        ELSE 'no_show'
    END AS STATUS,
    CASE MOD(SEQ4(),4) WHEN 0 THEN 15 WHEN 1 THEN 30 WHEN 2 THEN 45 ELSE 60 END AS DURATION_MINS,
    'Patient reported mild symptoms' AS VISIT_NOTES,
    'I10' AS DIAGNOSIS_CODE,
    UNIFORM(0, 100, RANDOM()) AS COPAY_AMOUNT,
    TRUE AS IS_BILLED,
    CURRENT_TIMESTAMP() AS CREATED_AT,
    CURRENT_TIMESTAMP() AS UPDATED_AT
FROM TABLE(GENERATOR(ROWCOUNT => 20000));

-- ============================================================
-- Add 16,000 more claims
-- ============================================================
INSERT INTO HEALTHCARE_DB.RAW.CLAIMS
SELECT
    SEQ4() + 8001 AS CLAIM_ID,
    UNIFORM(1, 2000, RANDOM()) AS PATIENT_ID,
    UNIFORM(1, 100, RANDOM()) AS PROVIDER_ID,
    UNIFORM(1, 10000, RANDOM()) AS APPOINTMENT_ID,
    DATEADD(day, -UNIFORM(0, 60, RANDOM()), CURRENT_DATE()) AS CLAIM_DATE,
    DATEADD(day, -UNIFORM(1, 3, RANDOM()), DATEADD(day, -UNIFORM(0, 60, RANDOM()), CURRENT_DATE())) AS SERVICE_DATE,
    'I10' AS DIAGNOSIS_CODE,
    '99213' AS PROCEDURE_CODE,
    UNIFORM(50, 15000, RANDOM())::FLOAT AS BILLED_AMOUNT,
    UNIFORM(50, 15000, RANDOM())::FLOAT * 0.8 AS ALLOWED_AMOUNT,
    UNIFORM(50, 15000, RANDOM())::FLOAT * 0.7 AS PAID_AMOUNT,
    UNIFORM(50, 15000, RANDOM())::FLOAT * 0.1 AS PATIENT_RESPONSIBILITY,
    CASE WHEN UNIFORM(1,100,RANDOM()) <= 70 THEN 'paid'
         WHEN UNIFORM(1,100,RANDOM()) <= 80 THEN 'pending'
         ELSE 'denied' END AS CLAIM_STATUS,
    NULL AS DENIAL_REASON,
    'BlueCross' AS INSURANCE_PROVIDER,
    UNIFORM(1, 45, RANDOM()) AS DAYS_TO_PROCESS,
    CURRENT_TIMESTAMP() AS CREATED_AT,
    CURRENT_TIMESTAMP() AS UPDATED_AT
FROM TABLE(GENERATOR(ROWCOUNT => 16000));

-- ============================================================
-- Verify new row counts after regression simulation
-- ============================================================
SELECT 'APPOINTMENTS' AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DB.RAW.APPOINTMENTS UNION ALL
SELECT 'CLAIMS'       AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DB.RAW.CLAIMS;
-- Expected: APPOINTMENTS = 30,000  |  CLAIMS = 24,000
