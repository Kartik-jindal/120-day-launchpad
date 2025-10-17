-- 0) Quick context (counts)
SELECT 'customers' AS t, COUNT(*) AS n FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

-- 1) UNION ALL vs UNION (ALL preserves duplicates; UNION dedups)
SELECT 'A' AS src, customer_id FROM customers WHERE customer_id IN (1,2)
UNION ALL
SELECT 'B', customer_id FROM customers WHERE customer_id IN (2,3);

SELECT customer_id FROM customers WHERE customer_id IN (1,2)
UNION
SELECT customer_id FROM customers WHERE customer_id IN (2,3);

-- 2) DISTINCT masking a join bug (fan-out via detail join)
-- BAD: detail join multiplies rows; DISTINCT hides the issue (don’t do this)
SELECT DISTINCT c.customer_id, c.name, o.order_id
FROM customers c
JOIN orders o USING(customer_id)
JOIN order_items oi USING(order_id)
ORDER BY c.customer_id, o.order_id;

-- Show the row explosion explicitly (assert: item_rows >= order_rows)
WITH raw AS (
  SELECT o.order_id
  FROM orders o JOIN order_items oi USING(order_id)
)
SELECT (SELECT COUNT(*) FROM raw) AS item_rows,
       (SELECT COUNT(*) FROM orders) AS order_rows;

-- 3) FIX: pre-aggregate detail, then join (one row per order)
WITH order_totals AS (
  SELECT order_id, SUM(qty*price) AS rev
  FROM order_items
  GROUP BY order_id
)
SELECT c.customer_id, c.name, o.order_id, ot.rev
FROM customers c
JOIN orders o USING(customer_id)
LEFT JOIN order_totals ot USING(order_id)
ORDER BY c.customer_id, o.order_id;

-- Sanity: each order_id should appear once after fix
WITH order_totals AS (
  SELECT order_id, SUM(qty*price) AS rev
  FROM order_items
  GROUP BY order_id
),
fixed AS (
  SELECT o.order_id
  FROM orders o LEFT JOIN order_totals ot USING(order_id)
)
SELECT COUNT(*) AS fixed_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM fixed;

-- 4) INTERSECT/EXCEPT mini-demo (SQLite supports both)
-- Customers who had BOTH paid and cancelled orders
SELECT DISTINCT customer_id FROM orders WHERE status='paid'
INTERSECT
SELECT DISTINCT customer_id FROM orders WHERE status='cancelled';

-- Customers who had paid orders but NEVER cancelled (left anti via EXCEPT)
SELECT DISTINCT customer_id FROM orders WHERE status='paid'
EXCEPT
SELECT DISTINCT customer_id FROM orders WHERE status='cancelled';

-- Notes:
-- - Use UNION ALL for stacking; UNION only when you truly need dedup (it’s costly).
-- - Never “fix” duplicates with DISTINCT. Fix the grain: pre-aggregate child rows, then join to parent.
-- - Fan-out smell: row counts jump after joining 1->many tables (e.g., orders -> order_items).