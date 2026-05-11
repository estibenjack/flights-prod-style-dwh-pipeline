import os
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import text
from dotenv import load_dotenv


def load_to_bronze():
    load_dotenv()

    # setup conn .env vars
    db = os.getenv("POSTGRES_DB")
    user = os.getenv("POSTGRES_USER")
    password = os.getenv("POSTGRES_PASSWORD")
    host = os.getenv("POSTGRES_HOST")
    port = os.getenv("POSTGRES_PORT")

    conn_str = f"postgresql://{user}:{password}@{host}:{port}/{db}"
    engine = create_engine(conn_str)

    # truncate raw_ tables before doing a fresh load in case a previous load failed half way through
    with engine.begin() as conn:
        print("Clearing raw tables for a fresh load...")
        conn.execute(
            text("TRUNCATE TABLE raw_flights, raw_airports, raw_airlines"))

    # load smaller lookup tables
    print("Loading lookup tables...")
    for table in ['airports', 'airlines']:
        df = pd.read_csv(f"data/raw/{table}.csv")
        # clean column names to match bronze schema
        df.columns = [c.lower() for c in df.columns]
        df.to_sql(f"raw_{table}", engine, if_exists='append', index=False)
        print(f"Successfully loaded {table}")

    # load big flights file in chunks
    print("Loading flights data (chunking)...")
    chunksize = 100000
    flight_chunks = pd.read_csv("data/raw/flights.csv",
                                chunksize=chunksize,
                                dtype={
                                    'ORIGIN_AIRPORT': str,
                                    'DESTINATION_AIRPORT': str,
                                    'CANCELLATION_REASON': str
                                })

    for i, chunk in enumerate(flight_chunks):
        # clean column names to match bronze schema
        chunk.columns = [c.lower() for c in chunk.columns]
        # 'if_exists='append' ' is so we don't delete previous chunks
        chunk.to_sql('raw_flights', engine, if_exists='append', index=False)

        # log process every 100k rows
        print(
            f"Uploaded chunk {i + 1: >3} - ({(i + 1) * chunksize: >10,} rows processed... )")

    print("Load complete")


if __name__ == "__main__":
    load_to_bronze()
