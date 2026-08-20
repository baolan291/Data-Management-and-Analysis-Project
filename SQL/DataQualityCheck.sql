\-- =========================================================
-- Supply Chain Analytics Project
-- File: 03_data_quality.sql
-- Purpose: Validate data quality and business logic
-- =========================================================


-- =========================================================
-- 1. SUPPLIER DATA QUALITY
-- =========================================================

-- Check missing supplier values
SELECT
    COUNT(*) AS total_suppliers,
    COUNT(supplier_name) AS suppliers_with_name,
    COUNT(supplier_region) AS suppliers_with_region,
    COUNT(lead_time_days) AS suppliers_with_lead_time
FROM suppliers;


-- =========================================================
-- 2. PRODUCT DATA QUALITY
-- =========================================================

-- Check missing product values
SELECT
    COUNT(*) AS total_products,
    COUNT(product_name) AS products_with_name,
    COUNT(category) AS products_with_category,
    COUNT(supplier_id) AS products_with_supplier,
    COUNT(unit_cost) AS products_with_cost,
    COUNT(unit_price) AS products_with_price
FROM products;


-- Check invalid pricing
SELECT
    product_id,
    product_name,
    unit_cost,
    unit_price
FROM products
WHERE unit_price <= unit_cost;


-- =========================================================
-- 3. ORDER DATA QUALITY
-- =========================================================

-- Check missing order values
SELECT
    COUNT(*) AS total_orders,
    COUNT(customer_id) AS orders_with_customer,
    COUNT(warehouse_id) AS orders_with_warehouse,
    COUNT(order_date) AS orders_with_date,
    COUNT(status) AS orders_with_status
FROM orders;


-- Check order status values
SELECT
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- Check order date range
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM orders;


-- =========================================================
-- 4. ORDER ITEM DATA QUALITY
-- =========================================================

-- Check missing order item values
SELECT
    COUNT(*) AS total_order_items,
    COUNT(order_id) AS items_with_order,
    COUNT(product_id) AS items_with_product,
    COUNT(quantity) AS items_with_quantity,
    COUNT(unit_price) AS items_with_price
FROM order_items;


-- Check quantity range
SELECT
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    AVG(quantity) AS avg_quantity
FROM order_items;


-- Check invalid quantities
SELECT *
FROM order_items
WHERE quantity <= 0;


-- Check invalid prices
SELECT *
FROM order_items
WHERE unit_price <= 0;


-- Check order item price consistency with product price
SELECT
    oi.order_item_id,
    oi.product_id,
    oi.unit_price AS order_item_price,
    p.unit_price AS product_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.unit_price <> p.unit_price;


-- =========================================================
-- 5. INVENTORY DATA QUALITY
-- =========================================================

-- Check missing inventory values
SELECT
    COUNT(*) AS total_inventory,
    COUNT(warehouse_id) AS inventory_with_warehouse,
    COUNT(product_id) AS inventory_with_product,
    COUNT(inventory_date) AS inventory_with_date,
    COUNT(stock_level) AS inventory_with_stock,
    COUNT(reorder_point) AS inventory_with_reorder_point
FROM inventory;


-- Count missing stock and reorder values
SELECT
    COUNT(*) FILTER (
        WHERE stock_level IS NULL
    ) AS missing_stock,

    COUNT(*) FILTER (
        WHERE reorder_point IS NULL
    ) AS missing_reorder_point,

    COUNT(*) FILTER (
        WHERE stock_level IS NULL
          AND reorder_point IS NULL
    ) AS missing_both
FROM inventory;


-- Review inventory records with missing data
SELECT *
FROM inventory
WHERE stock_level IS NULL
   OR reorder_point IS NULL;


-- Check missing inventory values by warehouse
SELECT
    warehouse_id,
    COUNT(*) AS affected_records
FROM inventory
WHERE stock_level IS NULL
   OR reorder_point IS NULL
GROUP BY warehouse_id
ORDER BY affected_records DESC;


-- Check missing inventory values by date
SELECT
    inventory_date,
    COUNT(*) AS affected_records
FROM inventory
WHERE stock_level IS NULL
   OR reorder_point IS NULL
GROUP BY inventory_date
ORDER BY inventory_date;


-- Check negative stock levels
SELECT *
FROM inventory
WHERE stock_level < 0;


-- Check negative reorder points
SELECT *
FROM inventory
WHERE reorder_point < 0;


-- =========================================================
-- 6. SHIPMENT DATA QUALITY
-- =========================================================

-- Check missing shipment values
SELECT
    COUNT(*) AS total_shipments,
    COUNT(order_id) AS shipments_with_order,
    COUNT(ship_date) AS shipments_with_ship_date,
    COUNT(expected_delivery_date) AS shipments_with_expected_date,
    COUNT(actual_delivery_date) AS shipments_with_actual_date,
    COUNT(carrier) AS shipments_with_carrier,
    COUNT(shipping_cost) AS shipments_with_cost
FROM shipments;


-- Check invalid shipping cost
SELECT *
FROM shipments
WHERE shipping_cost <= 0;


-- Review shipments without an actual delivery date by order status
SELECT
    o.status,
    COUNT(*) AS shipment_count
FROM shipments s
JOIN orders o
    ON s.order_id = o.order_id
WHERE s.actual_delivery_date IS NULL
GROUP BY o.status
ORDER BY shipment_count DESC;


-- Completed orders without actual delivery date
SELECT
    COUNT(*) AS completed_without_delivery
FROM shipments s
JOIN orders o
    ON s.order_id = o.order_id
WHERE o.status = 'Completed'
  AND s.actual_delivery_date IS NULL;


-- Invalid delivery dates:
-- actual delivery occurs before shipment
SELECT
    COUNT(*) AS invalid_delivery_dates
FROM shipments
WHERE actual_delivery_date < ship_date;


-- Early deliveries:
-- valid business condition, not necessarily a data error
SELECT
    COUNT(*) AS early_deliveries
FROM shipments
WHERE actual_delivery_date < expected_delivery_date;


-- =========================================================
-- 7. REFERENTIAL INTEGRITY CHECKS
-- =========================================================

-- Products without a valid supplier
SELECT
    p.product_id,
    p.supplier_id
FROM products p
LEFT JOIN suppliers s
    ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;


-- Orders without a valid customer
SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Orders without a valid warehouse
SELECT
    o.order_id,
    o.warehouse_id
FROM orders o
LEFT JOIN warehouses w
    ON o.warehouse_id = w.warehouse_id
WHERE w.warehouse_id IS NULL;


-- Order items without a valid order
SELECT
    oi.order_item_id,
    oi.order_id
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items without a valid product
SELECT
    oi.order_item_id,
    oi.product_id
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Inventory without a valid warehouse
SELECT
    i.inventory_id,
    i.warehouse_id
FROM inventory i
LEFT JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE w.warehouse_id IS NULL;


-- Inventory without a valid product
SELECT
    i.inventory_id,
    i.product_id
FROM inventory i
LEFT JOIN products p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Shipments without a valid order
SELECT
    s.shipment_id,
    s.order_id
FROM shipments s
LEFT JOIN orders o
    ON s.order_id = o.order_id
WHERE o.order_id IS NULL;
