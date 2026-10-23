-- ============================================================
-- fct_appointments
-- Final appointments fact table — widest model in the project.
-- Sourced from int_appointments_enriched (ephemeral CTE join).
-- ============================================================

SELECT
    -- Keys
    appointment_id,
    patient_id,
    provider_id,

    -- Appointment details
    appointment_date,
    appointment_time,
    appointment_datetime,
    appointment_type,
    status,

    -- Status flags
    is_completed,
    is_cancelled,
    is_no_show,
    is_emergency,

    -- Clinical details
    duration_mins,
    visit_notes,
    diagnosis_code,

    -- Financial
    copay_amount,
    is_billed,
    revenue_at_risk,

    -- Patient context
    patient_name,
    age_years,
    age_group,
    gender,
    insurance_provider,
    is_medicare,
    is_medicaid,
    patient_city,
    patient_state,
    patient_is_active,

    -- Provider context
    provider_name,
    specialty,
    specialty_group,
    hospital,
    department,
    experience_tier,
    provider_is_active,

    -- Time intelligence
    week_number,
    month_year,
    TO_CHAR(appointment_date, 'YYYY-MM') AS appointment_month,

    -- Business classification
    is_completed AND is_billed AND copay_amount > 0   AS is_revenue_generating,

    -- Audit
    created_at,
    updated_at

FROM {{ ref('int_appointments_enriched') }}
