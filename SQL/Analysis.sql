-- =========================================================
-- Supply Chain Analytics Project
-- File: 04_business_analysis.sql
-- Purpose: Business analysis queries
-- =========================================================


-- =========================================================
-- 1. ORDER PERFORMANCE
-- =========================================================

-- Order status distribution
SELECT
    status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- Monthly order volume
SELECT
    DATE_TRUNC('month', order_date) AS order_month,
    COUNT(*) AS order_count
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;


-- Orders by year
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    COUNT(*) AS order_count
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY order_year;


-- =========================================================
-- 2. PRODUCT PERFORMANCE
-- =========================================================

-- Top 10 products by revenue
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Top 10 products by gross profit
SELECT
    p.product_id,
    p.product_name,
    SUM(
        (oi.unit_price - p.unit_cost) * oi.quantity
    ) AS total_gross_profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_gross_profit DESC
LIMIT 10;


-- Top 10 products by profit margin
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    SUM(
        (oi.unit_price - p.unit_cost) * oi.quantity
    ) AS total_gross_profit,
    ROUND(
        SUM((oi.unit_price - p.unit_cost) * oi.quantity)
        * 100.0
        / SUM(oi.quantity * oi.unit_price),
        2
    ) AS profit_margin
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY profit_margin DESC
LIMIT 10;


-- =========================================================
-- 3. CUSTOMER PERFORMANCE
-- =========================================================

-- Top 10 customers by number of orders
SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC
LIMIT 10;


-- Top 10 customers by revenue
SELECT
    o.customer_id,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_revenue DESC
LIMIT 10;


-- Customers with highest cancellation rate
-- Only customers with at least 10 orders
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,
    ROUND(
        SUM(
            CASE
                WHEN status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 10
ORDER BY cancellation_rate DESC
LIMIT 10;


-- =========================================================
-- 4. INVENTORY PERFORMANCE
-- =========================================================

-- Inventory status
SELECT
    CASE
        WHEN stock_level <= reorder_point THEN 'Need Reorder'
        ELSE 'Sufficient Stock'
    END AS inventory_status,
    COUNT(*) AS inventory_count
FROM inventory
GROUP BY inventory_status;


-- Reorder rate by warehouse
SELECT
    warehouse_id,
    COUNT(*) AS total_inventory_records,
    SUM(
        CASE
            WHEN stock_level <= reorder_point THEN 1
            ELSE 0
        END
    ) AS reorder_records,
    ROUND(
        SUM(
            CASE
                WHEN stock_level <= reorder_point THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS reorder_rate
FROM inventory
GROUP BY warehouse_id
ORDER BY reorder_rate DESC;


-- Stockout occurrences by product
SELECT
    product_id,
    COUNT(*) AS stockout_records
FROM inventory
WHERE stock_level = 0
GROUP BY product_id
ORDER BY stockout_records DESC
LIMIT 10;


-- =========================================================
-- 5. SUPPLIER PERFORMANCE
-- =========================================================

-- Average supplier lead time by region
SELECT
    supplier_region,
    ROUND(AVG(lead_time_days)) AS avg_lead_time_days
FROM suppliers
GROUP BY supplier_region
ORDER BY avg_lead_time_days DESC;


-- Reorder rate by supplier
SELECT
    s.supplier_id,
    s.supplier_name,
    s.supplier_region,
    s.lead_time_days,
    COUNT(*) AS total_inventory_records,
    SUM(
        CASE
            WHEN i.stock_level <= i.reorder_point THEN 1
            ELSE 0
        END
    ) AS reorder_records,
    ROUND(
        SUM(
            CASE
                WHEN i.stock_level <= i.reorder_point THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS reorder_rate
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_region,
    s.lead_time_days
ORDER BY reorder_rate DESC;


-- =========================================================
-- 6. LOGISTICS PERFORMANCE
-- =========================================================

-- Average delivery time
SELECT
    ROUND(
        AVG(actual_delivery_date - ship_date)
    ) AS avg_delivery_days
FROM shipments
WHERE actual_delivery_date IS NOT NULL;


-- On-time delivery distribution
SELECT
    CASE
        WHEN actual_delivery_date <= expected_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS shipment_count
FROM shipments
WHERE actual_delivery_date IS NOT NULL
GROUP BY delivery_status;


-- Average days late
SELECT
    ROUND(
        AVG(actual_delivery_date - expected_delivery_date),
        2
    ) AS avg_days_late
FROM shipments
WHERE actual_delivery_date > expected_delivery_date;


-- On-time rate by carrier
SELECT
    carrier,
    COUNT(*) AS total_shipments,
    SUM(
        CASE
            WHEN actual_delivery_date <= expected_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_shipments,
    ROUND(
        SUM(
            CASE
                WHEN actual_delivery_date <= expected_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_rate
FROM shipments
WHERE actual_delivery_date IS NOT NULL
GROUP BY carrier
ORDER BY on_time_rate DESC;


-- Average shipping cost by carrier
SELECT
    carrier,
    COUNT(*) AS total_shipments,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost
FROM shipments
GROUP BY carrier
ORDER BY avg_shipping_cost DESC;


-- =========================================================
-- 7. WAREHOUSE PERFORMANCE
-- =========================================================

-- Orders by warehouse
SELECT
    warehouse_id,
    COUNT(*) AS order_count
FROM orders
GROUP BY warehouse_id
ORDER BY order_count DESC;


-- Revenue by warehouse
SELECT
    o.warehouse_id,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.warehouse_id
ORDER BY total_revenue DESC;