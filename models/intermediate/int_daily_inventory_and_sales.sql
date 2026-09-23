-- Intermediate: one row per sku/dc/day with sales and on-hand joined, plus a
-- trailing-28-day average daily sales window (the building block that
-- fct_inventory_health needs for days-of-supply). Isolated here so the same
-- windowed metric isn't recomputed differently in multiple marts.

with inventory as (

    select * from {{ ref('stg_inventory_snapshot') }}

),

sales as (

    select * from {{ ref('stg_sales') }}

),

joined as (

    select
        inv.snapshot_date as activity_date,
        inv.sku_id,
        inv.dc_id,
        inv.on_hand_qty,
        coalesce(sa.units_sold, 0) as units_sold

    from inventory inv
    left join sales sa
        on sa.sku_id = inv.sku_id
        and sa.dc_id = inv.dc_id
        and sa.sale_date = inv.snapshot_date

),

with_trailing_avg as (

    select
        *,
        avg(units_sold) over (
            partition by sku_id, dc_id
            order by activity_date
            rows between 27 preceding and current row
        ) as avg_daily_sales_28d

    from joined

)

select * from with_trailing_avg
