WITH order_reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score
    FROM olist_order_reviews_dataset
    GROUP BY order_id
),
delivery_review_impact AS (
    SELECT
        CASE
            WHEN oc.delay_days <= 0 THEN 'On time / early'
            WHEN oc.delay_days <= 3 THEN '1-3 days late'
            WHEN oc.delay_days <= 7 THEN '4-7 days late'
            WHEN oc.delay_days <= 14 THEN '8-14 days late'
            ELSE '15+ days late'
        END AS delay_bucket,
        COUNT(*) AS orders_with_reviews,
        AVG(r.average_review_score) AS average_review_score
    FROM orders_clean oc
    JOIN order_reviews r
        ON oc.order_id = r.order_id
    GROUP BY 1
)
SELECT
    delay_bucket,
    orders_with_reviews,
    ROUND(average_review_score, 2) AS average_review_score
FROM delivery_review_impact
ORDER BY
    CASE delay_bucket
        WHEN 'On time / early' THEN 1
        WHEN '1-3 days late' THEN 2
        WHEN '4-7 days late' THEN 3
        WHEN '8-14 days late' THEN 4
        WHEN '15+ days late' THEN 5
    END;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        oc.order_id,
        oc.purchase_timestamp,
        oc.is_late,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY oc.purchase_timestamp, oc.order_id
        ) AS order_number
    FROM orders_clean oc
    JOIN olist_customers_dataset c
        ON oc.customer_id = c.customer_id
),
first_orders AS (
    SELECT
        customer_unique_id,
        purchase_timestamp AS first_order_date,
        is_late AS first_order_late
    FROM customer_orders
    WHERE order_number = 1
),
repeat_90d AS (
    SELECT DISTINCT
        f.customer_unique_id
    FROM first_orders f
    JOIN customer_orders o
        ON f.customer_unique_id = o.customer_unique_id
        AND o.order_number > 1
        AND o.purchase_timestamp > f.first_order_date
        AND o.purchase_timestamp <= f.first_order_date + INTERVAL '90 days'
)
SELECT
    CASE
        WHEN f.first_order_late THEN 'First order late'
        ELSE 'First order on time / early'
    END AS first_order_delivery,
    COUNT(*) AS customers,
    COUNT(r.customer_unique_id) AS repeat_customers_90d,
    ROUND(
        100.0 * COUNT(r.customer_unique_id) / COUNT(*),
        2
    ) AS repeat_rate_90d
FROM first_orders f
LEFT JOIN repeat_90d r
    ON f.customer_unique_id = r.customer_unique_id
WHERE f.first_order_date <= (
    SELECT MAX(purchase_timestamp) FROM orders_clean
) - INTERVAL '90 days'
GROUP BY 1
ORDER BY 1;
