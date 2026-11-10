-- =============================================================
-- 04_data_model.sql
-- Builds a STAR SCHEMA (Sternschema) for reporting and Power BI:
--   fact_sales   = the facts: one row per sold item (numbers to add up)
--   dim_product  = describes the product (category)
--   dim_customer = describes the customer (city, state)
--   dim_date     = describes the date (year, month, quarter)
-- Run: sqlite3 data/olist.db < sql/04_data_model.sql
-- =============================================================

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_date;

-- FACT table: only DELIVERED orders count as real sales.
-- One row per order item. Keys (order_id, product_id, customer_id, order_date)
-- connect it to the dimension tables.
CREATE TABLE fact_sales AS
SELECT i.order_id,
       i.order_item_id,
       i.product_id,
       o.customer_id,
       o.purchase_date                 AS order_date,
       i.price                         AS revenue,
       i.freight_value                 AS freight
FROM clean_order_items AS i
JOIN clean_orders      AS o ON i.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- DIMENSION: products (only those that appear in sales)
CREATE TABLE dim_product AS
SELECT product_id, category
FROM clean_products
WHERE product_id IN (SELECT product_id FROM fact_sales);

-- DIMENSION: customers (only those that appear in sales)
CREATE TABLE dim_customer AS
SELECT customer_id, customer_unique_id, city, state
FROM clean_customers
WHERE customer_id IN (SELECT customer_id FROM fact_sales);

-- DIMENSION: dates. One row per day that has sales,
-- with ready-made columns for reports (year, month, quarter).
-- STRFTIME formats a date: '%Y' = year, '%m' = month number.
CREATE TABLE dim_date AS
SELECT DISTINCT
       order_date                                   AS date,
       CAST(STRFTIME('%Y', order_date) AS INTEGER)  AS year,
       CAST(STRFTIME('%m', order_date) AS INTEGER)  AS month,
       STRFTIME('%Y-%m', order_date)                AS year_month,
       'Q' || ((CAST(STRFTIME('%m', order_date) AS INTEGER) + 2) / 3) AS quarter
FROM fact_sales
ORDER BY date;

-- Check 1: size of each table
SELECT 'fact_sales' AS table_name, COUNT(*) AS row_count FROM fact_sales
UNION ALL SELECT 'dim_product',  COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_date',     COUNT(*) FROM dim_date;

-- Check 2: total revenue and delivered orders
SELECT ROUND(SUM(revenue), 2) AS total_revenue,
       COUNT(DISTINCT order_id) AS delivered_orders
FROM fact_sales;