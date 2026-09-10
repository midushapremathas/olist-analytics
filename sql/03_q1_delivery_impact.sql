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
