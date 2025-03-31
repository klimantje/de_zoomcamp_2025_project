
    
    

with child as (
    select start_station_id as from_field
    from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys`
    where start_station_id is not null
),

parent as (
    select location_id as to_field
    from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_locations`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


