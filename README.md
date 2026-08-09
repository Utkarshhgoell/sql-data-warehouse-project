# 🏗️ SQL Data Warehouse Project

A modern data warehouse built with SQL Server — from raw CRM/ERP source files
to a clean, analytics-ready **star schema** — following the **Medallion
Architecture** (Bronze → Silver → Gold).

> 🎓 **This is a Guided Project**, completed by following the free
> **[SQL Data Warehouse from Scratch](https://youtu.be/SSKVgrwhzus)** course
> by **[Data With Baraa](https://www.youtube.com/@DataWithBaraa)** on YouTube.
> All architecture concepts, course structure, and the original dataset are
> credited to Baraa Khatib Salkini — full credit section [below](#-acknowledgements--credit).
> The SQL scripts in this repository are my own implementation, written
> while working through the course.

---

## 📖 Project Overview

This project consolidates sales data from two source systems — **CRM** and
**ERP** — into a single SQL Server data warehouse, and builds SQL-based
analytics on top of it.

It covers:

- 🏗️ **Data Architecture** — designing a warehouse using Bronze, Silver, and Gold layers
- 🔄 **ETL Pipelines** — extracting, cleansing, and loading data with T-SQL stored procedures
- 🧩 **Data Modeling** — building fact and dimension tables in a star schema
- ✅ **Data Quality** — validation checks for nulls, duplicates, and referential integrity

---

## 🏛️ Data Architecture

![Data Architecture](docs/data_architecture.svg)

| Layer      | Purpose                                                                                   |
|------------|---------------------------------------------------------------------------------------------------|
| **Bronze** | Raw data, loaded as-is from CRM/ERP CSV source files via `BULK INSERT`. No transformations. |
| **Silver** | Cleansed, standardized, and de-duplicated data — types cast, codes decoded, dates validated. |
| **Gold**   | Business-ready views modeled as a star schema, exposed for reporting and analytics.        |

---

## 🔀 Data Flow

![Data Flow](docs/data_flow.svg)

## ⭐ Data Model — Star Schema

![Star Schema](docs/data_model_star_schema.svg)

The Gold layer exposes one fact view and two dimension views:

- **`Gold.fact_sales`** — one row per sales order line
- **`Gold.dim_customers`** — one row per customer, merged from CRM + ERP
- **`Gold.dim_products`** — one row per currently active product

Full column-level documentation is in [`docs/data_catalog.md`](docs/data_catalog.md).

---

## 📂 Repository Structure

```
sql-data-warehouse-project/
│
├── datasets/                              # Raw source CSV files (CRM + ERP)
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── docs/                                  # Documentation and diagrams
│   ├── data_architecture.svg              # Medallion architecture diagram
│   ├── data_flow.svg                      # Table-level lineage diagram
│   ├── data_model_star_schema.svg         # Gold layer star schema
│   ├── data_catalog.md                    # Column-level documentation of Gold views
│   └── naming_conventions.md              # Naming rules for schemas, tables, and columns
│
├── scripts/                               # SQL scripts for ETL and modeling
│   ├── bronze/
│   │   ├── ddl_bronze.sql                 # Table definitions
│   │   └── proc_load_bronze.sql           # Truncate + Bulk Insert load procedure
│   ├── silver/
│   │   ├── ddl_silver.sql                 # Table definitions
│   │   └── proc_load_silver.sql           # Cleansing & transformation load procedure
│   └── gold/
│       └── ddl_gold.sql                   # Star schema views
│
├── tests/
│   └── quality_checks.sql                 # Data quality validation queries
│
├── LICENSE
├── .gitignore
└── README.md
```

---

## 🚀 How to Run

1. Create a database named `Datawarehouse` in SQL Server (SSMS or Azure Data Studio), and create the `Bronze`, `Silver`, and `Gold` schemas.
2. Run `scripts/bronze/ddl_bronze.sql` to create the Bronze tables.
3. Run `scripts/silver/ddl_silver.sql` to create the Silver tables.
4. Open `scripts/bronze/proc_load_bronze.sql`, update the `@SourcePath` variable to point to your local `datasets` folder, then run it to create the load procedure.
5. Execute `EXEC Bronze.load_bronze;` to load the raw CSVs into Bronze.
6. Run `scripts/silver/proc_load_silver.sql` to create the transformation procedure, then execute `EXEC Silver.load_silver;`.
7. Run `scripts/gold/ddl_gold.sql` to create the Gold layer views.
8. Run `tests/quality_checks.sql` to validate the load.

---

## 🛠️ Tech Stack

- **SQL Server** — data warehouse engine
- **T-SQL** — DDL, stored procedures, and views
- **SSMS** — database development and querying
- **Draw.io** *(concepts)* / **hand-built SVG diagrams** — architecture documentation
- **Git & GitHub** — version control

---

## 🙏 Acknowledgements & Credit

This project was completed as a **guided learning exercise**, built entirely
by watching and following the **free SQL Data Warehouse course** by
**Data With Baraa** on YouTube. The course structure, the Medallion
Architecture approach, and the CRM/ERP practice datasets used in this
project all originate from his work.

- 📺 **YouTube Channel:** [Data With Baraa](https://www.youtube.com/@DataWithBaraa)
- 🎬 **Course Video:** [SQL Data Warehouse from Scratch](https://youtu.be/SSKVgrwhzus)
- 💻 **Original Repository:** [DataWithBaraa/sql-data-warehouse-project](https://github.com/DataWithBaraa/sql-data-warehouse-project)
- 🌐 **Website:** [datawithbaraa.com](https://www.datawithbaraa.com)

Huge thanks to Baraa for making this course completely free and accessible —
if you're learning data engineering, go subscribe to his channel.

The SQL scripts, table designs, README, and diagrams in *this* repository
are my own work, written and adapted while completing the course.

---

## 👤 About Me

**Utkarsh Goel**
Guided Project — SQL Data Warehousing & Analytics

Feel free to connect or reach out if you have questions about this project!

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE).
