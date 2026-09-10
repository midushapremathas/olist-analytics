import pandas as pd
import matplotlib.pyplot as plt
from sqlalchemy import create_engine

engine = create_engine("postgresql+psycopg2://localhost/olist_analytics")

query = """
WITH order_level_reviews AS (
    SELECT
        oc.order_id,
        oc.delay_days,
        AVG(r.review_score) AS review_score
    FROM orders_clean oc
    JOIN olist_order_reviews_dataset r
        ON oc.order_id = r.order_id
    GROUP BY oc.order_id, oc.delay_days
),
bucketed_orders AS (
    SELECT
        CASE
            WHEN delay_days <= 0 THEN 'On time / early'
            WHEN delay_days <= 3 THEN '1-3 days late'
            WHEN delay_days <= 7 THEN '4-7 days late'
            WHEN delay_days <= 14 THEN '8-14 days late'
            ELSE '15+ days late'
        END AS delay_bucket,
        delay_days,
        review_score
    FROM order_level_reviews
)
SELECT
    delay_bucket,
    COUNT(*) AS orders,
    ROUND(AVG(delay_days)::numeric, 2) AS avg_delay_days,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score
FROM bucketed_orders
GROUP BY delay_bucket
ORDER BY
    CASE delay_bucket
        WHEN 'On time / early' THEN 1
        WHEN '1-3 days late' THEN 2
        WHEN '4-7 days late' THEN 3
        WHEN '8-14 days late' THEN 4
        WHEN '15+ days late' THEN 5
    END
"""

df = pd.read_sql(query, engine)

engine.dispose()

print(df.to_string(index=False))

plt.figure(figsize=(10, 6))
plt.bar(df["delay_bucket"], df["avg_review_score"])
plt.xlabel("Delivery delay")
plt.ylabel("Average review score")
plt.title("Customer Review Score Falls as Delivery Delays Increase")
plt.xticks(rotation=20)
plt.ylim(0, 5)
plt.tight_layout()
plt.savefig("outputs/delivery_delay_vs_review_score.png", dpi=300)
plt.show()
