--Query 1
--Use a subquery to find any customer lifetime value above the median
--Return customer id, first and last name and lifetime value in a descending order of lifetime value.
SELECT 
	customer_id,
	first_name,
	last_name,
	lifetime_value
FROM customers
WHERE lifetime_value > (
	SELECT PERCENTILE_CONT(0.5)
		WITHIN GROUP (ORDER BY lifetime_value)
	FROM customers
)
ORDER BY lifetime_value DESC;

--Query 2
--Return Q4 orders with more than twice the average order value in Q4
--Use subquery
SELECT
	order_id,
	order_date,
	order_total
FROM orders
WHERE order_date >= '2024-10-01'
  AND order_date < '2025-01-01'
  AND order_total > 2 * (
	SELECT AVG(order_total)
	FROM orders
	WHERE order_date >= '2024-10-01'
	  AND order_date < '2025-01-01'
)
ORDER BY order_total DESC;

--Query 3
--Return Average Q4 2024 revenue per customer from states that have more than 5,000 customers
SELECT
	ROUND(SUM(o.order_total) / COUNT(DISTINCT c.customer_id), 2) AS avg_q4_revenue_per_customer
FROM customers AS c
INNER JOIN orders as o
	ON o.customer_id = c.customer_id 
WHERE o.order_date >= '2024-10-01'
	AND o.order_date < '2025-01-01'
	AND c.state IN (
		SELECT state
		FROM customers
		GROUP BY state
		HAVING COUNT(*) > 5000
	);

--Query 4
--Return the highest and lowest average lifetime value of the states.
--Use a subqery to grab from a table that has grouped by states their average lifetime value
SELECT 
	ROUND(MAX(avg_lifetime_value), 2) AS highest_state_avg,
	ROUND(MIN(avg_lifetime_value), 2) AS lowest_state_avg
FROM (
	SELECT 
		state,
		AVG(lifetime_value) AS avg_lifetime_value
	FROM customers
	GROUP BY state
)

--Query 5
--Find top 5 state with highest total Q4 customer spending
--Use 2 CTEs 
WITH q4_spending_per_customer AS (
	SELECT
		customer_id,
		SUM(order_total) as q4_spending
	FROM orders
	WHERE order_date >= '2024-10-01'
		AND order_date < '2025-01-01'
	GROUP BY customer_id 
),
customer_q4_spending_with_state AS (
	SELECT 
		c.customer_id,
		c.state,
		spc.q4_spending
	FROM customers as c
	INNER JOIN q4_spending_per_customer as spc
		ON c.customer_id = spc.customer_id 
)
SELECT
	state,
	SUM(q4_spending) AS total_q4_spending
FROM customer_q4_spending_with_state 
GROUP BY state 
ORDER BY total_q4_spending DESC
LIMIT 5;

--Query 6
--Find customer in loyalty-program how much they spend in Q4
WITH customer_with_loyalty_id AS (
	SELECT
		customer_id,
		first_name,
		last_name,
		state,
		loyalty_id 
	FROM customers
	WHERE loyalty_id IS NOT NULL
),
customer_q4_orders AS (
	SELECT
		c.customer_id,
		o.order_date,
		o.order_total
	FROM orders as o
	INNER JOIN customers as c
		ON c.customer_id = o.customer_id 
	WHERE o.order_date >= '2024-10-01'
		AND o.order_date < '2025-01-01'
),
total_q4_spend_per_loyalty_customer AS (
	SELECT
		c.customer_id,
		SUM(o.order_total) AS q4_spend
	FROM customer_with_loyalty_id AS c
	INNER JOIN customer_q4_orders AS o
		ON c.customer_id = o.customer_id 
	GROUP BY c.customer_id, c.loyalty_id, c.first_name, c.last_name, c.state
)
SELECT 
	cl.customer_id,
	cl.first_name,
	cl.last_name,
	cl.state, 
	slc.q4_spend
FROM total_q4_spend_per_loyalty_customer AS slc
INNER JOIN customer_with_loyalty_id AS cl
	ON slc.customer_id = cl.customer_id 
ORDER BY q4_spend DESC
LIMIT 20;

--Query 7
--Return products that within seen decrease in order from within 30 days after change date to within 30 days after supplier change date
WITH bakery_supplier_change AS (
	SELECT
		product_id,
		product_name,
		last_supplier_change_date
	FROM products
	WHERE category = 'Bakery'
		AND last_supplier_change_date >= '2024-09-01'
		AND last_supplier_change_date < '2024-11-01'
),
product_order_count AS (
	SELECT
		b.product_id,
		b.product_name,
		b.last_supplier_change_date,
		COUNT(CASE WHEN o.order_date < b.last_supplier_change_date THEN 1 END) AS orders_before,
		COUNT(CASE WHEN o.order_date > b.last_supplier_change_date THEN 1 END) AS orders_after
	FROM bakery_supplier_change AS b
	LEFT JOIN order_items AS oi
		ON oi.product_id = b.product_id 
	LEFT JOIN orders AS o
		ON o.order_id  = oi.order_id
		AND o.order_date >= b.last_supplier_change_date - INTERVAL '30 days'
		AND o.order_date < b.last_supplier_change_date + INTERVAL '30 days'
	GROUP BY b.product_id, b.product_name, b.last_supplier_change_date 
)
SELECT
    product_id,
    product_name,
    last_supplier_change_date,
    orders_before,
    orders_after
FROM product_order_count
WHERE orders_before > 0
  AND orders_after <= 0.8 * orders_before
  
  --Query 8
  --Find each catgory best selling item and how much compared to the rest of the category
  WITH q4_product_units AS (
  	SELECT 
  		p.product_id,
  		p.product_name,
  		p.category,
  		SUM(oi.quantity) AS units_sold
  	FROM order_items AS oi
  	INNER JOIN orders AS o
  		ON o.order_id = oi.order_id 
  	INNER JOIN products AS p
  		ON p.product_id = oi.product_id 
  	WHERE o.order_date >= '2024-10-01'
  		AND o.order_date < '2025-01-01'
  	GROUP BY p.product_id, p.product_name, p.category 
  ),
  category_unit_total AS (
  	SELECT
  		category,
  		SUM(units_sold) AS category_units
  	FROM q4_product_units 
  	GROUP BY category 
  ),
  category_top_product AS (
  	SELECT DISTINCT ON (category)
  		category,
  		product_name,
  		units_sold
  	FROM q4_product_units 
  	ORDER BY category, units_sold DESC
  )
  SELECT 
  	ctp.category,
  	ctp. product_name,
  	ctp.units_sold,
  	c.category_units
  FROM category_top_product as ctp
  INNER JOIN category_unit_total AS c
  	ON c.category = ctp.category 
  ORDER BY c.category_units DESC;
  
  