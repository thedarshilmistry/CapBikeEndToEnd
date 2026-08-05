{{ config(materialized='table', schema='SILVER') }}

SELECT * FROM {{ source('BRONZE', 'raw_trips') }} 
    WHERE 
        ride_id IS NULL OR
        rideable_type IS NULL OR
        started_at IS NULL OR
        ended_at IS NULL OR
        start_station_name IS NULL OR
        start_station_id IS NULL OR
        end_station_name IS NULL OR
        end_station_id IS NULL OR
        start_lat IS NULL OR
        start_lng IS NULL OR
        end_lat IS NULL OR
        end_lng IS NULL OR
        member_casual IS NULL

        OR

        date_diff('minute', CAST(started_at AS DATETIME), CAST(ended_at AS DATETIME)) < 0 OR
        date_diff('minute', CAST(started_at AS DATETIME), CAST(ended_at AS DATETIME)) > 500


        