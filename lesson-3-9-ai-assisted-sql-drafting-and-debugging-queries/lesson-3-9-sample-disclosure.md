Query: Show YoY revenue change for each store by percentage for Q4 2024 and 2023

Prompt Used: "Show the YoY revenue change for each store as a percentage."

Original AI output:
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

Kept: The Overall query including CTE structure. CASE, FROM, INNER JOIN and GROUP BY

Changed or Rejected: yoy_pct in the main table. ADDED NULLIF() for the lower half of the fraction. NULLIF(q4_2023, 0) 

Why: There may be a possibility that q4_2024 = 0 causing a divided by 0 scenario

Verification: Checked on DBeaver if the query did not cause a divided by zero error.