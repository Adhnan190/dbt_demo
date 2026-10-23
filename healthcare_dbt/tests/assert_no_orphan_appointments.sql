-- ============================================================
-- assert_no_orphan_appointments
-- Fails if any appointment references a patient_id that does not
-- exist in dim_patients (referential integrity check).
-- ============================================================

SELECT a.appointment_id
FROM {{ ref('fct_appointments') }} a
LEFT JOIN {{ ref('dim_patients') }} p
    ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL
