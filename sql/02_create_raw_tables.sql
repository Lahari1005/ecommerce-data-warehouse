-- ============================================================
-- E-Commerce Data Warehouse
-- 02 - Create Raw Tables
-- ============================================================

-- Customers
CREATE TABLE raw.customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

-- Orders
CREATE TABLE raw.orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    order_status TEXT NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP NOT NULL,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES raw.customers(customer_id)
);

-- Products
CREATE TABLE raw.products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- Sellers
CREATE TABLE raw.sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);

-- Order Items
CREATE TABLE raw.order_items (
    order_id TEXT NOT NULL,
    order_item_id INTEGER NOT NULL,
    product_id TEXT NOT NULL,
    seller_id TEXT NOT NULL,
    shipping_limit_date TIMESTAMP NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    freight_value NUMERIC(12,2) NOT NULL,

    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, order_item_id),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES raw.orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES raw.products(product_id)
);

-- Order Payments
CREATE TABLE raw.order_payments (
    order_id TEXT NOT NULL,
    payment_sequential INTEGER NOT NULL,
    payment_type TEXT NOT NULL,
    payment_installments INTEGER NOT NULL,
    payment_value NUMERIC(12,2) NOT NULL,

    CONSTRAINT pk_order_payments
        PRIMARY KEY (order_id, payment_sequential),

    CONSTRAINT fk_order_payments_order
        FOREIGN KEY (order_id)
        REFERENCES raw.orders(order_id)
);

-- Order Reviews
CREATE TABLE raw.order_reviews (
    review_id TEXT NOT NULL,
    order_id TEXT NOT NULL,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    CONSTRAINT pk_order_reviews
        PRIMARY KEY (review_id, order_id),

    CONSTRAINT fk_order_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES raw.orders(order_id)
);

-- Geolocation
-- No primary key because ZIP code prefixes occur multiple times.
CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix INTEGER NOT NULL,
    geolocation_lat NUMERIC(10,7),
    geolocation_lng NUMERIC(10,7),
    geolocation_city TEXT,
    geolocation_state TEXT
);

-- Product Category Translation
CREATE TABLE raw.category_name_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);