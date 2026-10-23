-- ============================================================
-- rpt_daily_operations
-- Incremental daily operations summary — one row per calendar day.
-- On full-refresh: processes all dates.
-- On incremental: processes from the most recent report_date onward.
-- ============================================================

{{
  config(
    materialized='incremental',
    unique_key='report_date',
    incremental_strategy='merge'
  )
}}

WITH appointment_daily AS (
    SELECT
        appointment_date                            AS report_date,
        COUNT(*)                                    AS total_appointments,
        COUNT_IF(is_completed)                      AS completed_count,
        COUNT_IF(is_cancelled)                      AS cancelled_count,
        COUNT_IF(is_no_show)                        AS no_show_count,
        COUNT_IF(is_emergency)                      AS emergency_count,
        SUM(copay_amount)                           AS total_copay_collected
    FROM {{ ref('stg_appointments') }}

    {% if is_incremental() %}
    WHERE appointment_date >= (SELECT MAX(report_date) FROM {{ this }})
    {% endif %}

    GROUP BY 1
),

claims_daily AS (
    SELECT
        claim_date                                  AS report_date,
        COUNT(*)                                    AS new_claims_filed,
        COUNT_IF(denial_flag)                       AS claims_denied,
        COUNT_IF(claim_status = 'paid')             AS claims_paid,
        COUNT_IF(claim_status = 'pending')          AS claims_pending,
        ROUND(SUM(billed_amount), 2)                AS total_billed,
        ROUND(SUM(paid_amount), 2)                  AS total_paid,
        ROUND(SUM(patient_responsibility), 2)       AS total_patient_responsibility
    FROM {{ ref('stg_claims') }}

    {% if is_incremental() %}
    WHERE claim_date >= (SELECT MAX(report_date) FROM {{ this }})
    {% endif %}

    GROUP BY 1
)

SELECT
    COALESCE(a.report_date, c.report_date)                              AS report_date,

    -- Appointment metrics
    COALESCE(a.total_appointments, 0)                                   AS total_appointments,
    COALESCE(a.completed_count, 0)                                      AS completed_count,
    COALESCE(a.cancelled_count, 0)                                      AS cancelled_count,
    COALESCE(a.no_show_count, 0)                                        AS no_show_count,
    COALESCE(a.emergency_count, 0)                                      AS emergency_count,
    COALESCE(a.total_copay_collected, 0)                                AS total_copay_collected,

    -- Claim metrics
    COALESCE(c.new_claims_filed, 0)                                     AS new_claims_filed,
    COALESCE(c.claims_denied, 0)                                        AS claims_denied,
    COALESCE(c.claims_paid, 0)                                          AS claims_paid,
    COALESCE(c.claims_pending, 0)                                       AS claims_pending,
    COALESCE(c.total_billed, 0)                                         AS total_billed,
    COALESCE(c.total_paid, 0)                                           AS total_paid,
    COALESCE(c.total_patient_responsibility, 0)                         AS total_patient_responsibility,

    -- Derived KPIs
    ROUND(
        COALESCE(c.claims_denied, 0) / NULLIF(COALESCE(c.new_claims_filed, 0), 0),
    4)                                                                  AS denial_rate,
    ROUND(
        COALESCE(a.no_show_count, 0) / NULLIF(COALESCE(a.total_appointments, 0), 0),
    4)                                                                  AS no_show_rate,
    ROUND(
        COALESCE(c.total_paid, 0) / NULLIF(COALESCE(c.total_billed, 0), 0),
    4)                                                                  AS payment_rate,
    CURRENT_TIMESTAMP()                                                 AS updated_at

FROM appointment_daily a
FULL OUTER JOIN claims_daily c
    ON a.report_date = c.report_date
