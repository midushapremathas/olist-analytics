# Olist E-Commerce Analytics

## Project Overview

An end-to-end e-commerce analytics project using the Brazilian E-Commerce Public Dataset by Olist.

The project focuses on three business questions around delivery performance, customer value, and seller performance. The analysis uses PostgreSQL and SQL to clean, validate, and analyse approximately 100,000 orders.

## Business Questions

1. What does late delivery actually cost?
2. Which customers are worth keeping?
3. Which sellers are underperforming?

## Key Findings

### 1. Delivery Performance

- 96,470 delivered orders were eligible for delivery-delay analysis.
- 8.11% of eligible orders were delivered late.
- On-time or early orders had an average review score of 4.29.
- Late orders had an average review score of 2.57.
- Review scores declined as delivery delays became more severe.
- 90-day repeat purchase rates were 2.03% for on-time or early orders and 1.82% for late orders. The 0.21 percentage-point difference provides limited evidence of a repeat-purchase effect.

### 2. Customer Value and Retention

- 93,350 unique customers were included in the customer analysis.
- 97.0% of customers made only one purchase.
- Repeat customers generated an average customer value of R$308.53 compared with R$160.73 for one-time customers.
- Repeat customers therefore had approximately 92% higher average customer value.
- RFM segmentation identified Champions, Loyal/High Value, Potential, At Risk, and Low Engagement customers.
- The Potential segment represented the largest share of revenue at 54.43%.
- Cohort analysis showed low 90-day retention across most customer cohorts.

### 3. Seller Performance

- 3,095 sellers were present in the dataset.
- 2,970 sellers had matched orders in the cleaned delivery dataset.
- 425 sellers had at least 50 orders and were used for the main seller performance comparison.
- These sellers had an average late-delivery rate of 7.82% and an average review score of 4.14.
- 114 sellers exceeded the late-delivery baseline while also falling below the review-score baseline.
- These underperforming sellers accounted for 21,443 affected orders and approximately R$2.79 million in revenue.

## Analysis Approach

The project prioritises business interpretation over applying techniques for their own sake.

Key methods include:

- Data profiling and validation
- Referential integrity checks
- Missing-value and duplicate analysis
- Delivery-delay calculation
- Review-score analysis
- Customer RFM segmentation
- One-time versus repeat customer analysis
- Cohort retention analysis
- Seller performance scorecards
- Baseline comparisons
- Sample-size and sensitivity checks

## Technology

- Python
- Pandas
- NumPy
- PostgreSQL
- SQL
- Jupyter
- Git and GitHub
- Power BI

## Dataset

Brazilian E-Commerce Public Dataset by Olist.

The dataset contains approximately 100,000 orders across nine related tables covering customers, orders, order items, payments, reviews, products, sellers, geolocation, and category translations.

Source: Kaggle — Olist

## Project Structure

```text
olist-analytics/
├── data/
│   ├── raw/
│   └── processed/
├── docs/
│   ├── data_profile.md
│   └── schema.md
├── notebooks/
│   └── 01_delivery_impact.py
├── outputs/
│   └── delivery_delay_vs_review_score.png
├── sql/
│   ├── 02_create_orders_clean.sql
│   ├── 03_q1_delivery_impact.sql
│   ├── 04_q2_customer_value.sql
│   └── 05_q3_seller_performance.sql
├── src/
│   └── load_data.py
├── .gitignore
├── README.md
└── requirements.txt

### 3. Seller Performance

- 3,095 sellers were present in the dataset.

- 2,970 sellers had matched orders in the cleaned delivery dataset.

- 425 sellers had at least 50 orders and were used for the main seller performance analysis.

- These sellers had an average late-delivery rate of 7.82% and a median of 6.83%.

- 114 sellers were classified as underperforming, representing 26.82% of sellers with 50+ orders.

- These underperforming sellers accounted for 21,443 affected orders and R$2,785,277.65 in revenue.
