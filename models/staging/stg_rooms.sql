{{ config(
    materialized='incremental',
    unique_key='room_id',
    incremental_strategy='merge'
) }}


SELECT

    _id AS room_id,

    propertyId AS property_id,

    TRIM(room_number) AS room_number,

    LOWER(type) AS room_type,

    updatedAt AS updated_at,

    deletedAt AS deleted_at,
    
    CASE 
        WHEN deletedAt IS NOT NULL THEN 1 
        ELSE 0 
    END AS is_deleted,

    CURRENT_TIMESTAMP() AS etl_updated_timestamp


FROM {{ source('raw','raw_rooms') }}

