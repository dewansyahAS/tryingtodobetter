{{ config(
    materialized='incremental',
    unique_key='property_id',
    incremental_strategy='merge'
) }}

SELECT

    _id AS property_id,

    TRIM(name) AS property_name,

    TRIM(city) AS city,

    DATE(lease_start_date) AS lease_start_date,

    DATE(lease_end_date) AS lease_end_date,

    updatedAt AS updated_at,

    deletedAt AS deleted_at,

     CASE 
        WHEN deletedAt IS NOT NULL THEN 1 
        ELSE 0 
    END AS is_deleted,

    CURRENT_TIMESTAMP() AS etl_updated_timestamp


FROM {{ source('raw','raw_properties') }}