{{ config(materialized='table', schema='bronze') }}

WITH drift_start AS (
    SELECT start_station_id
    FROM {{ source('bronze', 'trips') }}
    GROUP BY start_station_id
    HAVING COUNT(DISTINCT start_station_name) > 1
),

drift_end AS (
    SELECT end_station_id
    FROM {{ source('bronze', 'trips') }}
    GROUP BY end_station_id
    HAVING COUNT(DISTINCT end_station_name) > 1
)

SELECT t.*
FROM {{ source('bronze', 'trips') }} AS t
WHERE
    NULLIF(TRIM(t.ride_id), '') IS NULL
    OR NULLIF(TRIM(t.rideable_type), '') IS NULL
    OR t.started_at IS NULL
    OR t.ended_at IS NULL
    OR NULLIF(TRIM(t.start_station_name), '') IS NULL
    OR t.start_station_id IS NULL
    OR NULLIF(TRIM(t.end_station_name), '') IS NULL
    OR t.end_station_id IS NULL
    OR t.start_lat IS NULL
    OR t.start_lng IS NULL
    OR t.end_lat IS NULL
    OR t.end_lng IS NULL
    OR NULLIF(TRIM(t.member_casual), '') IS NULL

    OR EXTRACT(EPOCH FROM (t.ended_at::TIMESTAMP - t.started_at::TIMESTAMP)) < 0
    OR EXTRACT(EPOCH FROM (t.ended_at::TIMESTAMP - t.started_at::TIMESTAMP)) / 60 > 500

    OR EXISTS (SELECT 1 FROM drift_start d WHERE d.start_station_id = t.start_station_id)
    OR EXISTS (SELECT 1 FROM drift_end d WHERE d.end_station_id = t.end_station_id)