-- One row per order, with totals recalculated from the line items.
with orders as (
    select * from {{ ref('stg_orders') }}
),

items as (
    select
        order_id,
        count(*)        as line_count,
        sum(quantity)   as units,
        sum(line_total) as items_total
    from {{ ref('stg_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    coalesce(i.line_count, 0)  as line_count,
    coalesce(i.units, 0)       as units,
    coalesce(i.items_total, 0) as order_total,
    o.status = 'completed'     as is_completed
from orders o
left join items i
    on o.order_id = i.order_id
