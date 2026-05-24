{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY airline_id) AS airline_sk,
    airline_id                              AS iata_code,
    airline_name
FROM {{ ref('stg_airlines') }}
