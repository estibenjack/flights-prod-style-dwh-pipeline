-- staging model for airports

WITH raw_data AS (
  SELECT * FROM {{source('bronze', 'raw_airports')}}
)

SELECT
  CAST(iata_code AS TEXT) AS airport_id,
    CAST(airport AS TEXT) AS airport_name,
    CAST(city AS TEXT) AS city,
    CAST(state AS TEXT) AS state,
    CAST(country AS TEXT) AS country,
    CAST(latitude AS FLOAT) AS latitude,
    CAST(longitude AS FLOAT) AS longitude
FROM raw_data