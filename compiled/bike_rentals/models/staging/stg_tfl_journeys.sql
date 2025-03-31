


with source as (
        select * from `dezoomcamp2025-454617`.`bike_rentals`.`raw_journeys`
  ),
  renamed as (
  select
      rental_id,
      bike_id,
      COALESCE(bike_model, 'UNKNOWN') as bike_model,
      start_station_id,
      start_station,
      end_station_id,
      end_station, 
      start_date,
      end_date,
      
    CASE
        WHEN REGEXP_CONTAINS(start_date, r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") THEN PARSE_TIMESTAMP("%Y-%m-%d %H:%M:%S", start_date)
        WHEN REGEXP_CONTAINS(start_date, r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}") THEN PARSE_TIMESTAMP("%Y-%m-%d %H:%M", start_date)
        WHEN REGEXP_CONTAINS(start_date, r"\d{2}/\d{2}/\d{4} \d{2}:\d{2}") THEN PARSE_TIMESTAMP("%d/%m/%Y %H:%M", start_date)
        WHEN REGEXP_CONTAINS(start_date, r"\d{4}/\d{2}/\d{2}") THEN PARSE_TIMESTAMP("%Y/%m/%d", start_date)
        ELSE NULL
    END
 as ride_started,
      
    CASE
        WHEN REGEXP_CONTAINS(end_date, r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") THEN PARSE_TIMESTAMP("%Y-%m-%d %H:%M:%S", end_date)
        WHEN REGEXP_CONTAINS(end_date, r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}") THEN PARSE_TIMESTAMP("%Y-%m-%d %H:%M", end_date)
        WHEN REGEXP_CONTAINS(end_date, r"\d{2}/\d{2}/\d{4} \d{2}:\d{2}") THEN PARSE_TIMESTAMP("%d/%m/%Y %H:%M", end_date)
        WHEN REGEXP_CONTAINS(end_date, r"\d{4}/\d{2}/\d{2}") THEN PARSE_TIMESTAMP("%Y/%m/%d", end_date)
        ELSE NULL
    END
 as ride_ended,
      CAST(CAST(total_duration_ms AS INT)/60000 AS INT) as trip_duration_mins
  from source 
  )
select * from renamed
   

    -- recalculate latest day's data + previous
    -- NOTE: The _dbt_max_partition variable is used to introspect the destination table
    where date(ride_started) >= date_sub(date(_dbt_max_partition), interval 1 month)
    