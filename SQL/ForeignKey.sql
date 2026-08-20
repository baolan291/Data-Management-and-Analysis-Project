-- =========================================================
-- Supply Chain Analytics Project
-- File: 02_foreign_keys.sql
-- Purpose: Add foreign key relationships
-- =========================================================


-- =========================================================
-- 1. PRODUCTS -> SUPPLIERS
-- =========================================================

ALTER TABLE products
ADD CONSTRAINT fk_products_suppliers
FOREIGN KEY (supplier_id)
REFERENCES suppliers(supplier_id);


-- =========================================================
-- 2. ORDERS -> CUSTOMERS
-- =========================================================

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- =========================================================
-- 3. ORDERS -> WAREHOUSES
-- =========================================================

ALTER TABLE orders
ADD CONSTRAINT fk_orders_warehouses
FOREIGN KEY (warehouse_id)
REFERENCES warehouses(warehouse_id);


-- =========================================================
-- 4. ORDER ITEMS -> ORDERS
-- =========================================================

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);


-- =========================================================
-- 5. ORDER ITEMS -> PRODUCTS
-- =========================================================

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);


-- =========================================================
-- 6. INVENTORY -> WAREHOUSES
-- =========================================================

ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_warehouses
FOREIGN KEY (warehouse_id)
REFERENCES warehouses(warehouse_id);


-- =========================================================
-- 7. INVENTORY -> PRODUCTS
-- =========================================================

ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);


-- =========================================================
-- 8. SHIPMENTS -> ORDERS
-- =========================================================

ALTER TABLE shipments
ADD CONSTRAINT fk_shipments_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);