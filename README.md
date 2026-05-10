# Flight Delays & Cancellations — Production-Style Data Warehouse Pipeline ✈️

## Overview
This project takes the [2015 US Flight Delays and Cancellations](https://www.kaggle.com/datasets/usdot/flight-delays) dataset from Kaggle (5.8 million flight records across three CSV files) and uses it as the foundation for a production-style data warehouse pipeline.

The goal is to apply modern data engineering tools and best practices to build a fully layered ELT pipeline, following the Medallion Architecture, from raw ingestion through to business-ready analytical tables. The pipeline is built with data quality testing, workflow orchestration, and containerisation in mind, simulating the kind of data infrastructure you would find in a real production environment.

## Architecture
> Architecture diagram coming soon

The pipeline will follow the Medallion Architecture:
- **Bronze** — raw CSV data ingested into PostgreSQL as-is, no transformation
- **Silver** — staging models built with dbt, cleaning and typing the raw data
- **Gold** — mart models built with dbt, implementing a Star Schema for analytics

### Star Schema ER diagram
<img src="/docs/star-schema-er-diagram.drawio.png" width="480" alt="Star schema ER diagram">

## Data Source
**[2015 Flight Delays and Cancellations](https://www.kaggle.com/datasets/usdot/flight-delays)** — Kaggle

Three CSV files:
- `flights.csv` — 5.8 million flight records including departure/arrival times, delays, and cancellations
- `airlines.csv` — IATA airline codes and carrier names
- `airports.csv` — IATA airport codes, names, locations, and coordinates

## Project Structure
```
flights-prod-style-dwh-pipeline/
│
├── data/
│   └── bronze/
│
├── exploration/
│   ├── inspect_airlines.py
│   ├── inspect_airports.py
│   └── inspect_flights.py
│
├── ingestion/
├── dbt_flights/
├── orchestration/
├── tests/
├── docs/
│
├── requirements.txt
├── .gitignore
└── README.md
```

## Data Exploration Findings
Before writing any pipeline code, I profiled each CSV file to understand the data structure, identify nulls and validate candidate business keys.

**airlines.csv** — 14 carriers, IATA codes are unique with no duplicates or nulls. Clean and ready for dimension modelling.

**airports.csv** — 322 airports, IATA codes are unique. Some nulls present in latitude/longitude columns for a small number of airports.

**flights.csv** — 5.8 million rows, 31 columns. Key findings:
- Cancellation-related columns (`CANCELLATION_REASON`, `AIR_SYSTEM_DELAY` etc) have high null counts as expected — cancelled flights won't have delay values
- `ARRIVAL_DELAY` has nulls for diverted and cancelled flights
- `CANCELLATION_REASON` uses single letter codes (A, B, C, D) that will need decoding in the staging layer
