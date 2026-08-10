/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'Silver' schema tables from the 'Bronze' schema.
    It truncates the Silver tables before loading and applies the cleansing,
    standardization, and de-duplication rules described inline for each table.

    Run: EXEC Silver.load_silver;
Author:
    Utkarsh Goel
===============================================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
	PRINT '=============================================================';
	PRINT 'Loading Silver Layer';
	PRINT '=============================================================';

	PRINT '-------------------------------------------------------------';
	PRINT 'Loading CRM Tables';
	PRINT '-------------------------------------------------------------';

	-- ==========================================================================
	-- Silver.crm_cust_info
	-- Rules: Trim names, standardize marital status / gender to readable values,
	--        keep only the most recent record per customer (cst_id).
	-- ==========================================================================
	TRUNCATE TABLE Silver.crm_cust_info;
	INSERT INTO Silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname)  AS cst_lastname,
		CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			ELSE 'n/a' 
		END AS cst_marital_status,
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a' 
		END AS cst_gndr,
		cst_create_date
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM Bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
	) t
	WHERE flag_last = 1;

	-- ==========================================================================
	-- Silver.crm_prd_info
	-- Rules: Split prd_key into cat_id + prd_key, default null cost to 0,
	--        standardize product line codes, derive prd_end_dt from the next
	--        record's start date so date ranges never overlap.
	-- ==========================================================================
	TRUNCATE TABLE Silver.crm_prd_info;
	INSERT INTO Silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key))          AS prd_key,
		prd_nm,
		ISNULL(prd_cost, 0) AS prd_cost,
		CASE	
			WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountains'
			WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
			WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		CAST(
			LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
			AS DATE
		) AS prd_end_dt
	FROM Bronze.crm_prd_info;

	-- ==========================================================================
	-- Silver.crm_sales_details
	-- Rules: Convert 8-digit integer dates to DATE (or NULL if invalid),
	--        recalculate price/sales when missing, zero, negative, or
	--        inconsistent with quantity * price.
	-- ==========================================================================
	TRUNCATE TABLE Silver.crm_sales_details;
	INSERT INTO Silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE 
			WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE 
			WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE 
			WHEN sls_sales IS NULL OR sls_sales <= 0 THEN 
				CASE 
					WHEN sls_price > 0 AND sls_quantity > 0 THEN (sls_quantity * sls_price)
					ELSE NULL 
				END
			WHEN sls_price > 0 AND sls_quantity > 0 AND sls_sales != (sls_quantity * sls_price) THEN 
				(sls_quantity * sls_price)
			ELSE sls_sales 
		END AS sls_sales,
		sls_quantity,
		CASE 
			WHEN sls_price IS NULL OR sls_price <= 0 THEN 
				CASE 
					WHEN sls_sales > 0 AND sls_quantity > 0 THEN (sls_sales / sls_quantity)
					ELSE NULL 
				END
			ELSE sls_price 
		END AS sls_price
	FROM Bronze.crm_sales_details;

	PRINT '-------------------------------------------------------------';
	PRINT 'Loading ERP Tables';
	PRINT '-------------------------------------------------------------';

	-- ==========================================================================
	-- Silver.erp_CUST_AZ12
	-- Rules: Strip stray 'NAS' prefix from CID, null out future birth dates,
	--        standardize gender values.
	-- ==========================================================================
	TRUNCATE TABLE Silver.erp_CUST_AZ12;
	INSERT INTO Silver.erp_CUST_AZ12 (
		CID,
		BDATE,
		GEN
	)
	SELECT
		CASE 
			WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
			ELSE CID
		END AS CID,
		CASE 
			WHEN BDATE > GETDATE() THEN NULL
			ELSE BDATE
		END AS BDATE,
		CASE 
			WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE')   THEN 'Male'
			ELSE 'n/a'
		END AS GEN
	FROM Bronze.erp_CUST_AZ12;

	-- ==========================================================================
	-- Silver.erp_LOC_A101
	-- Rules: Remove hyphens from CID, standardize country abbreviations.
	-- ==========================================================================
	TRUNCATE TABLE Silver.erp_LOC_A101;
	INSERT INTO Silver.erp_LOC_A101 (
		CID,
		CNTRY
	)
	SELECT 
		REPLACE(CID, '-', '') AS CID,
		CASE	
			WHEN UPPER(TRIM(CNTRY)) IN ('US', 'USA') THEN 'United States'
			WHEN UPPER(TRIM(CNTRY)) = 'DE' THEN 'Germany'
			WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
			ELSE TRIM(CNTRY)
		END AS CNTRY
	FROM Bronze.erp_LOC_A101;

	-- ==========================================================================
	-- Silver.erp_PX_CAT_G1V2
	-- Rules: Direct 1:1 pass-through; source data arrives already clean.
	-- ==========================================================================
	TRUNCATE TABLE Silver.erp_PX_CAT_G1V2;
	INSERT INTO Silver.erp_PX_CAT_G1V2 (
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
	)
	SELECT
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
	FROM Bronze.erp_PX_CAT_G1V2;

	PRINT '=============================================================';
	PRINT 'Silver Layer Load Complete';
	PRINT '=============================================================';
END
GO
