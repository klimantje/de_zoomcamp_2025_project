with source as (
        select * from {{ source('tfl', 'journeys') }}
  ),
  renamed as (
      select *
          

      from source
  )
  select * from renamed
    