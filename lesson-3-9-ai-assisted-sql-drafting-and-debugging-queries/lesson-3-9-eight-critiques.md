1. Output 1
 Prompt: List customers and their full names from Minnesota.

SELECT customer_id, full_name, state
FROM customers
WHERE state = 'MN';

error: Hallucinated columns or functions

Column full_name does not exist
use the Concat() function to connect first_name and last_name with a space between.

2. Output 2
Prompt: Show the month and total revenue for each month of 2024.

SELECT
  MONTH(order_date) AS order_month,
  SUM(order_total) AS revenue
FROM orders
WHERE YEAR(order_date) = 2024
GROUP BY MONTH(order_date)
ORDER BY order_month;

error: Hallucinated columns or functions

MONTH() function does not exist in postgreSQL. 

EXTRACT() or DATE_TRUNC() to get the month 

3. Output 3
Prompt: For each customer, show the total number of unique stores they've shopped at.

SELECT
  customer_id,
  COUNT(store_id) AS unique_stores
FROM orders
GROUP BY customer_id;

error: Wrong-for-task aggregations

Prompt is looking for "unique" but there is no DISTINCT in COUNT() causing to count store_id that have already appeared.

USe COUNT(DISTINCT store_id)

4. Output 4
Prompt: For each store, calculate Q4 2024 revenue per customer (average spend per customer that store had in Q4).

SELECT
  store_id,
  AVG(order_total) AS revenue_per_customer
FROM orders
WHERE order_date >= '2024-10-01' AND order_date < '2025-01-01'
GROUP BY store_id;

error: Semantic misalignment

The prompt is looking for average spend per customer for each store. The code will only find the average per order for each store.

Add customer_id to SELECT and GROUP BY

5. Output 5
Prompt: Show the YoY revenue change for each store as a percentage.

WITH yoy AS (
  SELECT
    store_id,
   SUM(CASE WHEN order_date >= '2024-10-01' AND order_date < '2025-01-01' THEN order_total ELSE 0 END) AS q4_2024,
  SUM(CASE WHEN order_date >= '2023-10-01' AND order_date < '2024-01-01' THEN order_total ELSE 0 END) AS q4_2023
   FROM orders
  GROUP BY store_id
)
SELECT
  store_id,
  (q4_2024 - q4_2023) / q4_2023 * 100 AS yoy_pct
FROM yoy;

error: 
Edge case oversights

If q4_2023 = 0, there will be a case where something divided by 0 will happen.

Use NULLIF() and set it if q4_2023 = 0, turn it to NULL.

6. Output 6
Prompt: Find all orders placed on December 31, 2024.

SELECT order_id, customer_id, order_date, order_total
FROM orders
WHERE order_date BETWEEN '2024-12-31 00:00:00' AND '2024-12-31 23:59:59';

error: 
WHERE order_date BETWEEN '2024-12-31 00:00:00' AND '2024-12-31 23:59:59';

THe time period between '2024-12-31 23:59:59' and '2025-01-01 00:00:00', is lost

7. Output 7
Prompt: For each loyalty-program-enrolled customer, show their Q4 2024 spend.

SELECT
  c.customer_id,
  c.loyalty_id,
  SUM(o.order_total) AS q4_spend
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-10-01' AND o.order_date < '2025-01-01'
GROUP BY c.customer_id, c.loyalty_id;

error:
Edge case oversights

No filter for NULL in c.loyalty_id. 

IS NOT NULL for c.loyalty_id in WHERE is needed

8. Output 8

Prompt: Show the rank of each store within its region by Q4 2024 revenue. Return only the top 3 per region.

SELECT
  s.region,
  s.store_name,
  SUM(o.order_total) AS q4_revenue,
  RANK() OVER (PARTITION BY s.region ORDER BY SUM(o.order_total) DESC) AS region_rank
FROM orders AS o
INNER JOIN stores AS s ON o.store_id = s.store_id
WHERE o.order_date >= '2024-10-01' AND o.order_date < '2025-01-01'
  AND region_rank <= 3
GROUP BY s.region, s.store_name
ORDER BY s.region, region_rank;

error:
 Hallucinated columns or functions. 

 region_rank does not exist yet for region_rank to be used in the where statement

 Needed to create a CTE then call it over at the main table. 
