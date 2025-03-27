with source as (
        select * from {{ source('tfl', 'journeys') }}
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
      try_strptime(start_date, ['%d/%m/%Y %H:%M', '%m/%d/%Y %H:%M', '%Y-%m-%d %H:%M:%S']) as ride_started,
      try_strptime(end_date, ['%d/%m/%Y %H:%M', '%m/%d/%Y %H:%M', '%Y-%m-%d %H:%M:%S']) as ride_ended,
      total_duration_ms
  from source 
  )
select * from renamed
    