{{ config(materialized='table') }}

-- hard-coded lookup for the four cancellation reason codes
SELECT
    ROW_NUMBER() OVER (ORDER BY reason_code) AS cancellation_reason_sk,
    reason_code,
    reason_description
FROM (
    VALUES
        ('A', 'Airline/Carrier'),
        ('B', 'Weather'),
        ('C', 'National Air System'),
        ('D', 'Security')
) AS t(reason_code, reason_description)
