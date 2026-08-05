{{ config(materialized='table', schema='SILVER') }}

SELECT 
    ride_id,
    rideable_type,
    CAST(started_at AS DATETIME) AS start_time,
    CAST(ended_at AS DATETIME) AS end_time,
    CAST(start_station_id AS INT) AS start_stn_id,
    start_station_name AS start_stn_name,
    ROUND(start_lat, 5) AS start_lat,
    ROUND(start_lng, 5) AS start_lng,
    CAST(end_station_id AS INT) AS end_stn_id,
    end_station_name AS end_stn_name, 
    ROUND(end_lat, 5) AS end_lat,
    ROUND(end_lng, 5) AS end_lng,
    member_casual AS rider_type
FROM {{ source('BRONZE', 'raw_trips') }}

WHERE ride_id NOT IN (SELECT ride_id FROM {{ ref('QUARANTINE') }})

    
