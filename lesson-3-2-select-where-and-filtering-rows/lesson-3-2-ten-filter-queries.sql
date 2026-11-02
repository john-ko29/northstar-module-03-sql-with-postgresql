-- Return columns customer id, first name, last name and email from the customers table only if customer is from Wisconsin
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE state = 'WI'

--Return columns customer id, first name, last name, email and loyalty id from customers table only if customer is from Wisconsin and part of the loyalty program
SELECT customer_id, first_name, last_name, email, state, loyalty_id 
FROM customers
WHERE state = 'WI'
	AND loyalty_id IS NOT NULL;

--Return columns order id, customer id, order date, and order total from orders table with order dates in October 2024
SELECT order_id, customer_id, order_date, order_total
FROM orders
WHERE order_date >= '2024-10-01'
	AND order_date < '2024-11-01';

--Return 50 customers with order id, customer id, order date, and order total from orders table with order dates in October 2024 with order total greater than 300 
SELECT order_id, customer_id, order_date, order_total
FROM orders
WHERE order_date >= '2024-10-01'
	AND order_date < '2024-11-01'
	AND order_total > 300
	LIMIT 50;

--Return 20 customers with id, first name, and last name from customers table with last name starting with 'P'
SELECT customer_id, first_name, last_name
FROM customers
WHERE last_name LIKE 'P%'
LIMIT 20;

--Return 20 customers with id, first name, last name, and email from customers table with email ending in '@yahoo' ignoring case-insensitive
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE email ILIKE '%@yahoo.com'
LIMIT 20;

--Return products with id, name and category from products table with categories in 'Produce', 'Dairy', and 'Bakery'
SELECT product_id, product_name, category
FROM products
WHERE category IN ('Produce', 'Bakery', 'Dairy');

--Return 30 products with id, name and category from products table with categories in 'Produce', 'Dairy', and 'Bakery'
SELECT product_id, product_name, category
FROM products
WHERE category NOT IN ('Produce', 'Bakery', 'Dairy')
	AND product_name ILIKE '%organic%'
LIMIT 30;

-- Return 30 orders with id, customer id, order date, order total and payment method from orders table with pyament method is gift card and order total between 25 and 75
SELECT order_id, customer_id, order_date, order_total, payment_method
FROM orders
WHERE payment_method = 'gift_card'
	AND order_total BETWEEN 25 AND 75
LIMIT 30;

--Return 30 customers with id, first name, last name, email, state, loyalty id, and subscribed status from customers table where customer is from WI or MN, has a loyalty ID and is not email subscribed
SELECT customer_id, first_name, last_name, email, state, loyalty_id, email_subscribed
FROM customers
WHERE state IN ('MN', 'WI')
	AND loyalty_id IS NOT NULL
	AND (email_subscribed = FALSE OR email_subscribed IS NULL)
	AND email ILIKE '%@gmail.com'
LIMIT 30;