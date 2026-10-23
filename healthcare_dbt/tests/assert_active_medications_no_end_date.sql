-- ============================================================
-- assert_active_medications_no_end_date
-- Fails if a medication is marked active (is_active = TRUE)
-- but has an end_date in the past — indicates a data sync issue
-- between the source system's active flag and the end date field.
-- ============================================================

SELECT medication_id
FROM {{ ref('stg_medications') }}
WHERE is_active = TRUE
  AND end_date IS NOT NULL
  AND end_date < CURRENT_DATE()
