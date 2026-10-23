-- ============================================================
-- dim_providers
-- Provider dimension with aggregated appointment stats and
-- workload tier classification.
-- ============================================================

WITH provider_attrs AS (
    SELECT
        provider_id,
        full_name,
        specialty,
        specialty_group,
        department,
        npi_number,
        hospital,
        years_experience,
        experience_tier,
        is_active,
        joined_date,
        created_at
    FROM {{ ref('stg_providers') }}
),

appointment_stats AS (
    SELECT
        provider_id,
        COUNT(*)                                                            AS total_appointments,
        COUNT_IF(is_completed)                                              AS completed_appointments,
        COUNT_IF(is_cancelled)                                              AS cancelled_appointments,
        COUNT_IF(is_no_show)                                                AS no_show_appointments,
        COUNT_IF(is_emergency)                                              AS emergency_appointments,
        ROUND(COUNT_IF(is_completed) / NULLIF(COUNT(*), 0), 4)             AS completion_rate,
        COUNT(DISTINCT appointment_date)                                    AS days_with_appointments,
        ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT appointment_date), 0), 2)   AS avg_appointments_per_day,
        MAX(appointment_date)                                               AS last_appointment_date,
        MIN(appointment_date)                                               AS first_appointment_date
    FROM {{ ref('stg_appointments') }}
    GROUP BY 1
)

SELECT
    p.provider_id,
    p.full_name,
    p.specialty,
    p.specialty_group,
    p.department,
    p.npi_number,
    p.hospital,
    p.years_experience,
    p.experience_tier,
    p.is_active,
    p.joined_date,
    p.created_at,

    -- Appointment volume metrics
    COALESCE(a.total_appointments, 0)           AS total_appointments,
    COALESCE(a.completed_appointments, 0)       AS completed_appointments,
    COALESCE(a.cancelled_appointments, 0)       AS cancelled_appointments,
    COALESCE(a.no_show_appointments, 0)         AS no_show_appointments,
    COALESCE(a.emergency_appointments, 0)       AS emergency_appointments,
    COALESCE(a.completion_rate, 0)              AS completion_rate,
    COALESCE(a.days_with_appointments, 0)       AS days_with_appointments,
    COALESCE(a.avg_appointments_per_day, 0)     AS avg_appointments_per_day,
    a.last_appointment_date,
    a.first_appointment_date,

    -- Workload classification
    CASE
        WHEN COALESCE(a.total_appointments, 0) >= 200  THEN 'High'
        WHEN COALESCE(a.total_appointments, 0) >= 80   THEN 'Medium'
        ELSE 'Low'
    END                                         AS workload_tier

FROM provider_attrs p
LEFT JOIN appointment_stats a
    ON p.provider_id = a.provider_id
