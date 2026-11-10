-- =============================================================
-- 03_clean_data.sql
-- Builds CLEAN tables from the raw tables:
--   * correct data types (text -> numbers / dates)
--   * empty text '' -> NULL (= "no value")
--   * readable English category names
-- Run: sqlite3 data/olist.db < sql/03_clean_data.sql
-- =============================================================

-- New SQL tools used here:
--   CREATE TABLE x AS SELECT ...  -> save the result of a query as a new table
--   NULLIF(a, '')                 -> turns empty text into NULL
--   COALESCE(a, b, c)             -> takes the first value that is not NULL
--   LEFT JOIN                     -> keep ALL rows from the left table, even without a match

DROP TABLE IF EXISTS clean_orders;
DROP TABLE IF EXISTS clean_order_items;
DROP TABLE IF EXISTS clean_products;
DROP TABLE IF EXISTS clean_customers;

-- 1) Orders: keep all orders and statuses (KPIs filter on 'delivered' later).
--    Dates: empty -> NULL. Extra columns for date and month make reporting easier.
CREATE TABLE clean_orders AS
SELECT order_id,
       customer_id,
       order_status,
       NULLIF(order_purchase_timestamp, '')        AS purchase_ts,
       DATE(order_purchase_timestamp)              AS purchase_date,
       SUBSTR(order_purchase_timestamp, 1, 7)      AS purchase_month,
       NULLIF(order_delivered_customer_date, '')   AS delivered_ts,
       NULLIF(order_estimated_delivery_date, '')   AS estimated_delivery_ts
FROM raw_orders;

-- 2) Order items: prices as real numbers (fixes the "text trap").
CREATE TABLE clean_order_items AS
SELECT order_id,
       CAST(order_item_id AS INTEGER)  AS order_item_id,
       product_id,
       seller_id,
       CAST(price AS REAL)             AS price,
       CAST(freight_value AS REAL)     AS freight_value
FROM raw_order_items;

-- 3) Products: English category names.
--    LEFT JOIN keeps products even if no translation exists.
--    The 2 categories without translation are translated by hand (CASE).
--    Products without any category get 'unknown' (610 products).
CREATE TABLE clean_products AS
SELECT p.product_id,
       COALESCE(
           t.product_category_name_english,
           CASE p.product_category_name
                WHEN 'pc_gamer' THEN 'pc_gamer'
                WHEN 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'small_kitchen_appliances'
           END,
           'unknown'
       )                                         AS category,
       CAST(NULLIF(p.product_weight_g, '') AS REAL) AS weight_g
FROM raw_products AS p
LEFT JOIN raw_category_translation AS t
       ON p.product_category_name = t.product_category_name;

-- 4) Customers: one row per customer_id, with city and state.
CREATE TABLE clean_customers AS
SELECT customer_id,
       customer_unique_id,
       customer_city   AS city,
       customer_state  AS state
FROM raw_customers;

-- Check: rows per clean table (must match the raw tables)
SELECT 'clean_orders' AS table_name, COUNT(*) AS row_count FROM clean_orders
UNION ALL SELECT 'clean_order_items', COUNT(*) FROM clean_order_items
UNION ALL SELECT 'clean_products',    COUNT(*) FROM clean_products
UNION ALL SELECT 'clean_customers',   COUNT(*) FROM clean_customers;

-- Check: how many products per special category value?
SELECT category, COUNT(*) AS products
FROM clean_products
WHERE category IN ('unknown', 'pc_gamer', 'small_kitchen_appliances')
GROUP BY category;