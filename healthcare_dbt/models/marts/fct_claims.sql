-- ============================================================
-- fct_claims
-- Final claims fact table with full financials and risk flags.
-- Sourced from int_claims_enriched (ephemeral CTE join).
-- ============================================================

SELECT
    -- Keys
    claim_id,
    patient_id,
    provider_id,
    appointment_id,

    -- Dates
    claim_date,
    service_date,

    -- Clinical coding
    diagnosis_code,
    procedure_code,

    -- Financial amounts
    billed_amount,
    allowed_amount,
    paid_amount,
    patient_responsibility,
    expected_reimbursement,
    claim_gap,
    adjustment_amount,
    coverage_rate,

    -- Claim status
    claim_status,
    denial_reason,
    denial_flag,

    -- Insurance
    claim_insurance_provider,

    -- Processing
    days_to_process,
    processing_tier,

    -- Patient context
    patient_name,
    age_group,
    patient_insurance_provider,
    is_medicare,
    is_medicaid,
    patient_city,
    patient_state,

    -- Provider context
    provider_name,
    specialty,
    specialty_group,
    hospital,
    experience_tier,

    -- Business flags
    is_high_value,
    denial_flag AND billed_amount > 1000               AS financial_risk_flag,

    -- Audit
    created_at,
    updated_at

FROM {{ ref('int_claims_enriched') }}
