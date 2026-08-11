{{ config(materialized='table', schema='gold') }}

SELECT 
    ride_id,
    rideable_type,
    start_time,
    end_time,
    start_stn_id,
    end_stn_id,
    rider_type
FROM {{ ref('trips') }}