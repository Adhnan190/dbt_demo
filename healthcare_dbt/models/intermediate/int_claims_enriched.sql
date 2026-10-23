-- ============================================================
-- int_claims_enriched
-- Joins claims with patient insurance info and provider specialty.
-- Calculates financial risk metrics used in fct_claims.
-- ============================================================

WITH claims AS (
    SELECT
        claim_id,
        patient_id,
        provider_id,
        appointment_id,
        claim_date,
        service_date,
        diagnosis_code,
        procedure_code,
        billed_amount,
        allowed_amount,
        paid_amount,
        patient_responsibility,
        claim_status,
        denial_reason,
        insurance_provider        AS claim_insurance_provider,
        days_to_process,
        denial_flag,
        adjustment_amount,
        coverage_rate,
        processing_tier,
        created_at,
        updated_at
    FROM {{ ref('stg_claims') }}
),

patients AS (
    SELECT
        patient_id,
        full_name           AS patient_name,
        age_group,
        insurance_provider  AS patient_insurance_provider,
        is_medicare,
        is_medicaid,
        city,
        state
    FROM {{ ref('stg_patients') }}
),

providers AS (
    SELECT
        provider_id,
        full_name           AS provider_name,
        specialty,
        specialty_group,
        hospital,
        experience_tier
    FROM {{ ref('stg_providers') }}
),

claims_enriched AS (
    SELECT
        c.*,
        p.patient_name,
        p.age_group,
        p.patient_insurance_provider,
        p.is_medicare,
        p.is_medicaid,
        p.city                              AS patient_city,
        p.state                             AS patient_state,
        pr.provider_name,
        pr.specialty,
        pr.specialty_group,
        pr.hospital,
        pr.experience_tier,
        -- Financial derived columns
        ROUND(c.allowed_amount * 0.85, 2)  AS expected_reimbursement,
        ROUND(c.billed_amount - c.paid_amount, 2) AS claim_gap,
        c.billed_amount > 5000             AS is_high_value
    FROM claims c
    LEFT JOIN patients p
        ON c.patient_id = p.patient_id
    LEFT JOIN providers pr
        ON c.provider_id = pr.provider_id
)

SELECT * FROM claims_enriched
