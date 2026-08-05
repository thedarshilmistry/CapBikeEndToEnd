/* TODO
    - Add geolocation logic
    - Add distance matrix logic  
*/
{{ config(materialized='table') }}

SELECT 
    DISTINCT(Start_stn_id),
    Start_stn_name
FROM {{ ref('Silver') }}