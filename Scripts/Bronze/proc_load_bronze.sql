/* ==============================================================================
   Script Name:    Bronze Layer Data Ingestion (Truncate & Load)
   Author:         Utkarsh Goel
   
   Description:    This script performs a full data refresh of the Bronze schema.
                   It first truncates existing tables to remove old records, then
                   uses BULK INSERT to load raw CSV data from the local datasets
                   folder (CRM and ERP source systems) into their respective
                   Bronze tables.

   Target Schema:  Bronze

   Setup:          Update the @SourcePath variable below to the absolute path of
                   the 'datasets' folder on the machine running SQL Server, then
                   execute EXEC Bronze.load_bronze;

   Notes:          - Uses TABLOCK to optimize the bulk loading process.
                   - FIRSTROW = 2 skips the header row in the source files.
                   - Ensure the local file paths are accessible by the SQL Server
                     service account before executing.
   ============================================================================== */

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @SourcePath NVARCHAR(500) = 'C:\sql-data-warehouse-project\datasets'; -- << update to your local path

	PRINT '=============================================================';
	PRINT 'Loading Bronze Layer';
	PRINT '=============================================================';

	PRINT '-------------------------------------------------------------';
	PRINT 'Loading CRM Tables';
	PRINT '-------------------------------------------------------------';

	TRUNCATE TABLE Bronze.crm_cust_info;
	BULK INSERT Bronze.crm_cust_info
	FROM 'C:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	TRUNCATE TABLE Bronze.crm_prd_info;
	BULK INSERT Bronze.crm_prd_info
	FROM 'C:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	TRUNCATE TABLE Bronze.crm_sales_details;
	BULK INSERT Bronze.crm_sales_details
	FROM 'C:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	PRINT '-------------------------------------------------------------';
	PRINT 'Loading ERP Tables';
	PRINT '-------------------------------------------------------------';

	TRUNCATE TABLE Bronze.erp_CUST_AZ12;
	BULK INSERT Bronze.erp_CUST_AZ12
	FROM 'C:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	TRUNCATE TABLE Bronze.erp_LOC_A101;
	BULK INSERT Bronze.erp_LOC_A101
	FROM 'C:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2;
	BULK INSERT Bronze.erp_PX_CAT_G1V2
	FROM 'C:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	PRINT '=============================================================';
	PRINT 'Bronze Layer Load Complete';
	PRINT '=============================================================';
END
GO
