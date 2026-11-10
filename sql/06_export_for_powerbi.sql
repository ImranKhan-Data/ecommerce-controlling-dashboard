-- =============================================================
-- 06_export_for_powerbi.sql
-- Exports the star schema as CSV files into data/processed/
-- so Power BI can load them.
-- Run (from the project folder):
--     sqlite3 data/olist.db < sql/06_export_for_powerbi.sql
-- Lines starting with a dot (.) are sqlite3 commands, not SQL:
--   .headers on   -> first line of the CSV = column names
--   .mode csv     -> write results as comma-separated values
--   .output file  -> send the next results into this file
-- =============================================================

.headers on
.mode csv

.output data/processed/fact_sales.csv
SELECT * FROM fact_sales;

.output data/processed/dim_product.csv
SELECT * FROM dim_product;

.output data/processed/dim_customer.csv
SELECT * FROM dim_customer;

.output data/processed/dim_date.csv
SELECT * FROM dim_date;

.output stdout
SELECT 'Export finished: 4 CSV files in data/processed/' AS status;