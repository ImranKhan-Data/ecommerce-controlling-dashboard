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