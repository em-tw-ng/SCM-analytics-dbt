-- Staging: 1:1 with the source, light renaming/typing only. No business logic here.
with source as (

    select * from {{ ref('skus') }}

),

renamed as (

    select
        sku_id,
        sku_name,
        category,
        cast(unit_cost as decimal(10, 2)) as unit_cost

    from source

)

select * from renamed
