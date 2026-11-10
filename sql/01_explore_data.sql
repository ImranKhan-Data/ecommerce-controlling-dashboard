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