-- Daily revenue for completed orders only.
select
    order_date,
    count(*)                                         as completed_orders,
    sum(order_total)                                 as revenue,
    {{ safe_divide('sum(order_total)', 'count(*)') }} as avg_order_value
from {{ ref('fct_orders') }}
where is_completed
group by order_date
