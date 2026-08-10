# Data Catalog — Gold Layer

## Overview

The Gold Layer is the business-facing layer of the warehouse, structured as a
star schema for reporting and analytics. It consists of one fact view and two
dimension views built on top of the cleansed Silver layer.

---

### 1. `Gold.dim_customers`

**Purpose:** One row per customer, enriched with demographic details merged
from the CRM and ERP source systems.

| Column Name       | Data Type     | Description                                                          |
|--------------------|---------------|------------------------------------------------------------------------------|
| customer_key       | INT           | Surrogate key uniquely identifying each customer record in the Gold layer.   |
| customer_id        | INT           | Original customer identifier from the CRM system.                            |
| customer_number    | NVARCHAR(50)  | Alphanumeric customer identifier used for tracing and joins.                 |
| firstname          | NVARCHAR(50)  | Customer's first name.                                                       |
| lastname           | NVARCHAR(50)  | Customer's last name.                                                        |
| country            | NVARCHAR(50)  | Country of residence (e.g. 'Australia', 'Germany').                          |
| marital_status     | NVARCHAR(50)  | Marital status of the customer ('Married', 'Single', 'n/a').                 |
| birthdate          | DATE          | Date of birth, sourced from the ERP system (NULL if invalid/future date).    |
| gender             | NVARCHAR(50)  | Gender ('Male', 'Female', 'n/a'), reconciled between CRM and ERP.            |
| create_date        | DATE          | Date the customer record was first created in the CRM system.                |

---

### 2. `Gold.dim_products`

**Purpose:** One row per currently active product, enriched with category
and subcategory attributes.

| Column Name    | Data Type     | Description                                                             |
|-----------------|---------------|---------------------------------------------------------------------------------|
| product_key     | INT           | Surrogate key uniquely identifying each product record in the Gold layer.       |
| product_id      | INT           | Original product identifier from the CRM system.                                |
| product_number  | NVARCHAR(50)  | Structured alphanumeric product code.                                           |
| product_name    | NVARCHAR(50)  | Descriptive product name.                                                       |
| category_id     | NVARCHAR(50)  | Identifier linking the product to its category.                                 |
| category        | NVARCHAR(50)  | High-level product category (e.g. 'Bikes', 'Accessories').                      |
| subcategory     | NVARCHAR(50)  | Detailed product subcategory.                                                   |
| maintenance     | NVARCHAR(50)  | Indicates whether the product requires maintenance ('Yes'/'No').                |
| cost            | INT           | Product cost/unit price.                                                        |
| product_line    | NVARCHAR(50)  | Product line ('Mountains', 'Road', 'Touring', 'Other Sales').                   |
| start_date      | DATE          | Date the product became active/available for sale.                              |

---

### 3. `Gold.fact_sales`

**Purpose:** One row per sales order line, linking to the customer and
product dimensions.

| Column Name    | Data Type     | Description                                                             |
|-----------------|---------------|---------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | Unique sales order identifier.                                                  |
| product_key     | INT           | Foreign key to `Gold.dim_products.product_key`.                                 |
| customer_key    | INT           | Foreign key to `Gold.dim_customers.customer_key`.                               |
| order_date      | DATE          | Date the order was placed.                                                      |
| shipping_date   | DATE          | Date the order was shipped.                                                     |
| due_date        | DATE          | Date the order payment was due.                                                 |
| sales_amount    | INT           | Total sales value of the order line (validated as quantity × price).            |
| quantity        | INT           | Number of units ordered.                                                        |
| price            | INT           | Unit price of the product for this order line.                                  |
