"""
This is my source-system access layer that will:
- connect to S3 bucket
- retrieve raw data
- load into pandas DataFrames
- return data for loading
"""

import os
from dotenv import load_dotenv
import pandas as pd
import boto3


def extract_csvs_from_s3_bucket():
    # load environment variables
    load_dotenv()

    s3_bucket_name = os.getenv("S3_BUCKET_NAME")
    aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
    aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
    region_name = os.getenv("AWS_REGION_NAME")

    # create boto3 S3 client
    s3 = boto3.client('s3',
                      aws_access_key_id=aws_access_key_id,
                      aws_secret_access_key=aws_secret_access_key,
                      region_name=region_name
                      )

    # read airports object from bucket and load into pandas dataframe
    response = s3.get_object(Bucket=s3_bucket_name, Key="raw/airports.csv")
    airports_df = pd.read_csv(response['Body'])

    # read airlines object from bucket and load into pandas df
    response = s3.get_object(Bucket=s3_bucket_name, Key="raw/airlines.csv")
    airlines_df = pd.read_csv(response['Body'])

    # read flights obj from bucket and load as chunked iterator
    response = s3.get_object(Bucket=s3_bucket_name, Key="raw/flights.csv")
    flights_chunks = pd.read_csv(response['Body'], chunksize=100000)

    # return dictionary of dataframes
    return {
        'airports': airports_df,
        'airlines': airlines_df,
        'flights_chunks': flights_chunks
    }


if __name__ == "__main__":
    data = extract_csvs_from_s3_bucket()

    airports_df = data['airports']
    airlines_df = data['airlines']
    flights_first_chunk = next(iter(data['flights_chunks']))

    # print head()/shape() for airports and airlines df, and flights first chunk
    print("\n== AIRPORTS HEAD ==")
    print(airports_df.head())
    print("\n== AIRPORTS SHAPE ==")
    print(airports_df.shape)

    print("\n== AIRLINES HEAD ==")
    print(airlines_df.head())
    print("\n== AIRLINES SHAPE ==")
    print(airlines_df.shape)

    print("\n== FLIGHTS HEAD ==")
    print(flights_first_chunk.head())
    print("\n== FLIGHTS SHAPE ==")
    print(flights_first_chunk.shape)
