-- A) Build in steps: order revenue -> top 2 orders per customer
WITH order_rev AS (
  SELECT
    o.order_id,
    o.customer_id,
    SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.order_id, o.customer_id
),
ranked AS (
  -- Window version (requires SQLite 3.25+)
  SELECT
    order_id,
    customer_id,
    rev,
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
  FROM order_rev
)
SELECT *
FROM ranked
WHERE rnk <= 2
ORDER BY customer_id, rnk, order_id;

-- A-alt) Fallback if your SQLite doesn't support window functions:
-- Comment the ranked CTE above and use this query in its place:
-- SELECT
--   o1.order_id,
--   o1.customer_id,
--   o1.rev,
--   1 + (
--     SELECT COUNT(DISTINCT o2.rev)
--     FROM order_rev o2
--     WHERE o2.customer_id = o1.customer_id
--       AND o2.rev > o1.rev
--   ) AS rnk
-- FROM order_rev o1
-- WHERE 1 + (
--   SELECT COUNT(DISTINCT o2.rev)
--   FROM order_rev o2
--   WHERE o2.customer_id = o1.customer_id
--     AND o2.rev > o1.rev
-- ) <= 2
-- ORDER BY o1.customer_id, rnk, o1.order_id;

-- B) NOT EXISTS (customers with no 'paid' orders)
SELECT c.customer_id, c.name
FROM customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
    AND o.status = 'paid'
)
ORDER BY c.customer_id;

-- C) LEFT-ANTI equivalent (sanity check of B)
WITH paid AS (
  SELECT DISTINCT customer_id
  FROM orders
  WHERE status = 'paid'
)
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN paid p ON p.customer_id = c.customer_id
WHERE p.customer_id IS NULL
ORDER BY c.customer_id;

-- D) Correlated subquery example: customers with total revenue > 2000
--    (Illustrates scalar subquery vs building a CTE)
SELECT
  c.customer_id,
  c.name,
  (
    SELECT COALESCE(SUM(oi.qty * oi.price), 0)
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id = c.customer_id
  ) AS total_revenue
FROM customers c
WHERE (
  SELECT COALESCE(SUM(oi.qty * oi.price), 0)
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.customer_id = c.customer_id
) > 2000
ORDER BY total_revenue DESC, c.customer_id;

-- Debug helpers (run ad-hoc if needed)
-- SELECT COUNT(*) AS orders FROM orders;
-- SELECT COUNT(*) AS items FROM order_items;
-- WITH order_rev AS (
--   SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
--   FROM orders o JOIN order_items oi USING(order_id)
--   GROUP BY o.order_id, o.customer_id
-- )
-- SELECT customer_id, COUNT(*) AS orders, SUM(rev) AS rev_sum
-- FROM order_rev
-- GROUP BY customer_id
-- ORDER BY rev_sum DESC;