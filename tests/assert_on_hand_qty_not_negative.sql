   select *
   from {{ ref('stg_inventory_snapshot') }}
   where on_hand_qty < 0