
    
    

with dbt_test__target as (

  select `bike_point_id` as unique_field
  from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_locations`
  where `bike_point_id` is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


