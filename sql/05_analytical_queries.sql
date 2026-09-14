-- ============================================================
-- E-Commerce Data Warehouse
-- 05 - Analytical Queries and Views
-- ============================================================


-- ============================================================
-- 1. Sales Summary
-- ============================================================

SELECT
    SUM(item_total) AS total_item_value,
    SUM(price) AS product_revenue,
    SUM(freight_value) AS freight_revenue
FROM warehouse.fact_order_items;


-- ============================================================
-- 2. Average Order Value
-- ============================================================

SELECT
    SUM(item_total) / COUNT(DISTINCT order_id) AS average_order_value
FROM warehouse.fact_order_items;


-- ============================================================
-- 3. Orders and Items
-- ============================================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_items,
    ROUND(
        COUNT(*)::NUMERIC / COUNT(DISTINCT order_id),
        2
    ) AS average_items_per_order
FROM warehouse.fact_order_items;


-- ============================================================
-- 4. Revenue by Product Category
-- ============================================================

SELECT
    p.product_category_name_english AS category,
    SUM(f.item_total) AS revenue
FROM warehouse.fact_order_items f
JOIN warehouse.dim_product p
    ON f.product_key = p.product_key
GROUP BY p.product_category_name_english
ORDER BY revenue DESC;


-- ============================================================
-- 5. Revenue by Seller
-- ============================================================

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    SUM(f.item_total) AS revenue
FROM warehouse.fact_order_items f
JOIN warehouse.dim_seller s
    ON f.seller_key = s.seller_key
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY revenue DESC;


-- ============================================================
-- 6. Revenue by Customer Location
-- ============================================================

SELECT
    c.customer_city,
    c.customer_state,
    SUM(f.item_total) AS revenue
FROM warehouse.fact_order_items f
JOIN warehouse.dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_city,
    c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 7. Monthly Revenue
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.item_total) AS revenue
FROM warehouse.fact_order_items f
JOIN warehouse.dim_date d
    ON f.purchase_date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


-- ============================================================
-- 8. Order Status Analysis
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM warehouse.order_analysis
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 9. Delivery Performance
-- ============================================================

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    COUNT(*) FILTER (
        WHERE delivery_vs_estimated_days <= 0
    ) AS early_or_on_time,
    COUNT(*) FILTER (
        WHERE delivery_vs_estimated_days > 0
    ) AS late_orders
FROM warehouse.order_analysis
WHERE order_delivered_customer_date IS NOT NULL;


-- ============================================================
-- 10. Payment Method Analysis
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    SUM(payment_value) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM warehouse.payment_analysis
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- 11. Review Score Distribution
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS review_count
FROM warehouse.review_analysis
GROUP BY review_score
ORDER BY review_score;


-- ============================================================
-- 12. Average Review Score
-- ============================================================

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM warehouse.review_analysis;


-- ============================================================
-- 13. Sales Analysis View
-- ============================================================
-- Combines fact and dimension information into an
-- analytics-friendly view used by Power BI.

CREATE OR REPLACE VIEW warehouse.sales_analysis AS
SELECT
    f.order_id,
    f.order_item_id,
    f.price,
    f.freight_value,
    f.item_total,

    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    p.product_category_name_english AS category,

    s.seller_city,
    s.seller_state,

    d.full_date,
    d.year,
    d.month,
    d.month_name,
    d.quarter

FROM warehouse.fact_order_items f

JOIN warehouse.dim_customer c
    ON f.customer_key = c.customer_key

JOIN warehouse.dim_product p
    ON f.product_key = p.product_key

JOIN warehouse.dim_seller s
    ON f.seller_key = s.seller_key

JOIN warehouse.dim_date d
    ON f.purchase_date_key = d.date_key;


-- ============================================================
-- 14. Order Analysis View
-- ============================================================
-- Keeps order-level analysis separate from the item-level
-- fact table.

CREATE OR REPLACE VIEW warehouse.order_analysis AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    EXTRACT(
        EPOCH FROM (
            o.order_delivered_customer_date -
            o.order_purchase_timestamp
        )
    ) / 86400 AS delivery_days,

    EXTRACT(
        EPOCH FROM (
            o.order_delivered_customer_date -
            o.order_estimated_delivery_date
        )
    ) / 86400 AS delivery_vs_estimated_days

FROM raw.orders o;


-- ============================================================
-- 15. Payment Analysis View
-- ============================================================

CREATE OR REPLACE VIEW warehouse.payment_analysis AS
SELECT
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM raw.order_payments;


-- ============================================================
-- 16. Review Analysis View
-- ============================================================

CREATE OR REPLACE VIEW warehouse.review_analysis AS
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_message,
    review_creation_date
FROM raw.order_reviews;


-- ============================================================
-- 17. Order Dimension View
-- ============================================================
-- Provides order-level attributes for Power BI relationships.

CREATE OR REPLACE VIEW warehouse.dim_order AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM raw.orders;