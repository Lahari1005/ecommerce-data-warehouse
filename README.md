\# E-Commerce Data Warehouse \& Analytics System



An end-to-end data analytics project that transforms raw e-commerce transaction data into an analytics-ready PostgreSQL data warehouse and an interactive Power BI dashboard.



\## Project Overview



Raw CSV Data → Data Profiling → PostgreSQL Raw Layer → Staging Transformations → Star Schema Data Warehouse → Analytical SQL → Power BI Dashboard



Uses the \*\*Brazilian E-Commerce Public Dataset by Olist\*\* (\~100,000 orders, covering customers, products, sellers, payments, reviews, and order fulfillment).



\## Objectives



\- Ingest and organize raw e-commerce data in PostgreSQL

\- Profile source data and identify data-quality issues

\- Build raw and staging database layers

\- Design a dimensional data warehouse using a star schema

\- Perform analytical SQL queries

\- Build an interactive Power BI dashboard

\- Document the workflow using Git and GitHub



\## Technology Stack



| Technology | Purpose |

|---|---|

| Python | Data profiling and exploration |

| Pandas | Dataset analysis |

| PostgreSQL | Data storage and data warehouse |

| SQL | Data transformation and analytics |

| Power BI | Interactive dashboard |

| Git / GitHub | Version control and source-code repository |



\## Dataset



\*\*Brazilian E-Commerce Public Dataset by Olist\*\* — anonymized marketplace data including customers, orders, order items, products, sellers, payments, reviews, geolocation, and product category translations. Covers \~100,000 orders from 2016–2018.



\*\*License:\*\* CC BY-NC-SA 4.0. Raw CSVs are not included in this repo — stored locally under `data/raw/` and excluded via `.gitignore`.



\## Data Profiling



Profiled with Python/Pandas before loading into PostgreSQL — checking dimensions, column types, missing values, duplicates, unique identifiers, order-status distribution, items per order, product completeness, and referential integrity.



\### Dataset Sizes



| Dataset | Rows |

|---|---|

| Customers | 99,441 |

| Orders | 99,441 |

| Order Items | 112,650 |

| Products | 32,951 |

| Sellers | 3,095 |

| Order Payments | 103,886 |

| Order Reviews | 99,224 |

| Geolocation | 1,000,163 |

| Category Translation | 71 |



\### Key Findings



\- `customer\_id` is unique; `customer\_unique\_id` can repeat (identifies true repeat customers).

\- Order items use `(order\_id, order\_item\_id)` as a composite key.

\- Missing delivery timestamps are expected for undelivered orders.

\- Some products have missing descriptive attributes.

\- No orphan orders, products, or customers found in referential-integrity checks.

\- Unusually long approval delays flagged as anomalies rather than deleted.



\## PostgreSQL Architecture



`raw` → `staging` → `warehouse`



\- \*\*Raw layer\*\*: source data with minimal transformation (`raw.customers`, `raw.orders`, `raw.order\_items`, `raw.products`, `raw.sellers`, `raw.order\_payments`, `raw.order\_reviews`, `raw.geolocation`, `raw.category\_name\_translation`)

\- \*\*Staging layer\*\*: intermediate transformations — approval-delay calc, delivery-duration calc, item-total calc (`price + freight\_value`), category enrichment, anomaly flagging

\- \*\*Warehouse layer\*\*: dimensional model (`warehouse.dim\_customer`, `dim\_product`, `dim\_seller`, `dim\_date`, `fact\_order\_items`)



\## Star Schema



\*\*Fact table:\*\* `warehouse.fact\_order\_items`



\*\*Grain:\*\* one row = one product item within one order. An order with 3 items produces 3 fact rows.



\- `COUNT(\*)` → counts order-item rows

\- `COUNT(DISTINCT order\_id)` → counts actual orders



\*\*Structure:\*\* `dim\_customer`, `dim\_product`, `dim\_seller`, and `dim\_date` all connect to the central `fact\_order\_items` table.



\*\*Fact table contains:\*\* order ID, order item ID, customer key, product key, seller key, purchase date key, product price, freight value, item total.



\*\*Surrogate keys\*\* (`customer\_key`, `product\_key`, `seller\_key`) are separate from source identifiers (`customer\_id`, `product\_id`, `seller\_id`), letting the warehouse keep its own internal IDs while retaining source-system IDs.



\## Analytical SQL



Covers total/product/freight revenue, average order value, total orders/items, revenue by category/seller/location, monthly revenue, order-status distribution, delivery performance, payment methods, and review-score distribution.



\### Key Results



| Metric | Value |

|---|---|

| Total Item Value | 15,843,553.24 |

| Product Revenue | 13,591,643.70 |

| Freight Value | 2,251,909.54 |

| Average Order Value | 160.58 |

| Orders Represented in Order Items | 98,666 |

| Average Items per Order | 1.14 |

| Average Review Score | 4.09 |



\### Additional Findings



\- `health\_beauty` was the highest-revenue product category.

\- Credit card payments had the largest payment value.

\- Most delivered orders arrived early or on time.

\- São Paulo generated the highest customer-location revenue.



\## Analytical Views



\- `warehouse.sales\_analysis` — combines fact, customer, product, seller, and date data (used by Power BI)

\- `warehouse.order\_analysis` — order status, timestamps, delivery duration

\- `warehouse.payment\_analysis` — payment-method data

\- `warehouse.review\_analysis` — review-score data

\- `warehouse.dim\_order` — order-level attributes for Power BI relationships/filtering



\## Power BI Dashboard



Connects to PostgreSQL analytical views (not raw CSVs). Includes: Total Revenue, Total Orders, Average Order Value, Total Freight, Total Items, Monthly Revenue Trend, Top 10 Product Categories, Revenue by State, Payment Value by Method, Delivery Performance, Customer Review Distribution, Average Review Score, and Order Status filtering.



The model uses the order-level dimension to support filtering across datasets of different grains (one order can have multiple items, payments, and reviews).



\## Data Quality Considerations



\- \*\*Missing delivery dates\*\*: expected for undelivered orders, not treated as errors.

\- \*\*Long approval delays\*\*: flagged (`approval\_delay\_anomaly = TRUE`) rather than deleted, preserving data for investigation.

\- \*\*Missing product attributes\*\*: retained rather than removed from the warehouse.



\## Repository Structure



ecommerce-data-warehouse/

├── data/raw/ # Source CSV files (gitignored)

├── src/profiling/profile\_data.py # Python profiling script

├── sql/

│ ├── 01\_create\_schemas.sql

│ ├── 02\_create\_raw\_tables.sql

│ ├── 03\_staging\_transformations.sql

│ ├── 04\_warehouse\_schema.sql

│ └── 05\_analytical\_queries.sql

├── powerbi/ecommerce\_sales\_dashboard.pbix

├── docs/

├── .gitignore

└── README.md





\## Reproducing the Project



1\. \*\*Clone the repo\*\*

```bash

&#x20;  git clone <repository-url>

&#x20;  cd ecommerce-data-warehouse

```

2\. \*\*Download the dataset\*\* — get the Olist dataset and extract CSVs into `data/raw/`

3\. \*\*Create the PostgreSQL database\*\* — name it `ecommerce\_dw`

4\. \*\*Run schema creation\*\* — `sql/01\_create\_schemas.sql`

5\. \*\*Create raw tables\*\* — `sql/02\_create\_raw\_tables.sql`, then load the CSVs

6\. \*\*Run staging transformations\*\* — `sql/03\_staging\_transformations.sql`

7\. \*\*Create the warehouse schema\*\* — `sql/04\_warehouse\_schema.sql`

8\. \*\*Run analytical queries/views\*\* — `sql/05\_analytical\_queries.sql`

9\. \*\*Open the dashboard\*\* — `powerbi/ecommerce\_sales\_dashboard.pbix`, configure the PostgreSQL connection to `ecommerce\_dw`



\*\*Note:\*\* current SQL scripts document the structures/transformations, but full data loading wasn't yet packaged as a single automated pipeline.



\## Limitations



\- Dataset covers 2016–2018; September 2018 is a partial month.

\- Portfolio data-engineering project, not a production platform.

\- Raw data excluded from repo due to licensing/size.

\- Uses a local PostgreSQL database, not cloud-hosted.

\- No advanced orchestration or cloud deployment (yet).



\## Future Improvements



Automated ETL pipeline, incremental loading, data-quality testing framework, Airflow orchestration, Docker-based deployment, cloud data warehouse, automated Power BI refresh, CI/CD for SQL/Python validation, advanced business metrics, historical dimension handling, production-grade monitoring.



\## Skills Demonstrated



Python, Pandas, SQL, PostgreSQL, relational database design, data profiling, data quality validation, ETL concepts, staging layers, dimensional modeling, star schemas, fact/dimension tables, surrogate keys, primary/foreign keys, analytical SQL, DAX, Power BI, Git, GitHub.



\## Author



\*\*Lahari Shyam\*\*



Built to demonstrate practical skills in data engineering, SQL analytics, dimensional modeling, and business intelligence.

