select
    count(*) as failures,
    count(*) != 0 as should_warn,
    count(*) != 0 as should_error
from (






    select `end_date`
    from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys`
    where `end_date` is null




) as dbt_internal_test
