WITH silver AS (
    SELECT 
        
        ("Start date"::TIMESTAMP)::DATE AS Start_Date,
        ("Start date"::TIMESTAMP)::TIME AS Start_TIME,
        ("End date"::TIMESTAMP)::DATE AS End_Date,
        ("End date"::TIMESTAMP)::TIME AS End_TIME,
        ROUND(CAST(Duration/60 AS FLOAT), 2) AS Duration,
        CAST("Start station number" AS USMALLINT) AS Start_stn_id,
        "Start station" AS Start_stn_name,
        CAST("End station number" AS USMALLINT) AS End_stn_id,
        "End station" AS End_stn_name,
        "Bike number" AS Bike_id,
        "Member type" AS Member_type     
    FROM Bronze
)

SELECT 
    COUNT(*) - COUNT(DISTINCT Start_Date) AS Start_Date,  
    COUNT(*) - COUNT(DISTINCT Start_TIME) AS Start_TIME, 
    COUNT(*) - COUNT(DISTINCT End_Date) AS End_Date, 
    COUNT(*) - COUNT(DISTINCT End_TIME) AS End_TIME, 
    COUNT(*) - COUNT(DISTINCT Duration) AS Duration, 
    COUNT(*) - COUNT(DISTINCT Start_stn_id) AS Start_stn_id, 
    COUNT(*) - COUNT(DISTINCT Start_stn_name) AS Start_stn_name, 
    COUNT(*) - COUNT(DISTINCT End_stn_id) AS End_stn_id, 
    COUNT(*) - COUNT(DISTINCT End_stn_name) AS End_stn_name, 
    COUNT(*) - COUNT(DISTINCT Bike_id) AS Bike_id, 
    COUNT(*) - COUNT(DISTINCT Member_type) AS Member_type 
FROM silver 


