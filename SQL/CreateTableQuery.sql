\-- =========================================================

\-- Supply Chain Analytics Project

\-- File: 01\_create\_tables.sql

\-- Purpose: Create core database tables

\-- =========================================================





\-- =========================================================

\-- 1. CUSTOMERS

\-- =========================================================



CREATE TABLE customers (

&#x20;   customer\_id INT PRIMARY KEY,

&#x20;   customer\_name VARCHAR(100),

&#x20;   region VARCHAR(50)

);





\-- =========================================================

\-- 2. SUPPLIERS

\-- =========================================================



CREATE TABLE suppliers (

&#x20;   supplier\_id INT PRIMARY KEY,

&#x20;   supplier\_name VARCHAR(100),

&#x20;   supplier\_region VARCHAR(50),

&#x20;   lead\_time\_days INT

);





\-- =========================================================

\-- 3. WAREHOUSES

\-- =========================================================



CREATE TABLE warehouses (

&#x20;   warehouse\_id INT PRIMARY KEY,

&#x20;   warehouse\_name VARCHAR(100),

&#x20;   region VARCHAR(50)

);





\-- =========================================================

\-- 4. PRODUCTS

\-- =========================================================



CREATE TABLE products (

&#x20;   product\_id INT PRIMARY KEY,

&#x20;   product\_name VARCHAR(100),

&#x20;   category VARCHAR(50),

&#x20;   supplier\_id INT,

&#x20;   unit\_cost DECIMAL(10,2),

&#x20;   unit\_price DECIMAL(10,2)

);





\-- =========================================================

\-- 5. ORDERS

\-- =========================================================



CREATE TABLE orders (

&#x20;   order\_id INT PRIMARY KEY,

&#x20;   customer\_id INT,

&#x20;   warehouse\_id INT,

&#x20;   order\_date TIMESTAMP,

&#x20;   status VARCHAR(30)

);





\-- =========================================================

\-- 6. ORDER ITEMS

\-- =========================================================



CREATE TABLE order\_items (

&#x20;   order\_item\_id INT PRIMARY KEY,

&#x20;   order\_id INT,

&#x20;   product\_id INT,

&#x20;   quantity INT,

&#x20;   unit\_price DECIMAL(10,2)

);





\-- =========================================================

\-- 7. INVENTORY

\-- =========================================================



CREATE TABLE inventory (

&#x20;   inventory\_id INT PRIMARY KEY,

&#x20;   warehouse\_id INT,

&#x20;   product\_id INT,

&#x20;   inventory\_date DATE,

&#x20;   stock\_level DECIMAL(10,2),

&#x20;   reorder\_point DECIMAL(10,2)

);





\-- =========================================================

\-- 8. SHIPMENTS

\-- =========================================================



CREATE TABLE shipments (

&#x20;   shipment\_id INT PRIMARY KEY,

&#x20;   order\_id INT,

&#x20;   ship\_date DATE,

&#x20;   expected\_delivery\_date DATE,

&#x20;   actual\_delivery\_date DATE,

&#x20;   carrier VARCHAR(30),

&#x20;   shipping\_cost DECIMAL(10,2)

);

