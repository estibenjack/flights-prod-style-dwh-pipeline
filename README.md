# Flight Delays & Cancellations — Production-Style Data Warehouse Pipeline ✈️

## Overview
This project takes the [2015 US Flight Delays and Cancellations](https://www.kaggle.com/datasets/usdot/flight-delays) dataset from Kaggle (5.8 million flight records across three CSV files) and uses it as the foundation for a production-style data warehouse pipeline.

The goal is to apply modern data engineering tools and best practices to build a fully layered ELT pipeline, following the Medallion Architecture, from raw ingestion through to business-ready analytical tables. The pipeline is built with data quality testing, workflow orchestration, and containerisation in mind, simulating the kind of data infrastructure you would find in a real production environment.

## Architecture
> Architecture diagram coming soon

The pipeline follows the Medallion Architecture:
- **Bronze (Raw)** — Data is pulled from an AWS S3 bucket using Python and `boto3`. To handle the large file sizes (5.8M rows) on a local machine, the data is loaded into PostgreSQL in chunks of 100,000 rows at a time. This keeps the machine from running out of memory.
- **Silver (Staging)** — In this step, I'll use dbt to clean up the raw data. This includes fixing mixed-type airport codes and ensuring all columns have the correct data types.
- **Gold (Warehouse)** — The final stage where data is organised into a star schema. This makes the data easier to query for tools like PowerBI or Tableau.

Currently, the PostgreSQL database is containerised with Docker to ensure a consistent environment across different machines. The extraction and loading scripts are running in a local Python environment at the moment, but I'm planning to containerise the full application logic and use Prefect for orchestration in the next phase.

### Data Modelling
<img src="/docs/star-schema-er-diagram.drawio.png" width="480" alt="Star schema ER diagram">

I designed a star schema for the Gold layer to follow industry-standard data warehousing practices. By separating quantitative **Facts** (flight events) from qualitative **Dimensions** (airport and airline context), this design provides several key benefits:

- The `fact_flights` table stays lean, containing only numeric metrics and keys, while descriptive metadata is stored in dedicated dimension tables.
- With 5.8 million records, joining on numeric keys is much faster than scanning a flat CSV.
- This approach follows the "Don't Repeat Yourself" (DRY) principle. If an airport or airline name changes, the update only happens once in a dimension table rather than across millions of flight records.

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
│   └── raw/
│
├── db/
│   ├── bronze_schema.sql
│   └── warehouse_schema.sql
│
├── docs/
│   └── star-schema-er-diagram.drawio.png
│
├── exploration/
│   ├── inspect_airlines.py
│   ├── inspect_airports.py
│   └── inspect_flights.py
│
├── ingestion/
│   └── extract_from_s3.py
│
├── loading/
│   └── load_to_bronze.py
│
├── dbt_flights/
├── orchestration/
├── tests/
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
- `CANCELLATION_REASON` uses single letter codes (A, B, C, D) that will need decoding in the Silver layer
- `ORIGIN_AIRPORT` and `DESTINATION_AIRPORT` contain mixed types (3-letter IATA codes and 5-digit numeric IDs) which will need to be cleaned in the Silver layer
- The file is too large for standard `pd.read_csv` on most local machines - needs chunking
