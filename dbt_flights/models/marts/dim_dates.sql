{{ config(materialized='table') }}

-- date dimension built from the distinct flight dates in the dataset
-- day_of_week: 1=Monday, 7=Sunday (matches the source data encoding)
WITH flight_dates AS (
    SELECT DISTINCT
        MAKE_DATE(flight_year, flight_month, flight_day) AS full_date,
        flight_year                                      AS year,
        flight_month                                     AS month,
        flight_day                                       AS day,
        day_of_week
    FROM {{ ref('stg_flights') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY full_date) AS date_sk,
    full_date,
    year,
    month,
    day,
    day_of_week,
    EXTRACT(QUARTER FROM full_date)::INT   AS quarter,
    day_of_week IN (6, 7)                  AS is_weekend
FROM flight_dates
