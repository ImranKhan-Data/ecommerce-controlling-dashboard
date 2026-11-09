-- =============================================================
-- 00_load_raw_data.sql
-- Loads the raw Olist CSV files into SQLite as "raw_" tables.
--
-- How to run (from the project folder, in the Terminal):
--     sqlite3 data/olist.db < sql/00_load_raw_data.sql
--
-- Raw layer: every column is loaded as TEXT, exactly as in the CSV.
-- Cleaning and correct data types come later (sql/02_...).
-- =============================================================

-- Start fresh: remove old raw tables if the script runs again
DROP TABLE IF EXISTS raw_orders;
DROP TABLE IF EXISTS raw_order_items;
DROP TABLE IF EXISTS raw_order_payments;
DROP TABLE IF EXISTS raw_products;
DROP TABLE IF EXISTS raw_customers;
DROP TABLE IF EXISTS raw_category_translation;

-- Import the CSV files (the first row becomes the column names)
.import --csv data/raw/olist_orders_dataset.csv              raw_orders
.import --csv data/raw/olist_order_items_dataset.csv         raw_order_items
.import --csv data/raw/olist_order_payments_dataset.csv      raw_order_payments
.import --csv data/raw/olist_products_dataset.csv            raw_products
.import --csv data/raw/olist_customers_dataset.csv           raw_customers
.import --csv data/raw/product_category_name_translation.csv raw_category_translation

-- Quick check: how many rows landed in each table?
SELECT 'raw_orders',               COUNT(*) FROM raw_orders
UNION ALL SELECT 'raw_order_items',          COUNT(*) FROM raw_order_items
UNION ALL SELECT 'raw_order_payments',       COUNT(*) FROM raw_order_payments
UNION ALL SELECT 'raw_products',             COUNT(*) FROM raw_products
UNION ALL SELECT 'raw_customers',            COUNT(*) FROM raw_customers
UNION ALL SELECT 'raw_category_translation', COUNT(*) FROM raw_category_translation;
