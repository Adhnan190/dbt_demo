SELECT
    medication_id,
    patient_id,
    provider_id,
    drug_name,
    drug_class,
    dosage,
    frequency,
    start_date,
    end_date,
    is_active,
    refill_count,
    days_supply,
    pharmacy,
    created_at,
    drug_class IN (
        'Statin','ACE Inhibitor','ARB','Beta Blocker','Antidiabetic','Thyroid'
    )                                                                   AS is_chronic,
    DATEDIFF('day', start_date, COALESCE(end_date, CURRENT_DATE()))     AS duration_days,
    DATEDIFF('day', start_date, COALESCE(end_date, CURRENT_DATE())) > 180 AS is_long_term
FROM {{ source('raw', 'medications') }}
