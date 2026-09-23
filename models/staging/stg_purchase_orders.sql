with source as (

    select * from {{ ref('purchase_orders') }}

),

renamed as (

    select
        po_id,
        vendor_id,
        sku_id,
        dc_id,
        cast(order_date as date) as order_date,
        cast(expected_date as date) as expected_date,
        cast(received_date as date) as received_date,
        expected_qty,
        received_qty,
        -- derived flags kept in staging since they describe *this* row, not a business aggregate
        received_date <= expected_date as was_on_time,
        received_qty < expected_qty as was_short_shipped

    from source

)

select * from renamed
