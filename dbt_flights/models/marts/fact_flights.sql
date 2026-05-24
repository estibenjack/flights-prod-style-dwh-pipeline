{{ config(materialized='table') }}

WITH flights AS (
    SELECT * FROM {{ ref('stg_flights') }}
),

airlines AS (
    SELECT airline_sk, iata_code FROM {{ ref('dim_airlines') }}
),

airports AS (
    SELECT airport_sk, iata_code FROM {{ ref('dim_airports') }}
),

dates AS (
    SELECT date_sk, full_date FROM {{ ref('dim_dates') }}
),

cancellation_reasons AS (
    SELECT cancellation_reason_sk, reason_code FROM {{ ref('dim_cancellation_reasons') }}
)

SELECT
    a.airline_sk AS airline_id,
    d.date_sk AS date_id,
    orig.airport_sk AS origin_airport_id,
    dest.airport_sk AS destination_airport_id,
    cr.cancellation_reason_sk AS cancellation_reason_id,
    f.flight_number,
    f.tail_number,
    f.scheduled_departure,
    f.actual_departure,
    f.departure_delay,
    f.scheduled_arrival,
    f.actual_arrival,
    f.arrival_delay,
    f.actual_elapsed_time AS elapsed_time,
    f.air_time,
    f.distance,
    f.is_cancelled,
    f.is_diverted,
    f.departure_delay_flag,
    f.arrival_delay_flag
FROM flights f
INNER JOIN airlines a
    ON f.airline_iata_code = a.iata_code
INNER JOIN airports orig
    ON f.origin_airport_iata = orig.iata_code
INNER JOIN airports dest
    ON f.destination_airport_iata = dest.iata_code
INNER JOIN dates d
    ON MAKE_DATE(f.flight_year, f.flight_month, f.flight_day) = d.full_date
LEFT JOIN cancellation_reasons cr
    ON f.cancellation_reason_code = cr.reason_code
