{{ config(materialized='table', schema='silver') }}

SELECT
    ride_id,
    rideable_type,
    started_at::timestamp AT TIME ZONE 'America/New_York' AS start_time,
    ended_at::timestamp AT TIME ZONE 'America/New_York' AS end_time,
    start_station_id::INT AS start_stn_id,
    start_station_name AS start_stn_name,
    ROUND(start_lat::numeric, 5) AS start_lat,
    ROUND(start_lng::numeric, 5) AS start_lng,
    end_station_id::INT AS end_stn_id,
    end_station_name AS end_stn_name,
    ROUND(end_lat::numeric, 5) AS end_lat,
    ROUND(end_lng::numeric, 5) AS end_lng,
    member_casual AS rider_type
FROM {{ source('bronze', 'trips') }}

WHERE NOT EXISTS (
    SELECT 1 FROM {{ ref('QUARANTINE') }} q
    WHERE q.ride_id = trips.ride_id
)