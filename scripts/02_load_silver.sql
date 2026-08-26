/*
===============================================================================
Script Name:     02_load_silver.sql
System / DB:     SQL Server (T-SQL) / OnlineRetailAnalytics
Layer:           Silver Layer (Data Cleansing & Transformation)
Description:     Encapsulates the Silver Layer ETL process inside a stored 
                 procedure. Consolidates multi-year raw Bronze datasets, 
                 performs data cleansing (string trimming, country name 
                 standardization, datatype casting), and filters out invalid 
                 records (NULL customer IDs).
Data Source:     bronze.retail_sales2009, bronze.retail_sales2010
Target Table:    silver.retail_online
Usage Example:   EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver	--EXEC silver.load_silver
AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME; 

		SET NOCOUNT ON;	--turn off redundant prompt

		--Create silver tables schema
		IF OBJECT_ID('silver.retail_online','U') IS NOT NULL
			DROP TABLE silver.retail_online

		CREATE TABLE silver.retail_online(
			invoice NVARCHAR(20),		--Retains 'C' prefixes for cancelltions
			stock_code NVARCHAR(20),	--Retains alphanumeric product codes (e.g., 'POST')
			description NVARCHAR(100),
			quantity INT,				--Preserves negative values for returned goods
			invoice_date DATETIME,
			price DECIMAL(10, 2),
			customer_id INT,
			country NVARCHAR(50)
		);

		SET @start_time = GETDATE();

		--Truncate existing rows in target table
		PRINT '>> Truncating and loading: silver.retail_online';
		TRUNCATE TABLE silver.retail_online;

		--Insert cleansed and consolidated data
		INSERT INTO silver.retail_online(
			invoice,
			stock_code,
			description,
			quantity,
			invoice_date,
			price,
			customer_id,
			country
		)
		SELECT 
			TRIM(invoice) AS invoice,
			TRIM(stock_code) AS stock_code,
			TRIM(description) AS description,
			quantity,
			COALESCE(
                		TRY_CONVERT(DATETIME, invoice_date, 120),	--Format ISO
                		TRY_CONVERT(DATETIME, invoice_date, 103),	--Format UK
                		TRY_CONVERT(DATETIME, invoice_date, 101),	--Format US
                		TRY_CONVERT(DATETIME, invoice_date)			--Stock SQL
            		) AS invoice_date,
			ABS(TRY_CAST(REPLACE(price, ',', '.') AS DECIMAL(10, 2))) AS price,
			customer_id,
			CASE country
				WHEN 'EIRE' THEN 'Ireland'
				WHEN 'USA'	THEN 'United States'
				WHEN 'RSA'	THEN 'Republic of South Africa'
				ELSE country
			END AS country
		FROM(
			SELECT invoice, stock_code, description, quantity, invoice_date, price, customer_id, country FROM 						bronze.retail_sales2009
			UNION ALL
			SELECT invoice, stock_code, description, quantity, invoice_date, price, customer_id, country FROM 						bronze.retail_sales2010
		) AS combined_bronze
		WHERE customer_id IS NOT NULL

		SET @end_time = GETDATE();

		--Time duration prompt
		PRINT '=================================';
		PRINT '	   DATA LOAD COMPLETED';
		PRINT ' Total load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '=================================';

	END TRY
			--Error prompt
	BEGIN CATCH
		PRINT '====================================';
		PRINT ' ERROR OCCURED DURING DATA LOADING';
		PRINT ' Error Message: ' + ERROR_MESSAGE();
		PRINT ' Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT ' Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '====================================';

		THROW;
	END CATCH;
END;