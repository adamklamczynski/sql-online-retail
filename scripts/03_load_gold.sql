/*
===============================================================================
Script Name:     03_load_gold.sql
System / DB:     SQL Server (T-SQL) / OnlineRetailAnalytics
Layer:           Gold Layer (Analytical Views / Star Schema)
Description:     Creates analytical views for the Gold Layer to form a 
                 Star Schema model (Fact & Dimensions). Standardizes column 
                 naming, calculates total transaction amounts, and aggregates 
                 unique product and customer dimensions for BI reporting.
Data Source:     silver.retail_online
Target Views:    gold.fact_sales, gold.dim_products, gold.dim_customers
===============================================================================
*/

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
	invoice			AS invoice_number,
	stock_code		AS product_code,
	customer_id,
	invoice_date,
	quantity,
	price			AS unit_price,
	CAST(quantity*price AS DECIMAL(12,2)) AS total_amount
FROM silver.retail_online
GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
	stock_code		AS product_code,
	MAX(TRIM(description))	AS description
FROM silver.retail_online
GROUP BY stock_code
GO

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
	customer_id,
	MAX(country)		AS country
FROM silver.retail_online
GROUP BY 
	customer_id
GO