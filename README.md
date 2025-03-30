# de_zoomcamp_2025_project
Data pipeline for the data engineering zoomcamp project

- [de\_zoomcamp\_2025\_project](#de_zoomcamp_2025_project)
  - [Problem description](#problem-description)
  - [Technologies used](#technologies-used)
    - [Architecture overview:](#architecture-overview)
    - [Terraform](#terraform)
    - [GCP](#gcp)
    - [DBT](#dbt)
    - [Kestra](#kestra)
  - [Datasets used](#datasets-used)
  - [Setup and running the project yourself](#setup-and-running-the-project-yourself)
    - [GCP setup](#gcp-setup)
  - [Next steps and improvements](#next-steps-and-improvements)


## Problem description

This project sets up a datapipeline to analyse Santander bike rentals.

We used the open [dataset](https://cycling.data.tfl.gov.uk/) which is provided by TfL (Transport London) under a permissive [license](https://tfl.gov.uk/corporate/terms-and-conditions/transport-data-service)

Bike journey data is enriched with bike rental locations data to provide insights into the following:

- Duration and distance of bike trips
- Popular stations
- Seasonal patterns
- Rise of electrical bikes

## Technologies used


### Architecture overview:

TODO: insert diagram

### Terraform

We used terraform as IAC to set up the GCS bucket, Bigquery dataset and external tables for the raw source data.

### GCP

- GCS: The TFL journey and bike point data is first saved as parquets to a google cloud storage bucket
- BigQuery: Bigquery is used as the datawarehouse
- Looker Studio: The final dashboard is made in looker studio.

### DBT

DBT is used to structure the data transformations in BigQuery. 

The DBT project is explained more [here](./bike_rentals/README.md)

### Kestra

The whole data pipeline from ingestion to transformations is orchestrated via Kestra.

## Datasets used

We used the open [dataset](https://cycling.data.tfl.gov.uk/) which is provided by TfL (Transport London) under a permissive [license](https://tfl.gov.uk/corporate/terms-and-conditions/transport-data-service)

More in detail, we used the journey data which can be found under the `usage-stats` prefix in the public s3 bucket `s3://cycling.data.tfl.gov.uk`.
Secondly, the [live feed data](https://tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml) of bike locations is ingested to enrich and complete the journey data.

## Setup and running the project yourself

Disclaimer: tested on MAC, not Windows.

- Clone this repository
- Create a virtual environment `virtualenv --clear .venv` 
- Activate and install dependencies `source .venv/bin/activate` & `pip install -r requirements.txt`
- Alternatively, if you prefer running this in a docker container or via VSCode devcontainer, use the included `devcontainer.json`

### GCP setup

- Create a GCP project and service account
- Make sure you store the service account json under `.creds\gcp_creds.json`
- Install terraform 
- Create the bucket, bigquery dataset and external table for the source data with `terraform apply`

Alternatively, you can do the above manually in your GCP console.


## Next steps and improvements

- Currently the pipeline, although using mostly GCP is running from local. 
  - It would be good to deploy this to a Cloud VM.
  - Something like transferservice can be used to transfer the raw files to GCS and perform all the processing there.
- The bike data can be further enriched with e.g. weather data to provide better insights.
- There is also still a lot of other data feeds available on TFL which can be used to extend the pipeline.
- The bike location data is actually streaming, but now only used to periodically update the bike locations.








