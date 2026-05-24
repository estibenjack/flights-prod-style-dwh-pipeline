{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY airport_id) AS airport_sk,
    airport_id                              AS iata_code,
    airport_name,
    city,
    state,
    country,
    latitude,
    longitude
FROM {{ ref('stg_airports') }}
