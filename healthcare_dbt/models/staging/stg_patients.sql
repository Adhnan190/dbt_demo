SELECT
    patient_id,
    TRIM(INITCAP(first_name))                                           AS first_name,
    TRIM(INITCAP(last_name))                                            AS last_name,
    TRIM(INITCAP(first_name)) || ' ' || TRIM(INITCAP(last_name))       AS full_name,
    date_of_birth::DATE                                                 AS date_of_birth,
    DATEDIFF('year', date_of_birth::DATE, CURRENT_DATE())               AS age_years,
    CASE
        WHEN DATEDIFF('year', date_of_birth::DATE, CURRENT_DATE()) < 18  THEN 'Pediatric'
        WHEN DATEDIFF('year', date_of_birth::DATE, CURRENT_DATE()) < 65  THEN 'Adult'
        ELSE 'Senior'
    END                                                                 AS age_group,
    gender,
    blood_type,
    phone,
    LOWER(email)                                                        AS email,
    city,
    state,
    insurance_provider,
    insurance_id,
    insurance_provider = 'Medicare'                                     AS is_medicare,
    insurance_provider = 'Medicaid'                                     AS is_medicaid,
    is_active,
    registered_at,
    updated_at,
    DATEDIFF('day', registered_at::DATE, CURRENT_DATE())                AS days_since_registration
FROM {{ source('raw', 'patients') }}
