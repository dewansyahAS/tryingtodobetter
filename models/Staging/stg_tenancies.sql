{{ config(
    materialized='incremental',
    unique_key='tenancy_id',
    incremental_strategy='merge'
) }}

SELECT

    _id AS tenancy_id,

    roomId AS room_id,

    tenant_id,

    DATE(checkInDate) AS check_in_date,

    DATE(checkOutDate) AS check_out_date,

    LOWER(TRIM(status)) AS status,

    updatedAt AS updated_at,

    CURRENT_TIMESTAMP() AS etl_updated_timestamp


FROM {{ source('raw','raw_tenancies') }}