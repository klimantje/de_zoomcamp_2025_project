select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select `location_lattitude`
from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_locations`
where `location_lattitude` is null



      
    ) dbt_internal_test