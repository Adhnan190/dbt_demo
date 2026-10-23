-- ============================================================
-- REPLACE THESE VALUES BEFORE RUNNING
-- ============================================================
-- Snowflake Account  : <your-account>.snowflakecomputing.com
-- Username           : <your-snowflake-username>
-- Role               : SYSADMIN  (or your admin role)
-- Warehouse          : COMPUTE_WH
-- ============================================================

USE DATABASE HEALTHCARE_DB;
USE SCHEMA RAW;

-- ============================================================
-- TABLE 1: PATIENTS (2,000 rows)
-- ============================================================
CREATE OR REPLACE TABLE HEALTHCARE_DB.RAW.PATIENTS AS
WITH name_lists AS (
    SELECT
        SEQ4() + 1 AS PATIENT_ID,
        CASE MOD(SEQ4(), 20)
            WHEN 0  THEN 'James'    WHEN 1  THEN 'Mary'
            WHEN 2  THEN 'Robert'   WHEN 3  THEN 'Patricia'
            WHEN 4  THEN 'John'     WHEN 5  THEN 'Jennifer'
            WHEN 6  THEN 'Michael'  WHEN 7  THEN 'Linda'
            WHEN 8  THEN 'William'  WHEN 9  THEN 'Barbara'
            WHEN 10 THEN 'David'    WHEN 11 THEN 'Elizabeth'
            WHEN 12 THEN 'Richard'  WHEN 13 THEN 'Susan'
            WHEN 14 THEN 'Joseph'   WHEN 15 THEN 'Jessica'
            WHEN 16 THEN 'Thomas'   WHEN 17 THEN 'Sarah'
            WHEN 18 THEN 'Charles'  ELSE 'Karen'
        END AS FIRST_NAME,
        CASE MOD(SEQ4(), 15)
            WHEN 0  THEN 'Smith'    WHEN 1  THEN 'Johnson'
            WHEN 2  THEN 'Williams' WHEN 3  THEN 'Brown'
            WHEN 4  THEN 'Jones'    WHEN 5  THEN 'Garcia'
            WHEN 6  THEN 'Miller'   WHEN 7  THEN 'Davis'
            WHEN 8  THEN 'Martinez' WHEN 9  THEN 'Wilson'
            WHEN 10 THEN 'Anderson' WHEN 11 THEN 'Taylor'
            WHEN 12 THEN 'Thomas'   WHEN 13 THEN 'Jackson'
            ELSE 'White'
        END AS LAST_NAME,
        DATEADD(
            day,
            UNIFORM(-23725, -6570, RANDOM()),   -- ~1940 to 2005
            CURRENT_DATE()
        ) AS DATE_OF_BIRTH,
        CASE MOD(SEQ4(), 2) WHEN 0 THEN 'M' ELSE 'F' END AS GENDER,
        CASE MOD(SEQ4(), 8)
            WHEN 0 THEN 'A+'  WHEN 1 THEN 'A-'
            WHEN 2 THEN 'B+'  WHEN 3 THEN 'B-'
            WHEN 4 THEN 'O+'  WHEN 5 THEN 'O-'
            WHEN 6 THEN 'AB+' ELSE 'AB-'
        END AS BLOOD_TYPE,
        '555-' || LPAD(TO_VARCHAR(UNIFORM(1000, 9999, RANDOM())), 4, '0') AS PHONE,
        CASE MOD(SEQ4(), 7)
            WHEN 0 THEN 'BlueCross' WHEN 1 THEN 'Aetna'
            WHEN 2 THEN 'Cigna'     WHEN 3 THEN 'United'
            WHEN 4 THEN 'Medicare'  WHEN 5 THEN 'Medicaid'
            ELSE 'Self-Pay'
        END AS INSURANCE_PROVIDER,
        'INS-' || UPPER(RANDSTR(8, RANDOM())) AS INSURANCE_ID,
        CASE WHEN UNIFORM(1, 100, RANDOM()) <= 90 THEN TRUE ELSE FALSE END AS IS_ACTIVE,
        DATEADD(
            second,
            UNIFORM(-94608000, 0, RANDOM()),   -- last 3 years
            CURRENT_TIMESTAMP()
        ) AS REGISTERED_AT,
        CASE MOD(SEQ4(), 8)
            WHEN 0 THEN 'New York'  WHEN 1 THEN 'Chicago'
            WHEN 2 THEN 'Houston'   WHEN 3 THEN 'Phoenix'
            WHEN 4 THEN 'Dallas'    WHEN 5 THEN 'Austin'
            WHEN 6 THEN 'Boston'    ELSE 'Seattle'
        END AS CITY
    FROM TABLE(GENERATOR(ROWCOUNT => 2000))
)
SELECT
    PATIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    DATE_OF_BIRTH,
    GENDER,
    BLOOD_TYPE,
    PHONE,
    LOWER(FIRST_NAME) || '.' || LOWER(LAST_NAME) || PATIENT_ID::VARCHAR || '@email.com' AS EMAIL,
    CITY,
    CASE CITY
        WHEN 'New York' THEN 'NY' WHEN 'Chicago' THEN 'IL'
        WHEN 'Houston'  THEN 'TX' WHEN 'Phoenix' THEN 'AZ'
        WHEN 'Dallas'   THEN 'TX' WHEN 'Austin'  THEN 'TX'
        WHEN 'Boston'   THEN 'MA' ELSE 'WA'
    END AS STATE,
    INSURANCE_PROVIDER,
    INSURANCE_ID,
    IS_ACTIVE,
    REGISTERED_AT,
    DATEADD(second, UNIFORM(0, 2592000, RANDOM()), REGISTERED_AT) AS UPDATED_AT
FROM name_lists;


-- ============================================================
-- TABLE 2: PROVIDERS (100 rows)
-- ============================================================
CREATE OR REPLACE TABLE HEALTHCARE_DB.RAW.PROVIDERS AS
WITH provider_base AS (
    SELECT
        SEQ4() + 1 AS PROVIDER_ID,
        CASE MOD(SEQ4(), 20)
            WHEN 0  THEN 'Dr. Alan Cooper'      WHEN 1  THEN 'Dr. Beth Harrison'
            WHEN 2  THEN 'Dr. Carlos Rivera'    WHEN 3  THEN 'Dr. Diana Patel'
            WHEN 4  THEN 'Dr. Edward Kim'       WHEN 5  THEN 'Dr. Fiona McAllister'
            WHEN 6  THEN 'Dr. George Thompson'  WHEN 7  THEN 'Dr. Helen Nguyen'
            WHEN 8  THEN 'Dr. Ivan Petrov'      WHEN 9  THEN 'Dr. Julia Santos'
            WHEN 10 THEN 'Dr. Kevin Walsh'      WHEN 11 THEN 'Dr. Laura Chen'
            WHEN 12 THEN 'Dr. Marcus Johnson'   WHEN 13 THEN 'Dr. Natalie Brooks'
            WHEN 14 THEN 'Dr. Oscar Ramirez'    WHEN 15 THEN 'Dr. Paula Wright'
            WHEN 16 THEN 'Dr. Quentin Blake'    WHEN 17 THEN 'Dr. Rachel Stone'
            WHEN 18 THEN 'Dr. Samuel Porter'    ELSE 'Dr. Teresa Young'
        END AS FULL_NAME,
        CASE MOD(SEQ4(), 10)
            WHEN 0 THEN 'Cardiology'          WHEN 1 THEN 'Oncology'
            WHEN 2 THEN 'Neurology'           WHEN 3 THEN 'Orthopedics'
            WHEN 4 THEN 'Pediatrics'          WHEN 5 THEN 'General Practice'
            WHEN 6 THEN 'Dermatology'         WHEN 7 THEN 'Psychiatry'
            WHEN 8 THEN 'Radiology'           ELSE 'Emergency Medicine'
        END AS SPECIALTY,
        CASE MOD(SEQ4(), 5)
            WHEN 0 THEN 'City General Hospital'
            WHEN 1 THEN 'St. Mary Medical Center'
            WHEN 2 THEN 'Riverside Health System'
            WHEN 3 THEN 'Metro University Hospital'
            ELSE 'Lakeside Clinic'
        END AS HOSPITAL,
        UNIFORM(1, 40, RANDOM()) AS YEARS_EXPERIENCE,
        CASE WHEN UNIFORM(1, 100, RANDOM()) <= 95 THEN TRUE ELSE FALSE END AS IS_ACTIVE,
        DATEADD(day, -UNIFORM(1, 5475, RANDOM()), CURRENT_DATE()) AS JOINED_DATE,
        DATEADD(second, -UNIFORM(0, 157680000, RANDOM()), CURRENT_TIMESTAMP()) AS CREATED_AT
    FROM TABLE(GENERATOR(ROWCOUNT => 100))
)
SELECT
    PROVIDER_ID,
    FULL_NAME,
    SPECIALTY,
    CASE SPECIALTY
        WHEN 'Cardiology'        THEN 'Cardiology Dept.'
        WHEN 'Oncology'          THEN 'Oncology Dept.'
        WHEN 'Neurology'         THEN 'Neurology Dept.'
        WHEN 'Orthopedics'       THEN 'Orthopedics Dept.'
        WHEN 'Pediatrics'        THEN 'Pediatrics Dept.'
        WHEN 'General Practice'  THEN 'Primary Care Dept.'
        WHEN 'Dermatology'       THEN 'Dermatology Dept.'
        WHEN 'Psychiatry'        THEN 'Behavioral Health Dept.'
        WHEN 'Radiology'         THEN 'Imaging Dept.'
        ELSE 'Emergency Dept.'
    END AS DEPARTMENT,
    'NPI-' || LPAD(TO_VARCHAR(UNIFORM(1000000000, 9999999999, RANDOM())), 10, '0') AS NPI_NUMBER,
    HOSPITAL,
    YEARS_EXPERIENCE,
    IS_ACTIVE,
    JOINED_DATE,
    CREATED_AT
FROM provider_base;


-- ============================================================
-- TABLE 3: APPOINTMENTS (10,000 rows)
-- ============================================================
CREATE OR REPLACE TABLE HEALTHCARE_DB.RAW.APPOINTMENTS AS
WITH appt_base AS (
    SELECT
        SEQ4() + 1 AS APPOINTMENT_ID,
        UNIFORM(1, 2000, RANDOM()) AS PATIENT_ID,
        UNIFORM(1, 100, RANDOM()) AS PROVIDER_ID,
        DATEADD(day, -UNIFORM(0, 547, RANDOM()), CURRENT_DATE()) AS APPOINTMENT_DATE,
        TIMEADD('minute', UNIFORM(480, 1020, RANDOM()), '00:00:00'::TIME) AS APPOINTMENT_TIME,
        CASE MOD(SEQ4(), 9)
            WHEN 0 THEN 'Routine Checkup'    WHEN 1 THEN 'Follow-up'
            WHEN 2 THEN 'Emergency'          WHEN 3 THEN 'Consultation'
            WHEN 4 THEN 'Procedure'          WHEN 5 THEN 'Lab Review'
            WHEN 6 THEN 'Vaccination'        WHEN 7 THEN 'Mental Health'
            ELSE 'Physical Therapy'
        END AS APPOINTMENT_TYPE,
        CASE MOD(SEQ4(), 4) WHEN 0 THEN 15 WHEN 1 THEN 30 WHEN 2 THEN 45 ELSE 60 END AS DURATION_MINS,
        CASE MOD(SEQ4(), 10)
            WHEN 0 THEN 'Patient reported mild symptoms'
            WHEN 1 THEN 'Follow-up after recent procedure'
            WHEN 2 THEN 'Annual wellness visit'
            WHEN 3 THEN 'Blood pressure management review'
            WHEN 4 THEN 'Prescription refill consultation'
            WHEN 5 THEN 'Lab results review'
            WHEN 6 THEN 'New complaint evaluation'
            WHEN 7 THEN 'Chronic condition management'
            WHEN 8 THEN 'Post-operative check'
            ELSE 'Preventive screening'
        END AS VISIT_NOTES,
        CASE MOD(SEQ4(), 8)
            WHEN 0 THEN 'Z00.00' WHEN 1 THEN 'I10'
            WHEN 2 THEN 'E11.9'  WHEN 3 THEN 'J06.9'
            WHEN 4 THEN 'M54.5'  WHEN 5 THEN 'F32.9'
            WHEN 6 THEN 'K21.0'  ELSE 'N39.0'
        END AS DIAGNOSIS_CODE,
        UNIFORM(1, 100, RANDOM()) AS status_roll
    FROM TABLE(GENERATOR(ROWCOUNT => 10000))
)
SELECT
    APPOINTMENT_ID,
    PATIENT_ID,
    PROVIDER_ID,
    APPOINTMENT_DATE,
    APPOINTMENT_TIME,
    APPOINTMENT_TYPE,
    CASE
        WHEN status_roll <= 65 THEN 'completed'
        WHEN status_roll <= 80 THEN 'scheduled'
        WHEN status_roll <= 90 THEN 'cancelled'
        ELSE 'no_show'
    END AS STATUS,
    DURATION_MINS,
    VISIT_NOTES,
    DIAGNOSIS_CODE,
    CASE
        WHEN status_roll <= 65 THEN
            CASE MOD(PATIENT_ID, 7)
                WHEN 4 THEN 0   -- Medicare
                WHEN 5 THEN 0   -- Medicaid
                WHEN 6 THEN 100 -- Self-Pay
                ELSE CASE MOD(APPOINTMENT_ID, 4)
                    WHEN 0 THEN 25 WHEN 1 THEN 50 WHEN 2 THEN 75 ELSE 100
                END
            END
        ELSE 0
    END::FLOAT AS COPAY_AMOUNT,
    CASE WHEN status_roll <= 65 THEN TRUE ELSE FALSE END AS IS_BILLED,
    DATEADD(second, -UNIFORM(0, 47520000, RANDOM()), CURRENT_TIMESTAMP()) AS CREATED_AT,
    DATEADD(second, UNIFORM(0, 86400, RANDOM()),
        DATEADD(second, -UNIFORM(0, 47520000, RANDOM()), CURRENT_TIMESTAMP())
    ) AS UPDATED_AT
FROM appt_base;


-- ============================================================
-- TABLE 4: CLAIMS (8,000 rows)
-- ============================================================
CREATE OR REPLACE TABLE HEALTHCARE_DB.RAW.CLAIMS AS
WITH claims_base AS (
    SELECT
        SEQ4() + 1 AS CLAIM_ID,
        UNIFORM(1, 2000, RANDOM()) AS PATIENT_ID,
        UNIFORM(1, 100, RANDOM()) AS PROVIDER_ID,
        CASE WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN UNIFORM(1, 10000, RANDOM()) ELSE NULL END AS APPOINTMENT_ID,
        DATEADD(day, -UNIFORM(0, 547, RANDOM()), CURRENT_DATE()) AS CLAIM_DATE_BASE,
        CASE MOD(SEQ4(), 8)
            WHEN 0 THEN 'Z00.00' WHEN 1 THEN 'I10'
            WHEN 2 THEN 'E11.9'  WHEN 3 THEN 'J06.9'
            WHEN 4 THEN 'M54.5'  WHEN 5 THEN 'F32.9'
            WHEN 6 THEN 'K21.0'  ELSE 'N39.0'
        END AS DIAGNOSIS_CODE,
        CASE MOD(SEQ4(), 8)
            WHEN 0 THEN '99213' WHEN 1 THEN '99214'
            WHEN 2 THEN '99215' WHEN 3 THEN '93000'
            WHEN 4 THEN '85025' WHEN 5 THEN '80053'
            WHEN 6 THEN '71046' ELSE '70553'
        END AS PROCEDURE_CODE,
        UNIFORM(50, 15000, RANDOM())::FLOAT AS BILLED_AMOUNT,
        UNIFORM(1, 100, RANDOM()) AS claim_status_roll,
        CASE MOD(SEQ4(), 7)
            WHEN 0 THEN 'BlueCross' WHEN 1 THEN 'Aetna'
            WHEN 2 THEN 'Cigna'     WHEN 3 THEN 'United'
            WHEN 4 THEN 'Medicare'  WHEN 5 THEN 'Medicaid'
            ELSE 'Self-Pay'
        END AS INSURANCE_PROVIDER,
        UNIFORM(1, 45, RANDOM()) AS DAYS_TO_PROCESS
    FROM TABLE(GENERATOR(ROWCOUNT => 8000))
),
claims_with_amounts AS (
    SELECT
        *,
        ROUND(BILLED_AMOUNT * UNIFORM(60, 95, RANDOM()) / 100.0, 2) AS ALLOWED_AMOUNT,
        CASE
            WHEN claim_status_roll <= 70  THEN 'paid'
            WHEN claim_status_roll <= 80  THEN 'pending'
            WHEN claim_status_roll <= 88  THEN 'denied'
            WHEN claim_status_roll <= 94  THEN 'partial'
            ELSE 'appealed'
        END AS CLAIM_STATUS
    FROM claims_base
),
claims_final AS (
    SELECT
        *,
        CASE CLAIM_STATUS
            WHEN 'paid'    THEN ROUND(ALLOWED_AMOUNT * UNIFORM(90, 100, RANDOM()) / 100.0, 2)
            WHEN 'partial' THEN ROUND(ALLOWED_AMOUNT * UNIFORM(50, 89, RANDOM()) / 100.0, 2)
            ELSE 0.0
        END AS PAID_AMOUNT
    FROM claims_with_amounts
)
SELECT
    CLAIM_ID,
    PATIENT_ID,
    PROVIDER_ID,
    APPOINTMENT_ID,
    CLAIM_DATE_BASE AS CLAIM_DATE,
    DATEADD(day, -UNIFORM(1, 3, RANDOM()), CLAIM_DATE_BASE) AS SERVICE_DATE,
    DIAGNOSIS_CODE,
    PROCEDURE_CODE,
    BILLED_AMOUNT,
    ALLOWED_AMOUNT,
    PAID_AMOUNT,
    GREATEST(ALLOWED_AMOUNT - PAID_AMOUNT, 0) AS PATIENT_RESPONSIBILITY,
    CLAIM_STATUS,
    CASE CLAIM_STATUS
        WHEN 'denied' THEN
            CASE MOD(CLAIM_ID, 5)
                WHEN 0 THEN 'Not covered'
                WHEN 1 THEN 'Pre-auth required'
                WHEN 2 THEN 'Duplicate claim'
                WHEN 3 THEN 'Invalid diagnosis'
                ELSE 'Provider not in network'
            END
        ELSE NULL
    END AS DENIAL_REASON,
    INSURANCE_PROVIDER,
    DAYS_TO_PROCESS,
    DATEADD(second, -UNIFORM(0, 47520000, RANDOM()), CURRENT_TIMESTAMP()) AS CREATED_AT,
    DATEADD(second, UNIFORM(0, 86400, RANDOM()),
        DATEADD(second, -UNIFORM(0, 47520000, RANDOM()), CURRENT_TIMESTAMP())
    ) AS UPDATED_AT
FROM claims_final;


-- ============================================================
-- TABLE 5: MEDICATIONS (15,000 rows)
-- ============================================================
CREATE OR REPLACE TABLE HEALTHCARE_DB.RAW.MEDICATIONS AS
WITH med_base AS (
    SELECT
        SEQ4() + 1 AS MEDICATION_ID,
        UNIFORM(1, 2000, RANDOM()) AS PATIENT_ID,
        UNIFORM(1, 100, RANDOM()) AS PROVIDER_ID,
        CASE MOD(SEQ4(), 12)
            WHEN 0  THEN 'Metformin'               WHEN 1  THEN 'Lisinopril'
            WHEN 2  THEN 'Atorvastatin'             WHEN 3  THEN 'Amlodipine'
            WHEN 4  THEN 'Omeprazole'               WHEN 5  THEN 'Levothyroxine'
            WHEN 6  THEN 'Metoprolol'               WHEN 7  THEN 'Albuterol'
            WHEN 8  THEN 'Gabapentin'               WHEN 9  THEN 'Sertraline'
            WHEN 10 THEN 'Hydrochlorothiazide'      ELSE 'Losartan'
        END AS DRUG_NAME,
        DATEADD(day, -UNIFORM(0, 730, RANDOM()), CURRENT_DATE()) AS START_DATE,
        UNIFORM(1, 100, RANDOM()) AS end_date_roll,
        CASE MOD(SEQ4(), 5)
            WHEN 0 THEN '500mg' WHEN 1 THEN '10mg'
            WHEN 2 THEN '20mg'  WHEN 3 THEN '5mg'
            ELSE '40mg'
        END AS DOSAGE,
        CASE MOD(SEQ4(), 5)
            WHEN 0 THEN 'Once daily'       WHEN 1 THEN 'Twice daily'
            WHEN 2 THEN 'Three times daily' WHEN 3 THEN 'As needed'
            ELSE 'Weekly'
        END AS FREQUENCY,
        UNIFORM(0, 12, RANDOM()) AS REFILL_COUNT,
        CASE MOD(SEQ4(), 3)
            WHEN 0 THEN 30 WHEN 1 THEN 60 ELSE 90
        END AS DAYS_SUPPLY,
        CASE MOD(SEQ4(), 5)
            WHEN 0 THEN 'CVS'       WHEN 1 THEN 'Walgreens'
            WHEN 2 THEN 'Rite Aid'  WHEN 3 THEN 'Walmart'
            ELSE 'Mail Order'
        END AS PHARMACY
    FROM TABLE(GENERATOR(ROWCOUNT => 15000))
)
SELECT
    MEDICATION_ID,
    PATIENT_ID,
    PROVIDER_ID,
    DRUG_NAME,
    CASE DRUG_NAME
        WHEN 'Metformin'            THEN 'Antidiabetic'
        WHEN 'Lisinopril'           THEN 'ACE Inhibitor'
        WHEN 'Atorvastatin'         THEN 'Statin'
        WHEN 'Amlodipine'           THEN 'Calcium Channel Blocker'
        WHEN 'Omeprazole'           THEN 'PPI'
        WHEN 'Levothyroxine'        THEN 'Thyroid'
        WHEN 'Metoprolol'           THEN 'Beta Blocker'
        WHEN 'Albuterol'            THEN 'Bronchodilator'
        WHEN 'Gabapentin'           THEN 'Anticonvulsant'
        WHEN 'Sertraline'           THEN 'SSRI'
        WHEN 'Hydrochlorothiazide'  THEN 'Diuretic'
        ELSE 'ARB'
    END AS DRUG_CLASS,
    DOSAGE,
    FREQUENCY,
    START_DATE,
    CASE WHEN end_date_roll <= 70 THEN NULL
         ELSE DATEADD(day, UNIFORM(30, 365, RANDOM()), START_DATE)
    END AS END_DATE,
    CASE WHEN end_date_roll <= 70 THEN TRUE ELSE FALSE END AS IS_ACTIVE,
    REFILL_COUNT,
    DAYS_SUPPLY,
    PHARMACY,
    DATEADD(second, -UNIFORM(0, 63072000, RANDOM()), CURRENT_TIMESTAMP()) AS CREATED_AT
FROM med_base;


-- ============================================================
-- Verify row counts
-- ============================================================
SELECT 'PATIENTS'     AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DB.RAW.PATIENTS    UNION ALL
SELECT 'PROVIDERS'    AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DB.RAW.PROVIDERS   UNION ALL
SELECT 'APPOINTMENTS' AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DB.RAW.APPOINTMENTS UNION ALL
SELECT 'CLAIMS'       AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DB.RAW.CLAIMS      UNION ALL
SELECT 'MEDICATIONS'  AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_DB.RAW.MEDICATIONS;
