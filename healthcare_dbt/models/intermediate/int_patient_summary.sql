-- ============================================================
-- int_patient_summary
-- Per-patient aggregate from appointments, claims, and medications.
-- Produces the metrics used to build dim_patients.
-- ============================================================

WITH appointment_stats AS (
    SELECT
        patient_id,
        COUNT(*)                                                        AS total_appointments,
        COUNT_IF(is_completed)                                          AS completed_appointments,
        COUNT_IF(is_cancelled)                                          AS cancelled_appointments,
        COUNT_IF(is_no_show)                                            AS no_show_appointments,
        ROUND(COUNT_IF(is_cancelled)  / NULLIF(COUNT(*), 0), 4)        AS cancellation_rate,
        ROUND(COUNT_IF(is_no_show)   / NULLIF(COUNT(*), 0), 4)        AS no_show_rate,
        MAX(appointment_date)                                           AS last_appointment_date,
        MIN(appointment_date)                                           AS first_appointment_date
    FROM {{ ref('stg_appointments') }}
    GROUP BY 1
),

claim_stats AS (
    SELECT
        patient_id,
        COUNT(*)                                                        AS total_claims,
        COUNT_IF(claim_status = 'paid')                                 AS paid_claims,
        COUNT_IF(denial_flag)                                           AS denied_claims,
        ROUND(SUM(billed_amount), 2)                                    AS total_billed,
        ROUND(SUM(paid_amount), 2)                                      AS total_paid,
        ROUND(SUM(patient_responsibility), 2)                           AS outstanding_balance,
        MAX(claim_date)                                                 AS last_claim_date
    FROM {{ ref('stg_claims') }}
    GROUP BY 1
),

medication_stats AS (
    SELECT
        patient_id,
        COUNT(*)                                                        AS total_medications,
        COUNT_IF(is_active)                                             AS active_medications,
        COUNT_IF(is_chronic)                                            AS chronic_medications,
        COUNT_IF(is_long_term)                                          AS long_term_medications,
        ROUND(AVG(duration_days), 1)                                    AS avg_medication_duration_days
    FROM {{ ref('stg_medications') }}
    GROUP BY 1
),

combined AS (
    SELECT
        COALESCE(a.patient_id, c.patient_id, m.patient_id)             AS patient_id,

        -- Appointment metrics
        COALESCE(a.total_appointments, 0)                               AS total_appointments,
        COALESCE(a.completed_appointments, 0)                           AS completed_appointments,
        COALESCE(a.cancelled_appointments, 0)                           AS cancelled_appointments,
        COALESCE(a.no_show_appointments, 0)                             AS no_show_appointments,
        COALESCE(a.cancellation_rate, 0)                                AS cancellation_rate,
        COALESCE(a.no_show_rate, 0)                                     AS no_show_rate,
        a.last_appointment_date,
        a.first_appointment_date,

        -- Claim metrics
        COALESCE(c.total_claims, 0)                                     AS total_claims,
        COALESCE(c.paid_claims, 0)                                      AS paid_claims,
        COALESCE(c.denied_claims, 0)                                    AS denied_claims,
        COALESCE(c.total_billed, 0)                                     AS total_billed,
        COALESCE(c.total_paid, 0)                                       AS total_paid,
        COALESCE(c.outstanding_balance, 0)                              AS outstanding_balance,
        c.last_claim_date,

        -- Medication metrics
        COALESCE(m.total_medications, 0)                                AS total_medications,
        COALESCE(m.active_medications, 0)                               AS active_medications,
        COALESCE(m.chronic_medications, 0)                              AS chronic_medications,
        COALESCE(m.long_term_medications, 0)                            AS long_term_medications,
        COALESCE(m.avg_medication_duration_days, 0)                     AS avg_medication_duration_days,

        -- Engagement score (weighted composite, max 100)
        LEAST(
            ROUND(
                -- Appointment frequency component (max 40 pts)
                LEAST(COALESCE(a.total_appointments, 0) * 2.0, 40)
                -- Completion rate component (max 30 pts)
                + COALESCE(a.completed_appointments, 0) / NULLIF(COALESCE(a.total_appointments, 0), 0) * 30
                -- Claim payment rate component (max 20 pts)
                + COALESCE(c.paid_claims, 0) / NULLIF(COALESCE(c.total_claims, 0), 0) * 20
                -- Medication adherence component (max 10 pts)
                + LEAST(COALESCE(m.active_medications, 0) * 2.5, 10),
            1),
        100)                                                            AS engagement_score

    FROM appointment_stats a
    FULL OUTER JOIN claim_stats c     ON a.patient_id = c.patient_id
    FULL OUTER JOIN medication_stats m ON COALESCE(a.patient_id, c.patient_id) = m.patient_id
)

SELECT * FROM combined
