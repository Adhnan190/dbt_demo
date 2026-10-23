{% snapshot patients_snapshot %}

{{
  config(
    target_schema='ANALYTICS',
    unique_key='patient_id',
    strategy='timestamp',
    updated_at='updated_at',
  )
}}

SELECT * FROM {{ source('raw', 'patients') }}

{% endsnapshot %}
