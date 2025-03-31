
   
      -- generated script to merge partitions into `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys`
      declare dbt_partitions_for_replacement array<timestamp>;

      
      
       -- 1. create a temp table with model data
        declare _dbt_max_partition timestamp default (
      select max(ride_started) from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys`
      where ride_started is not null
    );
  
    

    create or replace table `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys__dbt_tmp`
      
    partition by timestamp_trunc(ride_started, day)
    

    OPTIONS(
      expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 12 hour)
    )
    as (
      


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
    
    );
  
      -- 2. define partitions to update
      set (dbt_partitions_for_replacement) = (
          select as struct
              -- IGNORE NULLS: this needs to be aligned to _dbt_max_partition, which ignores null
              array_agg(distinct timestamp_trunc(ride_started, day) IGNORE NULLS)
          from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys__dbt_tmp`
      );

      -- 3. run the merge statement
      

    merge into `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys` as DBT_INTERNAL_DEST
        using (
        select
        * from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys__dbt_tmp`
      ) as DBT_INTERNAL_SOURCE
        on FALSE

    when not matched by source
         and timestamp_trunc(DBT_INTERNAL_DEST.ride_started, day) in unnest(dbt_partitions_for_replacement) 
        then delete

    when not matched then insert
        (`rental_id`, `bike_id`, `bike_model`, `start_station_id`, `start_station`, `end_station_id`, `end_station`, `start_date`, `end_date`, `ride_started`, `ride_ended`, `trip_duration_mins`)
    values
        (`rental_id`, `bike_id`, `bike_model`, `start_station_id`, `start_station`, `end_station_id`, `end_station`, `start_date`, `end_date`, `ride_started`, `ride_ended`, `trip_duration_mins`)

;

      -- 4. clean up the temp table
      drop table if exists `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys__dbt_tmp`

  


  

    