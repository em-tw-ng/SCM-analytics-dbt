-- One row per SKU: sell-through rate (units sold ÷ units received) and its
-- rank across the catalog, over all seed history. Written with a windowed
-- CTE + outer filter rather than QUALIFY so it runs unchanged on engines
-- that don't support QUALIFY (Snowflake and DuckDB both do, but this keeps
-- the model portable).

with sales as (

    select sku_id, sum(units_sold) as total_units_sold
    from {{ ref('stg_sales') }}
    group by sku_id

),

receipts as (

    select sku_id, sum(received_qty) as total_units_received
    from {{ ref('stg_purchase_orders') }}
    group by sku_id

),

joined as (

    select
        sk.sku_id,
        sk.sku_name,
        sk.category,
        coalesce(sa.total_units_sold, 0) as total_units_sold,
        coalesce(rc.total_units_received, 0) as total_units_received,
        coalesce(sa.total_units_sold, 0)::decimal
            / nullif(rc.total_units_received, 0) as sell_through_rate

    from {{ ref('stg_skus') }} sk
    left join sales sa on sa.sku_id = sk.sku_id
    left join receipts rc on rc.sku_id = sk.sku_id

),

ranked as (

    select
        *,
        rank() over (order by sell_through_rate desc) as sell_through_rank

    from joined

)

select * from ranked
order by sell_through_rank
