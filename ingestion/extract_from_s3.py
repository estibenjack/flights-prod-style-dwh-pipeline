"""
This is my source-system access layer that will:
- connect to S3 bucket
- download raw CSV files to the local /data/raw directory
"""

import os
import boto3
from dotenv import load_dotenv


def extract_from_s3():
    # load environment variables
    load_dotenv()

    s3_bucket_name = os.getenv("S3_BUCKET_NAME")
    aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
    aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
    region_name = os.getenv("AWS_REGION_NAME")

    # create boto3 S3 client with IAM credentials
    s3 = boto3.client('s3',
                      aws_access_key_id=aws_access_key_id,
                      aws_secret_access_key=aws_secret_access_key,
                      region_name=region_name
                      )

    # list of files to retrieve from the 'raw/' folder in S3
    files = [
        "airports.csv",
        "airlines.csv",
        "flights.csv"
    ]

    # create local staging directory if it doesn't already exist
    os.makedirs("data/raw", exist_ok=True)

    for file in files:
        s3_key = f"raw/{file}"
        local_path = f"data/raw/{file}"

        # s3.download_file works better here bc it uses managed multi-part threading for large files
        print(f"Downloading {file}...")
        s3.download_file(s3_bucket_name, s3_key, local_path)

    print("Extracction complete")


if __name__ == "__main__":
    extract_from_s3()
