{{ config(materialized='table', schema='GOLD') }}

SELECT 
    start_stn_id AS stn_id,
    FIRST(DISTINCT(start_stn_name)) AS stn_name,
    AVG(DISTINCT start_lat) AS lat,
    AVG(DISTINCT start_lng) AS lng
FROM {{ ref('trips') }}
GROUP BY start_stn_id
HAVING COUNT(DISTINCT start_stn_name) = 1
