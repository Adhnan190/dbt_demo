-- ============================================================
-- dim_patients
-- Patient dimension combining latest patient attributes with
-- lifetime value metrics from int_patient_summary.
-- ============================================================

WITH patient_attrs AS (
    SELECT
        patient_id,
        first_name,
        last_name,
        full_name,
        date_of_birth,
        age_years,
        age_group,
        gender,
        blood_type,
        phone,
        email,
        city,
        state,
        insurance_provider,
        insurance_id,
        is_medicare,
        is_medicaid,
        is_active,
        registered_at,
        updated_at,
        days_since_registration
    FROM {{ ref('stg_patients') }}
),

patient_summary AS (
    SELECT
        patient_id,
        total_appointments,
        completed_appointments,
        cancelled_appointments,
        no_show_appointments,
        cancellation_rate,
        no_show_rate,
        last_appointment_date,
        first_appointment_date,
        total_claims,
        paid_claims,
        denied_claims,
        total_billed,
        total_paid,
        outstanding_balance,
        last_claim_date,
        total_medications,
        active_medications,
        chronic_medications,
        long_term_medications,
        avg_medication_duration_days,
        engagement_score
    FROM {{ ref('int_patient_summary') }}
)

SELECT
    -- Identity
    p.patient_id,
    p.first_name,
    p.last_name,
    p.full_name,
    p.date_of_birth,
    p.age_years,
    p.age_group,
    p.gender,
    p.blood_type,
    p.phone,
    p.email,
    p.city,
    p.state,
    p.insurance_provider,
    p.insurance_id,
    p.is_medicare,
    p.is_medicaid,
    p.is_active,
    p.registered_at,
    p.updated_at,
    p.days_since_registration,

    -- Appointment metrics
    COALESCE(s.total_appointments, 0)              AS total_appointments,
    COALESCE(s.completed_appointments, 0)          AS completed_appointments,
    COALESCE(s.cancelled_appointments, 0)          AS cancelled_appointments,
    COALESCE(s.no_show_appointments, 0)            AS no_show_appointments,
    COALESCE(s.cancellation_rate, 0)               AS cancellation_rate,
    COALESCE(s.no_show_rate, 0)                    AS no_show_rate,
    s.last_appointment_date,
    s.first_appointment_date,

    -- Claim / financial metrics
    COALESCE(s.total_claims, 0)                    AS total_claims,
    COALESCE(s.paid_claims, 0)                     AS paid_claims,
    COALESCE(s.denied_claims, 0)                   AS denied_claims,
    COALESCE(s.total_billed, 0)                    AS total_billed,
    COALESCE(s.total_paid, 0)                      AS total_paid,
    COALESCE(s.outstanding_balance, 0)             AS outstanding_balance,
    s.last_claim_date,

    -- Medication metrics
    COALESCE(s.total_medications, 0)               AS total_medications,
    COALESCE(s.active_medications, 0)              AS active_medications,
    COALESCE(s.chronic_medications, 0)             AS chronic_medications,
    COALESCE(s.long_term_medications, 0)           AS long_term_medications,
    COALESCE(s.avg_medication_duration_days, 0)    AS avg_medication_duration_days,

    -- Engagement
    COALESCE(s.engagement_score, 0)                AS engagement_score,

    -- Lifetime value tier
    CASE
        WHEN COALESCE(s.total_paid, 0) >= 10000 THEN 'High Value'
        WHEN COALESCE(s.total_paid, 0) >= 2500  THEN 'Medium'
        ELSE 'Low'
    END                                            AS patient_tier,

    -- Churn risk
    CASE
        WHEN s.last_appointment_date IS NULL THEN 'High'
        WHEN DATEDIFF('day', s.last_appointment_date, CURRENT_DATE()) > 365 THEN 'High'
        WHEN DATEDIFF('day', s.last_appointment_date, CURRENT_DATE()) > 180 THEN 'Medium'
        ELSE 'Low'
    END                                            AS churn_risk

FROM patient_attrs p
LEFT JOIN patient_summary s
    ON p.patient_id = s.patient_id
