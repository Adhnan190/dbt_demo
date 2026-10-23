SELECT
    provider_id,
    full_name,
    specialty,
    department,
    npi_number,
    hospital,
    years_experience,
    is_active,
    joined_date,
    created_at,
    CASE
        WHEN years_experience < 5   THEN 'Junior'
        WHEN years_experience < 15  THEN 'Mid'
        ELSE 'Senior'
    END                                                                 AS experience_tier,
    CASE
        WHEN specialty IN ('Cardiology', 'Orthopedics', 'Oncology')             THEN 'Surgical'
        WHEN specialty IN ('Neurology', 'General Practice', 'Pediatrics',
                           'Dermatology', 'Emergency Medicine')                 THEN 'Medical'
        WHEN specialty IN ('Radiology')                                         THEN 'Diagnostic'
        WHEN specialty IN ('Psychiatry')                                        THEN 'Mental Health'
        ELSE 'Primary Care'
    END                                                                 AS specialty_group
FROM {{ source('raw', 'providers') }}
