{{ config(materialized='table') }}

SELECT * FROM read_csv_auto('Data\Raw\202001-capitalbikeshare-tripdata.csv')