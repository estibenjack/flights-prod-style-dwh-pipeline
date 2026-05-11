CREATE TABLE IF NOT EXISTS dim_airlines (
  airline_id SERIAL PRIMARY KEY,
  iata_code varchar(2) UNIQUE NOT NULL,
  airline_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_airports (
  airport_id SERIAL PRIMARY KEY,
  iata_code VARCHAR(3) UNIQUE NOT NULL,
  airport_name TEXT,
  city TEXT,
  state VARCHAR(2),
  country VARCHAR(50),
  latitude FLOAT,
  longitude FLOAT
);

CREATE TABLE IF NOT EXISTS dim_dates (
  date_id SERIAL PRIMARY KEY,
  full_date DATE UNIQUE NOT NULL,
  year INTEGER,
  month INTEGER,
  day INTEGER,
  day_of_week INTEGER,
  quarter INTEGER,
  is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_cancellation_reasons (
  reason_id SERIAL PRIMARY KEY,
  reason_code VARCHAR(1) UNIQUE NOT NULL,
  reason_description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS facts_flights (
  flight_id SERIAL PRIMARY KEY,
  airline_id INTEGER REFERENCES dim_airlines(airline_id),
  date_id INTEGER REFERENCES dim_dates(date_id),
  origin_airport_id INTEGER REFERENCES dim_airports(airport_id),
  destination_airport_id INTEGER REFERENCES dim_airports(airport_id),
  cancellation_reason_id INTEGER REFERENCES dim_cancellation_reasons(reason_id) NULL,
  flight_number VARCHAR(10),
  tail_number VARCHAR(10),
  scheduled_departure INTEGER,
  actual_departure INTEGER,
  departure_delay INTEGER,
  scheduled_arrival INTEGER,
  actual_arrival INTEGER,
  arrival_delay INTEGER,
  elapsed_time INTEGER,
  air_time INTEGER,
  distance INTEGER,
  is_cancelled BOOLEAN,
  is_diverted BOOLEAN,
  departure_delay_flag BOOLEAN,
  arrival_delay_flag BOOLEAN
);