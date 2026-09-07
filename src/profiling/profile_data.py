import pandas as pd

file_path = "data/raw/olist_customers_dataset.csv"

customers = pd.read_csv(file_path)

print("========== BASIC INFORMATION ==========")

print("\nFirst 5 rows:")
print(customers.head())

print("\nShape:")
print(customers.shape)

print("\nColumns:")
print(customers.columns.tolist())

print("\nData types:")
print(customers.dtypes)

print("\nMissing values:")
print(customers.isnull().sum())


print("\n========== UNIQUENESS ==========")

print("\nUnique customer_id values:")
print(customers["customer_id"].nunique())

print("\nUnique customer_unique_id values:")
print(customers["customer_unique_id"].nunique())

print("\nTotal rows:")
print(len(customers))


print("\n========== DUPLICATES ==========")

print("\nDuplicate customer_id values:")
print(customers["customer_id"].duplicated().sum())

print("\nDuplicate customer_unique_id values:")
print(customers["customer_unique_id"].duplicated().sum())

print("\n========== CUSTOMER UNIQUE ID FREQUENCY ==========")

customer_frequency = (
    customers["customer_unique_id"]
    .value_counts()
)

print("\nCustomers with more than one customer_id:")
print((customer_frequency > 1).sum())

print("\nMaximum customer_id records for one customer_unique_id:")
print(customer_frequency.max())

print("\nFrequency distribution:")
print(customer_frequency.value_counts().sort_index())

print("\n\n========== CORE DATASETS ==========")

orders = pd.read_csv("data/raw/olist_orders_dataset.csv")
order_items = pd.read_csv("data/raw/olist_order_items_dataset.csv")
products = pd.read_csv("data/raw/olist_products_dataset.csv")


print("\n========== ORDERS ==========")

print("\nShape:")
print(orders.shape)

print("\nColumns:")
print(orders.columns.tolist())

print("\nMissing values:")
print(orders.isnull().sum())

print("\nDuplicate order_id:")
print(orders["order_id"].duplicated().sum())

print("\nUnique order_id:")
print(orders["order_id"].nunique())


print("\n========== ORDER ITEMS ==========")

print("\nShape:")
print(order_items.shape)

print("\nColumns:")
print(order_items.columns.tolist())

print("\nMissing values:")
print(order_items.isnull().sum())

print("\nUnique order_id:")
print(order_items["order_id"].nunique())

print("\nUnique product_id:")
print(order_items["product_id"].nunique())


print("\n========== PRODUCTS ==========")

print("\nShape:")
print(products.shape)

print("\nColumns:")
print(products.columns.tolist())

print("\nMissing values:")
print(products.isnull().sum())

print("\nDuplicate product_id:")
print(products["product_id"].duplicated().sum())

print("\nUnique product_id:")
print(products["product_id"].nunique())

print("\n========== ORDER STATUS vs MISSING DATES ==========")

print("\nOrder status distribution:")
print(orders["order_status"].value_counts())

print("\nMissing order_approved_at by status:")
print(
    orders.groupby("order_status")["order_approved_at"]
    .apply(lambda x: x.isnull().sum())
)

print("\nMissing order_delivered_carrier_date by status:")
print(
    orders.groupby("order_status")["order_delivered_carrier_date"]
    .apply(lambda x: x.isnull().sum())
)

print("\nMissing order_delivered_customer_date by status:")
print(
    orders.groupby("order_status")["order_delivered_customer_date"]
    .apply(lambda x: x.isnull().sum())
)

print("\n========== ITEMS PER ORDER ==========")

items_per_order = (
    order_items
    .groupby("order_id")
    .size()
)

print("\nAverage items per order:")
print(items_per_order.mean())

print("\nMaximum items in one order:")
print(items_per_order.max())

print("\nItem count distribution:")
print(items_per_order.value_counts().sort_index())

print("\n========== PRODUCT MISSING DATA ANALYSIS ==========")

product_columns = [
    "product_category_name",
    "product_name_lenght",
    "product_description_lenght",
    "product_photos_qty",
    "product_weight_g",
    "product_length_cm",
    "product_height_cm",
    "product_width_cm"
]

print("\nNumber of missing values per product:")
print(
    products[product_columns]
    .isnull()
    .sum(axis=1)
    .value_counts()
    .sort_index()
)

print("\nProducts missing all of the first five descriptive fields:")
print(
    products[
        products[
            [
                "product_category_name",
                "product_name_lenght",
                "product_description_lenght",
                "product_photos_qty"
            ]
        ].isnull().all(axis=1)
    ].shape[0]
)

print("\n========== RELATIONSHIP VALIDATION ==========")

# Orders → Customers
orders_without_customer = ~orders["customer_id"].isin(customers["customer_id"])

print("\nOrders with no matching customer:")
print(orders_without_customer.sum())


# Order Items → Orders
items_without_order = ~order_items["order_id"].isin(orders["order_id"])

print("\nOrder items with no matching order:")
print(items_without_order.sum())


# Order Items → Products
items_without_product = ~order_items["product_id"].isin(products["product_id"])

print("\nOrder items with no matching product:")
print(items_without_product.sum())
