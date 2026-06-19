
{{ config(
    materialized='incremental',
    unique_key=['room_id', 'date_key'],
    incremental_strategy='merge'
) }}

WITH

all_rooms AS (
    SELECT
        r.room_id,
        r.property_id,
        r.deleted_at        AS room_deleted_at,
        p.deleted_at        AS property_deleted_at
    FROM {{ source('mart','stg_rooms') }} r
    JOIN {{ source('mart','stg_properties') }} p ON p.property_id = r.property_id
),

room_days AS (
    SELECT
        ar.room_id,
        ar.property_id,
        d.date_key,
        d.date_day
    FROM all_rooms ar
    CROSS JOIN {{ source('mart','dim_date') }} d
    WHERE
        (ar.room_deleted_at     IS NULL OR d.date_day < DATE(ar.room_deleted_at))
        AND (ar.property_deleted_at IS NULL OR d.date_day < DATE(ar.property_deleted_at))

),

total_rooms_per_property_day AS (
    SELECT
        property_id,
        date_key,
        COUNT(room_id) AS total_rooms
    FROM room_days
    GROUP BY property_id, date_key
),

room_occupancy AS (
    SELECT
        rm.room_id,
        rm.property_id,
        rm.date_key,
        CASE
            WHEN t.tenancy_id IS NOT NULL THEN 1
            ELSE 0
        END AS is_occupied
    FROM room_days rm
    LEFT JOIN (
        SELECT DISTINCT
            t2.room_id,
            t2.tenancy_id,
            d2.date_key AS dim_date_key
        FROM {{ source('mart','stg_tenancies') }} t2
        JOIN {{ source('mart','dim_date') }}  d2
          ON DATE(t2.check_in_date)  <= d2.date_day
         AND DATE(t2.check_out_date) >  d2.date_day
        WHERE t2.status != 'cancelled'
    ) t ON  t.room_id      = rm.room_id
        AND t.dim_date_key = rm.date_key
)

SELECT
    room_id,
    property_id,
    date_key,
    is_occupied
FROM room_occupancy
ORDER BY property_id, room_id, date_key