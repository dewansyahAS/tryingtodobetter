{{ config(
    materialized='table'
) }}

SELECT
    CAST(FORMAT_DATE('%Y%m%d', date_day) AS INT64)  AS date_key,  -- YYYYMMDD
    date_day,
    EXTRACT(YEAR  FROM date_day)  AS year,
    EXTRACT(MONTH FROM date_day)  AS month_number,
    EXTRACT(DAY   FROM date_day)  AS day_number,
    CEIL(EXTRACT(MONTH FROM date_day) / 3.0)  AS quarter
FROM UNNEST(
    GENERATE_DATE_ARRAY('2025-01-01', '2026-12-31', INTERVAL 1 DAY)
) AS date_day