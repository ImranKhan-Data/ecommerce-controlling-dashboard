-- =============================================================
-- 02_data_quality_checks.sql
-- Can we trust the data? Duplicates, empty values, wrong values.
-- Run: sqlite3 -header -column data/olist.db < sql/02_data_quality_checks.sql
-- Note: the CSV import stores empty fields as '' (empty text), not NULL.
-- =============================================================

-- C1: Duplicates? If both numbers are equal, every order_id exists only once.
SELECT COUNT(*)                 AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders
FROM raw_orders;

-- C2: Delivered orders WITHOUT a delivery date (should be 0, impossible case).
SELECT COUNT(*) AS delivered_without_date
FROM raw_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date = '';

-- C3: Products without a category (they would be "unknown" in the dashboard).
SELECT COUNT(*) AS products_without_category
FROM raw_products
WHERE product_category_name = '';

-- C4: Items with a price of 0 or less (impossible for a real sale).
SELECT COUNT(*) AS zero_or_negative_prices
FROM raw_order_items
WHERE CAST(price AS REAL) <= 0;

-- C5: Orders that have NO items at all (they bring no revenue).
-- NOT IN (...) = "the order_id does not appear in the items table".
SELECT COUNT(*) AS orders_without_items
FROM raw_orders
WHERE order_id NOT IN (SELECT order_id FROM raw_order_items);

-- C6: Categories that have no English translation.
SELECT DISTINCT product_category_name AS missing_translation
FROM raw_products
WHERE product_category_name <> ''
  AND product_category_name NOT IN
      (SELECT product_category_name FROM raw_category_translation);