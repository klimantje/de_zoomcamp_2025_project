
    
    

with all_values as (

    select
        bike_model as value_field,
        count(*) as n_records

    from `dezoomcamp2025-454617`.`bike_rentals`.`stg_tfl_journeys`
    group by bike_model

)

select *
from all_values
where value_field not in (
    'CLASSIC','PBSC_EBIKE','UNKNOWN'
)


