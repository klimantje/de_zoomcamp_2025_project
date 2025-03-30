terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
# Credentials only needs to be set if you do not have the GOOGLE_APPLICATION_CREDENTIALS set
    credentials = ".creds/gcp_creds.json"
}

resource "google_storage_bucket" "data-lake-bucket" {
  name          = "bikes_rental_zc"
  project    = "dezoomcamp2025-454617"
  location      = "europe-west4"

  # Optional, but recommended settings:
  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  // days
    }
  }

  force_destroy = true
}


resource "google_bigquery_dataset" "dataset" {
  dataset_id = "bike_rentals"
  project    = "dezoomcamp2025-454617"
  location   = "EU"
}


# This creates a BigQuery table with partitioning 
resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  project    = "dezoomcamp2025-454617"
  table_id   = "raw_journeys"

  external_data_configuration {
    # This defines an external data configuration for the BigQuery table
    # that reads Parquet data from the raw directory of our
    # Google Cloud Storage bucket.
    autodetect    = false
    source_format = "PARQUET"
    source_uris   = ["gs://bikes_rental_zc/raw/journeys/*.parquet"]
    hive_partitioning_options {
      mode              = "CUSTOM"
      source_uri_prefix = "gs://bikes_rental_zc/raw/journeys/{dt:STRING}"
    }
    schema = <<EOF
    [
    {
        "name": "rental_id",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Unique identifier for the rental"
    },
    {
        "name": "bike_id",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Unique identifier for the rental"
    },
    {
        "name": "bike_model",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    },
        {
        "name": "start_station_id",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    },
        {
        "name": "start_station",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    },
    {
        "name": "end_station_id",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    },
    {
        "name": "end_station",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    },
        {
        "name": "start_date",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    },
        {
        "name": "end_date",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    },
    {
        "name": "total_duration_ms",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Indicates type of bike"
    }
    ]
    EOF
  }

  

}


resource "google_bigquery_table" "locations" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  project    = "dezoomcamp2025-454617"
  table_id   = "raw_locations"
  
  external_data_configuration {
    # This defines an external data configuration for the BigQuery table
    # that reads Parquet data from the raw directory of our
    # Google Cloud Storage bucket.
    autodetect    = false
    source_format = "PARQUET"
    source_uris   = ["gs://bikes_rental_zc/raw/locations/*.parquet"]
    

  }
  
}