{{ config(materialized='table') }}

SELECT         
    ("Start date"::TIMESTAMP)::DATE AS Start_date,
    ("Start date"::TIMESTAMP)::TIME AS Start_time,
    ("End date"::TIMESTAMP)::DATE AS End_date,
    ("End date"::TIMESTAMP)::TIME AS End_time,
    ROUND(CAST(Duration/60 AS FLOAT), 2) AS Duration,
    CAST("Start station number" AS USMALLINT) AS Start_stn_id,
    "Start station" AS Start_stn_name,
    CAST("End station number" AS USMALLINT) AS End_stn_id,
    "End station" AS End_stn_name,
    "Bike number" AS Bike_id,
    "Member type" AS Member_type     
FROM "bikeshare"."main"."bronze"