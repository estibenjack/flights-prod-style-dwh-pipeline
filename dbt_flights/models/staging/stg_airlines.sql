-- staging model for airlines

WITH raw_data AS (
    SELECT * FROM {{source('bronze', 'raw_airlines')}}
)

SELECT
    CAST(iata_code AS TEXT) AS airline_id,
    CAST(airline AS TEXT) AS airline_name
FROM raw_data