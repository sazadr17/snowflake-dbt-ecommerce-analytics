select
    order_id,
    customer_id,
    order_date,
    lower(status) as status,
    order_total
from {{ ref('raw_orders') }}
