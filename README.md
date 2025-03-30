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







## Technologies used


### Architecture overview:

TODO: insert diagram

### Terraform

IAC

### GCP

- GCS
- BigQuery
- Looker Studio

### DBT

DBT is used for the data transformations in BigQuery. 

The DBT project is explained more [here](./bike_rentals/README.md)

### Kestra





## Datasets used

We used the open [dataset](https://cycling.data.tfl.gov.uk/) which is provided by TfL (Transport London) under a permissive [license](https://tfl.gov.uk/corporate/terms-and-conditions/transport-data-service)

More in detail, we used the journeydata which can be found under the `usage-stats` prefix in the public s3 bucket `s3://cycling.data.tfl.gov.uk`.




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





