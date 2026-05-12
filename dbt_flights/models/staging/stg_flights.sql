-- staging model for flights

WITH raw_data AS (
  -- pointing to public.raw_flights table
  SELECT * FROM {{source('bronze', 'raw_flights')}}
)

SELECT
  -- identifiers
  CAST(year AS INT) AS flight_year,
  CAST(month AS INT) AS flight_month,
  CAST(day AS INT) AS flight_day,
  airline AS airline_id,
  tail_number,
  flight_number,

  -- origin and destination
  CAST(origin_airport AS TEXT) AS origin_airport_id,
  CAST(destination_airport AS TEXT) AS destination_airport_id,

  -- times and delays
  CAST(departure_delay AS INT) AS departure_delay,
  CAST(arrival_delay AS INT) AS arrival_delay,
  CAST(cancelled AS BOOLEAN) AS is_cancelled,
  cancellation_reason
FROM raw_data