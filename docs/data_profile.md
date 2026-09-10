# Data Profile

## Dataset Overview

The Olist Brazilian E-Commerce dataset contains nine related tables covering customers, orders, order items, payments, reviews, products, sellers, geolocation, and product category translation.

The raw dataset contains approximately 100,000 orders and multiple related transactional tables.

## Table Sizes

| Table | Rows |
|---|---:|
| olist_customers_dataset | 99,441 |
| olist_geolocation_dataset | 1,000,163 |
| olist_order_items_dataset | 112,650 |
| olist_order_payments_dataset | 103,886 |
| olist_order_reviews_dataset | 99,224 |
| olist_orders_dataset | 99,441 |
| olist_products_dataset | 32,951 |
| olist_sellers_dataset | 3,095 |
| product_category_name_translation | 71 |

## Duplicate Baseline

The raw geolocation table contains 261,831 exact duplicate rows.

The other eight tables contain zero exact duplicate rows.

The order-items composite key `(order_id, order_item_id)` was verified to be unique across all 112,650 rows.

## Missing Values

The main missing-value issues are concentrated in operational timestamps, review text, and product attributes.

### Orders

- `order_approved_at`: 160 missing
- `order_delivered_carrier_date`: 1,783 missing
- `order_delivered_customer_date`: 2,965 missing

### Reviews

- `review_comment_title`: 87,656 missing
- `review_comment_message`: 58,247 missing

### Products

- `product_category_name`: 610 missing
- `product_name_lenght`: 610 missing
- `product_description_lenght`: 610 missing
- `product_photos_qty`: 610 missing
- `product_weight_g`: 2 missing
- `product_length_cm`: 2 missing
- `product_height_cm`: 2 missing
- `product_width_cm`: 2 missing

## Order Status

| Status | Orders |
|---|---:|
| delivered | 96,478 |
| shipped | 1,107 |
| canceled | 625 |
| unavailable | 609 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |

There are 96,476 orders with a recorded customer-delivery timestamp.

## Timeline

Purchase timestamps range from September 4, 2016 to October 17, 2018.

Orders by purchase year:

| Year | Orders |
|---|---:|
| 2016 | 329 |
| 2017 | 45,101 |
| 2018 | 54,011 |

## Customer Identity

The customer table contains 99,441 records but only 96,096 distinct `customer_unique_id` values.

There are 2,997 customers with multiple customer records.

The maximum number of orders associated with one underlying customer is 17.

For customer-level repeat-purchase analysis, `customer_unique_id` should therefore be used rather than `customer_id`.

## Review Structure

There are 547 orders with multiple review records.

The maximum number of reviews associated with one order is three.

A direct order-to-review join can therefore duplicate order-level observations unless reviews are aggregated or otherwise handled deliberately.

## Referential Integrity

The following relationships were checked and contained zero unmatched records:

- orders → customers
- order items → orders
- order items → products
- order items → sellers
- reviews → orders

## Timestamp Quality

The profiling identified:

- 166 orders where the recorded carrier-delivery timestamp occurs before the purchase timestamp.
- 23 orders where the recorded customer-delivery timestamp occurs before the carrier-delivery timestamp.

These records will be documented and handled explicitly during cleaning rather than silently corrected.

## Order and Payment Reconciliation

There are 98,666 distinct orders with order-item records and 99,440 distinct orders with payment records.

One delivered order has no payment record.

For orders with both item and payment records:

- Item value (`price + freight_value`): R$15,843,553.24
- Payment value: R$15,846,280.17
- Difference: R$2,726.93
- Relative difference: approximately 0.017%

There are 381 orders with an absolute difference greater than R$0.01 between item value and payment value.

The largest order-level difference is R$182.81.

The average absolute order-level difference is R$0.03.

These differences will be investigated before using financial measures in the analysis.

## Analytical Implications

The profiling establishes several important rules for later analysis:

1. Customer-level repeat-purchase analysis should use `customer_unique_id`.
2. Order-level metrics must account for the one-to-many relationship between orders and order items.
3. Payment records must be aggregated by `order_id` before order-level financial reconciliation.
4. Reviews require special handling because some orders have multiple review records.
5. Missing delivery timestamps cannot automatically be treated as late deliveries.
6. Timestamp anomalies should be documented and handled explicitly.
7. Financial calculations should distinguish item-level totals from order-level payment totals.
