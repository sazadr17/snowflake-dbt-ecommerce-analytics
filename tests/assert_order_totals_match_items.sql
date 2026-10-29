-- Fails (returns rows) if the source order total differs from the sum of its line items.
select
    o.order_id,
    o.order_total as source_total,
    f.order_total as calculated_total
from {{ ref('stg_orders') }} o
join {{ ref('fct_orders') }} f
    on o.order_id = f.order_id
where o.order_total != f.order_total
