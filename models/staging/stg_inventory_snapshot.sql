with source as (

    select * from {{ ref('inventory_snapshot') }}

),

renamed as (

    select
        cast(snapshot_date as date) as snapshot_date,
        sku_id,
        dc_id,
        on_hand_qty

    from source

)

select * from renamed
