# Supply Chain Analytics Project

## Project Overview

This project is an end-to-end **Supply Chain Analytics** portfolio project built using **PostgreSQL, SQL, and Tableau Public**.

The goal was to build a relational supply chain database, validate data quality, perform business analysis with SQL, and develop interactive dashboards to evaluate:

* Order performance
* Product revenue and profitability
* Customer behavior
* Inventory and stockout risk
* Supplier lead time
* Warehouse performance
* Shipment and carrier performance
* Revenue trends over time

The dataset covers **January 2024 through December 2025**.

---

## Tools Used

* PostgreSQL
* pgAdmin
* SQL
* Tableau Public
* CSV
* GitHub

---

## Dataset

The project uses a simulated supply chain dataset containing 8 relational tables:

| Table         | Description                                          |
| ------------- | ---------------------------------------------------- |
| `customers`   | Customer master data                                 |
| `suppliers`   | Supplier information and lead times                  |
| `warehouses`  | Warehouse locations                                  |
| `products`    | Product, category, cost, price, and supplier data    |
| `orders`      | Customer orders and order status                     |
| `order_items` | Products and quantities within each order            |
| `inventory`   | Monthly inventory snapshots by product and warehouse |
| `shipments`   | Shipment dates, carriers, delivery dates, and costs  |

### Dataset Size

* **5,000** customers
* **500** products
* **30** suppliers
* **5** warehouses
* **50,000** orders
* **99,901** order items
* **60,000** inventory records
* **50,000** shipments

---

## Database Relationships

The database was designed using primary and foreign key relationships.

```text
suppliers
    |
    └── products
            |
            ├── order_items
            └── inventory

customers
    |
    └── orders
            |
            ├── order_items
            └── shipments

warehouses
    |
    ├── orders
    └── inventory
```

Key foreign keys:

* `products.supplier_id → suppliers.supplier_id`
* `orders.customer_id → customers.customer_id`
* `orders.warehouse_id → warehouses.warehouse_id`
* `order_items.order_id → orders.order_id`
* `order_items.product_id → products.product_id`
* `inventory.warehouse_id → warehouses.warehouse_id`
* `inventory.product_id → products.product_id`
* `shipments.order_id → orders.order_id`

---

## Project Workflow

The project followed this workflow:

```text
Raw CSV Data
      ↓
PostgreSQL Database
      ↓
Primary / Foreign Keys
      ↓
Data Quality Validation
      ↓
SQL Business Analysis
      ↓
Analytics Views
      ↓
CSV Exports
      ↓
Tableau Public
      ↓
Business Insights
```

---

# Data Quality Validation

SQL was used to validate the dataset before performing business analysis.

Checks included:

* Missing values
* Invalid quantities
* Invalid prices
* Invalid stock levels
* Invalid reorder points
* Order status validation
* Date validation
* Foreign key integrity
* Cross-table pricing consistency
* Shipment delivery logic

### Key Data Quality Findings

* No products had `unit_price <= unit_cost`
* No order items had zero or negative quantity
* No negative inventory levels were found
* No negative reorder points were found
* **100 of 60,000 inventory records** contained missing `stock_level` or `reorder_point` values
* **3,853 shipments** did not have an `actual_delivery_date`
* **58 shipments** had an actual delivery date earlier than the ship date
* **4,065 shipments** were delivered earlier than expected

Missing inventory values were retained as `NULL` because missing information does not necessarily represent zero inventory.

---

# SQL Business Analysis

## 1. Order Performance

Order status distribution:

| Status    | Orders | Percentage |
| --------- | -----: | ---------: |
| Completed | 45,539 |     91.08% |
| Cancelled |  2,535 |      5.07% |
| Pending   |  1,926 |      3.85% |

Order volume:

* **2024:** 24,933 orders
* **2025:** 25,067 orders
* Year-over-year growth: approximately **0.54%**

Order demand remained relatively stable between the two years.

---

## 2. Product Performance

Products were evaluated using:

* Quantity sold
* Revenue
* Gross profit
* Gross profit margin

### Key Findings

* **Product 0354** generated the highest revenue at approximately **$439.6K**
* **Product 0194** generated the highest gross profit at approximately **$191.4K**
* The products with the highest quantity sold were different from the products generating the highest revenue
* The product with the highest profit margin did not generate the highest total profit

This demonstrates why product performance should be evaluated using multiple metrics rather than revenue alone.

---

## 3. Customer Performance

Customers were analyzed using:

* Number of orders
* Total revenue
* Average order value
* Cancellation rate

### Key Findings

* **Customer 04015** generated the highest revenue at approximately **$37.1K**
* The customer with the highest number of orders was not the highest-revenue customer
* Customer revenue was driven by both purchase frequency and average order value
* Among customers with at least 10 orders, **Customer 04988** had the highest cancellation rate at **45.45%**

---

## 4. Inventory Performance

Inventory status was determined using `stock_level` and `reorder_point`.

### Inventory Status

* **50,904** records: Sufficient Stock
* **8,714** records: Need Reorder
* **282** records: Stockout
* **100** records: Missing Data

Overall reorder risk:

> **Approximately 15% of inventory records were at or below their reorder point.**

### Warehouse Findings

* Warehouse D had the highest reorder rate at approximately **15.39%**
* Warehouse E had the lowest reorder rate at approximately **14.65%**
* Inventory risk was relatively evenly distributed across warehouses

### Stockout Findings

Products with the highest number of stockout occurrences included:

* Product 0496
* Product 0095

---

## 5. Supplier Performance

Suppliers were analyzed using:

* Lead time
* Supplier region
* Inventory reorder rate

### Average Lead Time by Region

| Region        | Avg Lead Time |
| ------------- | ------------: |
| Latin America |       20 days |
| Asia          |       19 days |
| Europe        |       19 days |
| North America |       13 days |

Latin America had the longest average supplier lead time.

However, supplier and regional reorder rates remained relatively similar, suggesting that:

> **Lead time alone did not show a clear relationship with inventory reorder risk in this dataset.**

---

## 6. Logistics Performance

Shipment performance was evaluated using delivery dates, expected dates, carrier, and shipping cost.

### Key KPIs

* Average delivery time: **5 days**
* On-time delivery rate: **68.86%**
* Late delivery rate: **31.14%**
* Average late delivery: **2.66 days**

### Carrier Performance

| Carrier   | On-Time Rate | Avg Shipping Cost |
| --------- | -----------: | ----------------: |
| Carrier B |       69.79% |            $45.28 |
| Carrier C |       68.65% |            $45.11 |
| Carrier A |       68.56% |            $44.95 |
| Carrier D |       68.45% |            $45.05 |

Carrier B had the strongest on-time performance, although its average shipping cost was also slightly higher.

---

## 7. Warehouse Performance

Warehouse performance was evaluated using:

* Order volume
* Revenue
* Reorder rate
* Stockout frequency

### Revenue by Warehouse

| Warehouse   | Orders | Revenue |
| ----------- | -----: | ------: |
| Warehouse B | 12,014 | $13.96M |
| Warehouse E | 10,062 | $11.42M |
| Warehouse A |  9,830 | $11.32M |
| Warehouse C |  9,603 | $11.29M |
| Warehouse D |  8,491 |  $9.78M |

Warehouse B processed the highest order volume and generated the most revenue.

Warehouse D handled the lowest order volume but showed the highest stockout frequency, suggesting that inventory risk was not simply driven by workload.

---

# Tableau Dashboards

Four dashboards were created in Tableau Public.

## 1. Executive Supply Chain Performance Overview

Provides a high-level overview of:

* Total Orders
* Total Revenue
* Cancellation Rate
* Reorder Rate
* On-Time Delivery Rate
* Order Status
* Top Products by Revenue
* Warehouse Revenue
* Inventory Status

![Executive Overview](dashboards/executive_overview.png)

---

## 2. Inventory & Supplier Performance

Focuses on inventory and sourcing risk:

* Reorder Rate
* Stockout Records
* Average Supplier Lead Time
* Reorder Rate by Warehouse
* Supplier Lead Time by Region
* Products with the Most Stockout Occurrences
* Supplier Reorder Rate

![Inventory & Supplier](dashboards/inventory_supplier.png)

---

## 3. Logistics & Customer Performance

Evaluates logistics and customer behavior:

* On-Time Delivery Rate
* Average Delivery Time
* Average Days Late
* On-Time Rate by Carrier
* Average Shipping Cost by Carrier
* Top Customers by Revenue
* Customer Cancellation Rate

![Logistics & Customer](dashboards/logistics_customer.png)

---

## 4. Revenue & Sales Trend

Analyzes sales activity over time:

* Total Revenue
* Total Orders
* Average Order Value
* Monthly Revenue Trend
* Monthly Order Volume
* Revenue by Product Category

![Revenue & Sales Trend](dashboards/revenue_sales_trend.png)

---

# Key Business Insights

1. **Order volume was stable year over year**, increasing by approximately 0.54% from 2024 to 2025.

2. **Revenue and volume were driven by different products**, showing that high sales volume does not automatically produce the highest revenue or profit.

3. **Approximately 15% of inventory records required replenishment**, while warehouse reorder rates remained relatively similar.

4. **Supplier lead time varied significantly by region**, but longer lead times did not clearly correspond with higher reorder rates.

5. **Nearly one-third of delivered shipments were late**, with late shipments averaging approximately 2.66 days beyond the expected delivery date.

6. **Carrier B achieved the highest on-time delivery rate**, but also had a slightly higher average shipping cost.

7. **Customer value was influenced by both purchase frequency and order size**, meaning order count alone was not sufficient for identifying high-value customers.

8. **Warehouse B led in revenue and order volume**, while Warehouse D showed greater inventory risk despite handling fewer orders.

---

# Repository Structure

```text
Supply_Chain_Analytics_Project/
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_foreign_keys.sql
│   ├── 03_data_quality.sql
│   ├── 04_business_analysis.sql
│   └── 05_analytics_views.sql
│
├── dashboards/
│   ├── executive_overview.png
│   ├── inventory_supplier.png
│   ├── logistics_customer.png
│   └── revenue_sales_trend.png
│
├── data/
│   └── tableau_exports/
│
└── README.md
```

---

# Skills Demonstrated

* Relational database design
* Primary and foreign keys
* SQL joins
* Aggregate functions
* `CASE WHEN`
* Conditional aggregation
* `GROUP BY`
* `HAVING`
* Data quality validation
* Revenue analysis
* Profitability analysis
* Inventory risk analysis
* Supplier performance analysis
* Customer analytics
* Warehouse analysis
* Logistics analytics
* KPI development
* Tableau dashboard design
* Business storytelling

---

# Limitations

This project uses a **simulated dataset** created for portfolio and analytical practice.

The dataset does not include variables such as:

* Supplier contracts
* Transportation distance
* Demand forecasts
* Safety stock targets
* Promotional activity
* Product service-level targets
* Transportation mode

Therefore, the project identifies operational patterns and relationships but does not establish causal conclusions.

---

# Tableau Public

**Interactive dashboards:**
https://public.tableau.com/app/profile/lan.chu8317/viz/DataManagementandIn-depthAnalysisDashboards

---

# Author

Lan Jimmie Chu

Supply Chain Management / Business Analytics
https://www.linkedin.com/in/lan-jimmie-chu-45baa8304/
