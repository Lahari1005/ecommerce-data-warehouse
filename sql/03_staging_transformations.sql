-- ============================================================
-- E-Commerce Data Warehouse
-- 03 - Staging Transformations
-- ============================================================

CREATE SCHEMA IF NOT EXISTS staging;


-- ============================================================
-- 1. Staging Orders
-- ============================================================
-- Adds derived metrics for approval and delivery duration.

CREATE TABLE staging.orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    EXTRACT(
        EPOCH FROM (
            order_approved_at - order_purchase_timestamp
        )
    ) / 60 AS approval_delay_minutes,

    EXTRACT(
        EPOCH FROM (
            order_delivered_customer_date - order_purchase_timestamp
        )
    ) / 86400 AS delivery_days

FROM raw.orders;


-- Flag unusually long approval delays.
-- A delay greater than 24 hours is treated as an anomaly.

ALTER TABLE staging.orders
ADD COLUMN approval_delay_anomaly BOOLEAN;

UPDATE staging.orders
SET approval_delay_anomaly =
    CASE
        WHEN approval_delay_minutes > 1440 THEN TRUE
        ELSE FALSE
    END;


-- ============================================================
-- 2. Staging Order Items
-- ============================================================
-- Adds item_total = product price + freight cost.

CREATE TABLE staging.order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    price + freight_value AS item_total

FROM raw.order_items;


-- ============================================================
-- 3. Staging Products
-- ============================================================
-- Adds the English product category name using the
-- category translation table.
--
-- LEFT JOIN is intentional:
-- products without a translation should still remain
-- in the staging layer.

CREATE TABLE staging.products AS
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm

FROM raw.products p

LEFT JOIN raw.category_name_translation t
    ON p.product_category_name =
       t.product_category_name;