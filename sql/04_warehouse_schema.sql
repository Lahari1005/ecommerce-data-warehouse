-- ============================================================
-- E-Commerce Data Warehouse
-- 04 - Warehouse Star Schema
-- ============================================================

CREATE SCHEMA IF NOT EXISTS warehouse;


-- ============================================================
-- 1. Customer Dimension
-- ============================================================

CREATE TABLE warehouse.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id TEXT NOT NULL,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);


-- ============================================================
-- 2. Product Dimension
-- ============================================================

CREATE TABLE warehouse.dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id TEXT NOT NULL,
    product_category_name TEXT,
    product_category_name_english TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);


-- ============================================================
-- 3. Seller Dimension
-- ============================================================

CREATE TABLE warehouse.dim_seller (
    seller_key SERIAL PRIMARY KEY,
    seller_id TEXT NOT NULL,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);


-- ============================================================
-- 4. Date Dimension
-- ============================================================

CREATE TABLE warehouse.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    quarter INTEGER NOT NULL
);


-- ============================================================
-- 5. Order Item Fact Table
-- ============================================================
-- Grain:
-- One row represents one product item within one order.

CREATE TABLE warehouse.fact_order_items (
    order_item_key SERIAL PRIMARY KEY,

    order_id TEXT NOT NULL,
    order_item_id INTEGER NOT NULL,

    customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    seller_key INTEGER NOT NULL,
    purchase_date_key INTEGER NOT NULL,

    price NUMERIC(12,2) NOT NULL,
    freight_value NUMERIC(12,2) NOT NULL,
    item_total NUMERIC(12,2) NOT NULL,

    CONSTRAINT uq_fact_order_item
        UNIQUE (order_id, order_item_id),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key)
        REFERENCES warehouse.dim_customer(customer_key),

    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_key)
        REFERENCES warehouse.dim_product(product_key),

    CONSTRAINT fk_fact_seller
        FOREIGN KEY (seller_key)
        REFERENCES warehouse.dim_seller(seller_key),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (purchase_date_key)
        REFERENCES warehouse.dim_date(date_key)
);