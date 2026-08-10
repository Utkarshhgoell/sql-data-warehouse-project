# Naming Conventions

This document defines the naming conventions used across schemas, tables,
views, columns, and other objects in this data warehouse.

## General Principles

- **Case:** `snake_case`, with lowercase letters and underscores to separate words.
- **Language:** English, for all object and column names.
- **Reserved Words:** Avoid using SQL reserved words as object names.

## Table Naming (Bronze / Silver)

`<source_system>_<entity>`

- `source_system`: name of the source system (`crm`, `erp`).
- `entity`: the entity name as it appears in the source (e.g. `cust_info`, `prd_info`).

Example: `crm_cust_info` → customer information from the CRM system.

## Table Naming (Gold)

`<category>_<entity>`

| Pattern      | Meaning                | Example              |
|--------------|-------------------------|-----------------------|
| `dim_`       | Dimension table          | `dim_customers`       |
| `fact_`      | Fact table                | `fact_sales`          |

## Column Naming

- **Surrogate Keys:** All primary keys in dimension tables use the suffix `_key` (e.g. `customer_key`, `product_key`).
- **Technical Columns:** System-generated metadata columns are prefixed `dwh_` (e.g. `dwh_create_date`), placed at the end of the table.

## Stored Procedures

Load procedures follow the pattern `load_<layer>` (e.g. `load_bronze`, `load_silver`), placed in the schema they load into.
