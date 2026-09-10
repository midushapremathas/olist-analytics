DROP TABLE IF EXISTS seller_scorecard;

CREATE TABLE seller_scorecard AS
WITH order_reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM olist_order_reviews_dataset
    GROUP BY order_id
),
seller_orders AS (
    SELECT
        seller_id,
        order_id,
        SUM(price + freight_value) AS order_revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id, order_id
)
SELECT
    so.seller_id,
    COUNT(*) AS orders,
    SUM(so.order_revenue) AS revenue,
    AVG(CASE WHEN oc.delay_days > 0 THEN 1.0 ELSE 0.0 END) * 100 AS late_rate_pct,
    AVG(orv.review_score) AS avg_review_score
FROM seller_orders so
JOIN orders_clean oc
    ON so.order_id = oc.order_id
LEFT JOIN order_reviews orv
    ON so.order_id = orv.order_id
GROUP BY so.seller_id;

SELECT
    COUNT(*) AS sellers_with_50_plus_orders
FROM seller_scorecard
WHERE orders >= 50;

SELECT
    ROUND(AVG(late_rate_pct)::numeric, 2) AS avg_late_rate_pct,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY late_rate_pct)::numeric,
        2
    ) AS median_late_rate_pct,
    ROUND(AVG(avg_review_score)::numeric, 2) AS avg_review_score
FROM seller_scorecard
WHERE orders >= 50;

SELECT
    seller_id,
    orders,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(late_rate_pct::numeric, 2) AS late_rate_pct,
    ROUND(
        (late_rate_pct - 7.82)::numeric,
        2
    ) AS late_rate_above_baseline_pp,
    ROUND(avg_review_score::numeric, 2) AS avg_review_score,
    ROUND(
        (avg_review_score - 4.14)::numeric,
        2
    ) AS review_vs_baseline
FROM seller_scorecard
WHERE orders >= 50
ORDER BY late_rate_pct DESC, avg_review_score ASC
LIMIT 20;

SELECT
    COUNT(*) AS underperforming_sellers,
    SUM(orders) AS affected_orders,
    ROUND(SUM(revenue)::numeric, 2) AS affected_revenue
FROM seller_scorecard
WHERE orders >= 50
  AND late_rate_pct > 7.82
  AND avg_review_score < 4.14;

SELECT
    COUNT(*) AS total_sellers_50_plus,
    COUNT(*) FILTER (
        WHERE late_rate_pct > 7.82
          AND avg_review_score < 4.14
    ) AS underperforming_sellers,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE late_rate_pct > 7.82
                  AND avg_review_score < 4.14
            )::numeric
            / COUNT(*)
        ) * 100,
        2
    ) AS underperforming_rate_pct
FROM seller_scorecard
WHERE orders >= 50;
