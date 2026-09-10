DROP TABLE IF EXISTS orders_clean;

CREATE TABLE orders_clean AS
SELECT
    *,
    order_purchase_timestamp::timestamp AS purchase_timestamp,
    order_approved_at::timestamp AS approved_timestamp,
    order_delivered_carrier_date::timestamp AS delivered_carrier_timestamp,
    order_delivered_customer_date::timestamp AS delivered_customer_timestamp,
    order_estimated_delivery_date::timestamp AS estimated_delivery_timestamp,
    EXTRACT(EPOCH FROM (
        order_delivered_customer_date::timestamp
        - order_purchase_timestamp::timestamp
    )) / 86400.0 AS delivery_days,
    EXTRACT(EPOCH FROM (
        order_delivered_customer_date::timestamp
        - order_estimated_delivery_date::timestamp
    )) / 86400.0 AS delay_days,
    CASE
        WHEN order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp
        THEN TRUE
        ELSE FALSE
    END AS is_late
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
