import duckdb
import os
import io
import os
import requests
import pandas as pd
from google.cloud import storage


duckdb.read_csv("s3://cycling.data.tfl.gov.uk/usage-stats/*2025.csv").to_parquet("/workspaces/de_zoomcamp_2025_project/data/2025_journeys.parquet")

os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="/workspaces/de_zoomcamp_2025_project/.creds/gcp_creds.json"

def upload_to_gcs(bucket, object_name, local_file):
    """
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

upload_to_gcs("bikes_rental_zc", "raw/2025_journeys.parquet",  "/workspaces/de_zoomcamp_2025_project/data/2025_journeys.parquet")