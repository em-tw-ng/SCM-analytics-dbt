-- One row per sku/dc/day: in-stock rate (trailing 30d) and days-of-supply
-- (on-hand ÷ trailing-28d avg daily sales). This is the daily-grain fact
-- table an "inventory health" dashboard would query directly.

with daily as (

    select * from {{ ref('int_daily_inventory_and_sales') }}

),

with_in_stock_rate as (

    select
        *,
        avg(case when on_hand_qty > 0 then 1 else 0 end) over (
            partition by sku_id, dc_id
            order by activity_date
            rows between 29 preceding and current row
        ) as in_stock_rate_30d

    from daily

),

final as (

    select
        activity_date,
        sku_id,
        dc_id,
        on_hand_qty,
        units_sold,
        avg_daily_sales_28d,
        in_stock_rate_30d,
        on_hand_qty / nullif(avg_daily_sales_28d, 0) as days_of_supply

    from with_in_stock_rate

)

select * from final
