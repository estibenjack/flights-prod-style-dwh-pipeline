CREATE TABLE IF NOT EXISTS raw_airlines(
  iata_code VARCHAR(2),
  airline TEXT,
  loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_airports (
  iata_code VARCHAR(3),
  airport TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  latitude FLOAT,
  longitude FLOAT,
  loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_flights (
  year INTEGER,
  month INTEGER,
  day INTEGER,
  day_of_week INTEGER,
  airline TEXT,
  flight_number INTEGER,
  tail_number TEXT,
  origin_airport TEXT,
  destination_airport TEXT,
  scheduled_departure INTEGER,
  departure_time FLOAT,
  departure_delay FLOAT,
  taxi_out FLOAT,
  wheels_off FLOAT,
  scheduled_time INTEGER,
  elapsed_time FLOAT,
  air_time FLOAT,
  distance INTEGER,
  wheels_on FLOAT,
  taxi_in FLOAT,
  scheduled_arrival INTEGER,
  arrival_time FLOAT,
  arrival_delay FLOAT,
  diverted INTEGER,
  cancelled INTEGER,
  cancellation_reason TEXT,
  air_system_delay FLOAT,
  security_delay FLOAT,
  airline_delay FLOAT,
  late_aircraft_delay FLOAT,
  weather_delay FLOAT,
  loaded_at TIMESTAMP DEFAULT NOW()
);