{{
 config(
   materialized = 'incremental',
   incremental_strategy = 'insert_overwrite',
   unique_key='rental_id',
   partition_by = {
     'field': 'ride_started', 
     'data_type': 'timestamp',
     'granularity': 'day'
   }
 )
}}


with source as (
        select * from {{ source('tfl', 'raw_journeys') }}
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
      {{ string_to_timestamp('start_date')}} as ride_started,
      {{ string_to_timestamp('end_date')}} as ride_ended,
      CAST(CAST(total_duration_ms AS INT)/60000 AS INT) as trip_duration_mins
  from source 
  )
select * from renamed
   {% if is_incremental() %}

    -- recalculate latest day's data + previous
    -- NOTE: The _dbt_max_partition variable is used to introspect the destination table
    where date(ride_started) >= date_sub(date(_dbt_max_partition), interval 1 month)
    {% endif %}