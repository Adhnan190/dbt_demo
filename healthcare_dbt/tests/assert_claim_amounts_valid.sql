-- ============================================================
-- assert_claim_amounts_valid
-- Fails if any paid claim has paid_amount greater than billed_amount
-- (indicates a data quality error in the source system).
-- ============================================================

SELECT claim_id
FROM {{ ref('fct_claims') }}
WHERE paid_amount > billed_amount
  AND claim_status = 'paid'
