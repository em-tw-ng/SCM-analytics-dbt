with source as (

    select * from {{ ref('sales') }}

),

renamed as (

    select
        cast(sale_date as date) as sale_date,
        sku_id,
        dc_id,
        units_sold

    from source

)

select * from renamed
