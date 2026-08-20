-- =========================================================
-- Supply Chain Analytics Project
-- File: 05_analytics_views.sql
-- Purpose: Create analytics views for Tableau dashboards
-- =========================================================


-- =========================================================
-- 1. CREATE ANALYTICS SCHEMA
-- =========================================================

CREATE SCHEMA IF NOT EXISTS analytics;


-- =========================================================
-- 2. ORDER PERFORMANCE VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.order_performance AS
SELECT
    status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY status;


-- =========================================================
-- 3. PRODUCT PERFORMANCE VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(oi.quantity) AS total_quantity_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS total_revenue,

    SUM(
        (oi.unit_price - p.unit_cost) * oi.quantity
    ) AS total_gross_profit,

    ROUND(
        SUM(
            (oi.unit_price - p.unit_cost) * oi.quantity
        ) * 100.0
        / SUM(oi.quantity * oi.unit_price),
        2
    ) AS profit_margin

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category;


-- =========================================================
-- 4. INVENTORY PERFORMANCE VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.inventory_performance AS
SELECT
    i.inventory_id,
    i.warehouse_id,
    w.warehouse_name,

    i.product_id,
    p.product_name,
    p.category,

    i.inventory_date,
    i.stock_level,
    i.reorder_point,

    CASE
        WHEN i.stock_level IS NULL
          OR i.reorder_point IS NULL
            THEN 'Missing Data'

        WHEN i.stock_level = 0
            THEN 'Stockout'

        WHEN i.stock_level <= i.reorder_point
            THEN 'Need Reorder'

        ELSE 'Sufficient Stock'
    END AS inventory_status

FROM inventory i

JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id

JOIN products p
    ON i.product_id = p.product_id;


-- =========================================================
-- 5. SUPPLIER PERFORMANCE VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.supplier_performance AS
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
    s.lead_time_days;


-- =========================================================
-- 6. SHIPMENT PERFORMANCE VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.shipment_performance AS
SELECT
    shipment_id,
    order_id,
    carrier,

    ship_date,
    expected_delivery_date,
    actual_delivery_date,

    shipping_cost,

    CASE
        WHEN actual_delivery_date IS NULL
            THEN 'Not Delivered'

        WHEN actual_delivery_date <= expected_delivery_date
            THEN 'On Time'

        ELSE 'Late'
    END AS delivery_status,

    CASE
        WHEN actual_delivery_date IS NOT NULL
        THEN actual_delivery_date - ship_date
        ELSE NULL
    END AS delivery_days,

    CASE
        WHEN actual_delivery_date > expected_delivery_date
        THEN actual_delivery_date - expected_delivery_date
        ELSE 0
    END AS days_late

FROM shipments;


-- =========================================================
-- 7. WAREHOUSE PERFORMANCE VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.warehouse_performance AS
SELECT
    w.warehouse_id,
    w.warehouse_name,

    COUNT(
        DISTINCT o.order_id
    ) AS order_count,

    SUM(
        oi.quantity * oi.unit_price
    ) AS total_revenue

FROM warehouses w

JOIN orders o
    ON w.warehouse_id = o.warehouse_id

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    w.warehouse_id,
    w.warehouse_name;


-- =========================================================
-- 8. CUSTOMER PERFORMANCE VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.customer_performance AS
SELECT
    c.customer_id,
    c.customer_name,

    COUNT(
        DISTINCT o.order_id
    ) AS order_count,

    SUM(
        oi.quantity * oi.unit_price
    ) AS total_revenue,

    ROUND(
        SUM(
            oi.quantity * oi.unit_price
        )
        / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value,

    COUNT(
        DISTINCT CASE
            WHEN o.status = 'Cancelled'
            THEN o.order_id
        END
    ) AS cancelled_orders,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.status = 'Cancelled'
                THEN o.order_id
            END
        ) * 100.0
        / COUNT(DISTINCT o.order_id),
        2
    ) AS cancellation_rate

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_id,
    c.customer_name;


-- =========================================================
-- 9. REVENUE TREND VIEW
-- =========================================================

CREATE OR REPLACE VIEW analytics.revenue_trend AS
SELECT
    DATE_TRUNC(
        'month',
        o.order_date
    ) AS order_month,

    COUNT(
        DISTINCT o.order_id
    ) AS order_count,

    SUM(
        oi.quantity * oi.unit_price
    ) AS total_revenue,

    ROUND(
        SUM(
            oi.quantity * oi.unit_price
        )
        / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    DATE_TRUNC(
        'month',
        o.order_date
    )

ORDER BY order_month;