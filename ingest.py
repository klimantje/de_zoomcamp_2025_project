""""
Loading and cleaning of journey data from s3://cycling.data.tfl.gov.uk
Since the data format has changed over the years, we do some renaming of columns and cleaning of milliseconds vs seconds with duckdb.
Files are downloaded and then uploaded to gcs in parquet in partitioned folders.
Loading and cleaning of bike rental locations from https://tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml
These are also uploaded as parquet to gcs.

Run with python ingest.py {trigger_date} to load only s3 files modified after you trigger date.
"""


# %%
import duckdb
import boto3
from botocore.config import Config
import pandas as pd
import re
import logging
import os
from google.cloud import storage
import requests
from lxml import etree
from datetime import datetime
import argparse

GCP_BUCKET = os.environ["GCP_BUCKET"]
GCP_JOURNEYS_PREFIX = "raw/journeys"
GCP_LOCATIONS_PREFIX = "raw/locations/locs.parquet"

def parse_date(date_str):
    """parse date string"""
    if date_str.endswith('Z'):
        return datetime.fromisoformat(date_str.replace('Z', '+00:00'))
    return datetime.fromisoformat(date_str)

def get_files_dict():
    """Retrieve list of files from tfl s3 bucket"""
    s3 = boto3.client("s3", aws_access_key_id="", aws_secret_access_key="")
    s3._request_signer.sign = lambda *args, **kwargs: None

    response = s3.list_objects_v2(
        Bucket="cycling.data.tfl.gov.uk",
        Prefix="usage-stats",
    )
    return response["Contents"]

columns_mapping = {
    "bike_number": "bike_id",
    "duration": "total_duration_ms",
    "end_station_number": "end_station_id",
    "endstation_id": "end_station_id",
    "endstation_name": "end_station",
    "number": "rental_id",
    "start_station_number": "start_station_id",
    "startstation_id": "start_station_id",
    "startstation_name": "start_station",
}
final_cols = [
    "rental_id",
    "bike_id",
    "bike_model",
    "start_station_id",
    "start_station",
    "end_station_id",
    "end_station",
    "start_date",
    "end_date",
    "total_duration_ms",
]

def clean_file(logger, file_path: str, parquet_path: str = None):
    """
    Read the source file in s3, normalize columns and rename where needed.
    Source files do not all have the same format so we do some preprocessing with duckdb    
    """
    raw_df = duckdb.read_csv(
        file_path, normalize_names=True, auto_type_candidates=["VARCHAR"]
    )
    if "duration" in raw_df.columns:
        #duration is in seconds while the others are in milliseconds
        raw_df = duckdb.sql(
            "select * REPLACE ((duration::INT)*1000)::VARCHAR as duration from raw_df"
        )
    to_map = {x: y for x, y in columns_mapping.items() if x in raw_df.columns}
    to_map_str = ", ".join([f"{x} as {y}" for x, y in to_map.items()])
    df_cleaned = duckdb.sql(f"select * RENAME ({to_map_str}) from raw_df")
    logger.info(f"writing {parquet_path}")
    cols_to_select = [col for col in final_cols if col in df_cleaned.columns]
    return df_cleaned.select(",".join(cols_to_select)).write_parquet(
        parquet_path, overwrite=True
    )


# %%
def clean_and_write_files(logger, trigger_date='2020-01-01'):
    """
    Clean files which arrived after trigger date and upload to gcs as parquet
    If no date is provided it will run as of 2020-01-01.
    """
    pattern = re.compile(r"usage-stats/.*Journey.*Data.*.csv")
    files_dict = get_files_dict()
    for file in files_dict:
        last_modified = file["LastModified"]
        compare_date = parse_date(trigger_date).astimezone(last_modified.tzinfo)
        logger.info(f"ingesting {file}")
        if pattern.match(file["Key"]) and file["LastModified"]>compare_date:
            file_key = file["Key"]
            csv_path = f"s3://cycling.data.tfl.gov.uk/{file_key}"
            file_name= file_key.split("/")[-1]
            partition_path = f"dt={last_modified.year}-{last_modified.month:02d}-{last_modified.day:02d}"
            parquet_path = f"./data/{file_name}".replace(".csv", ".parquet")
            clean_file(logger, csv_path, parquet_path)
            print(f"cleaned {file_name}")
            upload_to_gcs(
                GCP_BUCKET,
                f"{GCP_JOURNEYS_PREFIX}/{partition_path}/{file_name}".replace(".csv", ".parquet"),
                parquet_path,
            )
            print(f"uploaded to gcs")


def upload_to_gcs(bucket, object_name, local_file):
    """
    Upload files to gcs bucket
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    """
    # # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # # (Ref: https://github.com/googleapis/python-storage/issues/74)
    # storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    # storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client()
    bucket = client.bucket(bucket)
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)


def ingest_locations(url:str="https://tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml"):
    """
    Ingest bike rental location data from the live feed and upload as parquet to 
    As we don't use the live data, we will also only update this periodically to account for new locations    
    """
    res = requests.get(url)
    locs = res.content
    last_updated = etree.fromstring(locs).attrib.get('lastUpdate')
    df_loc = pd.read_xml(locs, dtype=object)
    df_loc["last_updated"] = last_updated
    df_loc.to_parquet(f"gs://{GCP_BUCKET}/{GCP_LOCATIONS_PREFIX}")


def main():
    """Run ingestion of the bike journey and location data"""
    parser = argparse.ArgumentParser(description='Ingest journey and location data after a given trigger date')
    parser.add_argument('trigger_date', nargs='?', default='2020-01-01', help='Date to compare against in ISO format')
    args = parser.parse_args()    
    logger = logging.Logger("ingestion", level="INFO")
    clean_and_write_files(logger, args.trigger_date)
    ingest_locations()


# %%
if __name__ == "__main__":
    main()