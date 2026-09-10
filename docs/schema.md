## Analytical Join Considerations

`customer_unique_id` should be used as the customer-level identifier for repeat-purchase analysis because multiple `customer_id` records can belong to the same underlying customer.

Reviews should not be joined to orders without considering multiple review records. A direct join can duplicate order-level observations for the 547 orders with more than one review.

Order items are one-to-many from orders, so order-level revenue calculations must aggregate item rows back to the order level before being combined with order-level metrics.

Payments can also contain multiple rows per order, so payment values should be aggregated by `order_id` before order-level reconciliation.

## Data Quality Findings

The profiling stage identified:

- 166 orders where the recorded carrier-delivery timestamp occurs before the purchase timestamp.
- 23 orders where the recorded customer-delivery timestamp occurs before the carrier-delivery timestamp.
- One delivered order has no payment record.
- 381 orders with both item and payment records have an absolute difference greater than R$0.01 between item value (`price + freight`) and payment value.
- The largest order-level financial difference is R$182.81.
- The average absolute financial difference is R$0.03.

# Database Schema

## Overview

The Olist Brazilian E-Commerce dataset contains nine related tables covering customers, orders, order items, payments, reviews, products, sellers, geolocation, and product category translation.

The core analytical path is:

customers → orders → order_items → products
                    ↓
                 payments
                    ↓
                 reviews

Orders also connect to sellers through order_items.

## Core Tables

### olist_customers_dataset

- Primary key: `customer_id`
- Customer-level identifier: `customer_unique_id`
- One `customer_unique_id` can correspond to multiple `customer_id` records.
- 99,441 rows
- 96,096 distinct `customer_unique_id` values

### olist_orders_dataset

- Primary key: `order_id`
- Foreign key: `customer_id`
- 99,441 rows
- One customer record can have multiple orders.

### olist_order_items_dataset

- Key: `order_id` + `order_item_id`
- Foreign key: `order_id`
- Foreign key: `product_id`
- Foreign key: `seller_id`
- 112,650 rows
- Multiple item rows can belong to the same order.

### olist_order_payments_dataset

- Foreign key: `order_id`
- 103,886 rows
- An order can have multiple payment records.

### olist_order_reviews_dataset

- Foreign key: `order_id`
- 99,224 rows
- Most orders have one review record, but 547 orders have multiple review records.
- One order has a maximum of three review records.

### olist_products_dataset

- Primary key: `product_id`
- 32,951 rows

### olist_sellers_dataset

- Primary key: `seller_id`
- 3,095 rows

### olist_geolocation_dataset

- Geographic reference data keyed by Brazilian zip-code prefix.
- 1,000,163 rows
- Contains 261,831 exact duplicate rows in the raw dataset.

### product_category_name_translation

- Category translation reference table.
- 71 rows

## Key Relationships

```text
olist_customers_dataset
        |
        | customer_id
        |
        v
olist_orders_dataset
        |
        +----------------------+
        |                      |
        | order_id             | order_id
        v                      v
olist_order_items_dataset   olist_order_reviews_dataset
        |
        +------------------+
        |                  |
        | product_id       | seller_id
        v                  v
olist_products_dataset   olist_sellers_dataset

olist_orders_dataset
        |
        | order_id
        v
olist_order_payments_dataset


## Analytical Join Considerations

`customer_unique_id` should be used as the customer-level identifier for repeat-purchase analysis because multiple `customer_id` records can belong to the same underlying customer.

Reviews should not be joined to orders without considering multiple review records. A direct join can duplicate order-level observations for the 547 orders with more than one review.

Order items are one-to-many from orders, so order-level revenue calculations must aggregate item rows back to the order level before being combined with order-level metrics.

Payments can also contain multiple rows per order, so payment values should be aggregated by `order_id` before order-level reconciliation.

## Data Quality Findings

The profiling stage identified:

- 166 orders where the recorded carrier-delivery timestamp occurs before the purchase timestamp.
- 23 orders where the recorded customer-delivery timestamp occurs before the carrier-delivery timestamp.
- One delivered order has no payment record.
- 381 orders with both item and payment records have an absolute difference greater than R$0.01 between item value (`price + freight`) and payment value.
- The largest order-level financial difference is R$182.81.
- The average absolute financial difference is R$0.03.
