# 🛒 E-Commerce Data Warehouse & Analytics (Medallion Architecture)

An end-to-end Data Engineering and Business Intelligence solution using **Microsoft SQL Server (T-SQL)** and **Power BI**. The pipeline ingests raw transactional CSV datasets, cleanses and models the data through a 3-tier **Medallion Architecture**, and exposes business-ready insights via interactive analytical reporting.

---

## 🏗️ Architecture Overview

The system follows the Medallion Data Architecture design pattern to process raw transactional data into clean analytical structures:

<img width="1702" height="922" alt="data_architecture" src="https://github.com/user-attachments/assets/4b0f8ab2-2fc0-4443-84fc-87ea02c87824" />


### 🥉 Bronze Layer (Raw Ingestion)
* **Object Type:** Tables (`bronze.retail_sales2009`, `bronze.retail_sales2010`)
* **Execution:** Stored Procedure (`bronze.load_bronze`)
* **Load Pattern:** Full load via `BULK INSERT` (Truncate & Insert batch processing)
* **Transformation:** None — ingests raw source CSV files as-is

### 🥈 Silver Layer (Data Cleansing)
* **Object Type:** Tables (`silver.retail_online`)
* **Execution:** Stored Procedure (`silver.load_silver`)
* **Load Pattern:** Batch processing (Truncate & Insert)
* **Transformations:** Data cleansing, string standardization, country mapping, datatype casting (`DATETIME`, `DECIMAL`), data integration (`UNION ALL`), and filtering out invalid records

### 🥇 Gold Layer (Star Schema)
* **Object Type:** Views (`gold.fact_sales`, `gold.dim_products`, `gold.dim_customers`)
* **Execution:** No load required (On-demand view execution)
* **Data Model:** **Star Schema**
* **Transformations:** Data decomposition, calculated fields (`quantity * price`), product aggregation (`GROUP BY`), and business logic modeling

---

## 📊 Business Intelligence & Reporting (Power BI)

The analytical models in the Gold Layer connect directly to Power BI to drive the **Executive Summary Dashboard**:

<img width="1524" height="835" alt="Executive_Summary" src="https://github.com/user-attachments/assets/fd8a2ea0-508d-4810-ab21-eccb1d565fdd" />


### Key Metrics Covered:
* **Total Revenue & Volume:** $16.65M Total Revenue across 45K Total Orders.
* **Returns & Shipping Insights:** Tracked Returned Revenue ($1.10M), Return Rate %, and Shipping Revenue.
* **Geographic Breakdown:** Top countries mapped by Revenue and Order Volume (led by United Kingdom at ~91.88%).
* **Product Performance:** Top 10 products ranked by order count (e.g., *White Hanging Heart T-Light Holder*).
* **Time Intelligence:** Dynamic time filtering (Year/Quarter/Month) spanning 2009–2011 trends.

---

## 🚀 How to Run

1. **Setup Database:** Execute `01_load_bronze.sql` to initialize database schemas and run `EXEC bronze.load_bronze`.
2. **Transform Data:** Execute `02_load_silver.sql` and run `EXEC silver.load_silver`.
3. **Build Views:** Execute `03_load_gold.sql` to generate analytical views.
4. **Power BI:** Open `reports/Executive_Summary.pbix` and connect to your SQL Server instance.

---

## 📁 Repository Layout

```text
├── datasets/             # Raw CSV data files
├── docs/                 # High Level Architecture & Dashboard images
├── scripts/
│   ├── 01_load_bronze.sql # Bronze DDL & Ingestion Procedure
│   ├── 02_load_silver.sql # Silver Transformation Procedure
│   └── 03_load_gold.sql   # Gold Star Schema Views
└── reports/
    └── Executive_Summary.pbix # Power BI Dashboard
