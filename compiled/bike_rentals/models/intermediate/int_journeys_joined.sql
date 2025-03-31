




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
