select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select rental_id
from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys`
where rental_id is null



      
    ) dbt_internal_test