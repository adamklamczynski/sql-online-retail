/*
===============================================================================
Script Name:     01_load_bronze.sql
System / DB:     SQL Server (T-SQL) / OnlineRetailAnalytics
Layer:           Bronze Layer (Data Ingestion)
Description:     Sets up the database foundation, schemas, and encapsulates the 
                 full Bronze Layer workflow inside a stored procedure. 
                 Automates table drops, schema creation, and raw bulk CSV 
                 ingestion without data transformation.
Data Source:     Raw Online Retail CSV datasets (2009-2010 & 2010-2011)
Usage Example:   EXEC bronze.load_bronze;
===============================================================================
*/

--Create new database and use them
CREATE DATABASE OnlineRetailAnalytics;
USE OnlineRetailAnalytics;

--Create 'Medallion Architecture'
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;

CREATE OR ALTER PROCEDURE bronze.load_bronze --EXEC bronze.load_bronze
AS
BEGIN
	SET NOCOUNT ON;  --turn off redundant prompt

	BEGIN TRY
		--Variables to count inserting time

		DECLARE @start_time DATETIME, @end_time DATETIME;
		SET @start_time = GETDATE();

		--If table already exists-drop it

		IF OBJECT_ID('bronze.retail_sales2009','U')IS NOT NULL
			DROP TABLE bronze.retail_sales2009
		
		--Create new/empty table

		CREATE TABLE bronze.retail_sales2009(
			invoice NVARCHAR(50),
			stock_code NVARCHAR(50),
			description NVARCHAR(255),
			quantity INT,
			invoice_date NVARCHAR(50),
			price NVARCHAR(50),
			customer_id INT NULL,
			country NVARCHAR(50)
		);

		IF OBJECT_ID('bronze.retail_sales2010','U')IS NOT NULL
			DROP TABLE bronze.retail_sales2010

		CREATE TABLE bronze.retail_sales2010(
			invoice NVARCHAR(50),
			stock_code NVARCHAR(50),
			description NVARCHAR(255),
			quantity INT,
			invoice_date NVARCHAR(50),
			price NVARCHAR(50),
			customer_id INT NULL,
			country NVARCHAR(50)
		);

		PRINT '>> Truncating and loading: bronze.retail_sales2009';

		--Cleaning table 

		TRUNCATE TABLE bronze.retail_sales2009;

		--Inserting data from CSV files

		BULK INSERT bronze.retail_sales2009
		FROM 'F:\online_retail_project\datasets\online_retail_II_09_10.csv' --CSV File location
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			CODEPAGE = '65001',
			TABLOCK
		);

		PRINT '>> Truncating and loading: bronze.retail_sales2010';
		TRUNCATE TABLE bronze.retail_sales2010;

		BULK INSERT bronze.retail_sales2010
		FROM 'F:\online_retail_project\datasets\online_retail_II_10_11.csv' --CSV File location
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			CODEPAGE = '65001',
			TABLOCK
		);
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
		PRINT ' ERROR OCCURED DURING LOADING DATE ';
		PRINT ' Error Message: ' + ERROR_MESSAGE();
		PRINT ' Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT ' Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '====================================';

		THROW;
	END CATCH;
END;