/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks for data consistency, accuracy, and 
    standardization across the 'Silver' and 'Gold' layers. It checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields (e.g. sales = quantity * price).

    Run these checks after executing Silver.load_silver and after creating the
    Gold views. Any row returned by a query below indicates a data quality
    issue that should be investigated.
Author:
    Utkarsh Goel
===============================================================================
*/

-- ============================================================================
-- Silver.crm_cust_info
-- ============================================================================

-- Expect no rows: duplicate or NULL primary keys
SELECT cst_id, COUNT(*)
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Expect no rows: unwanted leading/trailing spaces
SELECT cst_firstname
FROM Silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Expect distinct list to only show standardized values
SELECT DISTINCT cst_marital_status
FROM Silver.crm_cust_info;

-- ============================================================================
-- Silver.crm_prd_info
-- ============================================================================

-- Expect no rows: duplicate or NULL primary keys
SELECT prd_id, COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Expect no rows: negative or NULL product cost
SELECT prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Expect no rows: end date earlier than start date
SELECT *
FROM Silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ============================================================================
-- Silver.crm_sales_details
-- ============================================================================

-- Expect no rows: order date later than ship/due date
SELECT *
FROM Silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Expect no rows: sales must equal quantity * price, and none may be NULL,
-- zero, or negative
SELECT sls_sales, sls_quantity, sls_price
FROM Silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;

-- ============================================================================
-- Silver.erp_CUST_AZ12
-- ============================================================================

-- Expect no rows: birthdate outside a plausible range
SELECT BDATE
FROM Silver.erp_CUST_AZ12
WHERE BDATE < '1924-01-01' OR BDATE > GETDATE();

-- Expect distinct list to only show standardized values
SELECT DISTINCT GEN
FROM Silver.erp_CUST_AZ12;

-- ============================================================================
-- Gold Layer: Referential Integrity
-- ============================================================================

-- Expect no rows: fact_sales rows that fail to join to a dimension
SELECT f.*
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customers c ON f.customer_key = c.customer_key
LEFT JOIN Gold.dim_products  p ON f.product_key  = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;
