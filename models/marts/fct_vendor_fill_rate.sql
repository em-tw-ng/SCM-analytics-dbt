-- One row per vendor: fill rate and on-time rate over the trailing 90 days
-- of PO activity in the seed data. NULLIF guards divide-by-zero for a
-- vendor with zero expected units in the window.

with purchase_orders as (

    select * from {{ ref('stg_purchase_orders') }}

),

filtered as (

    select *
    from purchase_orders
    where order_date >= (select max(order_date) from purchase_orders) - interval '90 days'

),

aggregated as (

    select
        vendor_id,
        sum(received_qty) as total_received_qty,
        sum(expected_qty) as total_expected_qty,
        sum(received_qty)::decimal / nullif(sum(expected_qty), 0) as fill_rate,
        avg(case when was_on_time then 1 else 0 end) as on_time_rate,
        count(*) as po_line_count

    from filtered
    group by vendor_id

)

select * from aggregated
