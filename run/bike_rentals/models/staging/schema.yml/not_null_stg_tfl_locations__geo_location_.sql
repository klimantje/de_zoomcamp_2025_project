select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select `geo_location`
from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_locations`
where `geo_location` is null



      
    ) dbt_internal_test