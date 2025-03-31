with source as (
        select * from {{ source('tfl', 'raw_locations') }}
  ),
  renamed as (
      select
        {{ adapter.quote("id") }} as bike_point_id,
        {{ adapter.quote("name") }} as location_name,
        {{ adapter.quote("terminalName") }} as location_id,
        CAST( {{ adapter.quote("long") }} AS FLOAT64) as longitude,
        CAST( {{ adapter.quote("lat") }} AS FLOAT64) as lattitude,
        ST_GEOGPOINT(CAST( {{ adapter.quote("long") }} AS FLOAT64) , CAST( {{ adapter.quote("lat") }} AS FLOAT64)) as geo_location,
        CAST( {{ adapter.quote("installed") }} AS BOOL) as is_installed,
        {{ adapter.quote("locked") }} as is_locked,
       TIMESTAMP_MILLIS(CAST({{ adapter.quote("installDate") }} AS INT)) as installed_at,
       TIMESTAMP_MILLIS(CAST({{ adapter.quote("removalDate") }} AS INT )) as removed_at,
        {{ adapter.quote("temporary") }} as is_temporary,
        {{ adapter.quote("nbBikes") }} as number_of_bikes ,
        {{ adapter.quote("nbStandardBikes") }} as number_of_standard_bikes,
        {{ adapter.quote("nbEBikes") }} as number_of_ebikes,
        {{ adapter.quote("nbEmptyDocks") }} as number_of_empty_docks,
        {{ adapter.quote("nbDocks") }} as number_of_docks,
       TIMESTAMP_MILLIS(  CAST({{ adapter.quote("last_updated") }} AS INT)) as last_updated_at

      from source
  )
  select * from renamed
    