DROP TABLE IF EXISTS customer_rfm;

CREATE TABLE customer_rfm AS
WITH order_value AS (
    SELECT
        oc.order_id,
        c.customer_unique_id,
        oc.purchase_timestamp,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders_clean oc
    JOIN olist_customers_dataset c
        ON oc.customer_id = c.customer_id
    JOIN olist_order_items_dataset oi
        ON oc.order_id = oi.order_id
    GROUP BY
        oc.order_id,
        c.customer_unique_id,
        oc.purchase_timestamp
),
snapshot AS (
    SELECT MAX(purchase_timestamp) AS snapshot_date
    FROM orders_clean
)
SELECT
    ov.customer_unique_id,
    EXTRACT(DAY FROM (s.snapshot_date - MAX(ov.purchase_timestamp))) AS recency_days,
    COUNT(ov.order_id) AS frequency,
    SUM(ov.order_value) AS monetary
FROM order_value ov
CROSS JOIN snapshot s
GROUP BY
    ov.customer_unique_id,
    s.snapshot_date;


DROP TABLE IF EXISTS customer_rfm_scored;

CREATE TABLE customer_rfm_scored AS
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    CASE
        WHEN recency_days <= 91 THEN 5
        WHEN recency_days <= 176 THEN 4
        WHEN recency_days <= 267 THEN 3
        WHEN recency_days <= 381 THEN 2
        ELSE 1
    END AS recency_score,
    CASE
        WHEN frequency = 1 THEN 1
        WHEN frequency = 2 THEN 2
        WHEN frequency = 3 THEN 3
        WHEN frequency = 4 THEN 4
        ELSE 5
    END AS frequency_score,
    CASE
        WHEN monetary <= 55.24 THEN 1
        WHEN monetary <= 87.35 THEN 2
        WHEN monetary <= 132.64 THEN 3
        WHEN monetary <= 208.54 THEN 4
        ELSE 5
    END AS monetary_score
FROM customer_rfm;


SELECT
    CASE
        WHEN recency_score >= 5 AND frequency_score >= 4 AND monetary_score >= 4
            THEN 'Champions'
        WHEN frequency_score >= 4 OR monetary_score >= 4
            THEN 'Loyal/High Value'
        WHEN recency_score >= 3 AND monetary_score >= 3
            THEN 'Potential'
        WHEN recency_score <= 2 AND monetary_score >= 2
            THEN 'At Risk'
        ELSE 'Low Engagement'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(monetary)::numeric, 2) AS avg_customer_value,
    ROUND(AVG(frequency)::numeric, 2) AS avg_orders,
    ROUND(AVG(recency_days)::numeric, 1) AS avg_recency_days
FROM customer_rfm_scored
GROUP BY customer_segment
ORDER BY customers DESC;


SELECT
    CASE
        WHEN frequency = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(AVG(monetary)::numeric, 2) AS avg_customer_value
FROM customer_rfm_scored
GROUP BY customer_type
ORDER BY customer_type;


WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        oc.purchase_timestamp
    FROM orders_clean oc
    JOIN olist_customers_dataset c
        ON oc.customer_id = c.customer_id
),
first_orders AS (
    SELECT
        customer_unique_id,
        MIN(purchase_timestamp) AS first_purchase
    FROM customer_orders
    GROUP BY customer_unique_id
),
cohort_results AS (
    SELECT
        DATE_TRUNC('month', first_purchase) AS cohort_month,
        COUNT(*) AS cohort_customers,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM customer_orders co
                WHERE co.customer_unique_id = first_orders.customer_unique_id
                  AND co.purchase_timestamp > first_orders.first_purchase
                  AND co.purchase_timestamp <= first_orders.first_purchase + INTERVAL '90 days'
            )
        ) AS retained_customers
    FROM first_orders
    WHERE first_purchase <= DATE '2018-05-31'
    GROUP BY DATE_TRUNC('month', first_purchase)
)
SELECT
    cohort_month,
    cohort_customers,
    retained_customers,
    ROUND(
        (retained_customers::numeric / cohort_customers) * 100,
        2
    ) AS retention_rate_pct
FROM cohort_results
ORDER BY cohort_month;