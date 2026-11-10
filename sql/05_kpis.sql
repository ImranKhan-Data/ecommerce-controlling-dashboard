 -- =============================================================
-- 05_kpis.sql
-- The KPIs (Kennzahlen) for the controlling dashboard.
-- Analysis period: 2017-01 to 2018-08 (complete months only;
-- 2016 and Sep/Oct 2018 have almost no orders and would distort trends).
-- Run: sqlite3 -header -column data/olist.db < sql/05_kpis.sql
-- =============================================================

-- K1: Headline KPIs for the whole period (the KPI cards in the dashboard)
-- Average order value (AOV, Durchschnittlicher Bestellwert) = revenue / orders
SELECT ROUND(SUM(f.revenue), 2)                                  AS revenue,
       COUNT(DISTINCT f.order_id)                                AS orders,
       ROUND(SUM(f.revenue) / COUNT(DISTINCT f.order_id), 2)     AS avg_order_value,
       COUNT(DISTINCT c.customer_unique_id)                      AS customers
FROM fact_sales   AS f
JOIN dim_customer AS c ON f.customer_id = c.customer_id
WHERE f.order_date BETWEEN '2017-01-01' AND '2018-08-31';

-- K2: Monthly revenue with growth vs previous month (MoM = month over month)
-- WITH ... AS (...) creates a temporary result we can reuse (a "CTE").
-- LAG(revenue) looks at the value of the PREVIOUS row (= previous month).
WITH monthly AS (
    SELECT d.year_month,
           ROUND(SUM(f.revenue), 2)    AS revenue,
           COUNT(DISTINCT f.order_id)  AS orders
    FROM fact_sales AS f
    JOIN dim_date   AS d ON f.order_date = d.date
    WHERE f.order_date BETWEEN '2017-01-01' AND '2018-08-31'
    GROUP BY d.year_month
)
SELECT year_month,
       revenue,
       orders,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year_month))
                   / LAG(revenue) OVER (ORDER BY year_month), 1) AS growth_pct
FROM monthly
ORDER BY year_month;

-- K3: Top 10 categories by revenue, with their share of total revenue
-- SUM(...) OVER () = the grand total, repeated on every row.
SELECT p.category,
       ROUND(SUM(f.revenue), 2)                                       AS revenue,
       ROUND(100.0 * SUM(f.revenue) / SUM(SUM(f.revenue)) OVER (), 1) AS share_pct
FROM fact_sales  AS f
JOIN dim_product AS p ON f.product_id = p.product_id
WHERE f.order_date BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 10;

-- K4: Top 10 states by revenue, with share of total
SELECT c.state,
       ROUND(SUM(f.revenue), 2)                                       AS revenue,
       ROUND(100.0 * SUM(f.revenue) / SUM(SUM(f.revenue)) OVER (), 1) AS share_pct
FROM fact_sales   AS f
JOIN dim_customer AS c ON f.customer_id = c.customer_id
WHERE f.order_date BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY c.state
ORDER BY revenue DESC
LIMIT 10;