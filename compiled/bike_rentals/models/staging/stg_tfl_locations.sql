with source as (
        select * from `dezoomcamp2025-454617`.`bike_rentals`.`raw_locations`
  ),
  renamed as (
      select
        `id` as bike_point_id,
        `name` as location_name,
        `terminalName` as location_id,
        CAST( `long` AS FLOAT64) as longitude,
        CAST( `lat` AS FLOAT64) as lattitude,
        ST_GEOGPOINT(CAST( `long` AS FLOAT64) , CAST( `lat` AS FLOAT64)) as geo_location,
        CAST( `installed` AS BOOL) as is_installed,
        `locked` as is_locked,
       TIMESTAMP_MILLIS(CAST(`installDate` AS INT)) as installed_at,
       TIMESTAMP_MILLIS(CAST(`removalDate` AS INT )) as removed_at,
        `temporary` as is_temporary,
        `nbBikes` as number_of_bikes ,
        `nbStandardBikes` as number_of_standard_bikes,
        `nbEBikes` as number_of_ebikes,
        `nbEmptyDocks` as number_of_empty_docks,
        `nbDocks` as number_of_docks,
       TIMESTAMP_MILLIS(  CAST(`last_updated` AS INT)) as last_updated_at

      from source
  )
  select * from renamed