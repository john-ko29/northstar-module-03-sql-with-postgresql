--Return number of rows in customers, number of rows with email not NULL, and number of rows with distinct emails
SELECT 
	COUNT(*) AS total_customer_count,
	COUNT(email) AS customer_with_email,
	COUNT(DISTINCT email) AS unique_customer
FROM customers;

-- Return the top 5 lifetime value customers in descending order with id, first name, last name and lifetime value. Exclude any lifetime value that is NULL
SELECT customer_id, first_name, last_name, lifetime_value
FROM customers
WHERE lifetime_value IS NOT NULL
ORDER BY lifetime_value DESC 
LIMIT 5;

--Return each state with their total customer count in descending order from customers table
SELECT state, COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;

--Return each state with their total customer count with loyalty ID in descending order from customers table 
SELECT state, COUNT(*) AS customer_count
FROM customers
WHERE loyalty_id IS NOT NULL
GROUP BY state
ORDER BY customer_count DESC;

--Return each state with total customer count over 5,000 in descending order from customers table
SELECT state, COUNT(*) AS customer_count
FROM customers
GROUP BY state
HAVING COUNT(*) > 5000
ORDER BY customer_count DESC;

--Return total sum of revenue of Q4
SELECT SUM(order_total) as total_revenue
FROM orders
WHERE order_date >= '2024-10-01' AND order_date < '2025-01-01';

--Return each payment method in descending order in total revenue with total usage, total revenue earned and average order value from orders table with date in the Q4
SELECT 
	payment_method,
	COUNT(*) AS order_count,
	SUM(order_total) AS q4_revenue,
	AVG(order_total) AS average_order_value
FROM orders
WHERE order_date >= '2024-10-01'
	AND order_date < '2025-01-01'
GROUP BY payment_method 
ORDER BY q4_revenue DESC;

--Find top 5 revenue store in descending order by ID and return the store's ID, total order count, total revenue, and average order value in the Q4
SELECT
	store_id,
	COUNT(*) AS order_count,
	SUM(order_total) AS q4_revenue,
	AVG(order_total) AS average_order_value
FROM orders
WHERE order_date >= '2024-10-01'
	AND order_date < '2025-01-01'
GROUP BY store_id
ORDER BY q4_revenue DESC
LIMIT 5;

--Return each store with Q4 revenue higher than $500,000 their store_id and revenue earned in Q4 from orders table. Listed in descending order.
SELECT store_id, SUM(order_total) AS q4_revenue
FROM orders 
WHERE order_date >= '2024-10-01'
	AND order_date < '2025-01-01'
GROUP BY store_id 
HAVING SUM(order_total) > 500000
ORDER BY q4_revenue DESC;

--Return each state with a total customer count with loyalty ID and lifetime value over $2,000. Only states with at least 100 customers who met this criteria Sort by customer count in descending order. 
SELECT state, COUNT(*) AS customer_count
FROM customers
WHERE loyalty_id IS NOT NULL
	AND lifetime_value > 2000
GROUP BY state 
HAVING COUNT(*) >= 100
ORDER BY customer_count DESC;
