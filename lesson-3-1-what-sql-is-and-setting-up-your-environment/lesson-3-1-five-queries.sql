SELECT * FROM stores;
-- Select all rows from table stores

SELECT * FROM products
LIMIT 10;
-- Take the first 10 rows from table products

SELECT product_name, category
FROM products LIMIT 20;
--Take first 20 rows with columns product_name and category from table products

SELECT COUNT(*) FROM customers;
--Count how many rows of data from table customers

SELECT supplier_name, city, country
FROM suppliers;
-- Display columns supplier_name, city, and country from table suppliers