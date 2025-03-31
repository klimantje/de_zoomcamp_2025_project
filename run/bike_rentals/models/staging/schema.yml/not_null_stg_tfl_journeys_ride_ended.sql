select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ride_ended
from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys`
where ride_ended is null



      
    ) dbt_internal_test