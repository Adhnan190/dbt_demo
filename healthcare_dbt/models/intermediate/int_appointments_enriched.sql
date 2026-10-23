-- ============================================================
-- int_appointments_enriched
-- Heavy join model: appointments x patients x providers
-- This is the key regression-detection model — runtime grows
-- proportionally with appointment row count.
-- ============================================================

WITH appointments AS (
    -- Base appointment records from staging
    SELECT
        appointment_id,
        patient_id,
        provider_id,
        appointment_date,
        appointment_time,
        appointment_datetime,
        appointment_type,
        status,
        is_completed,
        is_cancelled,
        is_no_show,
        is_emergency,
        duration_mins,
        visit_notes,
        diagnosis_code,
        copay_amount,
        is_billed,
        week_number,
        month_year,
        created_at,
        updated_at
    FROM {{ ref('stg_appointments') }}
),

patients AS (
    -- Relevant patient attributes for enrichment
    SELECT
        patient_id,
        full_name                   AS patient_name,
        age_years,
        age_group,
        gender,
        insurance_provider,
        is_medicare,
        is_medicaid,
        city,
        state,
        is_active                   AS patient_is_active
    FROM {{ ref('stg_patients') }}
),

providers AS (
    -- Relevant provider attributes for enrichment
    SELECT
        provider_id,
        full_name                   AS provider_name,
        specialty,
        specialty_group,
        hospital,
        department,
        experience_tier,
        is_active                   AS provider_is_active
    FROM {{ ref('stg_providers') }}
),

appointments_with_patients AS (
    -- First join: appointments + patient context
    SELECT
        a.*,
        p.patient_name,
        p.age_years,
        p.age_group,
        p.gender,
        p.insurance_provider,
        p.is_medicare,
        p.is_medicaid,
        p.city                      AS patient_city,
        p.state                     AS patient_state,
        p.patient_is_active
    FROM appointments a
    LEFT JOIN patients p
        ON a.patient_id = p.patient_id
),

appointments_enriched AS (
    -- Second join: bring in provider context
    SELECT
        ap.*,
        pr.provider_name,
        pr.specialty,
        pr.specialty_group,
        pr.hospital,
        pr.department,
        pr.experience_tier,
        pr.provider_is_active,
        -- Revenue at risk from no-shows
        CASE WHEN ap.is_no_show THEN ap.copay_amount ELSE 0 END  AS revenue_at_risk
    FROM appointments_with_patients ap
    LEFT JOIN providers pr
        ON ap.provider_id = pr.provider_id
)

SELECT * FROM appointments_enriched
