/* TODO 
    - Add usage logic
    - Add bike types
*/

{{ config(materialized='table') }}

SELECT 
    Distinct(Bike_id)
FROM {{ ref('Silver') }}