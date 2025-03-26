# %%
import duckdb
import boto3
import pandas as pd
import datetime
import re
import logging

def get_files_dict():
    s3 = boto3.client('s3', aws_access_key_id='', aws_secret_access_key='')
    s3._request_signer.sign = (lambda *args, **kwargs: None)


    response = s3.list_objects_v2(
        Bucket='cycling.data.tfl.gov.uk',
        Prefix='usage-stats',

    )
    return response["Contents"]


columns_mapping={
 "bike_number": "bike_id",
 'duration': "total_duration_ms",
 'end_station_number': "end_station_id",
 'endstation_id': "end_station_id",
 'endstation_name': "end_station",
 'number': "rental_id",
 'start_station_number': "start_station_id",
 'startstation_id': "start_station_id",
 'startstation_name': "start_station"

}
final_cols = ["rental_id", "bike_id", "bike_model", "start_station_id", "start_station", "end_station_id", "end_station", "start_date", "end_date", "total_duration_ms"]

# %%



def clean_file(file_path:str, parquet_path:str):
    logger.info(f"ingesting {file_path}")
    raw_df = duckdb.read_csv(file_path, normalize_names=True)
    if 'duration' in raw_df.columns:
        raw_df = duckdb.sql("select * REPLACE duration*1000 as duration from raw_df")
    to_map = {x:y for x,y in columns_mapping.items() if x in raw_df.columns}
    to_map_str = ', '.join([f"{x} as {y}" for x,y in to_map.items()])
    df_cleaned = duckdb.sql(f"select * RENAME ({to_map_str}) from raw_df")
    logger.info(f"writing {parquet_path}")
    cols_to_select = [col for col in final_cols if col in df_cleaned.columns]
    df_cleaned.select(",".join(cols_to_select)).write_parquet(parquet_path, overwrite=True)
    

# %%
def clean_and_write_files():
    pattern= re.compile(r'usage-stats/.*Journey.*Data.*.csv')
    files_dict = get_files_dict()
    for file in files_dict:
        logger.info(file)
        if pattern.match(file["Key"]) and file["LastModified"].year>2020:
            file_key = file["Key"]
            csv_path = f"s3://cycling.data.tfl.gov.uk/{file_key}"
            parquet_path = f"./data/{file_key}".replace(".csv", ".parquet")
            clean_file(csv_path, parquet_path)
    

# %%
if __name__ == '__main__':
    logger = logging.Logger("ingestion", level="INFO")
    clean_and_write_files()



