--Query 1
--Find the top 30 customer by q4 total spending and ranking them
SELECT
  customer_id,
  SUM(order_total) as q4_total_spend,
  RANK() OVER (ORDER BY SUM(order_total) DESC) AS spend_rank
FROM orders
WHERE order_date >= '2024-10-01'
  AND order_date < '2025-01-01'
GROUP BY customer_id 
LIMIT 30;

--Query 2
--Find Q4 spending for each customer based on id and seeeing their running total spending after each order. Only show customers with three or more orders that quarter
SELECT
  order_id,
  customer_id,
  order_date,
  order_total,
  SUM(order_total) OVER (PARTITION BY customer_id ORDER BY order_date) AS running_q4_spend
FROM orders
WHERE order_date >= '2024-10-01'
  AND order_date < '2025-01-01'
  AND customer_id IN (
    SELECT customer_id
    FROM orders 
    WHERE order_date >= '2024-10-01'
      AND order_date < '2025-01-01'
    GROUP BY customer_id
    HAVING COUNT(*) >= 3
  )
LIMIT 50;

--Query 3
--Get Q4 orders for customers with three or more orders and show them by order date the order total and then their previous order total.
SELECT 
  customer_id,
  order_date,
  order_total,
  LAG(order_total) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_total
FROM orders
WHERE order_date >= '2024-10-01'
  AND order_date < '2025-01-01'
  AND customer_id IN (
    SELECT customer_id
    FROM orders 
    WHERE order_date >= '2024-10-01'
      AND order_date < '2025-01-01'
    GROUP BY customer_id
    HAVING COUNT(*) >= 3
  )
ORDER BY customer_id, order_date 
LIMIT 50;

--Query 4
--Return each region and their stores by rank by total Q4 revenue
WITH store_q4_revenue AS (
  SELECT
    s.store_name,
    s.region,
    SUM(o.order_total) AS q4_revenue,
    RANK() OVER (PARTITION BY s.region ORDER BY SUM(o.order_total) DESC) AS region_rank
  FROM orders as o
  INNER JOIN stores AS s ON o.store_id = s.store_id 
  WHERE o.order_date >= '2024-10-01'
    AND o.order_date < '2025-01-01'
  GROUP BY s.store_name, s.region
) 
SELECT region, store_name, q4_revenue, region_rank
FROM store_q4_revenue 
ORDER BY region, region_rank;

--Query 5
--Return each region their top 3 stores by rank by total Q4 revenue
WITH store_q4_revenue AS (
  SELECT
    s.store_name,
    s.region,
    SUM(o.order_total) AS q4_revenue,
    RANK() OVER (PARTITION BY s.region ORDER BY SUM(o.order_total) DESC) AS region_rank
  FROM orders as o
  INNER JOIN stores AS s ON o.store_id = s.store_id 
  WHERE o.order_date >= '2024-10-01'
    AND o.order_date < '2025-01-01'
  GROUP BY s.store_name, s.region
) 
SELECT region, store_name, q4_revenue, region_rank
FROM store_q4_revenue 
WHERE region_rank <= 3
ORDER BY region, region_rank;

--Query 6
--Return high-volume customers in Q4 with counting of how many orders they have
SELECT 
  c.customer_id,
  c.first_name, 
  c.last_name,
  o.order_date::date,
  COUNT(o.order_id) OVER (PARTITION BY c.customer_id ORDER BY o.order_date)
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id 
WHERE o.order_date >= '2024-10-01'
  AND o.order_date < '2025-01-01'
  AND c.customer_id IN (
    SELECT customer_id
    FROM orders 
    WHERE order_date BETWEEN '2024-10-01' AND '2024-12-31'
    GROUP BY customer_id 
    HAVING COUNT(*) >= 10
  )
ORDER BY c.customer_id, o.order_date
LIMIT 50;

--Query 7
-- Return each order and their percentage rank among Q4 orders
SELECT
  order_id,
  customer_id,
  order_date::date,
  order_total,
  PERCENT_RANK() OVER (ORDER BY order_total) AS pct_rank
FROM orders
WHERE order_date >= '2024-10-01'
  AND order_date < '2025-01-01'
ORDER BY order_total DESC
LIMIT 30;

--Query 8
--Return First 5 Ranked custoby rows 
WITH customer_q4_spend AS (
  SELECT 
  c.customer_id,
  c.first_name,
  c.last_name,
  c.state,
  SUM(o.order_total) AS q4_spend
FROM customers as c
INNER JOIN orders as o ON c.customer_id = o.customer_id 
WHERE o.order_date >= '2024-10-01'
  AND o.order_date < '2025-01-01'
GROUP BY c.customer_id, c.first_name, c.last_name, c.state
),
ranked_customer AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY q4_spend DESC) AS state_rank
  FROM customer_q4_spend 
)
SELECT 
  state, 
  first_name, 
  last_name, 
  q4_spend, 
  state_rank
FROM ranked_customer 
WHERE state_rank <= 5
ORDER BY state, state_rank;

--Query 9
--Find store rank by Q4 revenue by region. Find the difference between region store rank by Q4 revenue.
WITH store_q4_rank AS (
  SELECT
    s.region,
    s.store_name,
    SUM(o.order_total) AS q4_revenue,
    RANK() OVER (PARTITION BY s.region ORDER BY SUM(o.order_total) DESC) AS region_rank
  FROM stores as s
  INNER JOIN orders as o ON s.store_id = o.store_id
  WHERE o.order_date >= '2024-10-01'
    AND o.order_date < '2025-01-01'
  GROUP BY s.region, s.store_name
  ORDER BY s.region, region_rank
)
SELECT
  region,
  store_name,
  q4_revenue,
  q4_revenue - LAG(q4_revenue ) OVER (PARTITION BY region ORDER BY region_rank ASC) AS change_from_prev,
  region_rank
FROM store_q4_rank;

--Query 10
--Which 5 products sold the most unit in each product category during Q4
WITH product_q4_rank AS (
  SELECT
    p.category,
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold
  FROM order_items AS oi
  INNER JOIN orders as o ON oi.order_id = o.order_id 
  INNER JOIN products as p ON p.product_id = oi.product_id 
  WHERE o.order_date >= '2024-10-01'
    AND o.order_date < '2025-01-01'
  GROUP BY p.category, p.product_id, p.product_name 
),
ranked_products AS (
  SELECT
    category,
    product_name,
    units_sold,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY units_sold DESC) AS category_rank
  FROM product_q4_rank 
)
SELECT
  category,
  product_name,
  units_sold,
  category_rank
FROM ranked_products 
WHERE category_rank <= 5
ORDER BY category, category_rank;