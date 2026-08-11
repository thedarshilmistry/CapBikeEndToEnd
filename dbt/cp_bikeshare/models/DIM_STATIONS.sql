{{ config(materialized='table', schema='gold') }}

SELECT DISTINCT ON (start_stn_id)
    start_stn_id AS stn_id,
    start_stn_name AS stn_name,
    start_lat AS lat,
    start_lng AS lng
FROM {{ ref('trips') }}
WHERE start_stn_id IS NOT NULL
ORDER BY start_stn_id, start_time DESC