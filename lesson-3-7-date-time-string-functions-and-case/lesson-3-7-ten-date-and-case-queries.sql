--Query 1
--Show each store their monthly revenue in Q4
--Group data by store id and by the month
SELECT
  s.store_id,
  DATE_TRUNC('month', order_date)::DATE AS month,
  SUM(o.order_total) AS q4_revenue
FROM orders as o
INNER JOIN stores AS s ON s.store_id = o.store_id 
WHERE o.order_date >= '2024-10-01'
  AND o.order_date < '2025-01-01'
GROUP BY s.store_id, DATE_TRUNC('month', order_date)
ORDER BY month;
--Checked if there was data for every store and their months

--Query 2
--Count by year then month customer's first order
--Sort them by year, then month
SELECT
  EXTRACT(year FROM c.first_order_date) as first_order_year,
  EXTRACT(month FROM c.first_order_date) as first_order_month,
  COUNT(c.customer_id) AS customer_count
FROM customers AS c
INNER JOIN orders as o ON c.customer_id = o.customer_id 
GROUP BY EXTRACT(year FROM c.first_order_date), EXTRACT(month FROM c.first_order_date)
ORDER BY first_order_year, first_order_month;
--Checked if every there was years until 2024. And each month had 12 months

--Query 3
--Return 30 orders in the last 90 days before Dec 31, 2024 with their id, date, customer ID and order total
SELECT
  order_id,
  order_date::DATE,
  customer_id,
  order_total
FROM orders
WHERE order_date >= DATE '2024-12-31' - INTERVAL '90 days'
  AND order_date <= DATE '2024-12-31' + INTERVAL '1 days'
LIMIT 30;
--ORDER BY ASC and DESC without LIMIT to see if 90 days eariler and Dec 31, 2024 was included as well

--Query 4
-- Return 30 Q4 orders with order total and classification based on order total
SELECT
  order_id,
  order_total,
  CASE
  	WHEN order_total >= 500 THEN 'High'
  	WHEN order_total >= 100 THEN 'Medium'
  	WHEN order_total >= 25 THEN 'Low'
  	ELSE 'Micro'
  END AS order_size
FROM orders
WHERE order_date >= '2024-10-01' and order_date < '2025-01-01'
LIMIT 30
--Removed LIMIT, checked order_total to see if it matches the case scenario 

--Query 5
--Find how much each order size have how much orders and the total revenue in Q4
SELECT
  CASE
  	WHEN order_total >= 500 THEN 'High'
  	WHEN order_total >= 100 THEN 'Medium'
  	WHEN order_total >= 25 THEN 'Low'
  	ELSE 'Micro'
  END AS order_size,
  COUNT(*) AS order_count,
  SUM(order_total) AS total_revenue
FROM orders
WHERE order_date >= '2024-10-01' and order_date < '2025-01-01' 
GROUP BY 1
ORDER BY total_revenue DESC;
--Used Query 4, to check how many rows of data there. 213,462 amount of rows in Query 4 which matched the total of orders of all four categories

--Query 6
--Return each region their Q4 2023 and 2024 revenue and yoy growth percentage
WITH yoy_by_region AS (
--Create CTE for each region their Q4 2024 and 2023 total revenue
  SELECT
    s.region,
    SUM(CASE WHEN o.order_date >= '2024-10-01' AND o.order_date < '2025-01-01' THEN o.order_total ELSE 0 END) AS q4_2024_revenue,
    SUM(CASE WHEN o.order_date >= '2023-10-01' AND o.order_date < '2024-01-01' THEN o.order_total ELSE 0 END) AS q4_2023_revenue
  FROM orders as o
  INNER JOIN stores as s ON o.store_id = s.store_id 
  WHERE o.order_date >= '2023-10-01' AND o.order_date < '2025-01-01'
  GROUP BY s.region
),
yoy_with_growth AS (
--Create CTE to find percentage change from Q4 2023 Revenue to Q4 2024 Revenue
SELECT
  region,
  q4_2024_revenue,
  q4_2023_revenue,
  ROUND(
    ((q4_2024_revenue  - q4_2023_revenue) / NULLIF(q4_2023_revenue, 0) * 100)::numeric, 1
  ) as yoy_growth_pct
FROM yoy_by_region
)
SELECT
  region,
  q4_2024_revenue,
  q4_2023_revenue,
  yoy_growth_pct 
FROM yoy_with_growth 
--Checked if the formula for yoy_growth_pct is accurate

--Query 7
--Return each region their Q4 2023 and 2024 revenue and yoy growth percentage then classififed it
WITH yoy_by_region AS (
--Create CTE for each region their Q4 2024 and 2023 total revenue
  SELECT
    s.region,
    SUM(CASE WHEN o.order_date >= '2024-10-01' AND o.order_date < '2025-01-01' THEN o.order_total ELSE 0 END) AS q4_2024_revenue,
    SUM(CASE WHEN o.order_date >= '2023-10-01' AND o.order_date < '2024-01-01' THEN o.order_total ELSE 0 END) AS q4_2023_revenue
  FROM orders as o
  INNER JOIN stores as s ON o.store_id = s.store_id 
  WHERE o.order_date >= '2023-10-01' AND o.order_date < '2025-01-01'
  GROUP BY s.region
),
yoy_with_growth AS (
--Create CTE to find percentage change from Q4 2023 Revenue to Q4 2024 Revenue
SELECT
  region,
  q4_2024_revenue,
  q4_2023_revenue,
  ROUND(
    ((q4_2024_revenue  - q4_2023_revenue) / NULLIF(q4_2023_revenue, 0) * 100)::numeric, 1
  ) as yoy_growth_pct,
  CASE
  	WHEN q4_2023_revenue = 0 THEN 'No prior data'
  	WHEN (q4_2024_revenue  - q4_2023_revenue) / NULLIF(q4_2023_revenue, 0) > 0.05 THEN 'Growing'
  	WHEN (q4_2024_revenue  - q4_2023_revenue) / NULLIF(q4_2023_revenue, 0) < -0.05 THEN 'Declining'
  	ELSE 'Flat'
  END AS classification
FROM yoy_by_region
)
SELECT
  region,
  q4_2024_revenue,
  q4_2023_revenue,
  yoy_growth_pct,
  classification 
FROM yoy_with_growth 
--Checked if teh classification is correct by comparing yoy_growth_pct to the flowchart 

--Query 8
--Check 50 customer their q4 spending and then rank them according to spend
SELECT
  c.customer_id,
  SUM(o.order_total) as q4_spend,
  CASE 
  	WHEN SUM(o.order_total) > 5000 THEN 'VIP'
  	WHEN SUM(o.order_total) >= 1000 THEN 'Loyal'
  	WHEN SUM(o.order_total) >= 200 THEN 'Casual'
  	ELSE 'Occasional'
  END AS tier
FROM customers as c
INNER JOIN orders as o ON c.customer_id = o.customer_id 
WHERE o.order_date >= '2024-10-01' and o.order_date < '2025-01-01'
GROUP BY c.customer_id 
LIMIT 50;
--Checked if q4 spend matches the tier

--Query 9
--Return each customers their full name, email in lowercase, and their email domain
SELECT
  customer_id,
  CONCAT(first_name, ' ', last_name) AS full_name,
  LOWER(email) AS email_normalized,
  Substring(email FROM POSITION('@' IN email) + 1) AS email_domain
FROM customers
WHERE state = 'MN';
--Pulled their first name and last name as different column and their email untouched and compared them to the results

--Query 10
--In 2024, how much each month revenue is and classify them by month revenue
SELECT
  DATE_TRUNC('month', order_date)::DATE as revenue_month,
  SUM(order_total) AS total_revenue,
  CASE 
  	WHEN SUM(order_total) >= 6000000 THEN 'High'
  	WHEN SUM(order_total) >= 4500000 THEN 'Medium'
    ELSE 'Low'
  END AS revenue_class
FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY revenue_month 
--Checked if revenue_month are in ascending date order
--Checked total_revenue matches the CASE scenarios