-- Fails if the join ever fans out (more than one row per grain)
   select activity_date, sku_id, dc_id, count(*) as row_count
   from {{ ref('fct_inventory_health') }}
   group by activity_date, sku_id, dc_id
   having count(*) > 1