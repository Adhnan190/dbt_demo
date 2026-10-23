SELECT
    appointment_id,
    patient_id,
    provider_id,
    appointment_date,
    appointment_time,
    appointment_date::TIMESTAMP_NTZ
        + appointment_time::TIME                                        AS appointment_datetime,
    appointment_type,
    status,
    status = 'completed'                                                AS is_completed,
    status = 'cancelled'                                                AS is_cancelled,
    status = 'no_show'                                                  AS is_no_show,
    appointment_type = 'Emergency'                                      AS is_emergency,
    duration_mins,
    visit_notes,
    diagnosis_code,
    copay_amount,
    is_billed,
    WEEKOFYEAR(appointment_date)                                        AS week_number,
    TO_CHAR(appointment_date, 'YYYY-MM')                                AS month_year,
    created_at,
    updated_at
FROM {{ source('raw', 'appointments') }}
