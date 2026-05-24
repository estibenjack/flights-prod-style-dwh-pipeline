{{ config(materialized='view') }}

WITH raw_data AS (
    SELECT * FROM {{ source('bronze', 'raw_flights') }}
),

-- the source data contains a mix of 3-letter IATA codes and 5-digit numeric IDs
-- in the origin/destination columns. numeric IDs have no match in the airports
-- dimension so we exclude them here rather than carry bad keys into the gold layer.
valid_airports AS (
    SELECT *
    FROM raw_data
    WHERE
        origin_airport ~ '^[A-Z]{3}$'
        AND destination_airport ~ '^[A-Z]{3}$'
)

SELECT
    -- date components (joined to dim_dates in gold layer)
    CAST(year AS INT) AS flight_year,
    CAST(month AS INT) AS flight_month,
    CAST(day AS INT) AS flight_day,
    CAST(day_of_week AS INT) AS day_of_week,

    -- identifiers
    airline AS airline_iata_code,
    CAST(flight_number AS INT) AS flight_number,
    tail_number,

    -- airports (guaranteed IATA-only after the filter above)
    origin_airport AS origin_airport_iata,
    destination_airport AS destination_airport_iata,

    -- departure
    CAST(scheduled_departure AS INT) AS scheduled_departure,
    CAST(departure_time AS INT) AS actual_departure,
    CAST(departure_delay AS INT) AS departure_delay,
    CAST(taxi_out AS INT) AS taxi_out,

    -- arrival
    CAST(scheduled_arrival AS INT) AS scheduled_arrival,
    CAST(arrival_time AS INT) AS actual_arrival,
    CAST(arrival_delay AS INT) AS arrival_delay,
    CAST(taxi_in AS INT) AS taxi_in,

    -- flight metrics
    CAST(scheduled_time AS INT) AS scheduled_elapsed_time,
    CAST(elapsed_time AS INT) AS actual_elapsed_time,
    CAST(air_time AS INT) AS air_time,
    CAST(distance AS INT) AS distance,

    -- status flags
    CAST(cancelled AS BOOLEAN) AS is_cancelled,
    CAST(diverted AS BOOLEAN) AS is_diverted,
    departure_delay > 0 AS departure_delay_flag,
    arrival_delay > 0 AS arrival_delay_flag,

    -- delay breakdown by cause (null on non-delayed/cancelled flights)
    CAST(air_system_delay AS INT) AS air_system_delay,
    CAST(security_delay AS INT) AS security_delay,
    CAST(airline_delay AS INT) AS airline_delay,
    CAST(late_aircraft_delay AS INT) AS late_aircraft_delay,
    CAST(weather_delay AS INT) AS weather_delay,

    -- cancellation reason: raw code preserved alongside human-readable label
    cancellation_reason AS cancellation_reason_code,
    CASE cancellation_reason
        WHEN 'A' THEN 'Airline/Carrier'
        WHEN 'B' THEN 'Weather'
        WHEN 'C' THEN 'National Air System'
        WHEN 'D' THEN 'Security'
        ELSE NULL
    END AS cancellation_reason_description

FROM valid_airports