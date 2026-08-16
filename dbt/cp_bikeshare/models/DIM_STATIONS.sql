{{ config(materialized='table', schema='gold') }}

WITH all_stations AS (
    SELECT 
        start_stn_id AS stn_id, 
        start_stn_name AS stn_name,
        start_lat AS lat, 
        start_lng AS lng
    FROM {{ ref('trips') }}
    WHERE start_stn_id IS NOT NULL

    UNION ALL

    SELECT 
        end_stn_id AS stn_id, 
        end_stn_name AS stn_name, 
        end_lat AS lat, 
        end_lng AS lng
    FROM {{ ref('trips') }}
    WHERE end_stn_id IS NOT NULL
)

SELECT DISTINCT ON (stn_id)
    stn_id, 
    stn_name, 
    lat, 
    lng
FROM all_stations
ORDER BY stn_id DESC