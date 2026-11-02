--Return 50 orders with their ID, date, total and the store name and city where the order comes from
--Inner Joined orders and stores tables by store_id and filtered in only Q4 orders
SELECT
	o.order_id,
	o.order_date,
	o.order_total,
	s.store_name,
	s.city
FROM orders AS o
INNER JOIN stores AS s
	ON o.store_id = s.store_id 
WHERE o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
LIMIT 50;


--Return store ID, name, city with their number of orders and total revenue in Q4 in total revenue descending order
-- Left Join so that orders with NULL will be included. COALESCE replaces NULL with 0.
SELECT 
	s.store_id,
	s.store_name,
	s.city,
	COUNT(o.order_id) AS q4_orders,
	COALESCE(SUM(o.order_total), 0) AS q4_revenue
FROM stores as s
LEFT JOIN orders AS o
	ON s.store_id = o.store_id 
	AND o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
GROUP BY s.store_id, s.store_name, s.city 
ORDER BY q4_revenue DESC;


--Return by region their Q4 order count, revenue and average order value. Two tables by inner joined, stores and orders table
SELECT
	s.region,
	COUNT(o.order_id) AS q4_order_count,
	SUM(o.order_total) AS q4_revenue,
	AVG(o.order_total) AS q4_average_value
FROM stores as s
INNER JOIN orders as o
	ON s.store_id = o.store_id 
WHERE o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
GROUP BY s.region 
ORDER BY q4_revenue;

--Return each customer their ID, first and last name, state, Q4 order count and Q4 total spending
--Inner joined two table, customers and orders, by customer_id
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	c.state,
	COUNT(o.order_id) as q4_order_count,
	SUM(o.order_total) as q4_total_spending
FROM customers as c
INNER JOIN orders as o
	ON c.customer_id = o.customer_id 
WHERE o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
GROUP BY c.customer_id, c.first_name, c.last_name, c.state 
ORDER BY q4_total_spending DESC
LIMIT 20;

--Return each order id, date, store name, store city, customer first and last name, and order total amount in Q4
--Joined three tables with orders with stores on store_id and orders with customer with customer_id
SELECT 
	o.order_id,
	o.order_date,
	s.store_name,
	s.city,
	c.first_name,
	c.last_name,
	o.order_total
FROM orders as o
INNER JOIN stores as s
	ON o.store_id = s.store_id
INNER JOIN customers as c
	ON o.customer_id = c.customer_id 
WHERE o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
ORDER BY o.order_total DESC
LIMIT 10;

--Return stores id, name, city and number of distinct customers in Q4
--Left join so to include stores that may have 0 customers in Q4
SELECT
	s.store_id,
	s.store_name,
	s.city,
	COUNT(DISTINCT o.customer_id) AS distinct_customers
FROM stores as s
LEFT JOIN orders as o
	ON s.store_id = o.store_id 
	AND o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
GROUP BY s.store_id, s.store_name, s.city 
ORDER BY distinct_customers DESC;

--Return store ID, name, city with their number of orders and total revenue in Q4 in total revenue descending order
-- Left Join so that orders with NULL will be included. COALESCE replaces NULL with 0.
SELECT 
	s.store_id,
	s.store_name,
	s.city,
	COUNT(o.order_id) AS q4_orders,
	COALESCE(SUM(o.order_total), 0) AS q4_revenue
FROM stores as s
LEFT JOIN orders AS o
	ON s.store_id = o.store_id 
WHERE o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
GROUP BY s.store_id, s.store_name, s.city 
ORDER BY q4_revenue DESC;
--I'm working with a dataset where every store has at least one Q4 order.
--The trap is that it will exclude stores that have 0 q4 orders

-- Return for each state by total revenue descending order their distinct amount of customers, total revenue and average order value for Q4.
SELECT
	c.state,
	COUNT(DISTINCT o.customer_id) AS distinct_customer,
	SUM(o.order_total) AS q4_total_revenue,
	AVG(o.order_total) AS q4_avg_value
FROM customers as c
INNER JOIN orders as o
	ON c.customer_id = o.customer_id 
GROUP BY c.state 
ORDER BY q4_total_revenue DESC; 	

-- Return top 10 stores with their name, city and how many distinct customers in Q4
SELECT
	s.store_name,
	s.city,
	COUNT(DISTINCT o.customer_id) AS distinct_customers
FROM stores as s
INNER JOIN orders as o
	ON s.store_id =o.store_id 
WHERE o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
GROUP BY s.store_name, s.city 
ORDER BY distinct_customers DESC
LIMIT 10;

--Find how much each state has loyalty customers and how many are distinct
SELECT 
	s.region,
	COUNT(c.loyalty_id) as loyalty_count,
	COUNT(DISTINCT c.loyalty_id) as distinct_loyalty_count
FROM stores as s
INNER JOIN orders as o
	ON s.store_id = o.store_id 
INNER JOIN customers as c
	ON c.customer_id = o.customer_id 
WHERE c.loyalty_id IS NOT NULL
GROUP BY s.region 
ORDER BY distinct_loyalty_count DESC;