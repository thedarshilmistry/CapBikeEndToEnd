{{ config(materialized='table') }}

SELECT 
    Start_date,
    Start_time,
    End_Date,
    End_time,
    Duration,
    Start_stn_id AS Start_stn,
    End_stn_id AS End_stn,
    Bike_id,
    Member_type
FROM {{ ref('Silver') }}