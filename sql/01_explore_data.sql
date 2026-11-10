-- =============================================================
-- 01_explore_data.sql
-- First look at the Olist data: size, time range, order status.
-- Run: sqlite3 -header -column data/olist.db < sql/01_explore_data.sql
-- =============================================================

-- Q1: How many orders are in the data?
SELECT COUNT(*) AS total_orders
FROM raw_orders;

-- Q2: Which time period does the data cover?
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM raw_orders;



-- Q3: How many orders were delivered?
-- WHERE filters the rows, COUNT(*) counts what is left.
SELECT COUNT(*) AS delivered_orders
FROM raw_orders
WHERE order_status = 'delivered';

-- Q4: Most expensive single item: text vs number comparison.
-- The raw columns are TEXT, so MAX(price) compares like words ("99" > "1000").
-- CAST(... AS REAL) turns the text into a number first, which gives the true maximum.
SELECT MAX(price)               AS max_price_as_text,
       MAX(CAST(price AS REAL)) AS max_price_as_number
FROM raw_order_items;

-- Q5: How many orders per status?
-- GROUP BY puts all rows with the same status into one group,
-- then COUNT(*) counts the rows in each group (like a pivot table in Excel).
SELECT order_status,
       COUNT(*) AS orders
FROM raw_orders
GROUP BY order_status
ORDER BY orders DESC;

-- Q6: How many orders per month?
-- SUBSTR(text, 1, 7) takes the first 7 characters of the date: '2017-12-05 ...' -> '2017-12'.
-- This is the base for the monthly trend in the dashboard.
SELECT SUBSTR(order_purchase_timestamp, 1, 7) AS order_month,
       COUNT(*) AS orders
FROM raw_orders
GROUP BY order_month
ORDER BY order_month;

-- Q7: Revenue and orders per month (first KPI!)
-- JOIN connects each order with its items via the shared column order_id.
-- "o" and "i" are short names (aliases) for the two tables.
-- Revenue = sum of item prices, delivered orders only, without freight costs.
-- COUNT(DISTINCT ...) because one order can have several items (rows).
SELECT SUBSTR(o.order_purchase_timestamp, 1, 7)  AS order_month,
       COUNT(DISTINCT o.order_id)                AS orders,
       ROUND(SUM(CAST(i.price AS REAL)), 2)      AS revenue
FROM raw_orders AS o
JOIN raw_order_items AS i
  ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;