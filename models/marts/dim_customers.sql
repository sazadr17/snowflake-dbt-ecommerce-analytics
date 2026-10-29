-- One row per customer, with lifetime order metrics and a value segment.
with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date)                              as first_order_date,
        max(order_date)                              as last_order_date,
        count(*)                                     as total_orders,
        count_if(is_completed)                       as completed_orders,
        sum(iff(is_completed, order_total, 0))       as lifetime_revenue
    from orders
    group by customer_id
)

select
    c.customer_id,
    c.first_name || ' ' || c.last_name               as full_name,
    c.email,
    c.city,
    c.signup_date,
    co.first_order_date,
    co.last_order_date,
    coalesce(co.total_orders, 0)                     as total_orders,
    coalesce(co.completed_orders, 0)                 as completed_orders,
    coalesce(co.lifetime_revenue, 0)                 as lifetime_revenue,
    case
        when coalesce(co.lifetime_revenue, 0) >= {{ var('high_value_threshold') }}   then 'high_value'
        when coalesce(co.lifetime_revenue, 0) >= {{ var('medium_value_threshold') }} then 'medium_value'
        when coalesce(co.lifetime_revenue, 0) > 0                                    then 'low_value'
        else 'no_purchases'
    end                                              as customer_segment
from customers c
left join customer_orders co
    on c.customer_id = co.customer_id
