SELECT
    claim_id,
    patient_id,
    provider_id,
    appointment_id,
    claim_date,
    service_date,
    diagnosis_code,
    procedure_code,
    billed_amount,
    allowed_amount,
    paid_amount,
    patient_responsibility,
    claim_status,
    denial_reason,
    insurance_provider,
    days_to_process,
    claim_status = 'denied'                                             AS not_denial_flag,
    ROUND(billed_amount - allowed_amount, 2)                            AS adjustment_amount,
    ROUND(paid_amount / NULLIF(billed_amount, 0), 4)                   AS coverage_rate,
    CASE
        WHEN days_to_process <= 7   THEN 'Fast'
        WHEN days_to_process <= 30  THEN 'Normal'
        ELSE 'Slow'
    END                                                                 AS processing_tier,
    created_at,
    updated_at
FROM {{ source('raw', 'claims') }}
