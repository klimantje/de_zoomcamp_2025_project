
   
      -- generated script to merge partitions into `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined`
      declare dbt_partitions_for_replacement array<timestamp>;

      
      
       -- 1. create a temp table with model data
        declare _dbt_max_partition timestamp default (
      select max(ride_started) from `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined`
      where ride_started is not null
    );
  
    

    create or replace table `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined__dbt_tmp`
      
    partition by timestamp_trunc(ride_started, day)
    

    OPTIONS(
      expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 12 hour)
    )
    as (
      




with journeys as (
  select * from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys` 
  ),
locations as (select * from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_locations`),
journeys_start as
(select 
journeys.rental_id, 
journeys.bike_id, 
journeys.bike_model, 
journeys.ride_started, 
journeys.ride_ended, 
journeys.trip_duration_mins,
journeys.end_station_id,
journeys.end_station,
COALESCE(locations.location_id, journeys.start_station_id) as start_station_id, 
COALESCE(locations.location_name, journeys.start_station) as start_station,
locations.bike_point_id as start_bike_point_id, 
locations.geo_location as start_geo_location,
locations.longitude as start_longitude,
locations.lattitude as start_lattitude

from 
journeys left join locations
on (journeys.start_station_id = locations.location_id
or journeys.start_station_id = locations.bike_point_id
or LPAD(journeys.start_station_id, 6, '0') = locations.location_id)
OR journeys.start_station = locations.location_name),
journeys_complete as (
select 
journeys_start.rental_id, 
journeys_start.bike_id, 
journeys_start.bike_model, 
journeys_start.ride_started, 
journeys_start.ride_ended,  
journeys_start.trip_duration_mins,
journeys_start.start_station_id,
journeys_start.start_station,
journeys_start.start_bike_point_id,
journeys_start.start_geo_location,
journeys_start.start_longitude,
journeys_start.start_lattitude,
COALESCE(locations.location_id, journeys_start.end_station_id) as end_station_id, 
COALESCE(locations.location_name, journeys_start.end_station) as end_station,
locations.bike_point_id as end_bike_point_id, 
locations.geo_location as end_geo_location,
locations.longitude as end_longitude,
locations.lattitude as end_lattitude
from journeys_start
left join locations
on (journeys_start.end_station_id = locations.location_id
or journeys_start.end_station_id = locations.bike_point_id
or LPAD(journeys_start.end_station_id, 6, '0') = locations.location_id
or journeys_start.end_station = locations.location_name)
)
select 
rental_id,
bike_id,
bike_model,
ride_started,
ride_ended,
trip_duration_mins,
start_station_id,
start_station,
start_bike_point_id,
start_geo_location,
end_station_id,
end_station,
end_bike_point_id,
end_geo_location,
ROUND(ST_DISTANCE(start_geo_location, end_geo_location) ) as trip_distance_in_meters
from journeys_complete


-- recalculate latest day's data + previous
-- NOTE: The _dbt_max_partition variable is used to introspect the destination table
where date(ride_started) >= date_sub(date(_dbt_max_partition), interval 1 month)

    );
  
      -- 2. define partitions to update
      set (dbt_partitions_for_replacement) = (
          select as struct
              -- IGNORE NULLS: this needs to be aligned to _dbt_max_partition, which ignores null
              array_agg(distinct timestamp_trunc(ride_started, day) IGNORE NULLS)
          from `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined__dbt_tmp`
      );

      -- 3. run the merge statement
      

    merge into `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined` as DBT_INTERNAL_DEST
        using (
        select
        * from `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined__dbt_tmp`
      ) as DBT_INTERNAL_SOURCE
        on FALSE

    when not matched by source
         and timestamp_trunc(DBT_INTERNAL_DEST.ride_started, day) in unnest(dbt_partitions_for_replacement) 
        then delete

    when not matched then insert
        (`rental_id`, `bike_id`, `bike_model`, `ride_started`, `ride_ended`, `trip_duration_mins`, `start_station_id`, `start_station`, `start_bike_point_id`, `start_geo_location`, `end_station_id`, `end_station`, `end_bike_point_id`, `end_geo_location`, `trip_distance_in_meters`)
    values
        (`rental_id`, `bike_id`, `bike_model`, `ride_started`, `ride_ended`, `trip_duration_mins`, `start_station_id`, `start_station`, `start_bike_point_id`, `start_geo_location`, `end_station_id`, `end_station`, `end_bike_point_id`, `end_geo_location`, `trip_distance_in_meters`)

;

      -- 4. clean up the temp table
      drop table if exists `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined__dbt_tmp`

  


  

    