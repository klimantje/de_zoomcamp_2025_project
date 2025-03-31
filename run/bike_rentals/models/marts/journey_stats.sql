
  
    

    create or replace table `dezoomcamp2025-454617`.`bike_rentals`.`journey_stats`
      
    
    

    OPTIONS()
    as (
      with journeys as (
    select * from `dezoomcamp2025-454617`.`bike_rentals`.`int_journeys_joined`
)

select 
start_station_id,
start_station,
end_station_id,
end_station,
bike_model,
timestamp_trunc(
        cast(ride_started as timestamp),
        month
    ) as ride_month, 
avg(trip_distance_in_meters) as average_trip_distance,
avg(trip_duration_mins) as average_trip_duration,
count(rental_id) as total_monthly_trips,
from journeys
group by 1,2,3,4,5,6
    );
  